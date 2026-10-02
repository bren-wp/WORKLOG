# WORKLOG — specifikacija proizvoda

## Svrha

WORKLOG je Android i iOS aplikacija za obrtnike, servisere, montažere i terenske timove. Cilj je da jedan posao ima jedan pouzdan zapis: klijent, lokacija, termin, vrijeme rada, materijal, fotografije, napomene, potpis i završni izvještaj.

## Verzija 0.7.0

Verzija 0.7.0 uklanja lažno početno seedanje podataka i pretvara evidenciju vremena u trajni model koji preživljava zatvaranje ekrana i ponovno pokretanje aplikacije.

### Novo u 0.7.0

- puni statusni lifecycle: planirano, potvrđeno, na putu, u tijeku, pauzirano, završeno i otkazano
- trajni radni intervali s početkom i završetkom
- aktivni interval ostaje aktivan nakon ponovnog učitavanja spremljenog stanja
- više vremenskih intervala po poslu
- ručna korekcija vremena uz obavezan razlog
- schema v7 uz kompatibilnost sa starim `minutesWorked` zapisima
- dashboard više nema hardkodirane sate, zapisnike ni fiksni datum
- PDF i pregled zapisnika koriste stvarno evidentirano vrijeme
- produkcijsko stanje više ne ubacuje demo klijente, poslove, tim ni lažne kontakt podatke
- CI provjerava format, analizu i testove te gradi APK, AAB i iOS no-codesign artefakt uz eksplicitnu provjeru da datoteke stvarno postoje

Napomena: serverska autentikacija, višekorisnička sinkronizacija i potpisani store artefakti i dalje zahtijevaju stvarnu produkcijsku infrastrukturu i privatne vjerodajnice vlasnika; aplikacija ih ne predstavlja kao dovršene.

## Verzija 0.6.0

Aplikacija više nije samo UI prototip. Verzija 0.6.0 uklanja statične demo poruke i obavijesti: razgovori se lokalno spremaju po klijentu, a obavijesti su trajni dnevnik stvarnih događaja u aplikaciji.

### Novo u 0.6.0

- trajno spremljen lokalni dnevnik razgovora po klijentu
- moje poruke i ručno evidentirani odgovori klijenta s vremenom nastanka
- prazno stanje umjesto lažnih unaprijed napisanih poruka
- trajni dnevnik stvarnih aktivnosti umjesto statičnih demo obavijesti
- read/unread stanje događaja i broj nepročitanih u izborniku
- označavanje svih događaja pročitanima i uklanjanje pročitanih
- automatski događaji za novi posao, novog klijenta, člana tima i odgovor klijenta
- događaji za uređivanje, pokretanje i završetak posla te dijeljenje PDF zapisnika
- poruke i aktivnosti uključene u lokalni JSON export i schema v6
- brisanje klijenta uklanja i njegov lokalni razgovor
- uklonjen stari razvojni `SimplePage` placeholder

Napomena: razgovor u 0.6.0 je lokalna evidencija komunikacije. Ne predstavlja serverski chat niti tvrdi da je poruka isporučena klijentu bez buduće backend integracije.

### Iz 0.5.0

- stvarni `DateTime` raspored za svaki posao
- migracija starih hrvatskih tekstualnih datuma i vremena iz 0.4 i starijih zapisa
- date picker i time picker pri izradi novog posla
- validacija da završetak mora biti nakon početka
- potpuno uređivanje naziva, klijenta, lokacije, termina, statusa, prioriteta, opisa i tehničara
- automatsko usklađivanje tekstualnog prikaza termina sa stvarnim rasporedom
- sortiranje poslova po terminu
- kalendar Dan / Tjedan / Mjesec
- navigacija na prethodno i sljedeće razdoblje te povratak na danas
- poseban prikaz poslova bez termina
- početni demo podaci koriste stvarne termine relativne na dan prvog pokretanja

### Iz 0.4.0

- lokalna autentikacija preko biometrije ili sigurnosne šifre uređaja
- automatsko zaključavanje WORKLOG-a nakon prijave i povratka iz pozadine
- sigurna migracija starih postavki: zaštita se ne uključuje bez nove potvrde korisnika
- lokalne Android/iOS obavijesti uz eksplicitno traženje sistemske dozvole
- testna obavijest iz Postavki
- lokalna obavijest pri pokretanju planiranog terenskog posla
- dodjela novog posla aktivnom članu terenskog tima
- prikaz dodijeljenog tehničara na kartici, kalendaru i detalju posla
- dodijeljeni tehničar u PDF zapisniku
- zaštita od uklanjanja člana tima koji ima aktivne dodijeljene poslove
- Android FragmentActivity, USE_BIOMETRIC, AppCompat LaunchTheme i desugaring konfigurirani kroz reproduktibilni build alat

### Iz 0.3.0

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
- kalendar s dnevnim, tjednim i mjesečnim prikazom
- baza klijenata i detalj klijenta
- lokalna evidencija razgovora s klijentom
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
- lokalne obavijesti i popis izvještaja
- iOS opisi dozvola za kameru, fototeku i Face ID
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
