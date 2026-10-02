<?php
declare(strict_types=1);

$path = parse_url((string) ($_SERVER['REQUEST_URI'] ?? '/'), PHP_URL_PATH) ?: '/';
$script = str_replace('\\', '/', dirname((string) ($_SERVER['SCRIPT_NAME'] ?? '/')));
$script = $script === '/' ? '' : rtrim($script, '/');
if ($script !== '' && str_starts_with($path, $script)) {
    $path = substr($path, strlen($script)) ?: '/';
}

if (!str_starts_with($path, '/api/')) {
    if ($path === '/assets/app.css') {
        header('Content-Type: text/css; charset=utf-8');
        readfile(__DIR__ . '/assets/app.css');
        exit;
    }
    if ($path === '/assets/app.js') {
        header('Content-Type: application/javascript; charset=utf-8');
        readfile(__DIR__ . '/assets/app.js');
        exit;
    }

    header('Content-Type: text/html; charset=utf-8');
    header('Content-Security-Policy: default-src \'self\'; script-src \'self\'; style-src \'self\'; img-src \'self\' data:; connect-src \'self\'; base-uri \'self\'; form-action \'self\'; frame-ancestors \'none\'');
    ?>
<!doctype html>
<html lang="hr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="dark">
  <title>WORKLOG račun</title>
  <link rel="stylesheet" href="assets/app.css">
</head>
<body>
  <main class="shell">
    <section class="brand">
      <div class="mark">W</div>
      <div>
        <p class="eyebrow">WORKLOG</p>
        <h1>Terenski rad pod kontrolom.</h1>
        <p class="lead">Sigurna registracija i prijava za WORKLOG mobilnu aplikaciju.</p>
      </div>
    </section>

    <section class="panel">
      <div class="tabs" role="tablist">
        <button class="tab active" data-mode="login" type="button">Prijava</button>
        <button class="tab" data-mode="register" type="button">Registracija</button>
      </div>

      <form id="auth-form" novalidate>
        <label id="name-row" class="hidden">
          Ime i prezime
          <input id="name" autocomplete="name" maxlength="120">
        </label>
        <label>
          E-mail
          <input id="email" type="email" autocomplete="email" required maxlength="190">
        </label>
        <label>
          Lozinka
          <input id="password" type="password" autocomplete="current-password" required minlength="10" maxlength="128">
        </label>
        <button class="primary" type="submit">Prijavi se</button>
        <p id="message" class="message" aria-live="polite"></p>
      </form>

      <div id="session" class="session hidden">
        <p class="eyebrow">Prijavljen račun</p>
        <strong id="session-name"></strong>
        <span id="session-email"></span>
        <button id="logout" class="secondary" type="button">Odjava</button>
      </div>
    </section>
  </main>
  <script src="assets/app.js" defer></script>
</body>
</html>
<?php
    exit;
}

require __DIR__ . '/src/bootstrap.php';

$method = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));

try {
    if ($method === 'GET' && $path === '/api/v1/health') {
        Http::json(['ok' => true, 'service' => 'WORKLOG Auth API']);
    }

    if ($method === 'POST' && $path === '/api/v1/auth/register') {
        $body = Http::jsonBody();
        Http::json($auth->register(
            (string) ($body['name'] ?? ''),
            (string) ($body['email'] ?? ''),
            (string) ($body['password'] ?? ''),
        ), 201);
    }

    if ($method === 'POST' && $path === '/api/v1/auth/login') {
        $body = Http::jsonBody();
        Http::json($auth->login(
            (string) ($body['email'] ?? ''),
            (string) ($body['password'] ?? ''),
        ));
    }

    if ($method === 'POST' && $path === '/api/v1/auth/refresh') {
        $body = Http::jsonBody();
        Http::json($auth->refresh((string) ($body['refresh_token'] ?? '')));
    }

    if ($method === 'GET' && $path === '/api/v1/auth/me') {
        Http::json($auth->me(Http::bearerToken()));
    }

    if ($method === 'POST' && $path === '/api/v1/auth/logout') {
        $body = Http::jsonBody();
        $auth->logout(
            Http::bearerToken(),
            (string) ($body['refresh_token'] ?? ''),
        );
        Http::json(['ok' => true]);
    }

    Http::json(['error' => 'Ruta ne postoji.'], 404);
} catch (InvalidArgumentException $error) {
    Http::json(['error' => $error->getMessage()], 422);
} catch (AuthHttpException $error) {
    Http::json(['error' => $error->getMessage()], $error->status);
} catch (Throwable $error) {
    error_log('WORKLOG backend error: ' . $error->getMessage());
    Http::json(['error' => 'Interna greška poslužitelja.'], 500);
}
