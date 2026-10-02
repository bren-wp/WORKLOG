<?php
declare(strict_types=1);

require_once __DIR__ . '/Config.php';
require_once __DIR__ . '/Database.php';
require_once __DIR__ . '/Http.php';
require_once __DIR__ . '/AuthService.php';

$root = dirname(__DIR__);
$config = new Config($root);

if ($config->bool('REQUIRE_HTTPS', true) && !Http::isHttps($config->bool('TRUST_PROXY', false))) {
    Http::json(['error' => 'HTTPS je obavezan.'], 400);
}

$allowedOrigins = $config->csv('CORS_ALLOWED_ORIGINS');
$origin = trim((string) ($_SERVER['HTTP_ORIGIN'] ?? ''));
if ($origin !== '' && in_array($origin, $allowedOrigins, true)) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Vary: Origin');
    header('Access-Control-Allow-Headers: Authorization, Content-Type');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
}

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$db = new Database($config);
$auth = new AuthService(
    $db->pdo(),
    $config,
    Http::clientIp($config->bool('TRUST_PROXY', false)),
    (string) ($_SERVER['HTTP_USER_AGENT'] ?? ''),
);
