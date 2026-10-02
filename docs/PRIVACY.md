# WORKLOG — privatnost i obrada podataka

Ovaj dokument opisuje stvarno ponašanje WORKLOG aplikacije u verziji 0.8.0. Nije zamjena za pravnu politiku privatnosti vlasnika proizvoda prije javne objave.

## Trenutni model podataka

WORKLOG trenutačno radi lokalno na uređaju. Aplikacija nema implementiran produkcijski backend, cloud sinkronizaciju, analytics SDK ni oglasni SDK.

Lokalno se mogu spremati podaci tvrtke, klijenti i kontakti, poslovi i termini, evidencija vremena, članovi tima, bilješke, materijal, fotografije prije/poslije, potpis klijenta, generirani PDF zapisnici, dnevnik aktivnosti i postavke.

Glavni aplikacijski zapis sprema se u privatni direktorij aplikacije u datoteku `state.json`. Fotografije, potpisi i PDF-ovi spremaju se u privatni WORKLOG direktorij aplikacije.

## Kamera i fotografije

Kamera i galerija koriste se samo nakon korisničke radnje za dodavanje fotografija uz posao. Odabrane fotografije spremaju se lokalno; produkcijski cloud upload trenutačno nije implementiran.

## Biometrija

Biometrija/PIN uređaja koriste se samo kao lokalna zaštita putem operacijskog sustava. WORKLOG ne prima niti sprema biometrijski predložak. Biometrija nije zamjena za serversku autentikaciju.

## Obavijesti

Aplikacija trenutačno koristi lokalne Android/iOS obavijesti. Push backend i lifecycle udaljenih device tokena još nisu implementirani.

## Lokacija i navigacija

WORKLOG trenutačno ne traži GPS lokacijsku dozvolu. Kada korisnik ručno odabere navigaciju do adrese posla, aplikacija otvara vanjsku Google Maps pretragu; odabrana adresa tada se predaje toj vanjskoj usluzi.

## Dijeljenje

Kada korisnik odabere dijeljenje PDF-a ili e-poštu, sadržaj se predaje sistemskom share sheetu ili odabranoj vanjskoj aplikaciji.

## Izvoz i brisanje

Aplikacija sadrži lokalni izvoz aplikacijskog stanja i brisanje lokalnih WORKLOG podataka.

Buduća serverska verzija mora zasebno implementirati izvoz udaljenih podataka, brisanje računa, retention pravila, uređaje/sesije i GDPR tokove.

## Autentikacija

Trenutni ekran prijave nije produkcijska serverska autentikacija. Registracija, reset lozinke, verifikacija e-pošte, refresh tokeni, rate limiting i upravljanje sesijama još zahtijevaju stvarni backend.

Zbog toga se trenutačna verzija ne smije predstavljati kao dovršena višekorisnička cloud aplikacija.

## Analytics i oglašavanje

U verziji 0.8.0 nema ugrađenog analytics ni advertising SDK-a. Ako se kasnije dodaju, ovaj dokument i store privacy odgovori moraju se ponovno izvesti iz stvarnog ponašanja aplikacije.
