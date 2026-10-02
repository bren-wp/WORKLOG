# WORKLOG — specifikacija proizvoda

## Svrha

WORKLOG je Android i iOS aplikacija za obrtnike, servisere, montažere i terenske timove. Cilj je da jedan posao ima jedan pouzdan zapis: klijent, lokacija, termin, vrijeme rada, materijal, fotografije, napomene, potpis i završni izvještaj.

## Trenutačno implementirano

- hrvatski onboarding, prijava i profil tvrtke
- početna nadzorna ploča s aktivnim poslovima
- filtriranje poslova prema statusu
- tjedni raspored
- baza klijenata i detalj klijenta
- razgovor s klijentom
- izrada novog naloga
- detalj naloga
- radni timer sa start/pauza/završetak
- dodavanje materijala i izračun ukupne vrijednosti
- bilješke i kontrolna lista
- prikaz prije/poslije
- potpis prstom na zaslonu
- pregled podataka prije zapisnika
- završetak posla
- sučelje za slanje izvještaja
- obavijesti i popis izvještaja

## Produkcijske integracije koje slijede

UI i domena su odvojeni tako da se sljedeće integracije mogu dodavati bez promjene vizualnog sustava:

- lokalna baza i sinkronizacija
- kamera i galerija uređaja
- spremanje stvarnog potpisa
- generiranje pravog PDF dokumenta
- e-pošta / WhatsApp / sustavno dijeljenje
- push obavijesti
- autentikacija i backend API
- karte i navigacija
- timovi, uloge i dozvole
- naplata i pretplate
