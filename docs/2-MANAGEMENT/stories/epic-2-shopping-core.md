# Epic 2: Lista Zakupow - Core

**Epic ID:** E2
**Tydzien:** 2 (poczatek)
**Priorytet:** Must Have
**Status:** Draft

**PRD Traces:** US-08, US-09, US-10, US-12
**FR Traces:** FR-07, FR-08, FR-10 (partial)
**Depends on:** Epic 1

---

## Podsumowanie

| Story | Tytul | Complexity | Priorytet | Status |
|-------|-------|------------|-----------|--------|
| 2-1 | Tworzenie Listy Zakupow | S | Must Have | Draft |
| 2-2 | Edycja i usuwanie Listy | S | Must Have | Draft |
| 2-3 | Dodawanie Produktow | M | Must Have | Draft |
| 2-4 | Edycja Produktow | S | Must Have | Draft |
| 2-5 | Usuwanie Produktow | S | Must Have | Draft |
| 2-6 | Odhaczanie Produktow | S | Must Have | Draft |
| 2-7 | Kategorie Produktow (predefiniowane) | M | Must Have | Draft |
| 2-8 | Widok Listy Szczegolowej | M | Must Have | Draft |

---

## Story 2-1: Tworzenie Listy Zakupow

### User Story
Jako **czlonek gospodarstwa (Admin lub Member)**
Chce **utworzyc nowa liste zakupow**
Zeby **organizowac zakupy dla rodziny**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Przycisk "Nowa lista" na ekranie list zakupow
- [ ] AC2: Modal/formularz z polem nazwy (max 100 znakow)
- [ ] AC3: Walidacja: nazwa wymagana, min 1 znak
- [ ] AC4: Po utworzeniu: lista pojawia sie na liscie
- [ ] AC5: Child NIE widzi przycisku "Nowa lista"
- [ ] AC6: Toast "Lista utworzona"

### Technical Notes
- Route: `/shopping`
- Server Action: `createShoppingList()`
- RLS: tylko Admin/Member moze INSERT
- Optimistic UI: lista pojawia sie natychmiast

### Dependencies
- Story 1-10 (Dashboard)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] RLS policy dziala (Child nie moze tworzyc)
- [ ] Code review zaliczone

---

## Story 2-2: Edycja i usuwanie Listy

### User Story
Jako **czlonek gospodarstwa (Admin lub Member)**
Chce **edytowac nazwe lub usunac liste**
Zeby **utrzymac porzadek w listach**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Menu kontekstowe (3 kropki) przy kazdej liscie
- [ ] AC2: Opcja "Edytuj" -> modal z nazwa
- [ ] AC3: Opcja "Usun" -> dialog potwierdzenia
- [ ] AC4: Po usunieciu: wszystkie produkty usuniete (cascade)
- [ ] AC5: Child NIE widzi opcji edycji/usuwania
- [ ] AC6: Toast "Lista zaktualizowana" / "Lista usunieta"

### Technical Notes
- Server Actions: `updateShoppingList()`, `deleteShoppingList()`
- Cascade delete w DB (ON DELETE CASCADE)
- Dialog potwierdzenia przed usunieciem

### Dependencies
- Story 2-1 (Tworzenie Listy)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Cascade delete dziala
- [ ] Code review zaliczone

---

## Story 2-3: Dodawanie Produktow

### User Story
Jako **czlonek gospodarstwa**
Chce **dodawac produkty do listy zakupow**
Zeby **miec kompletna liste zakupow**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Pole tekstowe "Dodaj produkt" na gorze listy
- [ ] AC2: Enter lub przycisk "+" dodaje produkt
- [ ] AC3: Opcjonalnie: wybor kategorii (dropdown)
- [ ] AC4: Opcjonalnie: ilosc i jednostka
- [ ] AC5: Produkt pojawia sie na liscie natychmiast (optimistic)
- [ ] AC6: Child MOZE dodawac produkty
- [ ] AC7: Walidacja: nazwa min 1 znak, max 200 znakow

### Technical Notes
- Server Action: `addShoppingItem()`
- Optimistic UI z revalidation
- Domyslna kategoria: "Inne"
- `created_by` zapisywane w DB

### Dependencies
- Story 2-1 (Tworzenie Listy)
- Story 2-7 (Kategorie)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Child moze dodawac
- [ ] Optimistic UI dziala
- [ ] Code review zaliczone

---

## Story 2-4: Edycja Produktow

### User Story
Jako **czlonek gospodarstwa**
Chce **edytowac dodany produkt**
Zeby **poprawic bledy lub dodac szczegoly**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Klikniecie w produkt otwiera tryb edycji
- [ ] AC2: Mozna zmienic: nazwe, kategorie, ilosc, jednostke
- [ ] AC3: Przycisk "Zapisz" lub Enter zapisuje zmiany
- [ ] AC4: Child moze edytowac TYLKO swoje produkty
- [ ] AC5: Admin/Member moze edytowac wszystkie

### Technical Notes
- Server Action: `updateShoppingItem()`
- RLS: Child - WHERE created_by = auth.uid()
- Inline edit lub modal

### Dependencies
- Story 2-3 (Dodawanie Produktow)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Child permission dziala
- [ ] Code review zaliczone

---

## Story 2-5: Usuwanie Produktow

### User Story
Jako **czlonek gospodarstwa (Admin lub Member)**
Chce **usunac produkt z listy**
Zeby **usunac niepotrzebne pozycje**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Ikona kosza lub swipe-to-delete
- [ ] AC2: Klikniecie usuwa produkt natychmiast
- [ ] AC3: Toast "Produkt usuniety" z opcja "Cofnij" (5s)
- [ ] AC4: Child NIE moze usuwac produktow
- [ ] AC5: Child nie widzi ikony kosza

### Technical Notes
- Server Action: `deleteShoppingItem()`
- Soft delete lub undo pattern
- RLS: tylko Admin/Member

### Dependencies
- Story 2-3 (Dodawanie Produktow)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Undo dziala
- [ ] Child permission dziala
- [ ] Code review zaliczone

---

## Story 2-6: Odhaczanie Produktow

### User Story
Jako **osoba robiaca zakupy**
Chce **odhaczac kupione produkty**
Zeby **wiedziec co jeszcze kupic**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Checkbox przy kazdym produkcie
- [ ] AC2: Klikniecie zmienia stan is_purchased
- [ ] AC3: Odhaczyony produkt: przekreslony tekst
- [ ] AC4: Odhaczyony produkt przenosi sie na dol listy
- [ ] AC5: Mozliwosc "ododhaczenia" (klikniecie w checkbox)
- [ ] AC6: Przycisk "Usun kupione" usuwa wszystkie odhaczyane
- [ ] AC7: Zapis purchased_by i purchased_at
- [ ] AC8: Kazdy (w tym Child) moze odhaczac

### Technical Notes
- Server Action: `toggleShoppingItem()`
- Optimistic UI dla natychmiastowej reakcji
- Sortowanie: unchecked first, then checked
- `purchased_by` = current user

### Dependencies
- Story 2-3 (Dodawanie Produktow)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Animacja przesuwania na dol
- [ ] Optimistic UI dziala
- [ ] Code review zaliczone

---

## Story 2-7: Kategorie Produktow (predefiniowane)

### User Story
Jako **uzytkownik**
Chce **kategoryzowac produkty**
Zeby **latwiej je znajdowac w sklepie**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Dropdown z predefiniowanymi kategoriami przy dodawaniu/edycji
- [ ] AC2: Kategorie: Nabial, Warzywa, Owoce, Pieczywo, Mieso, Ryby, Napoje, Mrozonki, Slodycze, Chemia, Inne
- [ ] AC3: Ikona emoji dla kazdej kategorii
- [ ] AC4: Domyslna kategoria: "Inne"
- [ ] AC5: Produkty wyswietlane z ikona kategorii
- [ ] AC6: Kategorie ladowane z DB (seed data)

### Technical Notes
- Seed data w `categories` table (is_default = true)
- Ikony jako unicode emoji
- Server Component laduje kategorie
- Cache kategorii (rzadko sie zmieniaja)

### Dependencies
- Story 2-3 (Dodawanie Produktow)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Seed data w DB
- [ ] Ikony wyswietlaja sie poprawnie
- [ ] Code review zaliczone

---

## Story 2-8: Widok Listy Szczegolowej

### User Story
Jako **uzytkownik**
Chce **widziec szczegoly listy zakupow**
Zeby **miec przejrzysty widok produktow do kupienia**

### Complexity: M (Medium)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Route `/shopping/[listId]` wyswietla pojedyncza liste
- [ ] AC2: Naglowek z nazwa listy + liczba produktow
- [ ] AC3: Lista produktow pogrupowana wizualnie (unchecked / checked)
- [ ] AC4: Przy kazdym produkcie: ikona kategorii, nazwa, ilosc
- [ ] AC5: Wskaznik ostatniej synchronizacji (timestamp)
- [ ] AC6: Przycisk "Wstecz" do listy list
- [ ] AC7: Empty state: "Brak produktow. Dodaj pierwszy!"

### Technical Notes
- Server Component z fetchem produktow
- Client Component dla interaktywnosci (checkbox, edit)
- Skeleton loading dla UX
- Responsive: mobile-first

### Dependencies
- Story 2-1 (Tworzenie Listy)
- Story 2-3 (Dodawanie Produktow)
- Story 2-6 (Odhaczanie)
- Story 2-7 (Kategorie)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Empty state dziala
- [ ] Responsive design
- [ ] Code review zaliczone

---

## Diagram Zaleznosci Stories

```
Epic 1 (1-10 Dashboard)
        |
        v
   2-1 (Create List)
        |
        +---> 2-2 (Edit/Delete List)
        |
        v
   2-7 (Categories) ---+
        |              |
        v              v
   2-3 (Add Items) <---+
        |
        +---> 2-4 (Edit Items)
        |
        +---> 2-5 (Delete Items)
        |
        +---> 2-6 (Toggle Items)
        |
        v
   2-8 (List Detail View)
```

---

## Child Permissions Summary

| Action | Admin | Member | Child |
|--------|-------|--------|-------|
| Create list | Yes | Yes | NO |
| Edit list name | Yes | Yes | NO |
| Delete list | Yes | Yes | NO |
| Add items | Yes | Yes | YES |
| Edit items | Yes | Yes | Only own |
| Delete items | Yes | Yes | NO |
| Check off items | Yes | Yes | YES |

---

## Changelog

### v1.0 (2025-12-09)
- Initial story breakdown
- 8 stories dla Epic 2

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Epic Status:** Draft
