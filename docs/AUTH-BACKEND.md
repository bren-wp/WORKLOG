# WORKLOG — serverska autentikacija

WORKLOG 0.11.0 uvodi stvarni e-mail/lozinka auth sloj bez Google i Apple prijave.

## Arhitektura

- Flutter klijent: `lib/services/auth_service.dart`
- backend i web portal: `/web`
- PHP 8.2+
- MySQL/MariaDB
- HTTPS obavezan u produkciji
- access token: kratkotrajni
- refresh token: dugotrajniji i rotira se pri osvježavanju
- u bazi se spremaju samo SHA-256 hash vrijednosti tokena
- tokeni na uređaju spremaju se preko `flutter_secure_storage`
- lozinke se spremaju preko PHP `password_hash`
- login/registracija imaju rate limiting

## API

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`
- `GET /api/v1/health`

## Konfiguracija mobilne aplikacije

Produkcijski build mora dobiti HTTPS API bazu:

```bash
flutter build apk --release \
  --dart-define=WORKLOG_API_BASE_URL=https://domena.hr/web/api/v1
```

Isto vrijedi za AAB/iOS build. Ako URL nije postavljen, aplikacija ne nudi lokalni bypass nego jasno pokazuje da backend nije konfiguriran.

## Konfiguracija backenda

Kopiraj `web/.env.example` u `web/.env`, unesi produkcijske DB vrijednosti, uvezi `web/database/schema.sql` i zaštiti `.env` od javnog pristupa. `web/.env` je u `.gitignore`.

## Trenutna granica

0.11.0 implementira stvarnu registraciju, prijavu, session restore/refresh i odjavu. Poslovi, klijenti, fotografije i ostali operativni podaci još se čuvaju lokalno; cloud sinkronizacija nije uvedena niti se simulira.
