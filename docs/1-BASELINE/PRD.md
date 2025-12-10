# PRD: HomeOS - Modularna Aplikacja do Zarzadzania Domem

## Informacje o Dokumencie
- **Wersja:** 1.1
- **Data utworzenia:** 2025-12-09
- **Ostatnia aktualizacja:** 2025-12-09
- **Autor:** PM Agent (John)
- **Status:** Draft
- **Discovery Ref:** @docs/0-DISCOVERY/PROJECT-UNDERSTANDING.md
- **Market Analysis Ref:** @docs/1-BASELINE/research/market-analysis.md

---

## 1. Executive Summary

**HomeOS** to modularna aplikacja webowa (PWA) do zarzadzania domem, skierowana do polskich rodzin z dziecmi. Rozwiazuje problem rozproszenia narzedzi domowych (listy zakupow, zadania, rachunki) w jednej, przystepnej cenowo aplikacji z nowoczesnym UX.

**Kluczowe wyrozniki:**
- Cena 2x nizsza od konkurencji (~80 PLN/rok vs 120-240 PLN)
- Mobile-first, nowoczesny interfejs (2025)
- Niezawodne powiadomienia
- Lokalizacja na polski rynek

**Timeline MVP:** 3 tygodnie
**Cel MVP:** 20 uzytkownikow, pozytywny feedback, walidacja rynkowa

---

## 2. Problem Statement

### Stan Obecny
Polskie rodziny korzystaja z wielu rozproszonych aplikacji do zarzadzania domem:
- Osobna aplikacja do list zakupow
- Osobna aplikacja do zadan domowych
- Arkusze kalkulacyjne lub notatki do rachunkow
- Brak wspoldzielenia miedzy czlonkami rodziny

### Pain Points
1. **Rozproszenie** - koniecznosc uzycia 3-5 roznych aplikacji
2. **Wysokie koszty** - Cozi $30-39/rok, FamilyWall $60/rok (120-240 PLN)
3. **Zawodne powiadomienia** - konkurenci maja problemy techniczne
4. **Przestarzaly UX** - interfejsy wygladaja jak z 2010 roku
5. **Brak lokalizacji** - aplikacje nie sa dostosowane do polskiego rynku

### Impact
- **Czas:** 15-30 minut dziennie na synchronizacje miedzy aplikacjami
- **Frustacja:** Cozi w maju 2024 ograniczyl darmowy tier - fala negatywnych opinii
- **Koszty:** Rodziny placa zbyt duzo za podstawowe funkcje

---

## 3. Target Users & Personas

### Glowna Grupa Docelowa
**Polskie rodziny z dziecmi** - szczegolnie rodzice w wieku 30-45 lat

### Persona 1: Anna (Admin/Owner)
- **Rola:** Mama, glowna organizatorka domu
- **Wiek:** 35 lat
- **Cele:**
  - Miec wszystko w jednym miejscu
  - Delegowac zadania rodzinie
  - Kontrolowac budzet domowy
- **Pain Points:**
  - Maz zapomina co kupic
  - Dzieci nie pamietaja o obowiazkach
  - Trudno sledzic wydatki
- **Tech Savviness:** Srednia
- **Urzadzenie:** iPhone (glownie), laptop (rzadko)

### Persona 2: Tomek (Member)
- **Rola:** Tata, wspoluczestnik organizacji
- **Wiek:** 38 lat
- **Cele:**
  - Widziec co trzeba kupic/zrobic
  - Szybko odhaczyc wykonane zadania
  - Nie byc bombardowanym powiadomieniami
- **Pain Points:**
  - Za duzo aplikacji do zainstalowania
  - Skomplikowane interfejsy
- **Tech Savviness:** Wysoka
- **Urzadzenie:** Android, laptop

### Persona 3: Zosia (Child)
- **Rola:** Corka, 12 lat
- **Cele:**
  - Widziec swoje obowiazki
  - Odhaczyc co zrobila
- **Pain Points:**
  - Rodzice zapominaja co jej przydzielili
- **Tech Savviness:** Wysoka
- **Urzadzenie:** Tablet, telefon

---

## 4. Goals Definition

### Cele Biznesowe (Business Goals)

| ID | Cel | Opis |
|----|-----|------|
| goal-1 | Walidacja produktu | 20 uzytkownikow MVP w 3 tygodnie |
| goal-2 | User satisfaction | NPS > 30 (lub >= 7/10 w ankiecie) |
| goal-3 | Retention | 40% monthly active users |
| goal-4 | Activation | 60% ukonczenia onboardingu |

### Cele Techniczne (Technical Goals)

| ID | Cel | Opis |
|----|-----|------|
| goal-tech-1 | Performance | Time to Interactive < 3s |
| goal-tech-2 | Availability | Uptime >= 99% |
| goal-tech-3 | Security | HTTPS, RLS, bezpieczne tokeny |

---

## 5. User Needs Definition

| ID | Potrzeba | Persona | Priorytet |
|----|----------|---------|-----------|
| user-need-1 | Szybki dostep do aplikacji | Wszystkie | Must Have |
| user-need-2 | Latwe logowanie (bez pamietania hasel) | Wszystkie | Must Have |
| user-need-3 | Wspoldzielenie z rodzina | Admin, Member | Must Have |
| user-need-4 | Kontrola rodzicielska (uprawnienia dzieci) | Admin | Must Have |
| user-need-5 | Tworzenie i zarzadzanie listami zakupow | Admin, Member | Must Have |
| user-need-6 | Organizacja listy (kategorie, sortowanie) | Wszystkie | Must Have |
| user-need-7 | Delegowanie produktow do osob | Admin, Member | Should Have |
| user-need-8 | Otrzymywanie powiadomien o zmianach | Wszystkie | Should Have |
| user-need-9 | Przeglad zadan domowych | Wszystkie | Should Have |
| user-need-10 | Personalizacja (dark mode) | Wszystkie | Should Have |
| user-need-11 | Lokalizacja (wybor jezyka PL/EN) | Wszystkie | Should Have |

---

## 6. Success Metrics (SMART)

### Cele Biznesowe

| Cel | Metryka | Target | Metoda Pomiaru | Deadline |
|-----|---------|--------|----------------|----------|
| Walidacja produktu | Liczba uzytkownikow | 20 osob | Supabase analytics | 3 tyg od startu |
| User satisfaction | NPS Score | >= 7/10 | Ankieta w aplikacji | 4 tyg od startu |
| Retention | 7-day retention | >= 50% | Analytics events | 4 tyg od startu |
| Activation | Onboarding completion | >= 60% | Supabase analytics | 3 tyg od startu |

### Cele Techniczne

| Cel | Metryka | Target | Metoda Pomiaru |
|-----|---------|--------|----------------|
| Wydajnosc | Time to Interactive | < 3s | Lighthouse |
| Niezawodnosc | Uptime | >= 99% | Vercel monitoring |
| UX | Core Web Vitals | Green | PageSpeed Insights |

---

## 7. Pricing Model

### Oficjalne Ceny

| Tier | PLN (primary) | USD (equivalent) | Funkcje |
|------|---------------|------------------|---------|
| **Free** | 0 PLN | $0 | Pelne funkcje z limitami + reklamy (nieinwazyjne) |
| **Premium (miesieczny)** | ~8 PLN/msc | ~$2/msc | Bez reklam, unlimited, export, AI suggestions |
| **Premium (roczny)** | ~80 PLN/rok | ~$20/rok | Jak wyzej, 17% taniej |

### Free Tier Limits

| Zasob | Limit | Powod |
|-------|-------|-------|
| Listy zakupow | Max 12 | Typowe uzycie przez rodzine |
| Produkty per lista | Max 50 | Wydajnosc + zacheta |
| Czlonkowie gospodarstwa | Max 10 | Rozszerzona rodzina + opieka |

**Uwaga:** Limity moga byc dostosowane na podstawie feedbacku uzytkownikow w Phase 1.

### Porownanie z Konkurencja

| Aplikacja | Cena roczna | HomeOS vs |
|-----------|-------------|-----------|
| Cozi | 120-160 PLN | 2x tanszy |
| FamilyWall | 240 PLN | 3x tanszy |
| HomeOS | ~80 PLN | - |

---

## 8. MVP Scope (3 tygodnie)

### Roadmap Faz
```
MVP (3 tyg) ------> Phase 1 (1-2 msc) ------> Phase 2 (3-4 msc) ------> Phase 3 (5-6 msc)
Auth + Shopping     Tasks pelne              Expenses                   Meal Planning
+ Tasks Preview     Bills Tracker            Real-time sync             Calendar
                    Offline                  BLIK                       AI features
```

---

### TYDZIEN 1: Fundament (Auth + Household)

#### US-01: Rejestracja Email
**Jako** nowy uzytkownik
**Chce** zarejestrowac sie przez email i haslo
**Zeby** miec konto w aplikacji

**Acceptance Criteria:**
- [ ] Formularz z polami: email, haslo, potwierdzenie hasla
- [ ] Walidacja: email format, haslo min 8 znakow
- [ ] Weryfikacja email (magic link)
- [ ] Komunikaty bledow po polsku
- [ ] Przekierowanie do tworzenia household po weryfikacji
- [ ] **Account Linking:** Jesli email juz istnieje z inna metoda auth (np. Google), wyswietl komunikat "Konto istnieje - zaloguj sie przez [metoda]" z opcja polaczenia kont

**Priorytet:** Must Have
**Traces to:** goal-1 (walidacja produktu), goal-4 (activation), user-need-1 (dostep do aplikacji)

---

#### US-02: Logowanie Google OAuth
**Jako** uzytkownik
**Chce** zalogowac sie przez Google
**Zeby** nie musiec pamietac kolejnego hasla

**Acceptance Criteria:**
- [ ] Przycisk "Zaloguj przez Google"
- [ ] Integracja z Supabase Google OAuth
- [ ] Automatyczne tworzenie profilu uzytkownika
- [ ] Obsluga bledow (anulowanie, blad sieci)
- [ ] **Account Linking:** Jesli email Google juz istnieje z metoda email/password:
  - Wyswietl komunikat "Konto z tym emailem juz istnieje"
  - Zaproponuj polaczenie kont (wymaga weryfikacji hasla)
  - Po polaczeniu: mozliwosc logowania obiema metodami

**Priorytet:** Must Have
**Traces to:** goal-4 (activation rate), user-need-2 (wygoda logowania)

---

#### US-03: Tworzenie Gospodarstwa Domowego
**Jako** nowy uzytkownik
**Chce** utworzyc gospodarstwo domowe
**Zeby** moc zaprosic rodzine

**Acceptance Criteria:**
- [ ] Formularz z nazwa gospodarstwa (np. "Kowalscy")
- [ ] Automatyczne przypisanie roli Admin
- [ ] Generowanie kodu zaproszenia (6 znakow)
- [ ] Generowanie QR code do zaproszenia
- [ ] Ekran sukcesu z instrukcja zapraszania

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-3 (wspoldzielenie z rodzina)

---

#### US-04: Zapraszanie Czlonkow (QR/Kod)
**Jako** Admin gospodarstwa
**Chce** zaprosic czlonkow rodziny
**Zeby** mogli korzystac z aplikacji

**Acceptance Criteria:**
- [ ] Wyswietlanie QR code do zeskanowania
- [ ] Wyswietlanie kodu tekstowego (6 znakow)
- [ ] Mozliwosc kopiowania kodu
- [ ] Mozliwosc udostepnienia linku (share API)
- [ ] Zaproszenie wygasa po 7 dniach

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-3

---

#### US-05: Dolaczanie do Gospodarstwa
**Jako** zaproszony uzytkownik
**Chce** dolaczyc do gospodarstwa
**Zeby** byc czescia rodzinnej organizacji

**Acceptance Criteria:**
- [ ] Ekran wprowadzania kodu zaproszenia
- [ ] Skanowanie QR code (kamera)
- [ ] Walidacja kodu (poprawnosc, waznosc)
- [ ] **Admin PRZYPISUJE role przy akceptacji** (nie user wybiera)
  - Zaproszony widzi ekran oczekiwania "Czekam na akceptacje..."
  - Admin otrzymuje powiadomienie o nowym zaproszeniu
  - Admin wybiera role: Member lub Child
  - Po akceptacji zaproszony otrzymuje dostep z przypisana rola
- [ ] Dla Child: zawsze wymaga akceptacji przez Admina

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-3, user-need-4

---

#### US-06: Zarzadzanie Rolami
**Jako** Admin
**Chce** zarzadzac rolami czlonkow
**Zeby** kontrolowac uprawnienia

**Acceptance Criteria:**
- [ ] Lista czlonkow z ich rolami
- [ ] Mozliwosc zmiany roli (Member <-> Child)
- [ ] Mozliwosc usuwania czlonkow
- [ ] Member moze zaprosic max 3 osoby
- [ ] Child nie moze zapraszac

**Priorytet:** Should Have
**Traces to:** goal-1, user-need-4 (kontrola rodzicielska)

---

#### US-06a: Rejestracja Dziecka (Child Registration)
**Jako** rodzic (Admin)
**Chce** utworzyc konto dla dziecka
**Zeby** dziecko moglo korzystac z aplikacji bez podawania emaila

**Acceptance Criteria:**
- [ ] Formularz tworzenia konta dziecka z polami: username, haslo
- [ ] **Tylko username** - bez wymogu emaila (prywatnosc dziecka)
- [ ] Username unikalny w ramach gospodarstwa
- [ ] Haslo ustalone przez rodzica (min 6 znakow)
- [ ] Automatyczne przypisanie roli Child
- [ ] **Parent approval required** - konto nieaktywne do akceptacji rodzica
- [ ] Dziecko loguje sie przez: username + haslo (bez OAuth)
- [ ] Rodzic moze zresetowac haslo dziecka
- [ ] Rodzic moze usunac konto dziecka

**Flow:**
1. Admin klika "Dodaj dziecko"
2. Wpisuje username i haslo dla dziecka
3. System tworzy konto z rola Child (pending approval)
4. Admin potwierdza -> konto aktywne
5. Dziecko loguje sie przez username/haslo

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-4 (kontrola rodzicielska)

**UWAGA:** Child nie uzywa emaila ze wzgledow prywatnosci (RODO, ochrona danych dzieci). Konto powiazane z gospodarstwem rodzica.

---

#### US-07: Dashboard (Placeholder)
**Jako** uzytkownik
**Chce** widziec glowny ekran aplikacji
**Zeby** miec dostep do wszystkich funkcji

**Acceptance Criteria:**
- [ ] Naglowek z nazwa gospodarstwa
- [ ] Nawigacja do Shopping List
- [ ] Nawigacja do Tasks (z oznaczeniem "Preview")
- [ ] Widoczna nazwa uzytkownika i rola
- [ ] Przycisk wylogowania

**Priorytet:** Must Have
**Traces to:** goal-4 (activation)

---

### TYDZIEN 2: Lista Zakupow (Pelna Funkcjonalnosc)

#### US-08: Tworzenie List Zakupow
**Jako** czlonek gospodarstwa (Admin lub Member)
**Chce** tworzyc listy zakupow
**Zeby** organizowac zakupy

**Acceptance Criteria:**
- [ ] Przycisk "Nowa lista"
- [ ] Pole nazwy listy (np. "Biedronka sobota")
- [ ] Lista widoczna dla wszystkich czlonkow
- [ ] Mozliwosc edycji nazwy
- [ ] Mozliwosc usuwania listy
- [ ] **Child NIE moze tworzyc list** (patrz: Child Permissions Matrix)

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-5 (lista zakupow)

---

#### US-09: Dodawanie Produktow
**Jako** czlonek gospodarstwa
**Chce** dodawac produkty do listy
**Zeby** miec kompletna liste zakupow

**Acceptance Criteria:**
- [ ] Pole tekstowe do dodawania produktu
- [ ] Automatyczne sugestie (historia produktow)
- [ ] Wybor kategorii (dropdown)
- [ ] Opcjonalnie: ilosc, jednostka
- [ ] Opcjonalnie: przypisanie do osoby
- [ ] **Child MOZE dodawac produkty** (patrz: Child Permissions Matrix)

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-5

---

#### US-10: Kategorie Produktow
**Jako** uzytkownik
**Chce** kategoryzowac produkty
**Zeby** latwiej je znajdowac w sklepie

**Acceptance Criteria:**
- [ ] Predefiniowane kategorie: Mleczne, Warzywa, Pieczywo, Mieso, Napoje, Inne
- [ ] Mozliwosc tworzenia wlasnych kategorii
- [ ] Ikony dla kazdej kategorii
- [ ] Domyslna kategoria: "Inne"

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-6 (organizacja listy)

---

#### US-11: Sortowanie i Drag & Drop
**Jako** uzytkownik
**Chce** sortowac liste zakupow
**Zeby** dopasowac ja do ukladu sklepu

**Acceptance Criteria:**
- [ ] Sortowanie wg kategorii (domyslne)
- [ ] Sortowanie reczne (drag & drop)
- [ ] Zapamietywanie preferencji sortowania
- [ ] Plynna animacja przy przesuwaniu

**Priorytet:** Must Have
**Traces to:** user-need-6

---

#### US-12: Odhaczanie Produktow
**Jako** osoba robiaca zakupy
**Chce** odhaczac kupione produkty
**Zeby** wiedziec co jeszcze kupic

**Acceptance Criteria:**
- [ ] Checkbox przy kazdym produkcie
- [ ] Odhaczyony produkt przenosi sie na dol (przekreslony)
- [ ] Mozliwosc "ododhaczenia"
- [ ] Przycisk "Usun kupione"

**Priorytet:** Must Have
**Traces to:** user-need-5

---

#### US-13: Synchronizacja Multi-User
**Jako** czlonek rodziny
**Chce** widziec zmiany innych osob
**Zeby** nie kupowac tego samego

**Acceptance Criteria:**
- [ ] Auto-refresh co 10 minut
- [ ] Przycisk "Odswiez teraz"
- [ ] Wskaznik ostatniej synchronizacji
- [ ] Wskaznik kto dodal/odhaczyc produkt

**Priorytet:** Must Have
**Traces to:** goal-1, user-need-3

---

#### US-14: Przypisywanie do Osob
**Jako** Admin/Member
**Chce** przypisac produkt do osoby
**Zeby** wiedziec kto ma co kupic

**Acceptance Criteria:**
- [ ] Dropdown z lista czlonkow
- [ ] Avatar/inicjaly przy przypisanym produkcie
- [ ] Filtrowanie: "Moje" / "Wszystkie"
- [ ] Opcjonalnie: powiadomienie dla przypisanej osoby

**Priorytet:** Should Have
**Traces to:** user-need-7 (delegowanie)

---

#### US-15: Push Notifications (Basic)
**Jako** uzytkownik
**Chce** otrzymywac powiadomienia
**Zeby** nie przegapic waznych zmian

**Acceptance Criteria:**
- [ ] Proba o zgode na powiadomienia
- [ ] Powiadomienie gdy ktos doda produkt do listy
- [ ] Powiadomienie gdy zostane przypisany do produktu
- [ ] Mozliwosc wylaczenia w ustawieniach

**Priorytet:** Should Have
**Traces to:** user-need-8 (powiadomienia)

---

### TYDZIEN 3: Tasks Preview + Polish

#### US-16: Tasks/Chores Preview
**Jako** uzytkownik
**Chce** widziec modul zadan
**Zeby** testowac przyszla funkcjonalnosc

**Acceptance Criteria:**
- [ ] Lista zadan domowych
- [ ] Dodawanie nowych zadan (tytul, opis)
- [ ] Przypisywanie do osob
- [ ] Odhaczanie wykonanych
- [ ] Oznaczenie "Preview" w UI

**Priorytet:** Should Have
**Traces to:** goal-1 (walidacja), user-need-9 (zadania)

---

#### US-17: Dark Mode
**Jako** uzytkownik
**Chce** przelaczac motyw jasny/ciemny
**Zeby** uzywac aplikacji wygodnie wieczorem

**Acceptance Criteria:**
- [ ] Toggle w ustawieniach
- [ ] Automatyczne wykrywanie preferencji systemu
- [ ] Plynna animacja przejscia
- [ ] Zapamietywanie preferencji

**Priorytet:** Should Have
**Traces to:** user-need-10 (personalizacja)

---

#### US-18: Jezyk PL/EN
**Jako** uzytkownik
**Chce** wybrac jezyk aplikacji
**Zeby** uzywac jej w preferowanym jezyku

**Acceptance Criteria:**
- [ ] Domyslnie: Polski
- [ ] Mozliwosc zmiany na Angielski
- [ ] Wszystkie teksty przetlumaczone
- [ ] Automatyczne wykrywanie jezyka przegladarki

**Priorytet:** Should Have
**Traces to:** user-need-11 (lokalizacja)

---

## 9. Child Permissions Matrix

### Uprawnienia wedlug Roli

| Akcja | Admin | Member | Child |
|-------|:-----:|:------:|:-----:|
| **Household** | | | |
| Tworzyc gospodarstwo | Y | N | N |
| Zapraszac czlonkow | Y (unlimited) | Y (max 3) | N |
| Akceptowac zaproszenia | Y | N | N |
| Zmieniac role | Y | N | N |
| Usuwac czlonkow | Y | N | N |
| Opuscic gospodarstwo | N (owner) | Y | Y |
| **Listy zakupow** | | | |
| Tworzyc liste | Y | Y | N |
| Edytowac nazwe listy | Y | Y | N |
| Usuwac liste | Y | Y | N |
| Dodawac produkty | Y | Y | Y |
| Edytowac produkty | Y | Y | Y (tylko swoje) |
| Usuwac produkty | Y | Y | N |
| Odhaczac produkty | Y | Y | Y |
| Przypisywac do osob | Y | Y | N |
| **Tasks (Preview)** | | | |
| Tworzyc zadania | Y | Y | N |
| Edytowac zadania | Y | Y | N |
| Odhaczac zadania | Y | Y | Y (tylko swoje) |
| **Ustawienia** | | | |
| Zmieniac ustawienia household | Y | N | N |
| Zmieniac swoj profil | Y | Y | Y |
| Zmieniac motyw/jezyk | Y | Y | Y |

**Legenda:** Y = Tak, N = Nie

### Child Permissions - Scenariusze Uzycia

**Scenariusz 1: Zosia (12 lat) dodaje produkt**
1. Zosia otwiera liste "Biedronka"
2. Klika "Dodaj produkt" -> wpisuje "Chipsy"
3. Produkt dodany - Zosia widzi swoj produkt na liscie
4. Zosia NIE moze usunac produktu (tylko Admin/Member)
5. Zosia NIE moze przypisac produktu do innej osoby

**Scenariusz 2: Zosia probuje utworzyc liste**
1. Zosia nie widzi przycisku "Nowa lista" (ukryty dla Child)
2. Jesli sprobuje przez URL -> blad "Brak uprawnien"

**Scenariusz 3: Zosia odhacza produkt**
1. Zosia jest w sklepie z Mama
2. Bierze mleko z polki -> odhacza "Mleko" na liscie
3. Produkt oznaczony jako kupiony (purchased_by = Zosia)
4. Mama widzi ze Zosia kupila mleko

**Scenariusz 4: Zosia edytuje swoj produkt**
1. Zosia dodala "Chipsy" ale chce zmienic na "Chipsy Lays"
2. Klika na produkt -> moze edytowac (bo sama dodala)
3. Zmienia nazwe -> zapisane
4. Zosia NIE moze edytowac produktow dodanych przez innych

---

## 10. Out of Scope

### Poza MVP (Phase 1+)

| Funkcja | Powod wylaczenia | Planowana faza |
|---------|-----------------|----------------|
| Offline cache | Wymaga dodatkowej architektury | Phase 1 |
| Bills Tracker | Zbyt duzy scope na MVP | Phase 1 |
| Tasks (pelna wersja) | Tylko preview w MVP | Phase 1 |
| Conflict resolution | Wymaga merge logic | Phase 1 |
| Export danych | Tylko Premium | Phase 1 |
| Real-time sync | 10 min refresh wystarczy na MVP | Phase 2 |
| Expenses tracking | Zlozony modul | Phase 2 |
| BLIK payments | Integracja platnicza | Phase 2 |
| Meal Planning | Nowy modul | Phase 3 |
| Family Calendar | Nowy modul | Phase 3 |
| AI suggestions | Wymaga ML | Phase 3 |
| Native mobile app | Dodatkowa platforma | Phase 3+ |

### Calkowicie Poza Scope

| Funkcja | Powod |
|---------|-------|
| Sledzenie lokalizacji | Prywatnosc, zbyt zlozone |
| Wiadomosci rodzinne (chat) | Konkurencja z WhatsApp |
| Gamifikacja | Odwraca uwage od core value |
| Social features | Nie jest to social app |
| Multi-household | 1 user = 1 household |

---

## 11. Technical Requirements

### Wymagania Funkcjonalne (FR)

| ID | Wymaganie | Priorytet | Traces To |
|----|-----------|-----------|-----------|
| FR-01 | Rejestracja email z weryfikacja | Must Have | US-01, goal-1 |
| FR-02 | Google OAuth login | Must Have | US-02, goal-4 |
| FR-03 | Account linking (email + OAuth) | Must Have | US-01, US-02, user-need-2 |
| FR-04 | CRUD gospodarstwa domowego | Must Have | US-03, US-04, US-05 |
| FR-05 | System zaproszen QR/kod | Must Have | US-04, US-05 |
| FR-06 | System rol (Admin/Member/Child) | Must Have | US-06 |
| FR-07 | CRUD list zakupow | Must Have | US-08 |
| FR-08 | CRUD produktow z kategoriami | Must Have | US-09, US-10 |
| FR-09 | Drag & drop sortowanie | Must Have | US-11 |
| FR-10 | Checkoff z sync | Must Have | US-12, US-13 |
| FR-11 | Push notifications (basic) | Should Have | US-15 |
| FR-12 | Tasks CRUD (preview) | Should Have | US-16 |
| FR-13 | Dark mode toggle | Should Have | US-17 |
| FR-14 | i18n PL/EN | Should Have | US-18 |

### Wymagania Niefunkcjonalne (NFR)

| ID | Kategoria | Wymaganie | Target |
|----|-----------|-----------|--------|
| NFR-01 | Performance | Time to Interactive | < 3s na 4G |
| NFR-02 | Performance | Lighthouse score | >= 90 |
| NFR-03 | Availability | Uptime | >= 99% |
| NFR-04 | Security | Auth token expiry | 7 dni |
| NFR-05 | Security | HTTPS only | 100% |
| NFR-06 | Security | Row Level Security | Wszystkie tabele |
| NFR-07 | Usability | Mobile-first responsive | 320px - 1920px |
| NFR-08 | Usability | Touch targets | >= 44px |
| NFR-09 | Sync | Refresh interval | 10 minut |
| NFR-10 | Sync | Manual refresh | < 2s |

---

## 12. UI/UX Requirements

### Design Principles
1. **Mobile-first** - projektowanie od malych ekranow
2. **Thumb-friendly** - wazne akcje w zasiegu kciuka
3. **Polish localization** - wszystkie teksty po polsku i angielsku wybor w settings
4. **Dark mode** - rownoczesne wsparcie jasnego i ciemnego motywu

### Key Screens (MVP)
1. **Onboarding** - Rejestracja / Logowanie
2. **Household Setup** - Tworzenie/Dolaczanie do gospodarstwa
3. **Dashboard** - Glowny ekran z nawigacja
4. **Shopping Lists** - Lista list zakupow
5. **Shopping List Detail** - Produkty + checkoff
6. **Tasks Preview** - Lista zadan
7. **Settings** - Profil, motyw, jezyk

### Accessibility
- [ ] Kontrast tekstu >= 4.5:1
- [ ] Focus states dla klawiatury
- [ ] Alt text dla obrazow
- [ ] Semantic HTML

### Brand & Tone
- **Nazwa:** HomeOS
- **Ton:** Profesjonalny ale przyjazny
- **Kolory:** Do ustalenia z UX Designer
- **Typografia:** System fonts (wydajnosc)

---

## 13. Dependencies

| Zaleznosc | Typ | Owner | Status | Ryzyko |
|-----------|-----|-------|--------|--------|
| Supabase (auth, DB) | External | Supabase | Dostepny | L |
| Vercel (hosting) | External | Vercel | Dostepny | L |
| Google OAuth | External | Google | Dostepny | L |
| Next.js 14+ | External | Vercel | Dostepny | L |
| Web Push API | External | Browser | Dostepny | M |

---

## 14. Risks & Mitigations

| Ryzyko | Impact | Probability | Mitygacja |
|--------|--------|-------------|-----------|
| 3 tygodnie za krotko | H | M | Scope MVP minimalny, Tasks tylko preview |
| Konkurencja (Cozi) | M | M | Nizsza cena, polski rynek, niezawodnosc |
| Push notifications zawodne | M | H | Testowac wczesnie, backup: email |
| Brak uzytkownikow | H | M | Beta testers z rodziny/znajomych |
| Supabase outage | H | L | Monitoring, graceful degradation |
| Google OAuth rejection | M | L | Email auth jako fallback |
| RODO compliance | H | M | Polityka prywatnosci, consent, data deletion |

---

## 15. Timeline

| Milestone | Data | Zaleznosci |
|-----------|------|------------|
| PRD Approval | 2025-12-09 | - |
| Architecture Design | 2025-12-10 | PRD |
| UX Wireframes | 2025-12-11 | PRD |
| Tydzien 1 Complete | 2025-12-16 | Architecture |
| Tydzien 2 Complete | 2025-12-23 | Tydzien 1 |
| MVP Complete | 2025-12-30 | Tydzien 2 |
| Beta Launch | 2025-12-30 | MVP |
| Feedback Collection | 2025-01-06 | Beta Launch |

---

## 16. Assumptions

| Zalozenie | Impact jesli bledne | Plan walidacji |
|-----------|---------------------|----------------|
| Polskie rodziny chca jednej aplikacji | Pivotujemy na inny rynek | Beta feedback |
| 8 PLN/msc akceptowalne | Testujemy inne ceny | A/B testing w Phase 1 |
| 10 min sync wystarczy | Wdrazamy real-time wczesniej | User interviews |
| PWA wystarczy (bez native app) | Budujemy native | User feedback |
| Supabase free tier wystarczy na start | Upgrade tier | Monitoring usage |

---

## 17. Traceability Matrix

| Requirement | Type | Priority | Traces To | Status |
|-------------|------|----------|-----------|--------|
| FR-01 | Functional | Must | goal-1, goal-4, US-01 | Draft |
| FR-02 | Functional | Must | goal-4, US-02 | Draft |
| FR-03 | Functional | Must | user-need-2, US-01, US-02 | Draft |
| FR-04 | Functional | Must | goal-1, US-03/04/05 | Draft |
| FR-05 | Functional | Must | goal-1, user-need-3, US-04/05 | Draft |
| FR-06 | Functional | Must | goal-1, user-need-4, US-06 | Draft |
| FR-07 | Functional | Must | goal-1, user-need-5, US-08 | Draft |
| FR-08 | Functional | Must | goal-1, user-need-5, user-need-6, US-09/10 | Draft |
| FR-09 | Functional | Must | user-need-6, US-11 | Draft |
| FR-10 | Functional | Must | goal-1, user-need-3, US-12/13 | Draft |
| FR-11 | Functional | Should | user-need-8, US-15 | Draft |
| FR-12 | Functional | Should | goal-1, user-need-9, US-16 | Draft |
| FR-13 | Functional | Should | user-need-10, US-17 | Draft |
| FR-14 | Functional | Should | user-need-11, US-18 | Draft |
| NFR-01 | Performance | Must | goal-tech-1 | Draft |
| NFR-02 | Performance | Must | goal-tech-1 | Draft |
| NFR-03 | Availability | Must | goal-tech-2 | Draft |
| NFR-04 | Security | Must | goal-tech-3 | Draft |
| NFR-05 | Security | Must | goal-tech-3 | Draft |
| NFR-06 | Security | Must | goal-tech-3 | Draft |

---

## 18. Open Questions

- [ ] Dokladna paleta kolorow i branding (wymaga UX Designer)
- [ ] Polityka RODO - kto przygotuje dokumenty?

### Push Notifications Scope (MVP)

**DECYZJA:** Basic push notifications w MVP oznacza:
- Notyfikacje tekstowe (text-only, bez rich media)
- Typy notyfikacji:
  - Nowy produkt dodany do listy
  - Produkt przypisany do uzytkownika
  - Nowy czlonek dolaczyl do gospodarstwa
- Platforma: Web Push API (przeglarkowe)
- Granularna kontrola: mozliwosc wylaczenia per typ w ustawieniach
- Nie obejmuje: rich notifications, obrazki, dzialania inline

**Implementacja pelniejsza w Phase 1** (real-time sync, reakcje na powiadomienia)

---

## 19. Updates Log

> **Auto-updated by FEATURE-FLOW** - tracks all changes after initial PRD approval

| Date | Feature | Phase | Type | Description | Impact |
|------|---------|-------|------|-------------|--------|
| - | - | - | - | - | - |

---

## Appendix

### Discovery Reference
- @docs/0-DISCOVERY/PROJECT-UNDERSTANDING.md

### Market Analysis
- @docs/1-BASELINE/research/market-analysis.md

### Related Documents
- Architecture: @docs/3-ARCHITECTURE/
- UX Design: @docs/1-BASELINE/ux/
- Epics & Stories: @docs/2-MANAGEMENT/

---

## Changelog

### v1.1 (2025-12-09)

**CRITICAL Fixes:**
1. **Goals Definition** - Dodano nowa sekcje (sekcja 4) z formalna definicja celow:
   - goal-1: Walidacja produktu (20 uzytkownikow MVP)
   - goal-2: User satisfaction (NPS > 30)
   - goal-3: Retention (40% monthly active)
   - goal-4: Activation (60% onboarding completion)
   - goal-tech-1/2/3: Cele techniczne

2. **User Needs Definition** - Dodano nowa sekcje (sekcja 5) z 11 zdefiniowanymi potrzebami uzytkownikow (user-need-1 do user-need-11)

3. **Pricing Consistency** - Dodano nowa sekcje (sekcja 7) z ujednoliconym modelem cenowym:
   - PLN jako primary: ~8 PLN/msc, ~80 PLN/rok
   - USD equivalent: ~$2/msc, ~$20/rok
   - Zsynchronizowano z market-analysis.md

**MAJOR Fixes:**
4. **Role Assignment (US-05)** - Zmieniono logike:
   - Admin PRZYPISUJE role przy akceptacji (nie user wybiera)
   - Zaproszony widzi ekran oczekiwania
   - Zaktualizowano Acceptance Criteria

5. **Account Linking** - Dodano scenariusz do US-01 i US-02:
   - Obsluga przypadku gdy email juz istnieje z inna metoda auth
   - Mozliwosc laczenia kont

6. **Child Permissions Matrix** - Dodano nowa sekcje (sekcja 9) z pelna macierza uprawnien dla rol Admin/Member/Child

7. **Free Tier Limits** - Zdefiniowano w sekcji Pricing:
   - Max 12 list zakupow
   - Max 50 produktow per lista
   - Max 10 czlonkow gospodarstwa

**MINOR Fixes:**
8. **Appendix Update** - Usunieto "(TBD)" z odniesen do dokumentow

9. **Traceability Matrix** - Zaktualizowano o nowe wymagania i poprawione traces

10. **FR Numbering** - Dodano FR-03 (Account linking), przeindeksowano pozostale

---

**Document Version:** 1.1
**Last Updated:** 2025-12-09
**Author:** PM Agent (John)
**Status:** Draft - Awaiting Review
