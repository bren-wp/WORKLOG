# WORKLOG

**WORKLOG** je Android i iOS aplikacija za organizaciju terenskog rada: poslovi, klijenti, raspored, evidencija vremena, materijal, fotografije prije/poslije, potpis klijenta i završni zapisnici.

> Dokaz obavljenog posla, bez kaosa.

## Status

Aktivni razvoj: **0.8.0**. Projekt je izgrađen u Flutteru s jednim kodom za Android i iOS. Cijelo korisničko sučelje je na hrvatskom i vizualno prati odobreni WORKLOG branding.

## Pokretanje

```bash
git clone https://github.com/bren-wp/WORKLOG.git
cd WORKLOG
./tool/bootstrap.sh
flutter run
```

Ako ste na Windowsu, pokrenite ekvivalent:

```powershell
flutter create --org com.brendigo --project-name worklog --platforms android,ios .
python tool/configure_platforms.py
flutter pub get
flutter run
```

## Implementirani moduli

- onboarding i lokalni prijavni tok (serverska autentikacija još nije produkcijski backend)
- postavljanje profila tvrtke
- Početna
- Poslovi, statusi i potpuno uređivanje naloga
- stvarni datum i vrijeme termina
- kalendar Dan / Tjedan / Mjesec s navigacijom
- Klijenti
- trajni lokalni dnevnik razgovora po klijentu
- stvarni dnevnik aktivnosti i nepročitanih događaja
- Novi posao
- Detalj posla
- Evidencija vremena s trajnim intervalima, pauzom/nastavkom i ručnom korekcijom s razlogom
- Materijal i troškovi
- Bilješke i kontrolna lista
- Fotografije prije/poslije
- potpis klijenta
- pregled zapisnika
- završetak posla
- slanje izvještaja
- Izvještaji i stvarni PDF zapisnici
- kamera i galerija
- lokalno spremanje potpisa
- sistemsko dijeljenje PDF-a
- upravljanje profilom tvrtke
- upravljanje terenskim timom
- dodjela poslova članovima tima
- lokalne Android/iOS obavijesti
- zaključavanje aplikacije biometrijom ili šifrom uređaja
- izvoz i brisanje lokalnih podataka

Detalji proizvoda: [docs/PRODUCT.md](docs/PRODUCT.md)  
Vizualni identitet: [docs/BRAND.md](docs/BRAND.md)

## Provjera kvalitete

GitHub Actions na svakoj promjeni izvršava:

- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- Android release APK build
- Android release AAB build
- provjeru postojanja i SHA-256 checksumova Android artefakata
- Android compile/target API 36 i min SDK 24 provjeru
- iOS Xcode 26+ / iOS 26+ SDK provjeru i deployment target 13.0
- iOS release build bez potpisivanja
- provjeru i upload no-codesign iOS artefakta

## Branding

Glavne boje:

- `#06111F` pozadina
- `#0B1E3A` površine
- `#3B82F6` primarna plava
- `#10B981` potvrda / završeno

Izvorni vektorski znak nalazi se u `assets/brand/worklog-mark.svg`.

Generirani produkcijski brand asseti:

- `assets/brand/generated/worklog-app-icon-1024.png`
- `assets/brand/generated/worklog-splash-mark-512.png`
- `store/android/assets/worklog-app-icon-512.png`
- `store/android/assets/worklog-feature-graphic-1024x500.png`
- `store/ios/assets/worklog-app-store-icon-1024.png`

`tool/generate_brand_assets.py` reproduktibilno generira launcher/App Store/Play Store assete iz WORKLOG geometrijskog znaka.

## Store i privatnost

- [Store compliance](docs/STORE-COMPLIANCE.md)
- [Privatnost i stvarno ponašanje podataka](docs/PRIVACY.md)
- [Android production signing](docs/ANDROID-SIGNING.md)
- [TestFlight priprema](docs/TESTFLIGHT.md)
- [Google Play listing — hr-HR](store/google-play/hr-HR.md)
- [App Store listing — hr-HR](store/app-store/hr-HR.md)

Produkcijski Android AAB je Play-ready tek kada su postavljene stvarne signing tajne. Potpisani iOS IPA/TestFlight build zahtijeva vlasnikove Apple Developer/App Store Connect vjerodajnice.

## Licenca

MIT — vidi [LICENSE](LICENSE).
