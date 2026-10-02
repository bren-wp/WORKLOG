<?php
declare(strict_types=1);

final class Http
{
    /** @return array<string,mixed> */
    public static function jsonBody(): array
    {
        $raw = file_get_contents('php://input');
        if ($raw === false || trim($raw) === '') {
            return [];
        }

        $decoded = json_decode($raw, true);
        if (!is_array($decoded)) {
            self::json(['error' => 'Neispravan JSON zahtjev.'], 400);
        }
        return $decoded;
    }

    /** @param array<string,mixed> $payload */
    public static function json(array $payload, int $status = 200): never
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        header('Cache-Control: no-store');
        echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public static function bearerToken(): string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if (!preg_match('/^Bearer\s+(.+)$/i', trim($header), $matches)) {
            self::json(['error' => 'Nedostaje autorizacija.'], 401);
        }
        return trim($matches[1]);
    }

    public static function clientIp(bool $trustProxy): string
    {
        if ($trustProxy && !empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            return trim(explode(',', (string) $_SERVER['HTTP_X_FORWARDED_FOR'])[0]);
        }
        return (string) ($_SERVER['REMOTE_ADDR'] ?? '');
    }

    public static function isHttps(bool $trustProxy): bool
    {
        if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
            return true;
        }
        if ($trustProxy) {
            return strtolower((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')) === 'https';
        }
        return false;
    }
}
