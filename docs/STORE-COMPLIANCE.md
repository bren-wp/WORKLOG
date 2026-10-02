# WORKLOG — Store Compliance

Stanje za WORKLOG 0.8.0. Dokument je tehnička pomoć za Google Play i App Store objavu i mora se ponovno provjeriti prije svakog javnog izdanja.

## Android / Google Play

Projekt generira:

- package ID: `com.brendigo.worklog`
- min SDK: 24
- compile SDK: 36
- target SDK: 36
- Java: 17
- predictive-back opt-in: uključen
- cleartext HTTP: onemogućen
- POST_NOTIFICATIONS: deklariran
- USE_BIOMETRIC: deklariran

Od 31. kolovoza 2026. nove Android aplikacije i ažuriranja za mobitele na Google Playu moraju ciljati Android 16 / API 36 ili noviji.

### Android signing

CI razlikuje dva slučaja:

1. ako postoje stvarne produkcijske signing tajne, artefakti se označavaju `production-signed`
2. ako tajne ne postoje, build koristi razvojni Flutter signing, artefakti nose oznaku `CI` i ne smiju se smatrati Play Store-ready paketima

Potrebne GitHub Actions tajne:

- `WORKLOG_ANDROID_KEYSTORE_BASE64`
- `WORKLOG_KEYSTORE_PASSWORD`
- `WORKLOG_KEY_ALIAS`
- `WORKLOG_KEY_PASSWORD`

Keystore i lozinke ne smiju se commitati u Git.

## iOS / App Store

Projekt generira:

- bundle ID: `com.brendigo.worklog`
- minimum deployment target: iOS 13.0
- usage description za kameru
- usage description za photo library
- usage description za Face ID
- release build bez codesigna u standardnom CI-u

Apple trenutačno zahtijeva da App Store Connect upload bude izgrađen s Xcode 26 ili novijim i iOS 26 SDK-om ili novijim. Od rujna 2026. upload mora ciljati iOS 13 ili noviji.

Standardni CI zato eksplicitno provjerava Xcode i iOS SDK prije no-codesign release builda.

### TestFlight i potpisani IPA

`.github/workflows/testflight.yml` priprema potpisani IPA i upload na TestFlight tek kada vlasnik doda:

- `APPSTORE_ISSUER_ID`
- `APPSTORE_API_KEY_ID`
- `APPSTORE_TEAM_ID`
- `APPSTORE_API_PRIVATE_KEY`

Bez tih podataka WORKLOG ne tvrdi da ima potpisani IPA.

## Apple Privacy / Google Data Safety — trenutno ponašanje

Trenutna aplikacija:

- nema produkcijski backend
- nema analytics SDK
- nema oglasni SDK
- nema cloud upload
- podatke sprema lokalno
- korisnički inicirano dijeljenje može predati PDF vanjskoj aplikaciji
- korisnički inicirana navigacija predaje adresu vanjskom Google Mapsu
- koristi kameru/galeriju za poslovne fotografije
- koristi lokalnu autentikaciju uređaja
- koristi lokalne obavijesti

Završni Data Safety i Privacy Nutrition Label odgovori moraju biti uneseni iz aktualne verzije neposredno prije objave.

## Preostale vanjske ovisnosti prije javne objave

- Play Console račun i aplikacijski zapis
- produkcijski Android upload/app signing ključ
- Apple Developer Program
- App Store Connect zapis za `com.brendigo.worklog`
- App Store Connect API ključ / Team ID
- javni URL stvarne pravne politike privatnosti
- konačni support URL / kontakt
- produkcijski backend za stvarnu registraciju, prijavu i sinkronizaciju ako se objavljuje kao višekorisnička cloud aplikacija
