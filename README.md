# WORKLOG

**WORKLOG** je Android i iOS aplikacija za organizaciju terenskog rada: poslovi, klijenti, raspored, evidencija vremena, materijal, fotografije prije/poslije, potpis klijenta i završni zapisnici.

> Dokaz obavljenog posla, bez kaosa.

## Status

Aktivni razvoj: **0.7.0**. Projekt je izgrađen u Flutteru s jednim kodom za Android i iOS. Cijelo korisničko sučelje je na hrvatskom i vizualno prati odobreni WORKLOG branding.

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

- onboarding i prijava
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
- iOS release build bez potpisivanja
- provjeru i upload no-codesign iOS artefakta

## Branding

Glavne boje:

- `#06111F` pozadina
- `#0B1E3A` površine
- `#3B82F6` primarna plava
- `#10B981` potvrda / završeno

Izvorni vektorski znak nalazi se u `assets/brand/worklog-mark.svg`.

## Licenca

MIT — vidi [LICENSE](LICENSE).
