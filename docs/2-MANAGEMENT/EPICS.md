# HomeOS - Epiki MVP

**Wersja:** 1.0
**Data:** 2025-12-09
**PRD Ref:** @docs/1-BASELINE/PRD.md
**Architecture Ref:** @docs/3-ARCHITECTURE/ARCHITECTURE.md

---

## Podsumowanie MVP

| Epic | Nazwa | Tydzien | Priorytet | Stories | Status |
|------|-------|---------|-----------|---------|--------|
| E1 | Fundament (Auth + Household) | 1 | Must Have | 10 | Draft |
| E2 | Lista Zakupow - Core | 2 (start) | Must Have | 8 | Draft |
| E3 | Lista Zakupow - Advanced | 2 (koniec) | Should Have | 6 | Draft |
| E4 | Tasks Preview + Settings | 3 | Should Have | 6 | Draft |

**Razem:** 30 stories dla MVP (3 tygodnie)

---

## Mapa Zaleznosci Epikow

```
E1: Fundament ─────────────────────────────────────────────┐
    (Auth + Household)                                     │
         │                                                 │
         ├──────────────────────────────────────────────┐  │
         │                                              │  │
         v                                              v  │
E2: Lista Zakupow - Core                    E4: Tasks + Settings
    (CRUD listy + produkty)                     (depends on E1)
         │                                              │
         v                                              │
E3: Lista Zakupow - Advanced ───────────────────────────┘
    (sortowanie, sync, przypisania)
```

---

## Epic 1: Fundament (Auth + Household)

**Cel:** Uzytkownik moze sie zarejestrowac, zalogowac i utworzyc/dolaczyc do gospodarstwa domowego.

**Tydzien:** 1
**Priorytet:** Must Have
**Traces to:** US-01, US-02, US-03, US-04, US-05, US-06, US-06a, US-07

### Stories

| ID | Tytul | Complexity | Priorytet |
|----|-------|------------|-----------|
| 1-1 | Setup projektu Next.js + Supabase | M | Must Have |
| 1-2 | Rejestracja Email z weryfikacja | M | Must Have |
| 1-3 | Logowanie Google OAuth | M | Must Have |
| 1-4 | Account Linking (Email + OAuth) | M | Must Have |
| 1-5 | Tworzenie Gospodarstwa Domowego | S | Must Have |
| 1-6 | Generowanie i wyswietlanie QR/kodu zaproszenia | M | Must Have |
| 1-7 | Dolaczanie do Gospodarstwa (kod/QR) | M | Must Have |
| 1-8 | Zarzadzanie Rolami (Admin Panel) | M | Should Have |
| 1-9 | Rejestracja Dziecka (Child Account) | M | Must Have |
| 1-10 | Dashboard (Placeholder) | S | Must Have |

### Acceptance Criteria (Epic Level)

- [ ] Nowy uzytkownik moze sie zarejestrowac przez email lub Google
- [ ] Uzytkownik moze utworzyc gospodarstwo domowe
- [ ] Admin moze zapraszac czlonkow przez QR lub kod
- [ ] Zaproszony moze dolaczyc do gospodarstwa
- [ ] Admin moze tworzyc konta dla dzieci
- [ ] Dashboard wyswietla nawigacje do modulow

### Technical Notes

- Supabase Auth dla email + OAuth
- Row Level Security (RLS) dla wszystkich tabel
- Next.js App Router z Server Components
- Middleware dla protected routes

### Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| OAuth config zlozony | M | Dokumentacja Supabase, testowanie wczesnie |
| QR scanning na mobile | M | Fallback do kodu tekstowego |

---

## Epic 2: Lista Zakupow - Core

**Cel:** Uzytkownik moze tworzyc listy zakupow i dodawac/odhaczac produkty.

**Tydzien:** 2 (poczatek)
**Priorytet:** Must Have
**Traces to:** US-08, US-09, US-10, US-12
**Depends on:** Epic 1

### Stories

| ID | Tytul | Complexity | Priorytet |
|----|-------|------------|-----------|
| 2-1 | Tworzenie Listy Zakupow | S | Must Have |
| 2-2 | Edycja i usuwanie Listy | S | Must Have |
| 2-3 | Dodawanie Produktow | M | Must Have |
| 2-4 | Edycja Produktow | S | Must Have |
| 2-5 | Usuwanie Produktow | S | Must Have |
| 2-6 | Odhaczanie Produktow | S | Must Have |
| 2-7 | Kategorie Produktow (predefiniowane) | M | Must Have |
| 2-8 | Widok Listy Szczegolowej | M | Must Have |

### Acceptance Criteria (Epic Level)

- [ ] Admin/Member moze utworzyc liste zakupow
- [ ] Kazdy czlonek moze dodawac produkty
- [ ] Produkty maja kategorie
- [ ] Produkty mozna odhaczac jako kupione
- [ ] Odhaczyony produkt przenosi sie na dol listy

### Technical Notes

- Server Actions dla CRUD
- Optimistic UI dla odhaczania
- Child moze dodawac, ale NIE usuwac produktow

### Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| RLS complexity | M | Testy jednostkowe dla policies |

---

## Epic 3: Lista Zakupow - Advanced

**Cel:** Zaawansowane funkcje listy: sortowanie, sync, przypisania.

**Tydzien:** 2 (koniec)
**Priorytet:** Should Have
**Traces to:** US-11, US-13, US-14, US-15
**Depends on:** Epic 2

### Stories

| ID | Tytul | Complexity | Priorytet |
|----|-------|------------|-----------|
| 3-1 | Sortowanie wg kategorii | S | Must Have |
| 3-2 | Drag & Drop reczne sortowanie | M | Must Have |
| 3-3 | Auto-refresh co 10 minut | S | Must Have |
| 3-4 | Manual refresh + timestamp | S | Must Have |
| 3-5 | Przypisywanie produktow do osob | M | Should Have |
| 3-6 | Push Notifications (basic) | L | Should Have |

### Acceptance Criteria (Epic Level)

- [ ] Lista sortuje sie automatycznie wg kategorii
- [ ] Uzytkownik moze recznie przestawiac produkty (drag & drop)
- [ ] Lista odswirza sie automatycznie co 10 minut
- [ ] Przycisk "Odswiez" pokazuje timestamp ostatniej synchronizacji
- [ ] Admin/Member moze przypisac produkt do osoby
- [ ] Uzytkownik otrzymuje powiadomienie push o nowym produkcie

### Technical Notes

- dnd-kit dla drag & drop
- useAutoRefresh hook dla 10 min sync
- Web Push API dla powiadomien
- Service Worker dla PWA

### Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Push reliability | H | Email fallback w Phase 1 |
| dnd-kit mobile issues | M | Testowanie na urzadzeniach |

---

## Epic 4: Tasks Preview + Settings

**Cel:** Preview modulu zadan i ustawienia uzytkownika.

**Tydzien:** 3
**Priorytet:** Should Have
**Traces to:** US-16, US-17, US-18
**Depends on:** Epic 1

### Stories

| ID | Tytul | Complexity | Priorytet |
|----|-------|------------|-----------|
| 4-1 | Lista zadan (CRUD) | M | Should Have |
| 4-2 | Przypisywanie zadan do osob | S | Should Have |
| 4-3 | Odhaczanie zadan | S | Should Have |
| 4-4 | Dark Mode toggle | M | Should Have |
| 4-5 | Wybor jezyka PL/EN | M | Should Have |
| 4-6 | Strona ustawien | S | Should Have |

### Acceptance Criteria (Epic Level)

- [ ] Uzytkownik widzi modul Tasks z oznaczeniem "Preview"
- [ ] Mozna tworzyc, edytowac i odhaczac zadania
- [ ] Toggle Dark Mode dziala natychmiast
- [ ] Zmiana jezyka przeladowuje teksty
- [ ] Ustawienia zapisuja sie w profilu uzytkownika

### Technical Notes

- next-themes dla dark mode
- next-intl dla i18n
- user_settings tabela w Supabase
- Tasks to preview - nie wymaga pelnej funkcjonalnosci

### Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| i18n complexity | M | Tylko 2 jezyki, proste teksty |

---

## Traceability Matrix: PRD User Stories -> Epiki

| PRD US | Nazwa | Epic | Stories |
|--------|-------|------|---------|
| US-01 | Rejestracja Email | E1 | 1-2 |
| US-02 | Logowanie Google OAuth | E1 | 1-3, 1-4 |
| US-03 | Tworzenie Gospodarstwa | E1 | 1-5 |
| US-04 | Zapraszanie Czlonkow | E1 | 1-6 |
| US-05 | Dolaczanie do Gospodarstwa | E1 | 1-7 |
| US-06 | Zarzadzanie Rolami | E1 | 1-8 |
| US-06a | Rejestracja Dziecka | E1 | 1-9 |
| US-07 | Dashboard | E1 | 1-10 |
| US-08 | Tworzenie List | E2 | 2-1, 2-2 |
| US-09 | Dodawanie Produktow | E2 | 2-3, 2-4, 2-5 |
| US-10 | Kategorie Produktow | E2 | 2-7 |
| US-11 | Sortowanie Drag & Drop | E3 | 3-1, 3-2 |
| US-12 | Odhaczanie Produktow | E2 | 2-6 |
| US-13 | Synchronizacja Multi-User | E3 | 3-3, 3-4 |
| US-14 | Przypisywanie do Osob | E3 | 3-5 |
| US-15 | Push Notifications | E3 | 3-6 |
| US-16 | Tasks Preview | E4 | 4-1, 4-2, 4-3 |
| US-17 | Dark Mode | E4 | 4-4 |
| US-18 | Jezyk PL/EN | E4 | 4-5 |

---

## Traceability Matrix: FR -> Epiki

| FR | Nazwa | Epic | Status |
|----|-------|------|--------|
| FR-01 | Email Auth | E1 | Draft |
| FR-02 | Google OAuth | E1 | Draft |
| FR-03 | Account Linking | E1 | Draft |
| FR-04 | Household CRUD | E1 | Draft |
| FR-05 | Invite System | E1 | Draft |
| FR-06 | Role System | E1 | Draft |
| FR-07 | Shopping Lists CRUD | E2 | Draft |
| FR-08 | Items + Categories | E2 | Draft |
| FR-09 | Drag & Drop | E3 | Draft |
| FR-10 | Checkoff + Sync | E2, E3 | Draft |
| FR-11 | Push Notifications | E3 | Draft |
| FR-12 | Tasks Preview | E4 | Draft |
| FR-13 | Dark Mode | E4 | Draft |
| FR-14 | i18n | E4 | Draft |

---

## Strategia Wdrozenia

### Tydzien 1: Epic 1 (Fundament)
- **Dni 1-2:** Setup projektu, Supabase, Auth (1-1, 1-2, 1-3)
- **Dni 3-4:** Account linking, Household (1-4, 1-5, 1-6)
- **Dni 5-7:** Join flow, Child accounts, Dashboard (1-7, 1-8, 1-9, 1-10)

### Tydzien 2: Epic 2 + 3 (Lista Zakupow)
- **Dni 1-3:** CRUD list i produktow (2-1 do 2-8)
- **Dni 4-5:** Sortowanie, Sync (3-1 do 3-4)
- **Dni 6-7:** Przypisania, Push (3-5, 3-6)

### Tydzien 3: Epic 4 (Tasks + Settings)
- **Dni 1-3:** Tasks Preview (4-1, 4-2, 4-3)
- **Dni 4-5:** Dark Mode, i18n (4-4, 4-5)
- **Dni 6-7:** Polish, QA, Beta launch (4-6)

---

## Changelog

### v1.0 (2025-12-09)
- Initial epic breakdown
- 30 stories dla MVP
- Traceability matrix complete

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Author:** Architect Agent
**Status:** Draft
