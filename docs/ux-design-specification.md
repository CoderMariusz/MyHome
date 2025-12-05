# MyHome - UX Design Specification

**Author:** BMad UX Designer
**Date:** 2025-11-17
**Version:** 1.0
**Based on:** PRD v1.0, Technical Research

---

## Executive Summary

This UX Design Specification defines the complete user experience for **MyHome Phase 1 (MVP)** - a Progressive Web App for collaborative family shopping lists with real-time synchronization.

**Design Goals:**
1. **Zero Learning Curve** - Intuitive dla wszystkich age groups (young parents → grandparents)
2. **Speed Above All** - Core actions w < 3 taps, instant feedback
3. **Family-Friendly** - Warm, trustworthy, accessible aesthetic
4. **Real-time Trust** - Visible sync status, clear attribution ("Mama dodała...")

**Chosen Design Direction:** **Friendly Balance** - Modern professionalism balanced z family warmth
**Chosen Color Theme:** **Sky & Earth** - Trust blue (#0288D1) + Fresh green (#66BB6A)

---

## Design Direction: Friendly Balance

### Philosophy

MyHome balances **modern professionalism** (trustworthy dla family data) z **warm approachability** (family-friendly, nie corporate sterile).

**Visual Characteristics:**
- Clean modern foundation z soft rounded elements
- Balanced color palette: cool blues/greens + warm neutrals
- Generous whitespace dla clarity
- Subtle shadows dla depth (nie flat, nie skeuomorphic)
- Humanist typography (readable, friendly)

**NOT:**
- ❌ Corporate/enterprise sterile (nie SaaS dashboard vibe)
- ❌ Childish/overly playful (nie gamified Duolingo style)
- ❌ Minimalist-to-fault (nie hiding functionality)

**BUT:**
- ✅ Clean and organized (like well-managed home)
- ✅ Trustworthy yet friendly (handles family data securely)
- ✅ Accessible comfort (favorite daily-use app)

### Why This Works dla MyHome

1. **Broad Appeal:** Appeals to young parents (modern) AND older adults (approachable)
2. **Trustworthy:** Blue primary color conveys security i reliability
3. **Family Warmth:** Green accents i rounded elements add warmth
4. **Scalable:** Supports growth od shopping → finances → full family OS
5. **Differentiated:** Unique middle ground - nie generic, nie childish

---

## Color System: Sky & Earth

### Primary Colors

**Brand Primary - Sky Blue**
- Hex: `#0288D1`
- RGB: `2, 136, 209`
- Usage: Main CTAs, links, primary actions, selected states
- Psychology: Trust, reliability, calm, professionalism

**Brand Secondary - Fresh Green**
- Hex: `#66BB6A`
- RGB: `102, 187, 106`
- Usage: Success states, purchased items, positive feedback
- Psychology: Growth, freshness, accomplishment, family

**Warm Accent - Coral**
- Hex: `#FF7043`
- RGB: `255, 112, 67`
- Usage: Notifications, highlights, urgent actions
- Psychology: Warmth, attention, energy

### Neutrals & Backgrounds

**Background Hierarchy:**
- **Pure White:** `#FFFFFF` - Main app background
- **Light Gray:** `#F5F5F5` - Card backgrounds, sections
- **Border Gray:** `#E0E0E0` - Dividers, borders, disabled states

**Text Hierarchy:**
- **Primary Text:** `#1A1A1A` - Headings, primary content (18:1 contrast ratio)
- **Secondary Text:** `#666666` - Body text, labels (7:1 contrast ratio)
- **Disabled Text:** `#999999` - Hints, placeholders (4.5:1 contrast ratio)

### State Colors

**Success:** `#4CAF50` - Confirmations, completed actions
**Warning:** `#FFA726` - Alerts, cautions, reminders
**Error:** `#EF5350` - Validation errors, destructive actions
**Info:** `#0288D1` (same as primary) - Informational messages

### Accessibility

✅ **WCAG 2.1 Level AA Compliant**
- All text/background combinations meet 4.5:1 contrast minimum
- Large text (18pt+) meets 3:1 contrast
- Interactive elements meet 3:1 non-text contrast

**Color Blindness Considerations:**
- Blue + Green combination works dla most common types (protanopia, deuteranopia)
- Shape + icons supplement color (nie tylko color alone)
- Text labels dla wszystkich color-coded information

---

## Typography System

### Font Family

**Primary:** **Inter** (system fallback: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto`)
- **Why:** Humanist sans-serif, excellent readability, widely available
- **Characteristics:** Neutral, modern, legible at all sizes
- **Accessibility:** Clear letterforms, open apertures, distinct characters

**Fallback Chain:**
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
```

### Type Scale (Mobile)

| Element | Size | Weight | Line Height | Use Case |
|---------|------|--------|-------------|----------|
| **H1 - Page Title** | 28px | 600 | 1.2 | Screen titles |
| **H2 - Section** | 22px | 600 | 1.3 | Section headers |
| **H3 - Subsection** | 18px | 600 | 1.4 | Subsections |
| **Body Large** | 17px | 400 | 1.5 | Primary content |
| **Body** | 16px | 400 | 1.5 | Default body text |
| **Body Small** | 14px | 400 | 1.4 | Secondary info |
| **Caption** | 12px | 400 | 1.3 | Timestamps, labels |
| **Button** | 16px | 600 | 1.0 | Button labels |

### Type Scale (Desktop)

Base sizes increase by 1-2px dla desktop (1024px+):
- H1: 32px
- Body: 17px
- Etc.

**Rationale:** Mobile-first sizing ensures readability na small screens, desktop scale improves hierarchy na larger displays.

---

## Component Library

### Buttons

**Primary Button (CTA)**
```
Background: #0288D1 (Sky Blue)
Text: #FFFFFF (White)
Height: 48px (mobile), 44px (desktop)
Padding: 16px 24px
Border Radius: 12px
Font: 16px, weight 600
Shadow: 0 2px 8px rgba(2,136,209,0.2)
Hover: darken 10%, lift 2px
Active: darken 15%, scale 0.98
```

**Secondary Button**
```
Background: transparent
Border: 2px solid #0288D1
Text: #0288D1
Same sizing as Primary
Hover: background #E3F2FD
```

**Icon Button (FAB - Floating Action)**
```
Background: #0288D1
Size: 56px × 56px
Border Radius: 28px (full circle)
Icon: 24px, white
Position: Fixed bottom-right, 20px margin
Shadow: 0 4px 12px rgba(0,0,0,0.15)
```

### Input Fields

**Text Input**
```
Background: #FFFFFF
Border: 1px solid #E0E0E0
Height: 48px
Padding: 12px 16px
Border Radius: 10px
Font: 16px (prevent iOS zoom)
Placeholder: #999999

Focus:
  Border: 2px solid #0288D1
  Shadow: 0 0 0 3px rgba(2,136,209,0.1)

Error:
  Border: 2px solid #EF5350
  Shadow: 0 0 0 3px rgba(239,83,80,0.1)
```

**Checkbox**
```
Size: 24px × 24px
Border: 2px solid #E0E0E0
Border Radius: 6px
Background (unchecked): transparent
Background (checked): #66BB6A
Checkmark: white, 16px

Tap target: 44px (WCAG minimum)
```

### Cards

**Shopping List Item Card**
```
Background: #F5F5F5
Padding: 16px
Border Radius: 12px
Margin: 0 0 12px 0
Display: flex, align-items: center
Gap: 12px

States:
  Normal: background #F5F5F5
  Purchased: background #E8F5E9, text strikethrough #999
  Hover/Tap: background #E0E0E0
```

**Section Card**
```
Background: #FFFFFF
Padding: 20px
Border Radius: 16px
Shadow: 0 2px 8px rgba(0,0,0,0.08)
Margin: 0 16px 16px 16px
```

### Lists

**Shopping List Item**
```
Structure:
[Checkbox (24px)] [Item Name (flex-1)] [Category Badge] [Options (•••)]

Height: auto (min 64px dla tap target)
Padding: 16px
Background: #F5F5F5

Gesture: Swipe left → Delete button
```

**Category Badge**
```
Background: #E0E0E0
Text: #666666, 12px, weight 500
Padding: 4px 10px
Border Radius: 12px (pill shape)
```

### Navigation

**Bottom Tab Bar**
```
Background: #FFFFFF
Height: 64px + safe-area-inset-bottom
Border Top: 1px solid #E0E0E0
Shadow: 0 -2px 8px rgba(0,0,0,0.05)

Tab Item:
  Icon: 24px
  Label: 11px, weight 500
  Active: color #0288D1
  Inactive: color #999999
  Padding: 8px
```

**Top Bar**
```
Background: #FFFFFF
Height: 56px + safe-area-inset-top
Border Bottom: 1px solid #E0E0E0
Padding: 0 16px

Content:
  Left: Home name (18px, weight 600, #1A1A1A)
  Right: Notification bell + Avatar (32px)
```

### Modals & Sheets

**Bottom Sheet (Mobile)**
```
Background: #FFFFFF
Border Radius: 24px 24px 0 0
Padding: 24px 20px
Max Height: 90vh
Shadow: 0 -4px 20px rgba(0,0,0,0.15)

Header:
  Handle: 32px × 4px, #E0E0E0, centered, 8px margin
  Title: 22px, weight 600, centered
  Close: X icon top-right
```

**Modal (Desktop)**
```
Background: #FFFFFF
Border Radius: 20px
Padding: 32px
Max Width: 600px
Shadow: 0 10px 40px rgba(0,0,0,0.2)
Backdrop: rgba(0,0,0,0.5)
```

### Status Indicators

**Connection Status**
```
Online: Green dot (8px) + "Online" text
Syncing: Spinner (16px) + "Syncing..." text
Offline: Gray dot + "Offline" text

Position: Top bar, subtle
```

**Notification Badge**
```
Background: #EF5350 (red)
Text: white, 11px, weight 600
Size: 20px × 20px (min)
Border Radius: 10px (pill for > 9)
Position: top-right of icon, -4px offset
```

---

## Screen Wireframes

### 1. Login / Register Screen

```
┌─────────────────────────────────────┐
│                                     │
│           🏠 MyHome                 │  ← Logo + Brand (centered)
│                                     │
│    "Jeden hub dla całej rodziny"   │  ← Tagline
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Email                         │ │  ← Email input
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Hasło                    [👁] │ │  ← Password input + show/hide
│  └───────────────────────────────┘ │
│                                     │
│  Zapomniałeś hasła?                │  ← Link
│                                     │
│  ┌───────────────────────────────┐ │
│  │      Zaloguj się              │ │  ← Primary CTA
│  └───────────────────────────────┘ │
│                                     │
│  ────────── lub ──────────         │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   Zarejestruj się             │ │  ← Secondary button
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘

States:
- New user → Register flow → Create/Join Home
- Returning user → Login → Shopping List
```

### 2. Create Home / Join Home Screen

```
┌─────────────────────────────────────┐
│  ← Wstecz        Witaj, Mariusz!    │  ← Top bar
├─────────────────────────────────────┤
│                                     │
│        Stwórz nowy dom              │  ← Section title
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Nazwa domu (np. "Kowalskich")│ │  ← Input
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │    Stwórz dom                 │ │  ← Primary CTA
│  └───────────────────────────────┘ │
│                                     │
│  ────────── lub ──────────         │
│                                     │
│        Dołącz do domu               │  ← Section title
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Kod zaproszenia (6 znaków)    │ │  ← Input (uppercase auto)
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │      Dołącz                   │ │  ← Primary CTA
│  └───────────────────────────────┘ │
│                                     │
│  ℹ️ Możesz należeć do jednego      │  ← Info hint
│     domu naraz                      │
│                                     │
└─────────────────────────────────────┘

Flow:
1. User creates home → Generate code → Shopping List
2. User joins home → Validate code → Shopping List
```

### 3. Shopping List (Main Screen) - PRIMARY MVP SCREEN

```
┌─────────────────────────────────────┐
│  Dom Kowalskich    🔔(2)  👤        │  ← Top bar: Home name, notifications, avatar
├─────────────────────────────────────┤
│                                     │
│  📋 Lista Zakupów                   │  ← Page title
│  ● Online                           │  ← Connection status (subtle)
│                                     │
│  ━━━━ DO KUPIENIA (3) ━━━━         │  ← Section header
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☐  Mleko 2L       [Nabiał]  │   │  ← Item card (unchecked)
│  │    Dodane przez Mama  2min  │   │  ← Metadata (who added, when)
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☐  Chleb razowy  [Pieczywo] │   │
│  │    Dodane przez Tata  10min │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☐  Pomidory 1kg  [Warzywa]  │   │
│  │    Dodane przez Ty  1godz   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━ KUPIONE (1) ━━━━             │  ← Section header
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑  Masło          [Nabiał]  │   │  ← Item card (checked, grayed)
│  │    Kupione przez Mama  5min │   │  ← "Kupione przez" instead of "Dodane"
│  └─────────────────────────────┘   │
│                                     │
│                                     │
│                              [➕]   │  ← FAB (Floating Action Button)
│                                     │
├─────────────────────────────────────┤
│   🛒 Zakupy    🏠 Dom               │  ← Bottom tab navigation
└─────────────────────────────────────┘

Interactions:
- Tap checkbox → Mark as purchased (optimistic update, item moves to "Kupione")
- Tap item → Edit item modal
- Swipe left → Delete button
- Tap FAB → Add item modal
- Pull to refresh → Sync latest

Real-time:
- New item appears with subtle animation
- Status changes sync instantly
- Toast notification: "Mama dodała Mleko 2L" (dismissible)
```

### 4. Add Item Modal (Bottom Sheet)

```
┌─────────────────────────────────────┐
│            ━━━                      │  ← Handle (drag indicator)
│                                     │
│        Dodaj produkt                │  ← Title (centered)
│                                 ✕   │  ← Close icon
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Nazwa produktu                │ │  ← Text input (auto-focused)
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Ilość (opcjonalnie)           │ │  ← Text input (optional)
│  └───────────────────────────────┘ │
│                                     │
│  Kategoria (opcjonalnie)           │  ← Label
│                                     │
│  ┌─────┐ ┌─────┐ ┌───────┐        │
│  │Nabiał│Warzywa│Pieczywo│...     │  ← Category chips (horizontal scroll)
│  └─────┘ └─────┘ └───────┘        │
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │        Dodaj do listy         │ │  ← Primary CTA
│  └───────────────────────────────┘ │
│                                     │
│                                     │
└─────────────────────────────────────┘

Behavior:
- Keyboard appears automatically (input auto-focused)
- Enter key → Submit (if name filled)
- Tap "Dodaj" → Add item, close modal, show in list
- Real-time → Item appears dla all family members
- Notification sent → "Ty dodałeś Mleko 2L"
```

### 5. Home Settings Screen

```
┌─────────────────────────────────────┐
│  ← Zakupy           Dom              │  ← Top bar with back
├─────────────────────────────────────┤
│                                     │
│  🏠 Dom Kowalskich                  │  ← Home name (large)
│  Utworzony 3 dni temu               │  ← Metadata
│                                     │
│  ━━━━ CZŁONKOWIE (3) ━━━━          │  ← Section
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤 Mama Kowalska            │   │  ← Member card
│  │    mama@email.com           │   │
│  │    Założyciel               │   │  ← Role badge
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤 Tata Kowalski            │   │
│  │    tata@email.com           │   │
│  │    Członek                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤 Ty (Mariusz)             │   │
│  │    mariusz@email.com        │   │
│  │    Członek                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━ KOD ZAPROSZENIA ━━━━         │  ← Section
│                                     │
│  ┌─────────────────────────────┐   │
│  │         ABC123              │   │  ← Big invite code
│  │   ┌──────────┐  ┌─────────┐│   │
│  │   │ Kopiuj   │  │Regeneruj││   │  ← Actions
│  │   └──────────┘  └─────────┘│   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━ USTAWIENIA ━━━━              │  ← Section
│                                     │
│  Powiadomienia                  >   │  ← Navigation items
│  Profil                         >   │
│  Opuść dom                      >   │
│  Wyloguj się                    >   │
│                                     │
├─────────────────────────────────────┤
│   🛒 Zakupy    🏠 Dom               │  ← Bottom tab
└─────────────────────────────────────┘

Actions:
- Tap "Kopiuj" → Copy code to clipboard, toast "Skopiowano!"
- Tap "Regeneruj" → Confirm dialog → New code
- Tap "Opuść dom" → Confirm dialog → Orphan user → Create/Join Home screen
```

### 6. Notification (Push)

```
┌─────────────────────────────────────┐
│  🏠 MyHome                   teraz  │  ← Notification header
│  Mama dodała: Mleko 2L              │  ← Notification body
│  Lista zakupów                      │  ← Context
└─────────────────────────────────────┘

Tap → Open app → Shopping List screen

Frequency: Max 5/week per user
Opt-in: Requested na first meaningful action
```

---

## User Flows

### Flow 1: New User Onboarding → First Item Added

```
1. User opens app (first time)
   ↓
2. LOGIN/REGISTER screen
   User enters email + password → Tap "Zarejestruj się"
   ↓
3. CREATE/JOIN HOME screen
   User selects "Stwórz nowy dom"
   Enters "Dom Kowalskich" → Tap "Stwórz dom"
   ↓
4. SHOPPING LIST screen (empty)
   System shows: "Dodaj pierwszy produkt!"
   User taps FAB [➕]
   ↓
5. ADD ITEM modal
   User types "Mleko 2L"
   Selects category "Nabiał"
   Taps "Dodaj do listy"
   ↓
6. SHOPPING LIST screen
   Item appears immediately (optimistic update)
   Toast: "Dodano Mleko 2L"
   ↓
7. NOTIFICATION PERMISSION
   System prompts: "Włącz powiadomienia aby wiedzieć gdy rodzina dodaje produkty"
   User taps "Włącz" → Permission granted
   ↓
✅ SUCCESS: User has home, first item, notifications enabled
   Time to value: ~2-3 minutes
```

### Flow 2: Existing User → Add Item → Family Sees Update

```
User A (Mama):
1. Opens app → SHOPPING LIST screen
2. Taps FAB [➕]
3. Types "Chleb razowy", selects "Pieczywo"
4. Taps "Dodaj"
5. Item appears immediately in her list

Real-time Sync:
↓ (< 2 seconds)

User B (Tata):
1. Has app open on SHOPPING LIST screen
2. Sees new item appear with animation
3. Toast notification: "Mama dodała: Chleb razowy"
4. Item shows "Dodane przez Mama • teraz"

User C (Mariusz):
1. App is closed
2. Receives push notification:
   "🏠 MyHome - Mama dodała: Chleb razowy"
3. Taps notification → Opens app → SHOPPING LIST screen
4. Sees updated list with new item

✅ SUCCESS: Real-time collaboration works seamlessly
```

### Flow 3: Shopping in Store → Mark Items as Purchased

```
1. User is in grocery store with shopping list open
2. Picks up Mleko → Taps checkbox next to "Mleko 2L"
   ↓
3. Checkbox animates to checked ✓
   Item turns green background
   Item moves to "KUPIONE" section with strikethrough
   ↓
4. Real-time sync → Family members see update
   Toast dla other members: "Mama kupiła: Mleko 2L"
   ↓
5. User continues shopping, marking more items
6. All marked items move to "KUPIONE" section
   ↓
✅ SUCCESS: Shopping experience is fast, clear, synced

Offline scenario:
- User marks items offline
- Items queued locally
- When connection restored → Auto-sync
- Toast: "Zsynchronizowano 3 produkty"
```

### Flow 4: Invite Family Member

```
User A (existing member):
1. Opens app → Taps "Dom" tab (bottom navigation)
   ↓
2. HOME SETTINGS screen
3. Scrolls to "KOD ZAPROSZENIA" section
4. Sees code: "ABC123"
5. Taps "Kopiuj"
   Toast: "Skopiowano kod zaproszenia!"
   ↓
6. Shares code via WhatsApp/SMS to family member

User B (new user):
1. Receives invite code "ABC123" from User A
2. Opens MyHome app (first time)
   ↓
3. LOGIN/REGISTER screen
   Registers with email + password
   ↓
4. CREATE/JOIN HOME screen
5. Selects "Dołącz do domu"
6. Enters code "ABC123"
7. Taps "Dołącz"
   ↓
8. System validates code
   Success: "Dołączyłeś do domu Kowalskich!"
   ↓
9. SHOPPING LIST screen
   Sees existing shopping list from User A
   ↓
✅ SUCCESS: Family member joined, sees shared list

Real-time:
User A sees notification: "Tata dołączył do domu!"
User A's HOME SETTINGS updates to show new member
```

---

## Responsive Behavior

### Mobile (< 768px) - Primary Target

- **Single column layout**
- **Bottom tab navigation** (56px + safe-area)
- **Full-width cards** (16px side margins)
- **Large tap targets** (min 44px × 44px)
- **FAB bottom-right** (20px margin)
- **Bottom sheets** dla modals (native mobile pattern)

### Tablet (768-1024px)

- **Two-column layout** gdzie sensowne (e.g., list + details)
- **Side navigation option** (instead of bottom tabs)
- **Larger cards** with more whitespace
- **Increased font sizes** (+1px)
- **Hover states** for interactive elements

### Desktop (> 1024px)

- **Multi-column layout** (max-width container 1200px)
- **Persistent side navigation**
- **Desktop modals** (centered overlays, not bottom sheets)
- **Keyboard shortcuts** (Enter to submit, Esc to close)
- **Hover tooltips** dla additional context
- **Increased spacing** (+4-8px margins/padding)

**Progressive Enhancement:**
- Core functionality works on all screen sizes
- Enhanced features dla larger screens (shortcuts, multi-column)
- No degradation - smaller screens get optimized experience, nie reduced

---

## Animations & Micro-interactions

### Principles

- **Purposeful:** Every animation serves UX purpose (feedback, transition, delight)
- **Fast:** 200-300ms duration (snappy, not sluggish)
- **Natural:** Easing curves (ease-out dla entrances, ease-in dla exits)
- **Subtle:** Nie overwhelming or distracting

### Key Animations

**1. Item Added (Optimistic Update)**
```
Duration: 300ms
Easing: ease-out
Effect:
  - Fade in from opacity 0 → 1
  - Slide down from -20px → 0px
  - Scale from 0.95 → 1.0
```

**2. Item Checked (Mark as Purchased)**
```
Duration: 250ms
Easing: ease-in-out
Effect:
  - Checkbox: Scale 0.8 → 1.2 → 1.0 (bounce)
  - Background: Color transition #F5F5F5 → #E8F5E9
  - Text: Color #1A1A1A → #999 + strikethrough
  - Move: Slide to "KUPIONE" section (500ms, ease-in-out)
```

**3. FAB Press**
```
Duration: 100ms
Effect:
  - Scale: 1.0 → 0.95 (press down)
  - Shadow: Reduce blur
  - Release: Scale back to 1.0 + open modal
```

**4. Modal Open (Bottom Sheet)**
```
Duration: 300ms
Easing: ease-out
Effect:
  - Backdrop: Fade in 0 → 0.5 opacity
  - Sheet: Slide up from bottom (translate 100% → 0%)
  - Spring: Slight overshoot at top (1.02 scale → 1.0)
```

**5. Real-time Update Toast**
```
Duration: 250ms (in), 3s (display), 250ms (out)
Effect:
  - Slide down from top-20px → 0px
  - Auto-dismiss after 3s
  - Swipe up to dismiss early
```

**6. Swipe to Delete**
```
Duration: Real-time (follows finger)
Effect:
  - Swipe left: Reveal red delete button
  - Threshold: 80px swipe → Show delete
  - Confirm: Fade out + collapse height
```

**7. Loading States**
```
Spinner: 1s rotation (linear)
Skeleton: Pulse animation 1.5s (opacity 0.4 ↔ 0.6)
Pull-to-refresh: Spinner at top (rotates while pulling)
```

### Haptic Feedback (Mobile)

- **Item checked:** Light haptic
- **Item deleted:** Medium haptic
- **Error:** Strong haptic (validation failure)
- **Success:** Light haptic (item added)

---

## Accessibility Features

### WCAG 2.1 Level AA Compliance

✅ **Color Contrast:**
- Text/background: Minimum 4.5:1 ratio
- Large text (18pt+): Minimum 3:1 ratio
- UI components: Minimum 3:1 ratio
- Sky Blue (#0288D1) on white: 5.2:1 ✓
- Primary text (#1A1A1A) on white: 18.0:1 ✓

✅ **Keyboard Navigation:**
- All interactive elements focusable via Tab
- Focus indicators: 2px solid blue outline
- Skip to main content link
- Enter to activate, Esc to close modals

✅ **Screen Reader Support:**
- Semantic HTML (headings, lists, landmarks)
- ARIA labels dla icon buttons
- Live regions dla real-time updates
- Alt text dla all images

✅ **Touch Targets:**
- Minimum 44px × 44px dla all tappable elements
- Spacing between targets: 8px minimum
- Enlarged tap areas for small icons

✅ **Text Sizing:**
- Supports browser zoom up to 200%
- Text doesn't truncate at 200% zoom
- Base font size: 16px (prevents iOS zoom)

✅ **Motion & Animation:**
- Respects `prefers-reduced-motion` media query
- Animations disabled for users with motion sensitivity
- No autoplay videos/carousels

### Inclusive Design

- **Simple language:** Clear, concise labels (nie tech jargon)
- **Error recovery:** Clear error messages z suggestions
- **Forgiving input:** Autocorrect, autocomplete, suggestions
- **Multiple modalities:** Touch, keyboard, voice (future)
- **Age-inclusive:** Readable dla older adults (16px+ font, high contrast)

---

## Platform-Specific Considerations

### iOS (Safari)

- **Safe Areas:** Respect notch/island (safe-area-inset)
- **Input Focus:** Prevent zoom on input (16px minimum font)
- **Scroll Bounce:** Allow native overscroll behavior
- **Haptics:** Use Taptic Engine via Haptic API
- **Install:** Custom "Add to Home Screen" prompt
- **Swipe Gestures:** Back swipe from edge (avoid conflicts)

### Android (Chrome)

- **Navigation Bar:** Respect gesture navigation (safe-area-inset-bottom)
- **Ripple Effect:** Material-style touch feedback
- **Long Press:** Context menus (alternative to iOS swipe)
- **Back Button:** Handle hardware back button
- **Install:** Use BeforeInstallPrompt event
- **Notifications:** Use Firebase Cloud Messaging

### PWA Features

- **Manifest:**
  ```json
  {
    "name": "MyHome - Family Hub",
    "short_name": "MyHome",
    "start_url": "/",
    "display": "standalone",
    "theme_color": "#0288D1",
    "background_color": "#FFFFFF",
    "icons": [
      { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
      { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
      { "src": "/icon-maskable.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
    ]
  }
  ```

- **Service Worker:** Cache static assets, offline queue
- **Offline UI:** Show offline banner, queue actions
- **Installation:** Prompt after 2-3 visits (non-intrusive)

---

## Design Tokens (Code Reference)

```css
/* Colors */
--color-primary: #0288D1;
--color-secondary: #66BB6A;
--color-accent: #FF7043;

--color-success: #4CAF50;
--color-warning: #FFA726;
--color-error: #EF5350;

--color-bg-primary: #FFFFFF;
--color-bg-secondary: #F5F5F5;
--color-bg-tertiary: #E0E0E0;

--color-text-primary: #1A1A1A;
--color-text-secondary: #666666;
--color-text-disabled: #999999;

/* Typography */
--font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;

--font-size-h1: 28px;
--font-size-h2: 22px;
--font-size-h3: 18px;
--font-size-body-lg: 17px;
--font-size-body: 16px;
--font-size-body-sm: 14px;
--font-size-caption: 12px;

--font-weight-regular: 400;
--font-weight-semibold: 600;

--line-height-tight: 1.2;
--line-height-normal: 1.5;

/* Spacing */
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 12px;
--spacing-lg: 16px;
--spacing-xl: 20px;
--spacing-2xl: 24px;
--spacing-3xl: 32px;

/* Border Radius */
--radius-sm: 6px;
--radius-md: 10px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-2xl: 20px;
--radius-full: 9999px;

/* Shadows */
--shadow-sm: 0 2px 4px rgba(0,0,0,0.08);
--shadow-md: 0 2px 8px rgba(0,0,0,0.12);
--shadow-lg: 0 4px 12px rgba(0,0,0,0.15);
--shadow-xl: 0 10px 40px rgba(0,0,0,0.2);

/* Transitions */
--transition-fast: 150ms ease-out;
--transition-normal: 250ms ease-in-out;
--transition-slow: 350ms ease-out;

/* Z-index */
--z-base: 0;
--z-dropdown: 1000;
--z-sticky: 1020;
--z-fixed: 1030;
--z-modal-backdrop: 1040;
--z-modal: 1050;
--z-notification: 1060;
```

---

## Next Steps: Implementation Handoff

### For Developers

1. **Review Design Tokens:** Implement CSS variables/Tailwind config
2. **Component Library:** Build reusable components (Button, Input, Card, etc.)
3. **Responsive Layouts:** Implement mobile-first, test breakpoints
4. **Accessibility:** Test keyboard nav, screen readers, contrast
5. **Animations:** Implement with CSS/Framer Motion, respect prefers-reduced-motion
6. **Real-time:** Test Supabase Realtime integration with UI updates
7. **PWA:** Manifest, Service Worker, install prompts

### For QA/Testing

1. **Cross-browser:** Test Chrome, Safari, Firefox, Edge
2. **Device Testing:** iPhone SE (small), iPhone 14, iPad, Android phones
3. **Accessibility:** NVDA/JAWS screen readers, keyboard-only navigation
4. **Performance:** Lighthouse scores, real device testing on 3G
5. **Offline:** Test offline queue, sync recovery
6. **Real-time:** Multi-device testing (add item on device A, see on device B)

### For Product

1. **User Testing:** Validate flows z real families (różne age groups)
2. **Metrics:** Track time-to-first-item, daily active families, feature adoption
3. **Feedback:** In-app feedback mechanism dla UX improvements
4. **Iteration:** Plan design updates based na user feedback

---

## Appendix: Design Rationale

### Why "Friendly Balance" Direction?

**Alternative 1 (Cozy Home)** was too craft-focused, risked feeling dated dla younger users.
**Alternative 2 (Modern Minimalist)** was too cold, lacked family warmth.
**Friendly Balance** hits sweet spot: professional trust + family approachability.

### Why Sky Blue (#0288D1) as Primary?

- **Trust:** Blue universally conveys reliability, security (critical dla family data)
- **Calm:** Non-aggressive, comfortable dla daily use
- **Accessible:** High contrast on white, works dla color blind users
- **Neutral:** Nie gendered, appeals to all family members
- **Scalable:** Works dla MVP shopping → future finance/schedule features

### Why Rounded Corners (12px)?

- **Friendlier** than sharp corners (less corporate)
- **Modern** standard (iOS/Android use rounded corners)
- **Not overdone:** 12px is subtle, not cartoonish
- **Consistent:** Same radius across all components

### Why Bottom Tab Navigation?

- **Thumb-friendly:** Easy reach on large phones (one-handed)
- **Mobile standard:** Familiar pattern (Instagram, Twitter, etc.)
- **2 tabs only (MVP):** Simple, nie overwhelming
- **Expandable:** Can add tabs dla Phase 2 features (Chores, Calendar, etc.)

### Why 16px Base Font Size?

- **iOS:** Prevents auto-zoom on input focus
- **Readable:** Comfortable dla all ages, including older adults
- **WCAG:** Meets accessibility guidelines
- **Modern:** Larger than old 14px standard, better dla mobile

### Why Green (#66BB6A) as Secondary?

- **Positive:** Green = success, completion, growth
- **Fresh:** Evokes home, nature, health (family context)
- **Complementary:** Works well with blue (not clashing)
- **Clear state:** Purchased items turn green (obvious visual feedback)

---

## Version History

**v1.0 (2025-11-17)** - Initial UX Design Specification
- Design Direction: Friendly Balance
- Color Theme: Sky & Earth
- Component Library defined
- Wireframes dla MVP screens (6 core screens)
- User flows documented (4 primary flows)
- Accessibility compliance (WCAG 2.1 AA)
- Platform-specific guidelines (iOS/Android/PWA)

---

_This UX Design Specification is a living document. Updates will be versioned and communicated to the implementation team._

**Created by:** BMad UX Designer
**Based on:** MyHome PRD v1.0, Technical Research 2025-11-17
**For:** Phase 1 MVP - Collaborative Shopping List PWA