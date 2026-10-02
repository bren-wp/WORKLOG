# WORKLOG — privatnost i obrada podataka

Ovaj dokument opisuje tehničko ponašanje WORKLOG aplikacije u verziji 0.11.0. Nije zamjena za konačnu pravnu politiku privatnosti vlasnika proizvoda prije javne objave.

## Lokalni operativni podaci

Klijenti, poslovi, termini, evidencija vremena, članovi tima, bilješke, materijal, fotografije, potpisi, PDF zapisnici, dnevnik aktivnosti i postavke i dalje se spremaju lokalno na uređaju. Cloud sinkronizacija tih podataka nije implementirana.

Glavni aplikacijski zapis sprema se u privatni direktorij aplikacije u datoteku `state.json`. Fotografije, potpisi i PDF-ovi spremaju se u privatni WORKLOG direktorij aplikacije.

## Serverska autentikacija

WORKLOG 0.11.0 koristi stvarni `/web` backend za registraciju i prijavu e-mailom i lozinkom. Google i Apple prijava nisu implementirane.

Backend obrađuje:
- ime korisnika
- e-mail adresu
- sigurni hash lozinke
- hash access/refresh tokena
- vrijeme nastanka i zadnje uporabe sesije
- IP adresu i user-agent za sigurnosnu evidenciju sesije i rate limiting

Lozinka se ne sprema u čistom tekstu. Access i refresh tokeni se na poslužitelju spremaju samo u hashiranom obliku. Mobilni tokeni koriste sigurnu pohranu operacijskog sustava preko `flutter_secure_storage`.

## Kamera i fotografije

Kamera i galerija koriste se samo nakon korisničke radnje za dodavanje fotografija uz posao. Odabrane fotografije spremaju se lokalno; cloud upload nije implementiran.

## Biometrija

Biometrija/PIN uređaja služe kao dodatna lokalna zaštita nakon serverske prijave. WORKLOG ne prima niti sprema biometrijski predložak.

## Obavijesti

Aplikacija trenutačno koristi lokalne Android/iOS obavijesti. Push backend i udaljeni device tokeni nisu implementirani.

## Lokacija, navigacija i dijeljenje

WORKLOG ne traži stalnu GPS lokaciju. Korisnički pokrenuta navigacija ili dijeljenje može predati adresu/PDF vanjskoj aplikaciji koju korisnik odabere.

## Izvoz i brisanje

Aplikacija sadrži lokalni izvoz aplikacijskog stanja i brisanje lokalnih WORKLOG podataka. Serversko potpuno brisanje računa i udaljeni GDPR export još nisu implementirani i moraju biti završeni prije produkcijske objave koja ih zahtijeva.

## Analytics i oglašavanje

WORKLOG nema ugrađen analytics ni advertising SDK.
