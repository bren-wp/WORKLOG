# WORKLOG /web backend

Produkcijski auth backend za WORKLOG mobilnu aplikaciju i mali web portal za registraciju/prijavu.

## Zahtjevi

- PHP 8.2+
- MySQL 8 / MariaDB 10.6+
- HTTPS
- PDO MySQL
- Apache s mod_rewrite ili ekvivalentno preusmjeravanje svih ruta na `index.php`

## Instalacija

1. Kopiraj `.env.example` u `.env`.
2. Postavi DB podatke i stvarni `APP_URL`.
3. Uvezi `database/schema.sql`.
4. Posluži mapu `web/` preko HTTPS-a.
5. Provjeri `GET /api/v1/health`.
6. Flutter build pokreni sa stvarnim URL-om, npr.:
   `flutter build apk --release --dart-define=WORKLOG_API_BASE_URL=https://domena.hr/web/api/v1`

## Auth API

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`

Access i refresh tokeni generiraju se kriptografski sigurno. U bazi se spremaju samo SHA-256 hash vrijednosti tokena. Lozinke se spremaju kroz PHP `password_hash` (Argon2id kada je dostupan, inače sigurni platform default). Login i registracija imaju rate limiting po IP-u i korisničkom identifikatoru.

## Važno

`.env` se ne smije commitati. Za produkciju ostavi `REQUIRE_HTTPS=true`. Ako hosting radi iza reverse proxyja, uključi `TRUST_PROXY=true` samo kada proxy kontroliraš i pravilno postavlja `X-Forwarded-Proto`.
