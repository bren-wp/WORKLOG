<?php
declare(strict_types=1);

final class AuthHttpException extends RuntimeException
{
    public function __construct(string $message, public readonly int $status)
    {
        parent::__construct($message);
    }
}

final class AuthService
{
    public function __construct(
        private PDO $db,
        private Config $config,
        private string $ip,
        private string $userAgent,
    ) {
    }

    /** @return array<string,mixed> */
    public function register(string $name, string $email, string $password): array
    {
        $name = trim($name);
        $email = strtolower(trim($email));
        $this->guardRateLimit('register:' . $email);

        if (mb_strlen($name) < 2 || mb_strlen($name) > 120) {
            throw new InvalidArgumentException('Ime mora imati između 2 i 120 znakova.');
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($email) > 190) {
            throw new InvalidArgumentException('Unesite valjanu e-mail adresu.');
        }
        $this->validatePassword($password);

        $query = $this->db->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
        $query->execute([$email]);
        if ($query->fetch()) {
            throw new AuthHttpException('Račun s tom e-mail adresom već postoji.', 409);
        }

        $id = self::uuid();
        $hash = $this->passwordHash($password);
        $now = self::now();

        $this->db->beginTransaction();
        try {
            $insert = $this->db->prepare(
                'INSERT INTO users (id, name, email, password_hash, email_verified_at, created_at, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?)',
            );
            $insert->execute([$id, $name, $email, $hash, null, $now, $now]);

            $session = $this->issueSession([
                'id' => $id,
                'name' => $name,
                'email' => $email,
            ], false);
            $this->db->commit();
            return $session;
        } catch (Throwable $error) {
            $this->db->rollBack();
            throw $error;
        }
    }

    /** @return array<string,mixed> */
    public function login(string $email, string $password): array
    {
        $email = strtolower(trim($email));
        $this->guardRateLimit('login:' . $email);

        $query = $this->db->prepare(
            'SELECT id, name, email, password_hash FROM users WHERE email = ? LIMIT 1',
        );
        $query->execute([$email]);
        $user = $query->fetch();

        if (!$user || !password_verify($password, (string) $user['password_hash'])) {
            throw new AuthHttpException('E-mail ili lozinka nisu ispravni.', 401);
        }

        if (password_needs_rehash((string) $user['password_hash'], $this->passwordAlgorithm())) {
            $rehash = $this->passwordHash($password);
            $update = $this->db->prepare('UPDATE users SET password_hash = ?, updated_at = ? WHERE id = ?');
            $update->execute([$rehash, self::now(), $user['id']]);
        }

        return $this->issueSession($user);
    }

    /** @return array<string,mixed> */
    public function refresh(string $refreshToken): array
    {
        if ($refreshToken === '') {
            throw new AuthHttpException('Nedostaje refresh token.', 401);
        }

        $hash = hash('sha256', $refreshToken);
        $query = $this->db->prepare(
            'SELECT s.id AS session_id, s.user_id, s.refresh_expires_at, u.id, u.name, u.email
             FROM auth_sessions s
             INNER JOIN users u ON u.id = s.user_id
             WHERE s.refresh_token_hash = ? AND s.revoked_at IS NULL
             LIMIT 1',
        );
        $query->execute([$hash]);
        $row = $query->fetch();

        if (!$row || strtotime((string) $row['refresh_expires_at']) <= time()) {
            throw new AuthHttpException('Sesija je istekla. Prijavite se ponovno.', 401);
        }

        $this->db->beginTransaction();
        try {
            $revoke = $this->db->prepare('UPDATE auth_sessions SET revoked_at = ? WHERE id = ?');
            $revoke->execute([self::now(), $row['session_id']]);
            $session = $this->issueSession([
                'id' => $row['user_id'],
                'name' => $row['name'],
                'email' => $row['email'],
            ], false);
            $this->db->commit();
            return $session;
        } catch (Throwable $error) {
            $this->db->rollBack();
            throw $error;
        }
    }

    /** @return array<string,mixed> */
    public function me(string $accessToken): array
    {
        $hash = hash('sha256', $accessToken);
        $query = $this->db->prepare(
            'SELECT s.id AS session_id, s.access_expires_at, u.id, u.name, u.email
             FROM auth_sessions s
             INNER JOIN users u ON u.id = s.user_id
             WHERE s.access_token_hash = ? AND s.revoked_at IS NULL
             LIMIT 1',
        );
        $query->execute([$hash]);
        $row = $query->fetch();

        if (!$row || strtotime((string) $row['access_expires_at']) <= time()) {
            throw new AuthHttpException('Sesija nije valjana.', 401);
        }

        $touch = $this->db->prepare('UPDATE auth_sessions SET last_seen_at = ? WHERE id = ?');
        $touch->execute([self::now(), $row['session_id']]);

        return [
            'user' => [
                'id' => $row['id'],
                'name' => $row['name'],
                'email' => $row['email'],
            ],
        ];
    }

    public function logout(string $accessToken, string $refreshToken = ''): void
    {
        $accessHash = hash('sha256', $accessToken);
        $refreshHash = $refreshToken !== '' ? hash('sha256', $refreshToken) : '';
        $sql = 'UPDATE auth_sessions SET revoked_at = ? WHERE revoked_at IS NULL AND access_token_hash = ?';
        $params = [self::now(), $accessHash];

        if ($refreshHash !== '') {
            $sql .= ' OR (revoked_at IS NULL AND refresh_token_hash = ?)';
            $params[] = $refreshHash;
        }

        $query = $this->db->prepare($sql);
        $query->execute($params);
    }

    /** @param array<string,mixed> $user @return array<string,mixed> */
    private function issueSession(array $user, bool $manageTransaction = true): array
    {
        $accessToken = self::token(32);
        $refreshToken = self::token(48);
        $accessTtl = max(300, $this->config->int('ACCESS_TOKEN_TTL_SECONDS', 900));
        $refreshTtl = max(86400, $this->config->int('REFRESH_TOKEN_TTL_SECONDS', 2592000));
        $now = self::now();
        $accessExpiresAt = gmdate('Y-m-d H:i:s', time() + $accessTtl);
        $refreshExpiresAt = gmdate('Y-m-d H:i:s', time() + $refreshTtl);

        if ($manageTransaction) {
            $this->db->beginTransaction();
        }

        try {
            $insert = $this->db->prepare(
                'INSERT INTO auth_sessions
                 (id, user_id, access_token_hash, refresh_token_hash, access_expires_at, refresh_expires_at,
                  revoked_at, created_at, last_seen_at, ip_address, user_agent)
                 VALUES (?, ?, ?, ?, ?, ?, NULL, ?, ?, ?, ?)',
            );
            $insert->execute([
                self::uuid(),
                $user['id'],
                hash('sha256', $accessToken),
                hash('sha256', $refreshToken),
                $accessExpiresAt,
                $refreshExpiresAt,
                $now,
                $now,
                mb_substr($this->ip, 0, 64),
                mb_substr($this->userAgent, 0, 255),
            ]);

            if ($manageTransaction) {
                $this->db->commit();
            }
        } catch (Throwable $error) {
            if ($manageTransaction && $this->db->inTransaction()) {
                $this->db->rollBack();
            }
            throw $error;
        }

        return [
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
            ],
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'access_expires_at' => $accessExpiresAt . 'Z',
            'refresh_expires_at' => $refreshExpiresAt . 'Z',
        ];
    }

    private function guardRateLimit(string $subject): void
    {
        $maxAttempts = max(3, $this->config->int('AUTH_MAX_ATTEMPTS', 8));
        $windowSeconds = max(60, $this->config->int('AUTH_WINDOW_SECONDS', 900));
        $bucket = hash('sha256', $this->ip . '|' . $subject);
        $now = time();

        $query = $this->db->prepare(
            'SELECT attempts, window_started_at FROM auth_rate_limits WHERE bucket_key = ? LIMIT 1',
        );
        $query->execute([$bucket]);
        $row = $query->fetch();

        if (!$row || strtotime((string) $row['window_started_at']) + $windowSeconds <= $now) {
            $upsert = $this->db->prepare(
                'INSERT INTO auth_rate_limits (bucket_key, attempts, window_started_at, updated_at)
                 VALUES (?, 1, ?, ?)
                 ON DUPLICATE KEY UPDATE attempts = 1, window_started_at = VALUES(window_started_at),
                 updated_at = VALUES(updated_at)',
            );
            $stamp = self::now();
            $upsert->execute([$bucket, $stamp, $stamp]);
            return;
        }

        if ((int) $row['attempts'] >= $maxAttempts) {
            throw new AuthHttpException('Previše pokušaja. Pokušajte ponovno kasnije.', 429);
        }

        $update = $this->db->prepare(
            'UPDATE auth_rate_limits SET attempts = attempts + 1, updated_at = ? WHERE bucket_key = ?',
        );
        $update->execute([self::now(), $bucket]);
    }

    private function validatePassword(string $password): void
    {
        if (strlen($password) < 10 || strlen($password) > 128) {
            throw new InvalidArgumentException('Lozinka mora imati između 10 i 128 znakova.');
        }
        if (!preg_match('/[A-Za-z]/', $password) || !preg_match('/\d/', $password)) {
            throw new InvalidArgumentException('Lozinka mora sadržavati slovo i broj.');
        }
    }

    /** @return int|string */
    private function passwordAlgorithm(): int|string
    {
        return defined('PASSWORD_ARGON2ID') ? PASSWORD_ARGON2ID : PASSWORD_DEFAULT;
    }

    private function passwordHash(string $password): string
    {
        $hash = password_hash($password, $this->passwordAlgorithm());
        if ($hash === false) {
            throw new RuntimeException('Lozinku nije moguće sigurno pohraniti.');
        }
        return $hash;
    }

    private static function token(int $bytes): string
    {
        return rtrim(strtr(base64_encode(random_bytes($bytes)), '+/', '-_'), '=');
    }

    private static function uuid(): string
    {
        $bytes = random_bytes(16);
        $bytes[6] = chr((ord($bytes[6]) & 0x0f) | 0x40);
        $bytes[8] = chr((ord($bytes[8]) & 0x3f) | 0x80);
        $hex = bin2hex($bytes);
        return sprintf(
            '%s-%s-%s-%s-%s',
            substr($hex, 0, 8),
            substr($hex, 8, 4),
            substr($hex, 12, 4),
            substr($hex, 16, 4),
            substr($hex, 20, 12),
        );
    }

    private static function now(): string
    {
        return gmdate('Y-m-d H:i:s');
    }
}
