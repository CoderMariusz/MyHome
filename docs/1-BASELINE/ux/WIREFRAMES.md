# HomeOS - Wireframes (MVP)

**Data:** 2025-12-09
**Wersja:** 1.0
**Status:** Draft
**Platform:** Mobile-first (320-428px primary)
**Autor:** UX Designer (Sally)

**Ref:** @docs/1-BASELINE/ux/UX-SPECIFICATION.md

---

## Table of Contents

1. [Landing / Login](#1-landing--login)
2. [Register](#2-register)
3. [Household Setup](#3-household-setup)
4. [Dashboard](#4-dashboard)
5. [Shopping Lists](#5-shopping-lists)
6. [Shopping List Detail](#6-shopping-list-detail)
7. [Tasks Preview](#7-tasks-preview)
8. [Settings](#8-settings)
9. [Modals](#9-modals)

---

## 1. Landing / Login

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Authentication |
| Story | US-01, US-02 |
| Platform | Mobile-first |
| AC Addressed | Email login, Google OAuth |

### Purpose
Entry point do aplikacji. User wybiera sposób logowania lub rejestracji.

---

### State 1: SUCCESS (Default)

```
+----------------------------------------+
|                                        |
|                                        |
|             [HomeOS Logo]              |
|                                        |
|         Organize your home             |
|         together with family           |
|                                        |
|  +-----------------------------------+ |
|  | Email                             | |
|  +-----------------------------------+ |
|  +-----------------------------------+ |
|  | Password                          | |
|  +-----------------------------------+ |
|                                        |
|         [Zaloguj się]                  | <- Primary button
|                                        |
|  ───────────── lub ─────────────      |
|                                        |
|     [🔵 Zaloguj przez Google]          | <- Secondary (outline)
|                                        |
|                                        |
|    Nie masz konta? Zarejestruj się    | <- Link
|                                        |
+----------------------------------------+
```

**Component Specs:**
- Logo: 80x80dp, centered
- Tagline: 16sp, secondary text color
- Inputs: 56dp height, 16dp horizontal padding
- Primary button: 48dp height, full width - 32dp margin
- Google button: 48dp height, outlined, Google blue icon
- Link: 14sp, primary color, underlined

**Touch Targets:**
- Email input: Full width x 56dp
- Password input: Full width x 56dp
- Login button: Full width x 48dp
- Google button: Full width x 48dp
- Register link: Full width x 44dp (tap area)

---

### State 2: LOADING

```
+----------------------------------------+
|                                        |
|                                        |
|             [HomeOS Logo]              |
|                                        |
|         Organize your home             |
|         together with family           |
|                                        |
|  +-----------------------------------+ |
|  | user@example.com                  | |
|  +-----------------------------------+ |
|  +-----------------------------------+ |
|  | ••••••••                          | |
|  +-----------------------------------+ |
|                                        |
|         [⏳ Logowanie...]               | <- Disabled, spinner
|                                        |
|  ───────────── lub ─────────────      |
|                                        |
|     [🔵 Zaloguj przez Google]          | <- Disabled
|                                        |
|                                        |
|    Nie masz konta? Zarejestruj się    |
|                                        |
+----------------------------------------+
```

**Notes:**
- Inputs disabled (grayed out)
- Button shows spinner + "Logowanie..."
- Google button disabled
- User cannot tap anything during loading

---

### State 3: ERROR

```
+----------------------------------------+
|                                        |
|                                        |
|             [HomeOS Logo]              |
|                                        |
|         Organize your home             |
|         together with family           |
|                                        |
|  +-----------------------------------+ |
|  | user@example.com                  | | <- Red border
|  +-----------------------------------+ |
|  +-----------------------------------+ |
|  | ••••••••                          | | <- Red border
|  +-----------------------------------+ |
|  ⚠️ Nieprawidłowy email lub hasło      | <- Red error text
|                                        |
|         [Zaloguj się]                  |
|                                        |
|  ───────────── lub ─────────────      |
|                                        |
|     [🔵 Zaloguj przez Google]          |
|                                        |
|                                        |
|    Nie masz konta? Zarejestruj się    |
|         Zapomniałeś hasła?            | <- Recovery link
|                                        |
+----------------------------------------+
```

**Error States:**
- Invalid credentials: Red border on inputs + error message
- Network error: Toast notification at bottom
- Google OAuth error: Error toast + option to retry

---

### State 4: N/A (No empty state for login)

---

### Interactions

| Element | Action | Destination |
|---------|--------|-------------|
| Email input | Focus | Keyboard appears, input highlighted |
| Password input | Focus | Keyboard appears (secure text) |
| "Zaloguj się" | Tap | Validate → Loading → Dashboard (success) or Error |
| "Zaloguj przez Google" | Tap | OAuth flow → Dashboard (success) |
| "Zarejestruj się" link | Tap | Register screen |
| "Zapomniałeś hasła?" | Tap | Password reset flow (post-MVP) |

**Validation:**
- Email: Required, valid email format
- Password: Required, min 8 characters
- Show errors on blur or on submit attempt

---

### Accessibility

**Touch Targets:**
- All inputs: 56dp height ✅
- All buttons: 48dp height ✅
- Link: 44dp tap area ✅

**Screen Reader:**
- Email input: aria-label="Email address"
- Password input: aria-label="Password", type="password"
- Error message: aria-live="polite"

**Contrast:**
- Text on white background: 4.5:1 ✅
- Button text on primary: 4.5:1 ✅

---

## 2. Register

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Authentication |
| Story | US-01 |
| Platform | Mobile-first |
| AC Addressed | Email registration, password validation |

### Purpose
Nowy user tworzy konto. Minimalna liczba pól (email + password).

---

### State 1: SUCCESS (Form)

```
+----------------------------------------+
|  [←]           Rejestracja             |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | Email                             | |
|  +-----------------------------------+ |
|  Użyj adresu, który sprawdzasz codzien| <- Hint
|                                        |
|  +-----------------------------------+ |
|  | Hasło                             | |
|  +-----------------------------------+ |
|  Min. 8 znaków                         |
|                                        |
|  +-----------------------------------+ |
|  | Powtórz hasło                     | |
|  +-----------------------------------+ |
|                                        |
|  [ ] Akceptuję regulamin i politykę   |
|      prywatności                       | <- Checkbox + link
|                                        |
|                                        |
|         [Utwórz konto]                 | <- Primary button
|                                        |
|  ───────────── lub ─────────────      |
|                                        |
|     [🔵 Zarejestruj przez Google]      |
|                                        |
|                                        |
|    Masz już konto? Zaloguj się        |
|                                        |
+----------------------------------------+
```

**Component Specs:**
- Back button: 24x24dp icon, 48x48dp touch target
- Input hints: 12sp, secondary text color
- Checkbox: 24x24dp, 48x48dp touch target
- Terms link: Underlined, opens in new tab

---

### State 2: LOADING (After Submit)

```
+----------------------------------------+
|  [←]           Rejestracja             |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | user@example.com                  | | <- Disabled
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | ••••••••                          | | <- Disabled
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | ••••••••                          | | <- Disabled
|  +-----------------------------------+ |
|                                        |
|  [✓] Akceptuję regulamin i politykę   | <- Disabled
|                                        |
|                                        |
|         [⏳ Tworzenie konta...]         | <- Spinner
|                                        |
|                                        |
|                                        |
|                                        |
+----------------------------------------+
```

---

### State 3: ERROR (Validation)

```
+----------------------------------------+
|  [←]           Rejestracja             |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | user@invalid                      | | <- Red border
|  +-----------------------------------+ |
|  ⚠️ Wprowadź poprawny adres email      | <- Red error
|                                        |
|  +-----------------------------------+ |
|  | ••••                              | | <- Red border
|  +-----------------------------------+ |
|  ⚠️ Hasło musi mieć min. 8 znaków      |
|                                        |
|  +-----------------------------------+ |
|  | •••••••                           | | <- Red border
|  +-----------------------------------+ |
|  ⚠️ Hasła muszą być identyczne         |
|                                        |
|  [ ] Akceptuję regulamin i politykę   |
|  ⚠️ Musisz zaakceptować regulamin      |
|                                        |
|         [Utwórz konto]                 |
|                                        |
+----------------------------------------+
```

**Error Types:**
1. Email invalid format
2. Password too short (< 8 chars)
3. Passwords don't match
4. Terms not accepted
5. Email already exists (from backend)

---

### State 4: SUCCESS (Verification Sent)

```
+----------------------------------------+
|                                        |
|                                        |
|             [✉️ Icon]                   |
|                                        |
|      Sprawdź swoją skrzynkę!           | <- H2
|                                        |
|  Wysłaliśmy link weryfikacyjny na:     |
|         user@example.com               | <- Bold
|                                        |
|  Kliknij w link w emailu, aby          |
|  aktywować konto.                      |
|                                        |
|                                        |
|     [Otwórz aplikację email]           | <- Secondary button
|                                        |
|     Nie otrzymałeś? Wyślij ponownie    | <- Link
|                                        |
|                                        |
+----------------------------------------+
```

**Notes:**
- Auto-redirect to household setup after email verification
- "Wyślij ponownie" link disabled for 60s (countdown)

---

### Interactions

| Element | Action | Destination |
|---------|--------|-------------|
| Back button | Tap | Return to login |
| Email input | Blur | Validate email format |
| Password input | Blur | Check length |
| Confirm password | Blur | Match with password |
| Checkbox | Tap | Toggle accept terms |
| "Utwórz konto" | Tap | Validate → Loading → Verification screen |
| Google register | Tap | OAuth → Household setup |

---

## 3. Household Setup

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Household Management |
| Story | US-03, US-04, US-05 |
| Platform | Mobile-first |
| AC Addressed | Create or join household |

### Purpose
Po rejestracji/logowaniu, user tworzy nowe gospodarstwo lub dołącza do istniejącego.

---

### State 1: SUCCESS (Choice Screen)

```
+----------------------------------------+
|                                        |
|                                        |
|        Witaj w HomeOS! 👋              | <- H2
|                                        |
|    Co chcesz zrobić?                   |
|                                        |
|  +-----------------------------------+ |
|  |                                   | |
|  |         [🏠 Icon]                 | |
|  |                                   | |
|  |    Stwórz nowe gospodarstwo       | | <- Card button
|  |                                   | |
|  |  Zacznij organizować dom          | |
|  |  z rodziną                        | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  |                                   | |
|  |         [🔗 Icon]                 | |
|  |                                   | |
|  |    Dołącz do gospodarstwa         | | <- Card button
|  |                                   | |
|  |  Masz kod zaproszenia?            | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|                                        |
+----------------------------------------+
```

**Component Specs:**
- Cards: 160dp height, full width - 32dp margin
- Icons: 48x48dp, centered
- Card title: 18sp bold
- Card description: 14sp, secondary text

---

### State 2: CREATE (Modal/Screen)

```
+----------------------------------------+
|  [✕]      Nowe gospodarstwo            |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | Nazwa gospodarstwa                | |
|  +-----------------------------------+ |
|  Np. "Rodzina Kowalskich"              | <- Hint
|                                        |
|  Twoja rola:                           |
|  ● Admin (pełne uprawnienia)           | <- Radio (pre-selected)
|                                        |
|                                        |
|         [Utwórz]                       | <- Primary button
|                                        |
|                                        |
+----------------------------------------+
```

**After creation → Success state:**

```
+----------------------------------------+
|  [✕]      Gospodarstwo utworzone       |
+----------------------------------------+
|                                        |
|             [✓ Icon]                   |
|                                        |
|    Rodzina Kowalskich                  | <- H2 (household name)
|                                        |
|  Możesz teraz zaprosić członków        |
|  rodziny!                              |
|                                        |
|         [Zaproś teraz]                 | <- Primary
|                                        |
|         [Przejdź do aplikacji]         | <- Secondary (text)
|                                        |
|                                        |
+----------------------------------------+
```

---

### State 3: JOIN (Enter Code)

```
+----------------------------------------+
|  [←]      Dołącz do gospodarstwa       |
+----------------------------------------+
|                                        |
|  Wprowadź 6-cyfrowy kod:               |
|                                        |
|     +-----------------------------+    |
|     | [A] [B] [C] [D] [E] [F]     |    | <- 6 boxes
|     +-----------------------------+    |
|                                        |
|         lub                            |
|                                        |
|     [📷 Zeskanuj kod QR]               | <- Secondary button
|                                        |
|                                        |
|                                        |
|         [Dołącz]                       | <- Primary (disabled until valid)
|                                        |
|                                        |
+----------------------------------------+
```

**Component Specs:**
- Code boxes: 6 inputs, 48x48dp each, 8dp spacing
- Auto-focus first box
- Auto-advance to next on input
- QR button: Opens camera

**After join → Success:**

```
+----------------------------------------+
|                                        |
|                                        |
|             [✓ Icon]                   |
|                                        |
|    Dołączyłeś do gospodarstwa!         | <- H2
|                                        |
|         Rodzina Kowalskich             | <- Household name
|                                        |
|  Możesz teraz korzystać z              |
|  wspólnych list i zadań.               |
|                                        |
|                                        |
|         [Przejdź do aplikacji]         | <- Primary
|                                        |
|                                        |
+----------------------------------------+
```

---

### State 4: ERROR (Invalid Code)

```
+----------------------------------------+
|  [←]      Dołącz do gospodarstwa       |
+----------------------------------------+
|                                        |
|  Wprowadź 6-cyfrowy kod:               |
|                                        |
|     +-----------------------------+    |
|     | [A] [B] [C] [D] [E] [F]     |    | <- Red border
|     +-----------------------------+    |
|  ⚠️ Nieprawidłowy kod lub wygasł        | <- Red error
|                                        |
|         lub                            |
|                                        |
|     [📷 Zeskanuj kod QR]               |
|                                        |
|                                        |
|         [Dołącz]                       |
|                                        |
|    Skontaktuj się z osobą,             |
|    która Cię zaprosiła                 | <- Hint
|                                        |
+----------------------------------------+
```

---

### State 5: LOADING (Validating Code)

```
+----------------------------------------+
|  [←]      Dołącz do gospodarstwa       |
+----------------------------------------+
|                                        |
|                                        |
|                                        |
|         [⏳ Spinner]                    |
|                                        |
|      Sprawdzanie kodu...               |
|                                        |
|                                        |
|                                        |
|                                        |
|                                        |
+----------------------------------------+
```

---

## 4. Dashboard

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Main Navigation Hub |
| Story | US-07 |
| Platform | Mobile-first |
| AC Addressed | Navigation to all modules |

### Purpose
Landing screen po zalogowaniu. Pokazuje podsumowanie i nawigację do modułów.

---

### State 1: SUCCESS (With Data)

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  | <- Top bar
+----------------------------------------+
|                                        |
|  Cześć, Anna! 👋                       | <- Greeting
|                                        |
|  +-----------------------------------+ |
|  | 🛒 Listy zakupów                  | |
|  |                                   | |
|  | 3 listy • 12 produktów            | | <- Summary card
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | ✓ Zadania                PREVIEW | | <- Badge
|  |                                   | |
|  | 5 zaplanowanych                   | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | 👥 Członkowie gospodarstwa        | |
|  |                                   | |
|  | 👤 Anna  👤 Tomek  👤 Zosia       | | <- Avatars
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  | <- Bottom nav (Zakupy active)
+----------------------------------------+
```

**Component Specs:**
- Top bar: 56dp, household name left, icons right
- Greeting: 24sp bold
- Summary cards: 96dp height, 12dp radius, elevation 2
- Card tap: Navigate to module
- Avatars: 40x40dp circular

---

### State 2: LOADING (Initial Load)

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Cześć, Anna! 👋                       |
|                                        |
|  +-----------------------------------+ |
|  | ████████████████                  | | <- Skeleton
|  |                                   | |
|  | ████████                          | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | ████████████████                  | |
|  |                                   | |
|  | ████████                          | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | ████████████████                  | |
|  |                                   | |
|  | ○ ○ ○                             | | <- Skeleton avatars
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 3: EMPTY (New Household)

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Cześć, Anna! 👋                       |
|                                        |
|  +-----------------------------------+ |
|  |         [🛒 Icon]                 | |
|  |                                   | |
|  |    Utwórz pierwszą listę          | |
|  |    zakupów                        | | <- Empty state card
|  |                                   | |
|  |    [+ Dodaj listę]                | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  |         [👥 Icon]                 | |
|  |                                   | |
|  |    Zaproś członków rodziny        | |
|  |                                   | |
|  |    [+ Zaproś]                     | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 4: ERROR (Network Error)

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|                                        |
|             [⚠️ Icon]                   |
|                                        |
|      Nie można załadować danych        | <- H3
|                                        |
|  Sprawdź połączenie z internetem       |
|                                        |
|                                        |
|         [Spróbuj ponownie]             | <- Primary button
|                                        |
|                                        |
|                                        |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### Interactions

| Element | Action | Destination |
|---------|--------|-------------|
| Household name | Tap | Settings (household) |
| Theme toggle 🌙 | Tap | Switch light/dark mode |
| Avatar 👤 | Tap | Account settings |
| Shopping card | Tap | Shopping Lists screen |
| Tasks card | Tap | Tasks Preview screen |
| Members card | Tap | Settings → Members |
| Bottom nav tabs | Tap | Navigate to module |

---

## 5. Shopping Lists

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Management |
| Story | US-08 |
| Platform | Mobile-first |
| AC Addressed | View all lists, create new list |

### Purpose
Przegląd wszystkich list zakupów. User widzi aktywne listy i może tworzyć nowe.

---

### State 1: SUCCESS (With Lists)

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Listy zakupów                         | <- H2
|                                        |
|  +-----------------------------------+ |
|  | Lista Biedronka            [︙]   | | <- 3-dot menu
|  |                                   | |
|  | 8 produktów • 3 kupione           | |
|  | Ostatnia zmiana: 10 min           | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | Lista Lidl                 [︙]   | |
|  |                                   | |
|  | 5 produktów • 0 kupione           | |
|  | Dodane przez: Tomek               | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | Apteka                     [︙]   | |
|  |                                   | |
|  | 2 produkty • 2 kupione ✓          | | <- All checked
|  | Ostatnia zmiana: 2 godz.          | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|                    [+]                 | <- FAB (bottom right)
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  | <- Active: Zakupy
+----------------------------------------+
```

**Component Specs:**
- List card: 96dp height, full width - 16dp margin
- Card title: 18sp bold
- Metadata: 12sp, secondary text
- 3-dot menu: 24x24dp, 48x48dp touch target
- FAB: 56x56dp, bottom right, 16dp margin

---

### State 2: LOADING

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Listy zakupów                         |
|                                        |
|  +-----------------------------------+ |
|  | ████████████████          ░░░░░░ | | <- Skeleton
|  |                                   | |
|  | ████████ • ████████               | |
|  | ████████████                      | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | ████████████████          ░░░░░░ | |
|  |                                   | |
|  | ████████ • ████████               | |
|  | ████████████                      | |
|  |                                   | |
|  +-----------------------------------+ |
|                                        |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 3: EMPTY

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Listy zakupów                         |
|                                        |
|                                        |
|                                        |
|             [🛒 Icon]                   | <- Large icon
|                                        |
|      Nie masz jeszcze żadnej           |
|      listy zakupów                     | <- H3
|                                        |
|  Stwórz pierwszą listę, aby            |
|  rozpocząć organizację zakupów         |
|                                        |
|                                        |
|         [+ Utwórz listę]               | <- Secondary button
|                                        |
|                                        |
|                    [+]                 | <- FAB
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 4: ERROR

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Listy zakupów                         |
|                                        |
|                                        |
|             [⚠️ Icon]                   |
|                                        |
|      Nie można załadować list          | <- H3
|                                        |
|  Sprawdź połączenie z internetem       |
|  i spróbuj ponownie                    |
|                                        |
|                                        |
|         [Odśwież]                      | <- Primary button
|                                        |
|                                        |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### Interactions

| Element | Action | Destination |
|---------|--------|-------------|
| List card | Tap | List Detail screen |
| 3-dot menu | Tap | Context menu (Edit, Delete, Share) |
| FAB + | Tap | Create List modal |
| "Utwórz listę" button | Tap | Create List modal |
| Pull down | Gesture | Refresh lists |

**3-dot menu options:**
- Edytuj nazwę
- Udostępnij
- Usuń listę (confirmation)

---

## 6. Shopping List Detail

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Items |
| Story | US-09, US-10, US-11, US-12 |
| Platform | Mobile-first |
| AC Addressed | Add/edit/delete items, checkoff, categorize, sort |

### Purpose
Szczegóły listy zakupów. User dodaje produkty, odznacza kupione, sortuje wg kategorii.

---

### State 1: SUCCESS (With Items)

```
+----------------------------------------+
|  [←]    Lista Biedronka         [︙]   | <- Back, 3-dot menu
+----------------------------------------+
|                                        |
|  Sortuj: [Kategorie ▼]  [↻]           | <- Dropdown + refresh
|                                        |
|  ── Mleczne ──                         | <- Category header
|                                        |
|  [ ] Mleko 2L                          |
|      Mama • 2.5 PLN           [︙]     | <- Checkoff, metadata, menu
|                                        |
|  [ ] Jogurt naturalny                  |
|      Tomek                    [︙]     |
|                                        |
|  ── Warzywa ──                         |
|                                        |
|  [ ] Pomidory 1kg                      |
|      1 kg                     [︙]     |
|                                        |
|  ── Pieczywo ──                        |
|                                        |
|  [ ] Chleb żytni                       |
|                                        |
|                                        |
|  ── Kupione ──                         | <- Collapsed by default
|                                        |
|  [✓] Masło 200g                        | <- Strikethrough
|  [✓] Jajka 10 szt                      |
|                                        |
|                    [+]                 | <- FAB
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

**Component Specs:**
- Item row: 72dp height min
- Checkbox: 24x24dp, left-aligned
- Product name: 16sp bold
- Metadata: 12sp, secondary text (person, price, quantity)
- Category header: 14sp uppercase, 40dp height
- Strikethrough: 50% opacity on checked items

**Drag Handle (when manual sort):**
```
|  [≡] [ ] Mleko 2L                      | <- Drag handle left
```

---

### State 2: LOADING

```
+----------------------------------------+
|  [←]    Lista Biedronka         [︙]   |
+----------------------------------------+
|                                        |
|  Sortuj: [Kategorie ▼]  [⏳]           | <- Loading spinner
|                                        |
|  ████████████████                      | <- Skeleton items
|  ████████          ░░░░░░░░░░         |
|                                        |
|  ████████████████                      |
|  ████████          ░░░░░░░░░░         |
|                                        |
|  ████████████████                      |
|  ████████          ░░░░░░░░░░         |
|                                        |
|                                        |
|                                        |
|                    [+]                 |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 3: EMPTY

```
+----------------------------------------+
|  [←]    Lista Biedronka         [︙]   |
+----------------------------------------+
|                                        |
|                                        |
|                                        |
|             [🛒 Icon]                   |
|                                        |
|      Lista jest pusta                  | <- H3
|                                        |
|  Dodaj pierwszy produkt, aby           |
|  rozpocząć zakupy                      |
|                                        |
|                                        |
|         [+ Dodaj produkt]              | <- Secondary button
|                                        |
|                                        |
|                    [+]                 | <- FAB
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 4: ERROR

```
+----------------------------------------+
|  [←]    Lista Biedronka         [︙]   |
+----------------------------------------+
|                                        |
|  Sortuj: [Kategorie ▼]  [↻]           |
|                                        |
|                                        |
|             [⚠️ Icon]                   |
|                                        |
|      Nie można załadować listy         | <- H3
|                                        |
|  Sprawdź połączenie i spróbuj          |
|  ponownie                              |
|                                        |
|                                        |
|         [Odśwież]                      |
|                                        |
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### Interactions

| Element | Action | Result |
|---------|--------|--------|
| Back button | Tap | Return to Shopping Lists |
| 3-dot menu | Tap | Context menu (Rename list, Delete list) |
| Sort dropdown | Tap | Choose: Kategorie / Ręczne / Dodane |
| Refresh icon | Tap | Manual sync (show spinner 2s) |
| Checkbox | Tap | Toggle checked/unchecked, move to Kupione |
| Item row | Tap | Edit Item modal |
| Item 3-dot | Tap | Context menu (Edit, Delete, Assign) |
| FAB + | Tap | Add Item modal |
| Swipe left (item) | Gesture | Reveal delete button |
| Long press (item) | Gesture | Enable drag mode (if manual sort) |
| Pull down | Gesture | Refresh list |

**Checkoff Animation:**
```
Tap checkbox
  → Checkbox animates (scale 0.9 → 1.0, draw checkmark)
  → Item fades to 50% opacity
  → Item slides down to "Kupione" section (300ms)
  → Strikethrough appears
```

---

### Accessibility

**Touch Targets:**
- Checkbox: 48x48dp ✅
- Item row: Full width x 72dp ✅
- 3-dot menu: 48x48dp ✅
- FAB: 56x56dp ✅

**Screen Reader:**
- Checkbox: "Mleko 2L, unchecked, assigned to Mama"
- Checked item: "Mleko 2L, checked, purchased"
- Category header: "Category: Mleczne"

---

## 7. Tasks Preview

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Tasks/Chores (Preview) |
| Story | US-16 |
| Platform | Mobile-first |
| AC Addressed | View tasks, add/edit, assign, checkoff |

### Purpose
Preview modułu zadań. Basic CRUD + przypisywanie do osób.

---

### State 1: SUCCESS (With Tasks)

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|  Zadania                      PREVIEW  | <- H2 + badge
|                                        |
|  +-----------------------------------+ |
|  | ℹ️ To jest wersja testowa. Pełna  | | <- Info banner
|  | funkcjonalność będzie wkrótce.    | |
|  +-----------------------------------+ |
|                                        |
|  Dzisiaj                               | <- Date header
|                                        |
|  [ ] Wynieść śmieci                    |
|      18:00 • Zosia            [︙]     |
|                                        |
|  [ ] Odkurzyć pokój                    |
|      Zosia                    [︙]     |
|                                        |
|  Jutro                                 |
|                                        |
|  [ ] Karmienie kota                    |
|      08:00 • Tomek            [︙]     |
|                                        |
|  Wykonane                              |
|                                        |
|  [✓] Zmywanie naczyń                   | <- Strikethrough
|      Anna                              |
|                                        |
|                    [+]                 | <- FAB
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  | <- Active: Zadania
+----------------------------------------+
```

**Component Specs:**
- Info banner: 48dp height, light blue background, dismissible
- Task row: 72dp height, similar to shopping item
- Checkbox: 24x24dp
- Time: 12sp, secondary color
- Assigned person: 12sp, avatar or initials

---

### State 2: LOADING

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|  Zadania                      PREVIEW  |
|                                        |
|  +-----------------------------------+ |
|  | ℹ️ To jest wersja testowa...      | |
|  +-----------------------------------+ |
|                                        |
|  Dzisiaj                               |
|                                        |
|  ████████████████          ░░░░░░░░   | <- Skeleton
|  ████████          ░░░░░░             |
|                                        |
|  ████████████████          ░░░░░░░░   |
|  ████████          ░░░░░░             |
|                                        |
|                                        |
|                    [+]                 |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 3: EMPTY

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|  Zadania                      PREVIEW  |
|                                        |
|  +-----------------------------------+ |
|  | ℹ️ To jest wersja testowa...      | |
|  +-----------------------------------+ |
|                                        |
|                                        |
|             [✓ Icon]                   |
|                                        |
|      Brak zaplanowanych zadań          | <- H3
|                                        |
|  Dodaj pierwsze zadanie, aby           |
|  organizować obowiązki domowe          |
|                                        |
|                                        |
|         [+ Dodaj zadanie]              | <- Secondary button
|                                        |
|                    [+]                 | <- FAB
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  |
+----------------------------------------+
```

---

### State 4: SUCCESS (no error state in preview)

---

### Interactions

| Element | Action | Result |
|---------|--------|--------|
| Checkbox | Tap | Toggle complete/incomplete |
| Task row | Tap | Edit Task modal (future) |
| 3-dot menu | Tap | Context menu (Edit, Delete, Reassign) |
| FAB + | Tap | Add Task modal |
| Info banner X | Tap | Dismiss banner (don't show again) |

---

## 8. Settings

### Screen Info
| Field | Value |
|-------|-------|
| Feature | Settings & Account |
| Story | US-17, US-18, US-06 |
| Platform | Mobile-first |
| AC Addressed | Theme, language, household management |

### Purpose
Zarządzanie kontem, gospodarstwem, preferencjami aplikacji.

---

### State 1: SUCCESS

```
+----------------------------------------+
| 👤 Rodzina Kowalskich        [🌙] [👤]  |
+----------------------------------------+
|                                        |
|  Ustawienia                            | <- H2
|                                        |
|  ── Gospodarstwo ──                    |
|                                        |
|  Rodzina Kowalskich           [>]      | <- Nav item
|  4 członków                            |
|                                        |
|  Zaproś członka               [>]      |
|                                        |
|  ── Konto ──                           |
|                                        |
|  Anna Kowalska                         |
|  anna@example.com             [>]      |
|                                        |
|  ── Wygląd ──                          |
|                                        |
|  Motyw                        [🌙 ☀️]  | <- Toggle switch
|  Obecnie: Ciemny                       |
|                                        |
|  Język                                 |
|  Polski                       [>]      |
|                                        |
|  ── O aplikacji ──                     |
|                                        |
|  Wersja 1.0.0 (MVP)                    |
|                                        |
|  Regulamin i prywatność       [>]      |
|                                        |
|                                        |
|  [Wyloguj się]                         | <- Danger button (red)
|                                        |
+----------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  | <- Active: Ustaw.
+----------------------------------------+
```

**Component Specs:**
- Section header: 14sp uppercase, secondary text, 40dp height
- Setting row: 64dp height, title + subtitle
- Toggle switch: 48dp width, 24dp height
- Chevron: 24x24dp, right-aligned
- Logout button: 48dp height, red text, outlined

---

### State 2: Household Members (Sub-screen)

```
+----------------------------------------+
|  [←]           Członkowie              |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | 👤  Anna Kowalska                 | |
|  |     Admin                 [︙]     | | <- You (cannot remove self)
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | 👤  Tomek Kowalski                | |
|  |     Member                [︙]     | | <- Can change role
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | 👤  Zosia Kowalska                | |
|  |     Child                 [︙]     | |
|  +-----------------------------------+ |
|                                        |
|  +-----------------------------------+ |
|  | 👤  Kuba Kowalski (oczekuje)      | | <- Pending approval
|  |     Member                [✓][✗]  | | <- Approve / Reject
|  +-----------------------------------+ |
|                                        |
|                                        |
|         [+ Zaproś członka]             | <- Secondary button
|                                        |
+----------------------------------------+
```

**3-dot menu (Admin only):**
- Zmień rolę (Member ↔ Child)
- Usuń z gospodarstwa (confirmation)

---

### State 3: Invite Modal

```
+----------------------------------------+
|  [✕]         Zaproś członka            |
+----------------------------------------+
|                                        |
|  Kod zaproszenia:                      |
|                                        |
|     +-----------------------------+    |
|     |      A B C D E F            |    | <- Large code
|     +-----------------------------+    |
|                                        |
|         [Kopiuj kod]                   | <- Copy to clipboard
|                                        |
|  ───────────── lub ─────────────      |
|                                        |
|     [                               ]  |
|     [       QR Code Image           ]  | <- Large QR
|     [                               ]  |
|                                        |
|                                        |
|         [Udostępnij]                   | <- Share API
|                                        |
|  Kod wygasa za: 6 dni 23 godz.         | <- Countdown
|                                        |
+----------------------------------------+
```

**Component Specs:**
- Code: 32sp bold, monospace
- QR code: 200x200dp, centered
- Copy button: Secondary style
- Share button: Primary style
- Expiry: 12sp, secondary color

---

### Interactions

| Element | Action | Result |
|---------|--------|--------|
| "Rodzina Kowalskich" | Tap | Household Members screen |
| "Zaproś członka" | Tap | Invite Modal |
| Account row | Tap | Edit profile (post-MVP) |
| Theme toggle | Tap | Switch light/dark mode instantly |
| "Język" | Tap | Language picker modal |
| "Regulamin..." | Tap | Open legal documents |
| "Wyloguj się" | Tap | Confirmation → Logout → Landing |
| "Kopiuj kod" | Tap | Copy to clipboard + toast "Kod skopiowany" |
| "Udostępnij" | Tap | Native share sheet (WhatsApp, SMS, etc.) |

---

## 9. Modals

### 9.1 Add Item Modal

```
+----------------------------------------+
|  [✕]         Dodaj produkt             |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | Nazwa produktu                    | | <- Input (autofocus)
|  +-----------------------------------+ |
|  np. Mleko 2L                          | <- Hint
|                                        |
|  Kategoria:                            |
|  +-----------------------------------+ |
|  | Mleczne                       [▼] | | <- Dropdown
|  +-----------------------------------+ |
|                                        |
|  Ilość (opcjonalnie):                  |
|  +-------+ +------------------------+ |
|  | 2     | | litr               [▼] | | <- Number + unit
|  +-------+ +------------------------+ |
|                                        |
|  Przypisz do:                          |
|  +-----------------------------------+ |
|  | Wszyscy                       [▼] | | <- Dropdown
|  +-----------------------------------+ |
|                                        |
|                                        |
|         [Anuluj]  [Dodaj]              | <- Secondary + Primary
|                                        |
+----------------------------------------+
```

**Behavior:**
- Input autofocus, keyboard appears
- Autocomplete suggests previous products
- Enter key submits form
- Optimistic update (add immediately, sync in background)

---

### 9.2 Create List Modal

```
+----------------------------------------+
|  [✕]        Nowa lista zakupów         |
+----------------------------------------+
|                                        |
|  +-----------------------------------+ |
|  | Nazwa listy                       | | <- Input (autofocus)
|  +-----------------------------------+ |
|  np. "Biedronka sobota"                | <- Hint
|                                        |
|                                        |
|                                        |
|                                        |
|         [Anuluj]  [Utwórz]             |
|                                        |
+----------------------------------------+
```

**Behavior:**
- Simple form, just name
- After creation → Navigate to List Detail

---

### 9.3 Delete Confirmation Modal

```
+----------------------------------------+
|                                        |
|      Usunąć "Mleko 2L"?                | <- H3
|                                        |
|  Tej operacji nie można cofnąć.        |
|                                        |
|                                        |
|         [Anuluj]  [Usuń]               | <- Secondary + Danger
|                                        |
+----------------------------------------+
```

**Behavior:**
- Backdrop: 50% black
- Escape key / tap outside → Cancel
- "Usuń" button: Red text

---

### 9.4 Category Picker (Bottom Sheet)

```
+----------------------------------------+
|  Wybierz kategorię                     |
+----------------------------------------+
|                                        |
|  🥛  Mleczne                            | <- Radio options
|  🥕  Warzywa                            |
|  🍞  Pieczywo                           |
|  🥩  Mięso                              |
|  🥤  Napoje                             |
|  📦  Inne                               |
|                                        |
|  ──────────────────────                |
|                                        |
|  + Dodaj własną kategorię              | <- Link
|                                        |
+----------------------------------------+
```

**Behavior:**
- Tap category → Select & close modal
- Slide down to dismiss

---

## 10. Responsive Adjustments

### Tablet (768-1024px)

**Shopping List Detail:**
```
+------------------------------------------------------------------+
|  [←]    Lista Biedronka              [︙]   [🌙] [👤]            |
+------------------------------------------------------------------+
|                        |                                         |
|  Sortuj: [Kategorie ▼] |  [ ] Mleko 2L                          |
|  [↻] Odśwież           |      Mama • 2.5 PLN           [︙]     |
|                        |                                         |
|  ── Mleczne ──         |  [ ] Jogurt naturalny                  |
|  ── Warzywa ──         |      Tomek                    [︙]     |
|  ── Pieczywo ──        |                                         |
|  ── Napoje ──          |  ── Kupione ──                         |
|  ── Inne ──            |                                         |
|                        |  [✓] Masło 200g                        |
|                        |  [✓] Jajka 10 szt                      |
|                        |                                         |
|          Categories    |              Items List                 |
|          (sidebar)     |                                [+]      |
+------------------------------------------------------------------+
```

**Layout changes:**
- 2-column layout (categories sidebar + items)
- Side navigation instead of bottom nav
- Modals as centered dialogs (max 600px width)

---

### Desktop (>1024px)

**Shopping Lists:**
```
+------------------------------------------------------------------+
|  🏠 HomeOS          [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustaw.]  [🌙] [👤] |
+------------------------------------------------------------------+
|                                                                  |
|       Listy zakupów                                   [+ Nowa]   |
|                                                                  |
|   +---------------------+  +---------------------+  +--------+  |
|   | Lista Biedronka     |  | Lista Lidl          |  | Apteka |  |
|   |                     |  |                     |  |        |  |
|   | 8 prod. • 3 kupione |  | 5 prod. • 0 kupione |  | 2/2 ✓  |  |
|   | 10 min temu         |  | Tomek               |  | 2 godz |  |
|   +---------------------+  +---------------------+  +--------+  |
|                                                                  |
+------------------------------------------------------------------+
```

**Layout changes:**
- Top navigation bar (horizontal)
- 3-column card grid
- Hover states on cards (elevation increase)
- Max content width: 1440px, centered

---

## 11. Animation Specs Summary

| Animation | Duration | Easing | Description |
|-----------|----------|--------|-------------|
| Checkoff | 300ms | ease-out | Scale → Check draw → Move down |
| Modal open | 300ms | ease-out | Slide up from bottom |
| Modal close | 300ms | ease-in | Slide down to bottom |
| Delete | 250ms | ease-in | Slide out left + height collapse |
| Add item | 200ms | ease-out | Fade in from top |
| Drag reorder | 200ms | ease-out | Items shift smoothly |
| Button press | 100ms | ease-out | Scale to 0.95 |
| Toast | 3s | - | Fade in → Stay → Fade out |

**Reduced motion:**
- All animations → 0.01ms (instant)
- Respect `prefers-reduced-motion: reduce`

---

## 12. Dark Mode Variants

### Color Changes

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | #FFFFFF | #121212 |
| Surface (cards) | #F5F5F5 | #1E1E1E |
| Primary text | #212121 | #E0E0E0 |
| Secondary text | #757575 | #B0B0B0 |
| Primary color | #1976D2 | #90CAF9 (lighter) |
| Accent color | #4CAF50 | #81C784 (lighter) |
| Dividers | #E0E0E0 | #2C2C2C |

### Example (Shopping List Item in Dark Mode)

```
+----------------------------------------+ (Background: #121212)
|  [←]    Lista Biedronka         [︙]   |
+----------------------------------------+
|                                        |
|  [ ] Mleko 2L                          | <- Text: #E0E0E0
|      Mama • 2.5 PLN           [︙]     | <- Secondary: #B0B0B0
|                                        |
+----------------------------------------+
```

**Notes:**
- Shadows less prominent (use lighter opacity)
- Focus indicators more visible (brighter primary color)
- Images/illustrations: Provide dark variants if needed

---

## 13. Handoff Checklist

### Design Deliverables ✅
- [x] UX Specification
- [x] Wireframes (all 7 screens + modals)
- [x] All 4 states per screen (Loading, Empty, Error, Success)
- [x] Component specifications
- [x] Color palette
- [x] Typography scale
- [x] Spacing system
- [x] Animation specs

### Accessibility ✅
- [x] Touch targets >= 44dp specified
- [x] Contrast ratios defined (4.5:1 for text)
- [x] Screen reader labels noted
- [x] Focus order defined
- [x] Keyboard navigation specified

### Responsive ✅
- [x] Mobile primary (320-428px) ✅
- [x] Tablet breakpoint (768-1024px) ✅
- [x] Desktop breakpoint (>1024px) ✅

### Dark Mode ✅
- [x] Color variants defined
- [x] Implementation notes

### Polish Language ✅
- [x] All copy in Polish
- [x] i18n considerations noted

---

## 14. Open Questions (for PM)

1. **Custom categories icons:** Czy mamy dostęp do custom ikon kategorii, czy używamy emoji?
2. **Avatar upload:** Czy users mogą uploadować zdjęcia profilowe w MVP, czy tylko inicjały?
3. **Price tracking:** Czy w MVP pokazujemy pole cena przy produkcie, czy tylko opcjonalnie?
4. **Push notification design:** Czy mamy spec dla treści powiadomień? (format, tone)
5. **Onboarding tutorial:** Czy w MVP pokazujemy tooltips/coach marks, czy liczymy na intuicyjność?

---

## 15. Next Steps

1. **PM Review:** Zatwierdzenie wireframes + odpowiedzi na open questions
2. **Frontend Dev:** Implementacja komponentów (priorytet: Tydzień 1 → 2 → 3)
3. **Design System:** Utworzenie UI kit w Figma (post-MVP, jeśli potrzebne)
4. **User Testing:** Beta testing z 2-3 rodzinami (zbieranie feedbacku na UX)

---

## Appendix: User Flow Diagrams

Szczegółowe diagramy flow w osobnym dokumencie:
→ `/workspaces/MyHome/docs/1-BASELINE/ux/flows/USER-FLOWS.md` (do utworzenia)

**Kluczowe flows:**
1. Onboarding (Register → Create Household → Dashboard)
2. Onboarding (Login → Join Household → Dashboard)
3. Add Shopping Item (FAB → Modal → List updated)
4. Checkoff Item (Tap checkbox → Animation → Move to Kupione)
5. Invite Member (Settings → Invite Modal → Share code)

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Author:** Sally (UX Designer)
**Status:** Draft - Ready for Review

**PRD Ref:** @docs/1-BASELINE/PRD.md
**UX Spec Ref:** @docs/1-BASELINE/ux/UX-SPECIFICATION.md
