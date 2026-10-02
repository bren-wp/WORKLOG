# WORKLOG — Android produkcijski signing

WORKLOG nikada ne sprema privatni keystore ili lozinke u repozitorij.

## GitHub Secrets

U `Settings → Secrets and variables → Actions` dodajte:

- `WORKLOG_ANDROID_KEYSTORE_BASE64` — Base64 sadržaj stvarnog upload keystorea
- `WORKLOG_KEYSTORE_PASSWORD` — lozinka keystorea
- `WORKLOG_KEY_ALIAS` — alias privatnog ključa
- `WORKLOG_KEY_PASSWORD` — lozinka privatnog ključa

## CI ponašanje

Ako su sve četiri vrijednosti dostupne:

- privremeni `.jks` nastaje samo na GitHub runneru
- Gradle koristi konfiguraciju `worklogRelease`
- `SIGNING-STATUS.txt` sadrži `production-signed`

Ako bilo koja vrijednost nedostaje:

- CI i dalje provjerava release build
- koristi se razvojni Flutter signing
- artefakti se zovu `*-Android-CI.apk` i `*-Android-CI.aab`
- `SIGNING-STATUS.txt` sadrži `ci-debug-signed-not-for-play`
- takav AAB nije deklariran kao Play Store-ready

## Pravila

- ne commitati `.jks`, `.keystore`, lozinke ili privatne ključeve
- čuvati sigurnu offline kopiju upload ključa
- za Play App Signing pratiti stvarne postavke Play Console računa
- pri rotaciji ključa ažurirati samo GitHub Secrets, ne aplikacijski kod
