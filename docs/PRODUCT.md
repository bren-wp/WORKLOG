# WORKLOG — specifikacija proizvoda

## Svrha

WORKLOG je Android i iOS aplikacija za obrtnike, servisere, montažere i terenske timove. Cilj je da jedan posao ima jedan pouzdan zapis: klijent, lokacija, termin, vrijeme rada, materijal, fotografije, napomene, potpis i završni izvještaj.

## Verzija 0.3.0

Aplikacija više nije samo UI prototip. Uz mobilne integracije i trajnu lokalnu pohranu, 0.3.0 uvodi stvarno upravljanje klijentima, profilom tvrtke, terenskim timom, postavkama te izvozom i brisanjem lokalnih podataka.

### Novo u 0.3.0

- dodavanje i uređivanje klijenata
- sigurno brisanje klijenta samo kada nema povezanih poslova
- pretraga klijenata po nazivu, adresi, telefonu i e-pošti
- stabilni ID-jevi klijenata i ponovno povezivanje poslova nakon učitavanja
- uređivanje profila tvrtke i broja zaposlenih
- stvarno spremanje podataka profila već iz onboardinga
- dodavanje, uređivanje, aktiviranje i uklanjanje članova terenskog tima
- trajne korisničke postavke
- uključivanje/isključivanje automatskog spremanja
- uključivanje/isključivanje obavijesti i kompaktnih kartica
- izvoz lokalnih WORKLOG podataka u JSON
- odjava iz aplikacije
- sigurno brisanje svih lokalnih WORKLOG podataka s potvrdom

### Implementirano

- hrvatski onboarding, prijava i profil tvrtke
- početna nadzorna ploča s aktivnim poslovima
- filtriranje poslova prema statusu
- tjedni raspored
- baza klijenata i detalj klijenta
- razgovor s klijentom
- izrada novog naloga
- detalj naloga
- stvarni poziv klijenta preko telefonske aplikacije
- otvaranje navigacije prema lokaciji posla
- radni timer sa start/pauza/završetak
- dodavanje materijala i izračun ukupne vrijednosti
- bilješke i kontrolna lista
- kamera i galerija za fotografije prije/poslije
- trajno kopiranje fotografija u privatni prostor WORKLOG aplikacije
- oporavak izgubljenog odabira fotografije na Androidu
- potpis prstom na zaslonu
- spremanje potpisa kao slike u privatnu pohranu
- pregled podataka prije zapisnika
- generiranje stvarnog PDF zapisnika
- fotografije i potpis u PDF zapisniku kada su dostupni
- sustavno dijeljenje PDF-a putem instaliranih aplikacija
- trajno spremanje poslova, materijala, bilješki, statusa i putanja dokumenata
- obavijesti i popis izvještaja
- iOS opisi dozvola za kameru i fototeku
- WORKLOG naziv aplikacije u generiranim Android/iOS projektima

## Lokalna pohrana

Operativni podaci spremaju se u privatni application documents prostor uređaja. Stanje se zapisuje atomski preko privremene datoteke kako bi se smanjio rizik od oštećenja JSON zapisa pri prekidu pisanja. Fotografije, potpisi i PDF zapisnici organiziraju se u zasebne WORKLOG podmape.

## PDF

PDF zapisnik uključuje:

- osnovne podatke o poslu
- podatke klijenta
- vrijeme rada
- materijal
- bilješke
- fotografije prije i poslije
- potpis klijenta
- status dovršenog posla

Trenutačni PDF koristi standardni ugrađeni font radi potpuno offline rada. Tekst PDF-a zato normalizira hrvatske dijakritičke znakove samo unutar PDF datoteke; mobilno sučelje ostaje potpuno na hrvatskom. U kasnijoj iteraciji može se dodati ugrađeni Unicode font uz odgovarajuću licencu.

## Produkcijske integracije koje još slijede

- stvarna korisnička autentikacija i backend API
- sigurna sinkronizacija između više uređaja
- push obavijesti
- timovi, uloge i dozvole
- naplata i pretplate
- cloud sigurnosne kopije
- server-side arhiva PDF zapisnika
- napredna izrada ponuda/računa
- potpuno offline-first konfliktno usklađivanje više uređaja
