# HomeOS - UX Design Specification

**Data:** 2025-12-09
**Wersja:** 1.1
**Status:** Draft → Updated
**Platform:** Mobile-first PWA
**Autor:** UX Designer (Sally)

---

## 1. Executive Summary

HomeOS to mobile-first PWA do zarządzania domem dla polskich rodzin. Design skupia się na:
- **Zero learning curve** - intuicyjny interfejs bez instrukcji
- **Speed above all** - każda akcja < 3 taps
- **Family-friendly** - czytelne dla wszystkich grup wiekowych
- **Real-time trust** - widoczność kto co zrobił

**Target devices:** Mobile primary (320-428px), responsive do desktop (1920px)

**Ref dokumenty:**
- @docs/1-BASELINE/PRD.md
- @docs/0-DISCOVERY/PROJECT-UNDERSTANDING.md
- @docs/1-BASELINE/research/ui-ux-research.md

**Powiazane dokumenty UX (w tym samym folderze):**
- UX-PRINCIPLES.md - zasady projektowania (w docs/1-BASELINE/ux/)
- USER-FLOWS.md - szczegolowe diagramy flow (w docs/1-BASELINE/ux/flows/)
- WIREFRAMES.md - wireframes ekranow (w docs/1-BASELINE/ux/)

---

## 2. User Flows Overview

### 2.1 Kluczowe Flow (MVP)

| Flow | Entry Point | Exit Point | Screens |
|------|-------------|------------|---------|
| **Onboarding (Register)** | Landing page | Dashboard | 3 screens |
| **Onboarding (Join Home)** | Landing page | Dashboard | 4 screens |
| **Add Shopping Item** | Shopping List | Back to list | 1 modal |
| **Check Off Item** | Shopping List | Same screen | 0 (inline) |
| **Create New List** | Shopping Lists | List detail | 1 modal |
| **Invite Member** | Settings | Share code | 1 screen |
| **Task Preview** | Tasks tab | Task detail | 2 screens |
| **Session Timeout** | Any screen | Login screen | 1 screen |
| **PWA Update** | Any screen | Banner prompt | 1 banner |
| **Offline Mode** | Any screen | Same + banner | 1 banner |

### 2.2 Flow Diagrams

Szczegółowe diagramy flow w osobnym dokumencie:
→ @docs/1-BASELINE/ux/flows/USER-FLOWS.md

---

## 3. Screen Inventory (MVP)

### 3.1 Ekrany MVP (10 głównych + modals)

| # | Screen Name | Type | Navigation | States Required |
|---|-------------|------|------------|-----------------|
| 1 | **Landing / Login** | Public | Entry point | Loading, Error, Success |
| 2 | **Register / Google OAuth** | Public | From Landing | Loading, Error, Success |
| 3 | **Household Setup** | Onboarding | After auth | Loading, Empty, Error, Success |
| 4 | **Dashboard** | Main | Bottom nav (Home) | Loading, Empty, Success |
| 5 | **Shopping Lists** | Main | Bottom nav (Home) | Loading, Empty, Error, Success |
| 6 | **Shopping List Detail** | Main | From Lists | Loading, Empty, Error, Success |
| 7 | **Tasks Preview** | Main | Bottom nav (Tasks) | Loading, Empty, Success |
| 8 | **Settings** | Main | Bottom nav (Settings) | Success |
| 9 | **Session Timeout** | System | Auto-trigger | Success (redirect to login) |
| 10 | **Offline Indicator** | System | Auto-trigger | Banner (persistent) |

### 3.2 Modals & Overlays

| Modal | Trigger | Purpose |
|-------|---------|---------|
| Add Item Modal | FAB + | Dodanie produktu do listy |
| Edit Item Modal | Tap item | Edycja produktu |
| Create List Modal | + button | Nowa lista zakupów |
| Delete Confirmation | Swipe → Delete | Potwierdzenie usunięcia |
| Invite Modal | "Zaproś" button | QR code + kod tekstowy (single-use) |
| Category Picker | Select dropdown | Wybór kategorii produktu |
| PWA Update Prompt | New version available | "Zaktualizuj aplikację" |
| Rate Limit Warning | Too many requests | "Spróbuj ponownie za X sekund" |

---

## 4. Navigation Structure

### 4.1 Bottom Navigation (Mobile Primary)

```
+---------------------------------------------+
|  [🛒 Zakupy]  [✓ Zadania]  [⚙️ Ustawienia]  |
+---------------------------------------------+
```

| Tab | Icon | Label | Screen | Badge |
|-----|------|-------|--------|-------|
| 1 | 🛒 | Zakupy | Shopping Lists | Count unchecked |
| 2 | ✓ | Zadania | Tasks Preview | "Preview" tag |
| 3 | ⚙️ | Ustawienia | Settings | None |

**Specs:**
- Height: 56dp
- Icons: 24x24dp
- Active color: Primary
- Inactive color: Gray 60%
- Touch target: 56x56dp (full tab width)

### 4.2 Top App Bar

```
+---------------------------------------------+
|  [←]    Screen Title              [🌙] [👤]  |
+---------------------------------------------+
```

**Variants:**
- **Main screens:** Home name (left) + Theme toggle + Avatar (right)
- **Detail screens:** Back button (left) + Title (center) + Actions (right)
- **Modals:** Close X (right) + Title (center)

**Specs:**
- Height: 56dp
- Title: 18sp bold
- Icons: 24x24dp
- Back button touch: 48x48dp

### 4.3 Information Architecture

```
Landing
 ├─ Login
 ├─ Register
 └─ Join Home (via code)
      ↓
Dashboard (after auth)
 ├─ Shopping Lists (tab 1)
 │   └─ List Detail
 │       ├─ Add Item (modal)
 │       └─ Edit Item (modal)
 ├─ Tasks Preview (tab 2)
 │   └─ Task Detail
 └─ Settings (tab 3)
     ├─ Household Members
     ├─ Invite (modal)
     ├─ Account
     └─ Theme/Language
```

---

## 5. Component Library (MVP)

### 5.1 Buttons

#### Primary Button
```
+---------------------------+
|    Primary Action Text    |  <- 48dp height
+---------------------------+
```
- **Use:** Main CTAs (Submit, Save, Add)
- **Height:** 48dp
- **Padding:** 16dp horizontal
- **Border radius:** 8dp
- **Font:** 16sp bold
- **Color:** Primary background, White text
- **Touch target:** Full button area (min 48x48dp)

#### Secondary Button
```
+---------------------------+
|   Secondary Action Text   |  <- 48dp height
+---------------------------+
```
- **Use:** Alternative actions (Cancel, Skip)
- **Height:** 48dp
- **Style:** Outlined (2dp border) or text-only
- **Color:** Primary text on transparent

#### FAB (Floating Action Button)
```
      +------+
      |  +   |  <- 56x56dp
      +------+
```
- **Position:** Bottom right, 16dp margin
- **Size:** 56x56dp
- **Icon:** 24x24dp
- **Elevation:** 6dp
- **Color:** Primary
- **aria-label:** "Dodaj nowy produkt"

### 5.2 Forms

#### Text Input
```
+----------------------------------+
| Label                            |
| +------------------------------+ |
| | User input text...           | |
| +------------------------------+ |
| Helper text / Error message      |
+----------------------------------+
```
- **Height:** 56dp (input area)
- **Padding:** 16dp horizontal
- **Border:** 1dp, rounded 4dp
- **Label:** 12sp, above input
- **Error state:** Red border + red error text below

#### Checkbox
```
[✓] Checked item
[ ] Unchecked item
```
- **Size:** 24x24dp
- **Touch target:** 48x48dp
- **Spacing:** 16dp between checkbox and label
- **aria-label:** "Oznacz {item} jako kupione"

#### Dropdown / Select
```
+----------------------------------+
| Selected option             [▼]  |
+----------------------------------+
```
- **Height:** 56dp
- **Chevron:** Right-aligned, 24x24dp

### 5.3 Lists

#### Shopping List Item
```
+----------------------------------------+
| [ ] Mleko 2L                           |
|     Mleczne • Mama               [︙]  |
+----------------------------------------+
```
**Components:**
- Checkbox (left, 24x24dp, touch 48x48dp)
- Product name (16sp bold)
- Metadata row: Category (12sp) • Assigned person (12sp)
- 3-dot menu (right, 24x24dp, touch 48x48dp)
- Row height: 72dp
- Touch target: Full row (48dp min)
- **aria-label:** "Mleko 2L, kategoria Mleczne, dodane przez Mama"

#### Task Item
```
+----------------------------------------+
| [ ] Wynieść śmieci                     |
|     Deadline: Dziś 18:00 • Zosia      |
+----------------------------------------+
```
- Similar structure to shopping item
- Deadline display instead of category

#### Member List Item
```
+----------------------------------------+
| 👤  Anna Kowalska              [Admin] |
+----------------------------------------+
```
- Avatar (left, 40x40dp)
- Name (16sp)
- Role badge (right, chip)

### 5.4 Cards

#### List Card (Shopping Lists Screen)
```
+---------------------------+
| Lista Biedronka           |
|                           |
| 8 produktów • 3 kupione   |
|                           |
| Ostatnia zmiana: 10 min   |
+---------------------------+
```
- **Size:** Full width, variable height
- **Padding:** 16dp
- **Border radius:** 12dp
- **Shadow:** Elevation 2dp
- **Touch target:** Full card

### 5.5 Modals

#### Bottom Sheet Modal (Mobile)
```
+----------------------------------------+
|               Add Item                 |
|  +-----------------------------------+ |
|  | Product name...                   | |
|  +-----------------------------------+ |
|  Category: [Mleczne        ▼]         |
|  Quantity: [2] [litr      ▼]          |
|  Assign to: [Mama          ▼]         |
|                                        |
|           [Cancel]  [Add]              |
+----------------------------------------+
```
- **Position:** Bottom slide-up
- **Border radius:** 16dp (top corners)
- **Backdrop:** 50% black overlay
- **Max height:** 80vh
- **role:** "dialog"
- **aria-modal:** "true"

#### Full Screen Modal (Complex forms)
- Used for multi-step forms
- Close X button (top right)

### 5.6 Feedback Components

#### Toast Notification
```
+----------------------------------------+
|  ✓  Item added to list                 |
+----------------------------------------+
```
- **Position:** Bottom, above nav (mobile) or top-right (desktop)
- **Duration:** 3s
- **Dismissible:** Swipe to dismiss
- **role:** "alert"
- **aria-live:** "polite"

#### Skeleton Loader
```
+----------------------------------------+
| ████████████████             ░░░░░░░░ |
| ████████          ░░░░░░░░░░░░        |
+----------------------------------------+
```
- Gray animated shimmer
- Matches layout of actual content

#### Empty State
```
+----------------------------------------+
|                                        |
|           [illustration]               |
|                                        |
|          No items yet                  |
|     Tap + to add your first item       |
|                                        |
+----------------------------------------+
```
- Centered content
- Friendly illustration (or icon)
- Clear CTA

#### Error State
```
+----------------------------------------+
|                                        |
|              [⚠️ icon]                  |
|                                        |
|       Something went wrong             |
|    {Specific error message}            |
|                                        |
|            [Try Again]                 |
|                                        |
+----------------------------------------+
```

---

## 6. Visual Design System

### 6.1 Color Palette

**DECYZJA: Blue/Green palette zatwierdzona** (patrz @docs/1-BASELINE/research/ui-ux-research.md)

#### Primary Colors (Light Mode)
```
Primary:     #1976D2  (Blue - trust, reliability)
Primary Dark: #1565C0
Primary Light: #BBDEFB

Accent:      #4CAF50  (Green - home, growth, success)
Accent Dark: #388E3C

Background:  #FFFFFF
Surface:     #F5F5F5
```

#### Semantic Colors
```
Error:       #D32F2F  (Red)
Warning:     #FFA726  (Orange)
Success:     #4CAF50  (Green)
Info:        #2196F3  (Light Blue)
```

#### Text Colors (Light Mode)
```
Primary Text:    #212121  (87% black)
Secondary Text:  #757575  (60% black)
Disabled Text:   #BDBDBD  (38% black)
```

#### Dark Mode Colors
```
Background:  #121212  (nie pure black - lepiej dla OLED)
Surface:     #1E1E1E
Primary:     #90CAF9  (Lighter blue)
Accent:      #81C784  (Lighter green)

Primary Text:    #E0E0E0
Secondary Text:  #B0B0B0
Disabled Text:   #6E6E6E
```

### 6.2 Typography

#### Font Family
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI',
             Roboto, 'Helvetica Neue', Arial, sans-serif;
```
**Rationale:** System fonts dla wydajności + natywny look

#### Type Scale

| Style | Size | Weight | Line Height | Use Case |
|-------|------|--------|-------------|----------|
| H1 | 32sp | Bold | 40sp | Page titles (rare) |
| H2 | 24sp | Bold | 32sp | Section headers |
| H3 | 20sp | Medium | 28sp | Card titles |
| Body 1 | 16sp | Regular | 24sp | Main content, list items |
| Body 2 | 14sp | Regular | 20sp | Secondary text |
| Caption | 12sp | Regular | 16sp | Metadata, timestamps |
| Button | 16sp | Bold | 16sp | Button labels |
| Overline | 10sp | Bold | 16sp | Labels, badges (uppercase) |

**Minimum size:** 16sp (dla czytelności, accessibility)

### 6.3 Spacing System

**8dp Grid System**
```
4dp  - Micro spacing (between icon and text)
8dp  - Small spacing (list item padding)
12dp - Medium spacing (card padding)
16dp - Large spacing (screen margins)
24dp - XL spacing (section separation)
32dp - XXL spacing (major sections)
```

### 6.4 Elevation / Shadows

| Level | Use Case | Shadow |
|-------|----------|--------|
| 0dp | Flat surfaces, background | None |
| 2dp | Cards, list items (resting) | Subtle shadow |
| 4dp | Cards on hover | Medium shadow |
| 6dp | FAB (resting) | Prominent shadow |
| 8dp | FAB on hover, modals | Strong shadow |
| 16dp | Navigation drawer | Very strong shadow |

**CSS Shadow Examples:**
```css
/* Elevation 2dp */
box-shadow: 0 2px 4px rgba(0,0,0,0.1);

/* Elevation 6dp */
box-shadow: 0 6px 12px rgba(0,0,0,0.15);
```

### 6.5 Border Radius

| Size | Use Case |
|------|----------|
| 4dp | Inputs, small chips |
| 8dp | Buttons, cards |
| 12dp | Large cards |
| 16dp | Modal tops, bottom sheets |
| 50% | Circular (avatars, FAB) |

### 6.6 Icons

**System:** Material Icons (outline style)
**Size:** 24x24dp (default), 20x20dp (inline with text)
**Color:** Match text color or primary

**Key Icons:**
- 🛒 Shopping bag (shopping lists)
- ✓ Check (tasks, checkoff)
- ⚙️ Settings
- + Plus (add actions)
- ← Back arrow
- ︙ 3-dot menu (more options)
- 👤 Person (user avatar fallback)

---

## 7. Responsive Breakpoints

### 7.1 Breakpoint Strategy

| Device | Width | Layout Strategy |
|--------|-------|-----------------|
| **Mobile S** | 320-374px | Single column, compact spacing |
| **Mobile M** | 375-424px | Single column (primary target) |
| **Mobile L** | 425-767px | Single column, generous spacing |
| **Tablet** | 768-1023px | 2-column grid where sensible, side nav option |
| **Desktop S** | 1024-1439px | 2-3 column grid, persistent nav |
| **Desktop L** | 1440px+ | Max-width 1440px, centered, 3-column grid |

### 7.2 Layout Changes per Breakpoint

#### Mobile (<768px) - PRIMARY DESIGN
- Bottom navigation
- Full-width components
- Single column lists
- Modals as bottom sheets
- FAB for primary action

#### Tablet (768-1024px)
- Side navigation option (drawer)
- 2-column card grid
- Wider modals (max 600px width, centered)
- FAB remains

#### Desktop (>1024px)
- Top navigation bar
- 3-column card grid
- Dialogs instead of bottom sheets
- Hover states visible
- Max content width: 1440px

---

## 8. Micro-interactions & Animations

### 8.1 Transition Durations

| Duration | Use Case |
|----------|----------|
| 100ms | Button press feedback |
| 200ms | Component state changes (hover, focus) |
| 300ms | Screen transitions, modal open/close |
| 500ms | Complex animations (drag & drop reorder) |

**Easing:** ease-out (default)

### 8.2 Key Animations

#### Checkoff Animation
```
1. Tap checkbox
   → Scale down to 0.95 (100ms)
2. Checkmark draws (animated stroke)
   → Duration 200ms
3. Item moves to "Kupione" section
   → Slide animation 300ms
   → Text strikethrough appears
```

#### Add Item Animation
```
1. Modal slides up from bottom (300ms)
2. Input auto-focuses, keyboard appears
3. On submit:
   → Modal slides down (300ms)
   → New item fades in at top of list (200ms)
   → Optimistic update (instant)
```

#### Delete Animation
```
1. Swipe left reveals red delete button
2. Tap "Usuń" → Confirmation modal
3. Confirm:
   → Item slides out left (250ms)
   → Height collapses (150ms)
   → Gap closes smoothly
```

#### Pull to Refresh
```
1. Pull down on list
   → Spinner appears, grows
2. Release when threshold reached
   → Spinner animates (rotate)
3. Content refreshes
   → Spinner fades out
   → List updates (optimistic)
```

#### Drag & Drop (List Reordering)
```
1. Long-press item (500ms)
   → Item lifts (shadow increases to 8dp)
   → Haptic feedback
2. Drag to new position
   → Other items shift smoothly (200ms)
3. Release
   → Item settles (300ms ease-out)
   → Position saved
```

### 8.3 Loading States

**Skeleton Screens** (preferred over spinners)
- Show layout structure immediately
- Animated shimmer effect (1.5s loop)
- Matches final content layout

**Spinners** (only when layout unknown)
- Circular spinner, primary color
- 32x32dp size
- Centered in container

### 8.4 Reduced Motion

**Respect user preferences:**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 9. Accessibility Requirements

### 9.1 Touch Targets (Critical)

**STANDARD: 48x48dp (Material Design 3)**

| Element Type | Minimum Size | Standard Size |
|--------------|--------------|---------------|
| Buttons | 48x48dp | 48x48dp |
| Checkboxes | 48x48dp | 48x48dp |
| Icons (tappable) | 48x48dp | 48x48dp |
| List items | Full width x 48dp height | 72dp height |
| FAB | 56x56dp | 56x56dp |

**UWAGA:** Uzywamy 48x48dp jako STANDARD (nie 44x44dp) zgodnie z Material Design 3.
Wyjatki tylko dla bardzo ograniczonej przestrzeni - wtedy minimum 44x44dp.

**Spacing:** Min 8dp between adjacent touch targets

### 9.2 Color Contrast (WCAG AA)

| Type | Ratio | Examples |
|------|-------|----------|
| Normal text | 4.5:1 | Body text, labels |
| Large text (18sp+) | 3:1 | Headers, titles |
| UI elements | 3:1 | Icons, borders, focus indicators |

**Tools to verify:**
- WebAIM Contrast Checker
- Chrome DevTools Lighthouse

### 9.3 Screen Reader Support

#### ARIA Labels (Complete List)

**Navigation:**
```html
<nav role="navigation" aria-label="Primary navigation">
  <button aria-label="Zakupy" aria-current="page">
    <ShoppingIcon />
  </button>
  <button aria-label="Zadania">
    <TaskIcon />
  </button>
  <button aria-label="Ustawienia">
    <SettingsIcon />
  </button>
</nav>
```

**Shopping List Item:**
```html
<div role="listitem" aria-labelledby="item-1-name">
  <input
    type="checkbox"
    id="item-1"
    aria-label="Oznacz Mleko 2L jako kupione"
    aria-describedby="item-1-meta"
  />
  <span id="item-1-name">Mleko 2L</span>
  <span id="item-1-meta" class="sr-only">
    Kategoria: Mleczne, dodane przez Mama
  </span>
  <button aria-label="Więcej opcji dla Mleko 2L">
    <MoreIcon />
  </button>
</div>
```

**FAB Button:**
```html
<button
  aria-label="Dodaj nowy produkt do listy"
  class="fab"
>
  <PlusIcon aria-hidden="true" />
</button>
```

**Delete Confirmation:**
```html
<div role="dialog" aria-labelledby="dialog-title" aria-modal="true">
  <h2 id="dialog-title">Usuń produkt</h2>
  <p>Czy na pewno chcesz usunąć "Mleko 2L"?</p>
  <button aria-label="Anuluj usuwanie">Anuluj</button>
  <button aria-label="Potwierdź usunięcie Mleko 2L">Usuń</button>
</div>
```

**Tab Navigation:**
```html
<div role="tablist" aria-label="Shopping list sections">
  <button role="tab" aria-selected="true" aria-controls="unchecked-panel">
    Do kupienia (5)
  </button>
  <button role="tab" aria-selected="false" aria-controls="checked-panel">
    Kupione (3)
  </button>
</div>
<div id="unchecked-panel" role="tabpanel" aria-labelledby="unchecked-tab">
  <!-- Unchecked items -->
</div>
```

#### Images & Icons
```html
<!-- Decorative icon (hidden from screen readers) -->
<svg aria-hidden="true" focusable="false">
  <path d="..."/>
</svg>

<!-- Informative image -->
<img
  src="empty-list.svg"
  alt="Pusta lista zakupów - nie dodano jeszcze żadnych produktów"
/>
```

#### Form Fields
```html
<div>
  <label for="product-name">Nazwa produktu</label>
  <input
    id="product-name"
    type="text"
    aria-required="true"
    aria-describedby="product-hint"
    aria-invalid="false"
  />
  <span id="product-hint" class="hint">
    Wpisz nazwę produktu, np. "Mleko 2L"
  </span>
  <span id="product-error" role="alert" class="error" hidden>
    <!-- Error message shown when aria-invalid="true" -->
  </span>
</div>
```

#### Dynamic Content Announcements
```html
<!-- Item added announcement -->
<div
  role="status"
  aria-live="polite"
  aria-atomic="true"
  class="sr-only"
>
  Mleko 2L dodane do listy
</div>

<!-- Critical error -->
<div
  role="alert"
  aria-live="assertive"
  class="sr-only"
>
  Błąd: Nie udało się zapisać zmian
</div>
```

### 9.4 Keyboard Navigation

#### Focus Order
1. Skip to main content link (hidden, keyboard-only)
2. Top navigation (left → right)
3. Main content (top → bottom, left → right)
4. Bottom navigation (left → right)

#### Focus Indicators
- Visible 2dp outline
- Color: Primary color
- Offset: 2dp from element edge
- Never remove `:focus` styles

#### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| Tab | Next focusable element |
| Shift+Tab | Previous focusable element |
| Enter/Space | Activate button/checkbox |
| Escape | Close modal/dialog |
| Arrow keys | Navigate lists (when focused) |

### 9.5 Semantic HTML

Use proper HTML elements:
- `<button>` for actions (not `<div>` with click handler)
- `<a>` for navigation
- `<input>` with correct `type` attribute
- `<nav>` for navigation areas
- `<main>` for main content
- `<header>`, `<footer>` where appropriate
- Headings hierarchy: H1 → H2 → H3 (no skipping)

---

## 10. System States & Edge Cases

### 10.1 Session Timeout Screen

**Trigger:** User inactive for 30 minutes (configurable)

```
+----------------------------------------+
|                                        |
|              [⏱️ icon]                  |
|                                        |
|       Twoja sesja wygasła              |
|    Zaloguj się ponownie aby            |
|    kontynuować                         |
|                                        |
|         [Zaloguj ponownie]             |
|                                        |
+----------------------------------------+
```

**Specs:**
- Full screen takeover
- Clear explanation
- Single CTA button (48x48dp min)
- Auto-redirect to login
- Preserve navigation state (deep link back after re-auth)

**Implementation:**
```javascript
// Show warning 5 minutes before timeout
if (inactiveTime === 25min) {
  showWarningBanner("Sesja wygaśnie za 5 minut");
}

// Logout at 30 minutes
if (inactiveTime === 30min) {
  logout();
  redirectTo('/login', { returnUrl: currentUrl });
}
```

### 10.2 PWA Update Prompt

**Trigger:** New version available (service worker update detected)

```
+----------------------------------------+
| 🎉 Nowa wersja dostępna!              |
| Zaktualizuj aby korzystać z nowych    |
| funkcji                        [X]     |
|                                        |
| [Później]          [Zaktualizuj]      |
+----------------------------------------+
```

**Specs:**
- Position: Top of screen, below nav bar
- Non-blocking (user can dismiss)
- Persist across sessions until updated
- Auto-update on next app launch (if dismissed)

**States:**
- **Available:** Show banner
- **Downloading:** Show progress "Pobieranie aktualizacji..."
- **Ready:** Show "Aktualizacja gotowa - uruchom ponownie"
- **Error:** Show "Aktualizacja nie powiodła się" + retry

**Implementation:**
```javascript
// Service worker lifecycle
sw.addEventListener('updatefound', () => {
  showUpdateBanner({
    message: "Nowa wersja dostępna!",
    actions: [
      { label: "Później", action: dismiss },
      { label: "Zaktualizuj", action: updateNow }
    ]
  });
});
```

### 10.3 Offline Indicator

**Trigger:** Network connection lost

```
+----------------------------------------+
| ⚠️ Brak połączenia z internetem       |
| Zmiany zostaną zapisane po            |
| przywróceniu połączenia         [X]   |
+----------------------------------------+
```

**Specs:**
- Position: Top of screen (banner, not full screen for MVP)
- Color: Warning (#FFA726) background
- Persistent until connection restored
- Show queue count if actions pending: "3 zmiany czekają na synchronizację"

**States:**
- **Offline:** Yellow banner "Brak połączenia"
- **Syncing:** Blue banner "Synchronizacja zmian..."
- **Synced:** Green banner "Wszystko zsynchronizowane" (auto-dismiss 3s)
- **Sync Error:** Red banner "Błąd synchronizacji - spróbuj ponownie"

**Post-MVP Enhancement:**
- Full offline mode with local storage
- Background sync API
- Conflict resolution UI

### 10.4 Rate Limiting UI

**Trigger:** User exceeds API rate limit (soft limit: 100 requests/minute)

**Soft Limit Warning (90% threshold):**
```
Toast notification:
"Zbyt wiele żądań - proszę zwolnić tempo"
```

**Hard Limit Block:**
```
+----------------------------------------+
|              [⏸️ icon]                  |
|                                        |
|     Za dużo żądań                      |
|     Spróbuj ponownie za 42 sekund     |
|                                        |
|     [Odśwież (42s)]                    |
+----------------------------------------+
```

**Specs:**
- Inline message (nie full screen blocker)
- Countdown timer visible
- Button disabled until timer expires
- Auto-enable when rate limit resets

**Implementation:**
```javascript
// Soft limit (90% of rate limit)
if (requestCount >= 90) {
  showToast("Zbyt wiele żądań - proszę zwolnić tempo", {
    type: 'warning',
    duration: 5000
  });
}

// Hard limit (100% of rate limit)
if (requestCount >= 100) {
  disableUI();
  showRateLimitMessage({
    retryAfter: rateLimitReset,
    countdown: true
  });
}
```

---

## 11. Error Messages Catalog (Polish)

### 11.1 Error Types & Display

| Code | Message (Polish) | Display | Recovery Action |
|------|------------------|---------|-----------------|
| **AUTH_INVALID** | "Nieprawidłowy email lub hasło" | Toast (red) | Retry login |
| **AUTH_EXPIRED** | "Sesja wygasła - zaloguj się ponownie" | Full screen | Redirect to login |
| **NETWORK_ERROR** | "Brak połączenia z internetem" | Banner (yellow, persistent) | Queue changes for sync |
| **NETWORK_TIMEOUT** | "Przekroczono czas oczekiwania" | Toast (red) | Retry button |
| **SERVER_ERROR** | "Błąd serwera - spróbuj ponownie" | Toast (red) | Retry button |
| **INVITE_EXPIRED** | "Kod zaproszenia wygasł" | Inline (below input) | Request new code |
| **INVITE_INVALID** | "Nieprawidłowy kod zaproszenia" | Inline (below input) | Re-enter code |
| **INVITE_USED** | "Ten kod został już wykorzystany" | Inline (below input) | Request new code |
| **LIST_NOT_FOUND** | "Lista nie została znaleziona" | Toast (red) | Return to lists |
| **ITEM_CONFLICT** | "Produkt został zmieniony przez innego użytkownika" | Toast (orange) | Refresh + retry |
| **RATE_LIMIT** | "Za dużo żądań - spróbuj ponownie za {seconds} sekund" | Inline (disabled state) | Wait + auto-retry |
| **PERMISSION_DENIED** | "Nie masz uprawnień do tej akcji" | Toast (red) | Contact admin |
| **VALIDATION_REQUIRED** | "To pole jest wymagane" | Inline (below field) | Fill field |
| **VALIDATION_TOO_LONG** | "Maksymalnie {max} znaków" | Inline (below field) | Shorten text |
| **SYNC_ERROR** | "Nie udało się zsynchronizować zmian" | Banner (red) | Manual retry button |

### 11.2 Error Display Patterns

**Toast (Non-blocking):**
```html
<div role="alert" aria-live="polite" class="toast toast-error">
  <span class="icon">⚠️</span>
  <span class="message">Nieprawidłowy email lub hasło</span>
  <button aria-label="Zamknij komunikat" class="close">×</button>
</div>
```

**Banner (Persistent):**
```html
<div role="alert" aria-live="assertive" class="banner banner-warning">
  <span class="icon">⚠️</span>
  <span class="message">Brak połączenia z internetem</span>
  <button class="action">Spróbuj ponownie</button>
  <button aria-label="Zamknij" class="close">×</button>
</div>
```

**Inline (Form validation):**
```html
<div class="form-field">
  <label for="invite-code">Kod zaproszenia</label>
  <input
    id="invite-code"
    type="text"
    aria-invalid="true"
    aria-describedby="invite-error"
  />
  <span id="invite-error" role="alert" class="error">
    Kod zaproszenia wygasł
  </span>
</div>
```

**Full Screen (Blocking):**
```html
<div role="dialog" aria-modal="true" class="error-screen">
  <div class="error-content">
    <svg class="icon" aria-hidden="true"><!-- Error icon --></svg>
    <h2>Sesja wygasła</h2>
    <p>Zaloguj się ponownie aby kontynuować</p>
    <button class="primary">Zaloguj ponownie</button>
  </div>
</div>
```

---

## 12. Notification Settings (Granular Control)

**Location:** Settings > Notifications

### 12.1 Notification Categories

```
┌─────────────────────────────────────┐
│ Powiadomienia                       │
├─────────────────────────────────────┤
│ [✓] Nowe produkty na listach       │
│     Gdy ktoś doda produkt           │
│                                     │
│ [✓] Zmiany w zadaniach             │
│     Gdy zadanie zostanie            │
│     przypisane lub zmienione        │
│                                     │
│ [✓] Nowi członkowie gospodarstwa   │
│     Gdy ktoś dołączy do domu        │
│                                     │
│ [ ] Przypomnienia o listach        │
│     Codziennie o 9:00 AM            │
│                                     │
│ [—] Wszystkie wyłączone            │
│                                     │
└─────────────────────────────────────┘
```

### 12.2 Notification Specs

**Settings Object:**
```javascript
{
  notifications: {
    enabled: true,
    categories: {
      shopping: {
        enabled: true,
        label: "Nowe produkty na listach",
        description: "Gdy ktoś doda produkt"
      },
      tasks: {
        enabled: true,
        label: "Zmiany w zadaniach",
        description: "Gdy zadanie zostanie przypisane lub zmienione"
      },
      members: {
        enabled: true,
        label: "Nowi członkowie gospodarstwa",
        description: "Gdy ktoś dołączy do domu"
      },
      reminders: {
        enabled: false,
        label: "Przypomnienia o listach",
        description: "Codziennie o 9:00 AM"
      }
    }
  }
}
```

**Toggle "Wszystkie wyłączone":**
- Disables all categories with single tap
- Changes to "Włącz wszystkie" when any category is enabled
- Preserves individual preferences (restore on re-enable)

---

## 13. Platform-Specific Considerations

### 13.1 PWA Requirements

#### Install Prompt
- Show custom install banner after 2 visits
- Position: Bottom, non-intrusive
- Dismissible (don't show again for 7 days)

#### Offline Support (Post-MVP)
- Service worker for caching
- "You're offline" banner when no connection
- Queue actions for sync when back online

#### App Icon
- 512x512px PNG
- Transparent or solid background
- Simple, recognizable icon
- Follows material design guidelines

### 13.2 iOS Specific

#### Safe Areas
```css
padding-top: env(safe-area-inset-top);
padding-bottom: env(safe-area-inset-bottom);
```

#### Scroll Behavior
- Enable momentum scrolling: `-webkit-overflow-scrolling: touch;`
- Prevent zoom on input focus (font-size >= 16px)

#### Home Screen
- `apple-touch-icon` (180x180px)
- `apple-mobile-web-app-capable` for standalone mode
- `apple-mobile-web-app-status-bar-style`

### 13.3 Android Specific

#### Theme Color
```html
<meta name="theme-color" content="#1976D2">
```
- Changes status bar color
- Matches app primary color

#### Splash Screen
- Generated from manifest icon
- Background color: Primary color

---

## 14. Performance Guidelines

### 14.1 Image Optimization

| Type | Format | Max Size | Strategy |
|------|--------|----------|----------|
| Icons | SVG | - | Inline or sprite |
| Photos | WebP (fallback: JPEG) | 500KB | Lazy load |
| Illustrations | SVG | 50KB | Inline |
| Avatar placeholders | SVG or data URI | 5KB | Inline |

### 14.2 Loading Strategy

1. **Critical CSS inline** in `<head>`
2. **Defer non-critical JS**
3. **Lazy load below-the-fold** images
4. **Preload key assets** (fonts, hero images)

### 14.3 Performance Budget

| Metric | Target | Tool |
|--------|--------|------|
| Time to Interactive | < 3s | Lighthouse |
| First Contentful Paint | < 1.5s | Lighthouse |
| Lighthouse Score | >= 90 | Chrome DevTools |
| Bundle size (JS) | < 200KB gzipped | Webpack Bundle Analyzer |

---

## 15. Handoff to Frontend

### 15.1 Deliverables

| Artifact | Location | Status |
|----------|----------|--------|
| UX Specification (this doc) | docs/1-BASELINE/ux/UX-SPECIFICATION.md | ✅ Complete (v1.1) |
| Wireframes | docs/1-BASELINE/ux/WIREFRAMES.md | ⏳ Next |
| User Flows | docs/1-BASELINE/ux/flows/USER-FLOWS.md | ⏳ Next |
| Component Specs | docs/1-BASELINE/ux/components/* | ⏳ If needed |

### 15.2 Design Tokens (for Frontend)

```json
{
  "colors": {
    "primary": "#1976D2",
    "primaryDark": "#1565C0",
    "primaryLight": "#BBDEFB",
    "accent": "#4CAF50",
    "error": "#D32F2F",
    "warning": "#FFA726",
    "success": "#4CAF50",
    "background": "#FFFFFF",
    "surface": "#F5F5F5",
    "textPrimary": "#212121",
    "textSecondary": "#757575"
  },
  "spacing": {
    "xs": "4dp",
    "sm": "8dp",
    "md": "12dp",
    "lg": "16dp",
    "xl": "24dp",
    "xxl": "32dp"
  },
  "typography": {
    "h1": { "size": "32sp", "weight": "bold" },
    "h2": { "size": "24sp", "weight": "bold" },
    "body1": { "size": "16sp", "weight": "regular" },
    "caption": { "size": "12sp", "weight": "regular" }
  },
  "borderRadius": {
    "sm": "4dp",
    "md": "8dp",
    "lg": "12dp",
    "xl": "16dp"
  }
}
```

### 15.3 Implementation Notes

#### Component Priority (Sprint Order)
1. **Week 1:** Buttons, Inputs, Navigation (Bottom Nav, Top Bar)
2. **Week 2:** List components (Shopping Item, Checkboxes), Modals
3. **Week 3:** Cards, Empty/Error states, Animations

#### Testing Checklist
- [ ] Test on iPhone SE (smallest screen: 375x667)
- [ ] Test on Android mid-range (412x915 common)
- [ ] Test on tablet (768px+)
- [ ] Test dark mode on all screens
- [ ] Test with Polish & English languages
- [ ] Run Lighthouse audit (target: 90+)
- [ ] Test keyboard navigation
- [ ] Test with screen reader (VoiceOver/TalkBack)
- [ ] Test session timeout flow
- [ ] Test offline indicator
- [ ] Test PWA update prompt

---

## 16. Open Questions for PM (RESOLVED)

### 16.1 Resolved Decisions

1. **~~Color branding:~~ RESOLVED**
   - ✅ Blue (#1976D2) + Green (#4CAF50) zatwierdzone
   - Rationale: Trust + Home associations, professional yet friendly

2. **~~Invite code security:~~ RESOLVED**
   - ✅ Single-use codes (bardziej bezpieczne)
   - Expire after: 7 days or first use

3. **~~Rate limiting UI:~~ RESOLVED**
   - ✅ Soft limit with komunikatem "Spróbuj ponownie za X sekund"
   - Hard limit: Disable UI with countdown timer

### 16.2 Still Open Questions

1. **Avatar personalization:** Czy users mogą wybrać avatar/kolor w MVP, czy tylko inicjały?
2. **Empty state illustrations:** Czy mamy budget na custom illustrations, czy używamy ikon?
3. **Onboarding skip:** Czy można pominąć onboarding tutorial w MVP (zero learning curve)?
4. **Language selector:** Domyślnie auto-detect z przeglądarki, czy pytać usera?
5. **Session timeout duration:** 30 minutes OK, czy krócej/dłużej?

---

## 17. Updates Log

| Date | Change | Author | Version |
|------|--------|--------|---------|
| 2025-12-09 | Initial draft | Sally (UX Designer) | 1.0 |
| 2025-12-09 | Added missing screens (session timeout, PWA update, offline) | Sally (UX Designer) | 1.1 |
| 2025-12-09 | Added complete ARIA labels catalog | Sally (UX Designer) | 1.1 |
| 2025-12-09 | Added error messages catalog (Polish) | Sally (UX Designer) | 1.1 |
| 2025-12-09 | Added notification settings (granular control) | Sally (UX Designer) | 1.1 |
| 2025-12-09 | Resolved open questions (color, invite code, rate limit) | Sally (UX Designer) | 1.1 |

---

## Appendix: Related Documents

- **PRD:** @docs/1-BASELINE/PRD.md
- **UX Principles:** @docs/1-BASELINE/ux/UX-PRINCIPLES.md
- **UI/UX Research:** @docs/1-BASELINE/research/ui-ux-research.md (color decision)
- **Wireframes:** @docs/1-BASELINE/ux/WIREFRAMES.md (next)
- **User Flows:** @docs/1-BASELINE/ux/flows/USER-FLOWS.md (next)
- **Project Understanding:** @docs/0-DISCOVERY/PROJECT-UNDERSTANDING.md

---

**Document Version:** 1.1
**Last Updated:** 2025-12-09
**Author:** Sally (UX Designer)
**Status:** Draft → Ready for Review
**Next Steps:** Create wireframes for all MVP screens with 4 states each
