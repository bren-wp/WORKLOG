<?php
declare(strict_types=1);

final class Config
{
    /** @var array<string,string> */
    private array $values = [];

    public function __construct(string $root)
    {
        $envFile = $root . '/.env';
        if (is_file($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
            foreach ($lines as $line) {
                $line = trim($line);
                if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) {
                    continue;
                }
                [$key, $value] = explode('=', $line, 2);
                $this->values[trim($key)] = trim($value, " \t\n\r\0\x0B\"'");
            }
        }
    }

    public function string(string $key, string $default = ''): string
    {
        $value = getenv($key);
        if ($value !== false) {
            return trim((string) $value);
        }
        return $this->values[$key] ?? $default;
    }

    public function int(string $key, int $default): int
    {
        $raw = $this->string($key);
        return $raw !== '' && ctype_digit($raw) ? (int) $raw : $default;
    }

    public function bool(string $key, bool $default = false): bool
    {
        $raw = strtolower($this->string($key));
        if ($raw === '') {
            return $default;
        }
        return in_array($raw, ['1', 'true', 'yes', 'on'], true);
    }

    /** @return list<string> */
    public function csv(string $key): array
    {
        $raw = $this->string($key);
        if ($raw === '') {
            return [];
        }
        return array_values(array_filter(array_map('trim', explode(',', $raw))));
    }
}
