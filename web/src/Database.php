<?php
declare(strict_types=1);

final class Database
{
    private PDO $pdo;

    public function __construct(Config $config)
    {
        $host = $config->string('DB_HOST', '127.0.0.1');
        $port = $config->int('DB_PORT', 3306);
        $name = $config->string('DB_NAME');
        $user = $config->string('DB_USER');
        $password = $config->string('DB_PASSWORD');

        if ($name === '' || $user === '') {
            throw new RuntimeException('Nedostaje konfiguracija baze podataka.');
        }

        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
            $host,
            $port,
            $name,
        );

        $this->pdo = new PDO($dsn, $user, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }

    public function pdo(): PDO
    {
        return $this->pdo;
    }
}
