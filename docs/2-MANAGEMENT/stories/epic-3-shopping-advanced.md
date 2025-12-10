# Epic 3: Lista Zakupow - Advanced

**Epic ID:** E3
**Tydzien:** 2 (koniec)
**Priorytet:** Should Have
**Status:** Draft

**PRD Traces:** US-11, US-13, US-14, US-15
**FR Traces:** FR-09, FR-10 (partial), FR-11
**Depends on:** Epic 2

---

## Podsumowanie

| Story | Tytul | Complexity | Priorytet | Status |
|-------|-------|------------|-----------|--------|
| 3-1 | Sortowanie wg kategorii | S | Must Have | Draft |
| 3-2 | Drag & Drop reczne sortowanie | M | Must Have | Draft |
| 3-3 | Auto-refresh co 10 minut | S | Must Have | Draft |
| 3-4 | Manual refresh + timestamp | S | Must Have | Draft |
| 3-5 | Przypisywanie produktow do osob | M | Should Have | Draft |
| 3-6 | Push Notifications (basic) | L | Should Have | Draft |

---

## Story 3-1: Sortowanie wg kategorii

### User Story
Jako **uzytkownik**
Chce **sortowac liste automatycznie wg kategorii**
Zeby **produkty byly pogrupowane jak w sklepie**

### Complexity: S (Small)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Domyslne sortowanie: wg kategorii (kolejnosc z DB)
- [ ] AC2: Produkty w kategorii posortowane alfabetycznie
- [ ] AC3: Naglowki kategorii widoczne (opcjonalnie)
- [ ] AC4: Odhaczyane produkty na koncu (niezaleznie od kategorii)
- [ ] AC5: Przelacznik "Sortuj wg kategorii" / "Wlasna kolejnosc"

### Technical Notes
- Client-side sorting (po fetchcie)
- Zustand store dla preferencji sortowania
- Kategorie maja `sort_order` w DB
- Memoizacja sortowania (performance)

### Dependencies
- Story 2-8 (Widok Listy Szczegolowej)
- Story 2-7 (Kategorie)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Sortowanie dziala plynnie
- [ ] Preferencja zapisywana lokalnie
- [ ] Code review zaliczone

---

## Story 3-2: Drag & Drop reczne sortowanie

### User Story
Jako **uzytkownik**
Chce **recznie przestawiac produkty drag & drop**
Zeby **dopasowac liste do mojej trasy w sklepie**

### Complexity: M (Medium)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Ikona "uchwytu" (grip) przy kazdym produkcie
- [ ] AC2: Przeciaganie zmienia kolejnosc na liscie
- [ ] AC3: Plynna animacja podczas przeciagania
- [ ] AC4: Nowa kolejnosc zapisywana w DB (sort_order)
- [ ] AC5: Dziala na touch devices (mobile)
- [ ] AC6: Odhaczyane produkty nie moga byc przeciagane

### Technical Notes
- Biblioteka: dnd-kit (accessible, performant)
- Server Action: `updateItemsOrder()`
- Batch update dla wydajnosci
- Debounce zapisywania (500ms)

### Dependencies
- Story 3-1 (Sortowanie wg kategorii)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Testy na mobile (touch)
- [ ] Animacje plynne
- [ ] Code review zaliczone

---

## Story 3-3: Auto-refresh co 10 minut

### User Story
Jako **czlonek rodziny**
Chce **widziec zmiany innych osob automatycznie**
Zeby **nie kupowac tego samego produktu**

### Complexity: S (Small)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Lista odswierza sie automatycznie co 10 minut
- [ ] AC2: Refresh dziala w tle (bez reload strony)
- [ ] AC3: Nowe/zmienione produkty pojawiaja sie bez utraty stanu UI
- [ ] AC4: Refresh nie przerywa aktywnej edycji produktu
- [ ] AC5: Refresh pauzuje gdy tab nieaktywny

### Technical Notes
- Custom hook: `useAutoRefresh(queryFn, intervalMs)`
- setInterval z cleanup
- Page Visibility API dla pauzy
- Merge state strategy (nie nadpisuj lokalnych zmian)

### Dependencies
- Story 2-8 (Widok Listy Szczegolowej)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Testy: refresh nie traci lokalnego state
- [ ] Page visibility dziala
- [ ] Code review zaliczone

---

## Story 3-4: Manual refresh + timestamp

### User Story
Jako **uzytkownik**
Chce **recznie odswizyc liste i widziec kiedy byla ostatnia synchronizacja**
Zeby **miec pewnosc ze dane sa aktualne**

### Complexity: S (Small)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Przycisk "Odswiez" (ikona refresh) w naglowku listy
- [ ] AC2: Klikniecie pobiera najnowsze dane
- [ ] AC3: Wyswietlanie "Ostatnia sync: X minut temu"
- [ ] AC4: Format czasu: "teraz", "1 min temu", "5 min temu", etc.
- [ ] AC5: Loading state podczas odswiezania (spinner)
- [ ] AC6: Toast "Lista zaktualizowana" po refresh

### Technical Notes
- Hook: `useAutoRefresh` z `manualRefresh()`
- Date formatting: relative time (np. date-fns)
- Zustand store dla lastRefresh timestamp
- Optimistic loading state

### Dependencies
- Story 3-3 (Auto-refresh)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Format czasu po polsku
- [ ] Loading state dziala
- [ ] Code review zaliczone

---

## Story 3-5: Przypisywanie produktow do osob

### User Story
Jako **Admin lub Member**
Chce **przypisac produkt do konkretnej osoby**
Zeby **wiedziec kto ma co kupic**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Dropdown z lista czlonkow gospodarstwa
- [ ] AC2: Mozliwosc wyboru "Wszyscy" (brak przypisania)
- [ ] AC3: Avatar/inicjaly przypisanej osoby przy produkcie
- [ ] AC4: Filtr: "Wszystkie" / "Moje" / "Nieprzypisane"
- [ ] AC5: Child NIE moze przypisywac produktow
- [ ] AC6: Powiadomienie dla przypisanej osoby (jesli wlaczone)

### Technical Notes
- Server Action: `assignShoppingItem()`
- Field: `assigned_to` w `shopping_list_items`
- Fetch czlonkow z `home_members`
- Trigger notyfikacji przy przypisaniu

### Dependencies
- Story 2-4 (Edycja Produktow)
- Story 1-8 (Zarzadzanie Rolami - lista czlonkow)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Filtrowanie dziala
- [ ] Avatar wyswietla sie poprawnie
- [ ] Code review zaliczone

---

## Story 3-6: Push Notifications (basic)

### User Story
Jako **uzytkownik**
Chce **otrzymywac powiadomienia o zmianach**
Zeby **nie przegapic waznych aktualizacji listy**

### Complexity: L (Large)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Prompt o zgode na powiadomienia (przy pierwszym uzyciu)
- [ ] AC2: Powiadomienie gdy ktos doda produkt do listy
- [ ] AC3: Powiadomienie gdy zostane przypisany do produktu
- [ ] AC4: Powiadomienie gdy nowy czlonek dolaczyl do gospodarstwa
- [ ] AC5: Mozliwosc wylaczenia per typ w ustawieniach
- [ ] AC6: Powiadomienia tylko tekst (bez obrazkow)

### Technical Notes
- Web Push API + Service Worker
- Tabela `push_subscriptions` dla endpointow
- VAPID keys w env
- Server-side: web-push library
- Typy: `new_item`, `assigned`, `new_member`

### Dependencies
- Story 3-5 (Przypisywanie - trigger dla `assigned`)
- Story 1-7 (Dolaczanie - trigger dla `new_member`)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Service Worker zarejestrowany
- [ ] Powiadomienia dostarczane (Chrome, Firefox)
- [ ] Ustawienia per typ dzialaja
- [ ] Code review zaliczone

---

## Diagram Zaleznosci Stories

```
Epic 2 (2-8 List Detail)
        |
        v
   3-1 (Sort by Category)
        |
        v
   3-2 (Drag & Drop)


Epic 2 (2-8 List Detail)
        |
        v
   3-3 (Auto-refresh)
        |
        v
   3-4 (Manual refresh)


Epic 2 (2-4 Edit Items)
        |
        v
   3-5 (Assign to Person)
        |
        v
   3-6 (Push Notifications)
        ^
        |
   1-7 (Join Home)
```

---

## Risk Assessment

| Story | Risk | Impact | Mitigation |
|-------|------|--------|------------|
| 3-2 | dnd-kit mobile issues | M | Test early on real devices |
| 3-3 | State conflicts during refresh | M | Merge strategy, lock during edit |
| 3-6 | Push unreliable on iOS Safari | H | Email fallback in Phase 1, clear UX |

---

## NFR Coverage

| NFR | Story | Implementation |
|-----|-------|----------------|
| NFR-09 (10 min sync) | 3-3 | Auto-refresh interval |
| NFR-10 (Manual refresh < 2s) | 3-4 | Optimized query |

---

## Changelog

### v1.0 (2025-12-09)
- Initial story breakdown
- 6 stories dla Epic 3

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Epic Status:** Draft
