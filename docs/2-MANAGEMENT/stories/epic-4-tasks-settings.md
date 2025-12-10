# Epic 4: Tasks Preview + Settings

**Epic ID:** E4
**Tydzien:** 3
**Priorytet:** Should Have
**Status:** Draft

**PRD Traces:** US-16, US-17, US-18
**FR Traces:** FR-12, FR-13, FR-14
**Depends on:** Epic 1

---

## Podsumowanie

| Story | Tytul | Complexity | Priorytet | Status |
|-------|-------|------------|-----------|--------|
| 4-1 | Lista zadan (CRUD) | M | Should Have | Draft |
| 4-2 | Przypisywanie zadan do osob | S | Should Have | Draft |
| 4-3 | Odhaczanie zadan | S | Should Have | Draft |
| 4-4 | Dark Mode toggle | M | Should Have | Draft |
| 4-5 | Wybor jezyka PL/EN | M | Should Have | Draft |
| 4-6 | Strona ustawien | S | Should Have | Draft |

---

## Story 4-1: Lista zadan (CRUD)

### User Story
Jako **uzytkownik**
Chce **widziec i zarzadzac zadaniami domowymi**
Zeby **organizowac obowiazki rodzinne**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Route `/tasks` z lista zadan
- [ ] AC2: Badge "Preview" w nawigacji i na stronie
- [ ] AC3: Przycisk "Nowe zadanie" (Admin/Member only)
- [ ] AC4: Formularz: tytul (wymagany), opis (opcjonalny)
- [ ] AC5: Lista zadan z tytulem i statusem
- [ ] AC6: Edycja zadania przez klikniecie
- [ ] AC7: Usuwanie zadania (Admin/Member only)
- [ ] AC8: Empty state: "Brak zadan. Dodaj pierwsze!"

### Technical Notes
- Route: `/tasks`
- Tabela: `tasks`
- Server Actions: `createTask()`, `updateTask()`, `deleteTask()`
- RLS: Admin/Member dla tworzenia/usuwania
- "Preview" badge = informacja ze modul w rozwoju

### Dependencies
- Story 1-10 (Dashboard)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Badge "Preview" widoczny
- [ ] CRUD dziala
- [ ] Code review zaliczone

---

## Story 4-2: Przypisywanie zadan do osob

### User Story
Jako **Admin lub Member**
Chce **przypisac zadanie do czlonka rodziny**
Zeby **kazdy wiedzial za co odpowiada**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Dropdown z lista czlonkow przy tworzeniu/edycji zadania
- [ ] AC2: Mozliwosc wyboru "Nieprzypisane"
- [ ] AC3: Avatar/imie przypisanej osoby przy zadaniu
- [ ] AC4: Filtr: "Wszystkie" / "Moje" / "Nieprzypisane"
- [ ] AC5: Child NIE moze przypisywac zadan

### Technical Notes
- Field: `assigned_to` w `tasks`
- Fetch czlonkow z `home_members`
- Podobna logika jak w Story 3-5 (Shopping)

### Dependencies
- Story 4-1 (Lista zadan)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Filtrowanie dziala
- [ ] Code review zaliczone

---

## Story 4-3: Odhaczanie zadan

### User Story
Jako **czlonek rodziny**
Chce **oznaczyc zadanie jako wykonane**
Zeby **inni widzieli ze jest zrobione**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Checkbox przy kazdym zadaniu
- [ ] AC2: Klikniecie zmienia stan is_completed
- [ ] AC3: Wykonane zadanie: przekreslone, na dole listy
- [ ] AC4: Child moze odhaczac TYLKO swoje zadania
- [ ] AC5: Admin/Member moze odhaczac wszystkie
- [ ] AC6: Zapis completed_by i completed_at

### Technical Notes
- Server Action: `toggleTask()`
- RLS: Child WHERE assigned_to = auth.uid()
- Optimistic UI
- Sortowanie: uncompleted first

### Dependencies
- Story 4-1 (Lista zadan)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Child permission dziala
- [ ] Optimistic UI dziala
- [ ] Code review zaliczone

---

## Story 4-4: Dark Mode toggle

### User Story
Jako **uzytkownik**
Chce **przelaczac motyw jasny/ciemny**
Zeby **uzywac aplikacji wygodnie o kazdej porze**

### Complexity: M (Medium)
### Type: Frontend + Backend

### Acceptance Criteria
- [ ] AC1: Toggle w ustawieniach: "Jasny" / "Ciemny" / "Systemowy"
- [ ] AC2: Domyslnie: Systemowy (preferencja OS)
- [ ] AC3: Zmiana motywu natychmiast widoczna
- [ ] AC4: Plynna animacja przejscia (transition)
- [ ] AC5: Preferencja zapisywana w profilu uzytkownika
- [ ] AC6: Motyw ladowany przy starcie (bez flash)

### Technical Notes
- Biblioteka: next-themes
- Tabela: `user_settings.theme`
- Server Action: `updateUserSettings()`
- CSS: Tailwind dark: variant
- Script w head dla no-flash

### Dependencies
- Story 4-6 (Strona ustawien)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] No flash on reload
- [ ] Animacja dziala
- [ ] Code review zaliczone

---

## Story 4-5: Wybor jezyka PL/EN

### User Story
Jako **uzytkownik**
Chce **wybrac jezyk aplikacji**
Zeby **uzywac jej w preferowanym jezyku**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Dropdown w ustawieniach: "Polski" / "English"
- [ ] AC2: Domyslnie: Polski
- [ ] AC3: Automatyczne wykrywanie jezyka przegladarki (pierwsze uzycie)
- [ ] AC4: Zmiana jezyka przeladowuje teksty (bez reload)
- [ ] AC5: Wszystkie teksty UI przetlumaczone
- [ ] AC6: Preferencja zapisywana w profilu uzytkownika

### Technical Notes
- Biblioteka: next-intl
- Pliki: `messages/pl.json`, `messages/en.json`
- Tabela: `user_settings.language`
- Middleware dla locale detection
- Server/Client component separation

### Dependencies
- Story 4-6 (Strona ustawien)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Wszystkie teksty przetlumaczone
- [ ] Locale detection dziala
- [ ] Code review zaliczone

---

## Story 4-6: Strona ustawien

### User Story
Jako **uzytkownik**
Chce **miec centralne miejsce do zarzadzania ustawieniami**
Zeby **dostosowac aplikacje do swoich potrzeb**

### Complexity: S (Small)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Route `/settings` dostepny z nawigacji
- [ ] AC2: Sekcja "Profil": imie wyswietlane, avatar
- [ ] AC3: Sekcja "Wyglad": Dark Mode toggle (Story 4-4)
- [ ] AC4: Sekcja "Jezyk": wybor PL/EN (Story 4-5)
- [ ] AC5: Sekcja "Powiadomienia": toggle per typ (jesli push wlaczone)
- [ ] AC6: Link do "Zarzadzania czlonkami" (dla Admina)
- [ ] AC7: Przycisk "Wyloguj"
- [ ] AC8: Przycisk "Opusc gospodarstwo" (dla non-Admin)

### Technical Notes
- Route: `/settings`
- Server Component + Client Components dla interaktywnosci
- Fetch user_settings z DB
- Protected route

### Dependencies
- Story 1-10 (Dashboard)
- Story 4-4 (Dark Mode)
- Story 4-5 (Jezyk)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Wszystkie sekcje dzialaja
- [ ] Responsive design
- [ ] Code review zaliczone

---

## Diagram Zaleznosci Stories

```
Epic 1 (1-10 Dashboard)
        |
        +---> 4-1 (Tasks CRUD)
        |         |
        |         +---> 4-2 (Assign Tasks)
        |         |
        |         +---> 4-3 (Complete Tasks)
        |
        +---> 4-6 (Settings Page)
                  |
                  +---> 4-4 (Dark Mode)
                  |
                  +---> 4-5 (Language)
```

---

## Tasks Preview - Ograniczenia

Ten modul jest oznaczony jako "Preview" w MVP. Oznacza to:

1. **Pelna wersja w Phase 1** - termin, powtarzalnosc, przypomnienia
2. **MVP ograniczony do:**
   - CRUD zadan
   - Przypisywanie do osob
   - Odhaczanie
3. **Brak w MVP:**
   - Terminy wykonania (due_date) - pole istnieje, UI placeholder
   - Powtarzalne zadania
   - Powiadomienia o zadaniach
   - Szablony zadan

---

## i18n - Zakres tlumaczen

### Pliki do przetlumaczenia:

```
messages/
├── pl.json  # Polski (domyslny)
└── en.json  # English
```

### Kategorie tekstow:

| Kategoria | Przykady |
|-----------|----------|
| Auth | "Zaloguj sie", "Zarejestruj", "Zapomnialeslem hasla" |
| Navigation | "Lista zakupow", "Zadania", "Ustawienia" |
| Shopping | "Dodaj produkt", "Usun kupione", "Kategorie" |
| Tasks | "Nowe zadanie", "Wykonane", "Przypisz do" |
| Settings | "Motyw", "Jezyk", "Powiadomienia" |
| Errors | "Cos poszlo nie tak", "Brak polaczenia" |
| Common | "Zapisz", "Anuluj", "Usun", "Edytuj" |

### Estymacja: ~200 kluczy

---

## NFR Coverage

| NFR | Story | Implementation |
|-----|-------|----------------|
| NFR-07 (Mobile-first) | 4-6 | Responsive settings page |
| NFR-08 (Touch 44px) | All | Button/checkbox sizes |

---

## Changelog

### v1.0 (2025-12-09)
- Initial story breakdown
- 6 stories dla Epic 4

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Epic Status:** Draft
