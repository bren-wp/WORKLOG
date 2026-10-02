# WORKLOG — TestFlight bez Windowsa i Maca

WORKLOG može graditi, potpisati i poslati iOS verziju u TestFlight potpuno kroz GitHub Actions. Nakon jednokratnog Apple/GitHub podešavanja, nove verzije mogu se instalirati izravno na iPhone kroz aplikaciju TestFlight.

## Što workflow radi

Datoteka `.github/workflows/testflight.yml`:

1. pokreće se ručno ili kada se objavi GitHub Release
2. koristi GitHubov macOS 26 runner i provjerava Xcode 26+
3. generira iOS projekt iz postojećeg Flutter projekta
4. radi release pripremu bez potpisa
5. koristi Xcode automatic signing uz App Store Connect API ključ
6. izrađuje potpisani `.ipa`
7. provjerava code signature i provisioning profile
8. sprema IPA kao GitHub Actions artefakt
9. šalje IPA u TestFlight

Bundle ID je:

`com.brendigo.worklog`

## Apple preduvjeti

Potreban je aktivan Apple Developer Program račun.

U Apple Developer / App Store Connect jednom treba pripremiti:

- eksplicitni App ID za `com.brendigo.worklog`
- aplikaciju WORKLOG u App Store Connectu s tim Bundle ID-om
- Team App Store Connect API ključ s dovoljnim ovlastima za distribuciju i provisioning

Za API ključ koristi Team key, ne Individual key, jer individualni ključevi nemaju pristup provisioning endpointima.

## GitHub Actions vrijednosti

U repozitoriju otvori:

`Settings → Secrets and variables → Actions`

### Variables

Dodaj:

- `APPSTORE_ISSUER_ID` — Issuer ID iz App Store Connect → Users and Access → Integrations
- `APPSTORE_API_KEY_ID` — Key ID API ključa
- `APPSTORE_TEAM_ID` — Apple Developer Team ID

### Secret

Dodaj:

- `APPSTORE_API_PRIVATE_KEY` — kompletan sadržaj datoteke `AuthKey_<KEY_ID>.p8`, uključujući BEGIN/END retke

Privatni ključ nikada se ne sprema u repozitorij.

## Prvo slanje

Nakon što su Apple podaci i GitHub vrijednosti postavljeni:

1. otvori GitHub repozitorij WORKLOG
2. otvori karticu Actions
3. odaberi workflow `WORKLOG TestFlight`
4. odaberi `Run workflow`
5. nakon uspješnog izvođenja pričekaj Appleovu obradu builda
6. u App Store Connect → TestFlight omogući build internim testerima
7. na iPhone instaliraj Appleovu aplikaciju TestFlight
8. prihvati poziv ili koristi isti Apple račun koji je dodan kao tester
9. instaliraj WORKLOG iz TestFlighta

## Automatski novi buildovi

Workflow se automatski pokreće i na događaj:

`release: published`

Zato svaki budući objavljeni GitHub Release može automatski proizvesti novi iOS build i poslati ga u TestFlight.

iOS build broj računa se kao postojeći broj iza znaka `+` u `pubspec.yaml` plus GitHub `run_number`. Za trenutno stanje `0.7.0+7` prvi TestFlight run zato koristi build broj `8`, a ne `1`.

## Sigurnost

- App Store Connect privatni ključ nalazi se samo u GitHub Actions Secrets.
- Workflow ne ispisuje sadržaj privatnog ključa.
- Xcode dobiva API ključ kroz privremenu datoteku na ephemeral macOS runneru.
- Potpisani IPA provjerava se s `codesign --verify`.
- Provjerava se prisutnost i čitljivost provisioning profila prije slanja.
- Nepotpisani iOS CI iz `ci.yml` ostaje odvojen i nastavlja raditi bez Apple vjerodajnica.

## Ako workflow padne

Najčešći uzroci su:

- nije aktivan Apple Developer Program
- App Store Connect app za `com.brendigo.worklog` nije kreiran
- API ključ nema odgovarajuće ovlasti
- `APPSTORE_TEAM_ID` nije točan
- API key vrijednosti nisu pravilno spremljene
- Appleovi ugovori u App Store Connectu čekaju prihvaćanje
- Bundle ID je registriran pod drugim Apple Developer timom

Ne dodavati certifikate, provisioning profile ili `.p8` ključeve u Git.
