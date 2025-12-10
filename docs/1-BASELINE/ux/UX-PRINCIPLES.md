# HomeOS - UX Design Principles

**Data:** 2025-12-09
**Status:** Reference dla UX Designer
**Źródło:** Ekstrakcja z oryginalnego PRD MyHome

---

## Design Philosophy

### Principle #1: Zero Learning Curve
- Interfejs tak intuicyjny że rodzice i dziadkowie używają bez instrukcji
- Common patterns (swipe to delete, tap to edit, pull to refresh)
- Minimal onboarding (< 2 ekrany, skip option)
- Contextual hints tylko gdy needed ("Tap + to add item")

### Principle #2: Speed Above All
- Każda akcja zajmuje **< 3 taps**
- Dodanie produktu: tap "+" → wpisz nazwę → tap "Dodaj" (2 taps + typing)
- Oznaczenie jako kupione: **single tap** na checkbox
- No unnecessary confirmations ("Are you sure?" tylko dla destructive actions)

### Principle #3: Family-Friendly
- Czytelne dla wszystkich age groups (duże fonts, high contrast)
- Neutral aesthetics (nie childish, nie corporate - "home-like")
- Personalizacja (każdy member może mieć avatar/color)
- Positive reinforcement (checkmarks, subtle animations, not overwhelming)

### Principle #4: Real-time Trust
- Widoczność kto co zrobił ("Mama dodała", "Tata kupił")
- Confidence w sync (timestamp ostatniej synchronizacji)
- Connection status always visible

---

## Visual Personality

### Mood
**Warm, reliable, uncluttered, family-oriented**

### NOT:
- Gamified/playful (nie Duolingo vibes)
- Corporate/sterile (nie enterprise SaaS)
- Minimalist-to-fault (nie hiding functionality)

### BUT:
- Clean and organized (like well-managed home)
- Accessible and comfortable (like favorite app you use daily)
- Trustworthy (handles family data, needs to feel secure)

---

## Key Interactions

### 1. Adding Shopping Item (Primary Flow)
```
Tap FAB "+" (bottom right)
    ↓
Modal: "Dodaj produkt"
    ↓
Input auto-focused, keyboard appears
    ↓
Type name (autocomplete suggests previous items)
    ↓
Optional: tap category chip
    ↓
Optional: add quantity
    ↓
Tap "Dodaj" lub Enter
    ↓
Item appears at top (optimistic update)
```
**Total time: ~5-10 seconds**

### 2. Marking Item as Purchased
```
Tap checkbox
    ↓
Checkbox animates to checked
    ↓
Item moves to "Kupione" section
    ↓
Subtle strikethrough
```
**Total time: < 1 second (single tap)**

### 3. Editing Item
```
Tap on item row
    ↓
Inline edit mode or modal
    ↓
Update name/quantity/category
    ↓
Tap "Zapisz"
```
**Total time: ~3-5 seconds**

### 4. Deleting Item
```
Swipe left on item (iOS) / Long-press (Android)
    ↓
Delete button appears (red)
    ↓
Tap "Usuń"
    ↓
Confirmation: "Usunąć [item]?"
    ↓
Item removed
```
**Total time: ~2-3 seconds**

### 5. Inviting Family Member
```
Navigate to Settings/Home
    ↓
Tap "Zaproś członka"
    ↓
6-digit code + QR displayed
    ↓
"Kopiuj kod" button
    ↓
Share via WhatsApp/SMS/email
```
**Total time: ~10 seconds**

### 6. Joining Home via Code
```
New user registers/logs in
    ↓
Prompt: "Dołącz" / "Stwórz nowy"
    ↓
Select "Dołącz"
    ↓
Enter 6-digit code OR scan QR
    ↓
Tap "Dołącz"
    ↓
Success: "Dołączyłeś do [nazwa]!"
```
**Total time: ~15-20 seconds**

---

## Navigation Structure (MVP)

### Bottom Tab Navigation (Mobile)
1. **Zakupy** (Home) - Shopping list view (default)
2. **Zadania** - Tasks preview (oznaczone "Preview")
3. **Ustawienia** - Home members, invite, account

### Top Bar
- Left: Home name ("Dom Kowalskich")
- Right: Theme toggle, Account avatar

---

## Responsive Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| **Mobile** | < 768px | Single column, bottom nav, full-width |
| **Tablet** | 768-1024px | Two columns where sensible, side nav option |
| **Desktop** | > 1024px | Multi-column, persistent nav |

---

## Accessibility Requirements

- [ ] Kontrast tekstu >= 4.5:1 (WCAG AA)
- [ ] Focus states dla keyboard navigation
- [ ] Touch targets >= 44px
- [ ] Alt text dla images
- [ ] Semantic HTML
- [ ] Minimum font size: 16px

---

## Brand Guidelines

### Nazwa
**HomeOS**

### Ton
Professional/practical + emoji/smaczki (nie za sucha)

### Kolory
Do ustalenia - sugestia:
- Primary: Niebieski (trust, reliability)
- Accent: Zielony (home, growth)
- Background: Neutralne (white/dark gray)
- Error: Czerwony
- Success: Zielony

### Typografia
System fonts dla wydajności:
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

---

## Dark Mode

### Implementation
- Toggle w Settings
- Auto-detect system preference
- Smooth transition animation
- Persist preference

### Colors
- Background: #121212 (nie pure black)
- Surface: #1E1E1E
- Text: #E0E0E0
- Accent: Lighter versions of primary colors

---

## Loading & Error States

### Loading
- Skeleton screens (nie spinners)
- Optimistic updates where possible
- Progress indicators dla długich operacji

### Errors
- Polish language messages
- Actionable (co user może zrobić)
- Nie techniczny żargon
- Toast notifications dla non-blocking
- Full screen dla blocking errors

### Empty States
- Friendly illustrations
- Clear CTA ("Dodaj pierwszy produkt")
- Helpful hints

---

## Micro-interactions

### Checkoff Animation
```
Tap → Scale down (0.9) → Checkmark draws → Scale up (1.0) → Move to bottom
Duration: 300ms
Easing: ease-out
```

### Add Item Animation
```
Item fades in from top → Slides into position
Duration: 200ms
```

### Delete Animation
```
Item slides out to left → Height collapses
Duration: 250ms
```

### Pull to Refresh
```
Pull down → Spinner appears → Release → Refresh → Bounce back
```

---

## Component Checklist (MVP)

### Forms
- [ ] Input fields with labels
- [ ] Validation messages
- [ ] Submit buttons
- [ ] Loading states

### Lists
- [ ] Shopping list item row
- [ ] Task item row
- [ ] Member list row
- [ ] Empty states

### Modals
- [ ] Add item modal
- [ ] Edit item modal
- [ ] Confirm delete modal
- [ ] Invite modal

### Navigation
- [ ] Bottom tab bar
- [ ] Top app bar
- [ ] Back button

### Feedback
- [ ] Toast notifications
- [ ] Loading skeleton
- [ ] Error states
- [ ] Success states

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Source:** Extracted from original MyHome PRD (docsOld)
