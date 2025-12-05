# MyHome - Product Requirements Document

**Author:** Mariusz
**Date:** 2025-11-17
**Version:** 1.0

---

## Executive Summary

**MyHome** to aplikacja mobilno-webowa zaprojektowana aby rozwiązać problem **fragmentacji narzędzi** w zarządzaniu gospodarstwem domowym. Rodziny obecnie używają 10+ różnych aplikacji do koordynacji codziennych zadań - WhatsApp do komunikacji, Google Calendar do wydarzeń, Splitwise do finansów, Notes do przepisów i osobnych apek do list zakupów i zadań domowych.

MyHome konsoliduje te rozproszone funkcje w **jeden unified family hub** z kluczową innowacją: **real-time synchronization** dla wszystkich członków gospodarstwa domowego.

**Problem:** Rodziny tracą czas i energię przełączając się między wieloma aplikacjami, synchronizując informacje manualnie, i tracąc kontekst w chaosie cyfrowych narzędzi.

**Rozwiązanie:** MyHome dostarcza centralne miejsce dla wszystkich aspektów koordynacji domowej - od list zakupów, przez zadania, finanse, kalendarz, przepisy, po dokumenty - wszystko zsynchronizowane real-time dla całej rodziny.

**Target Audience:** Rodziny 2-6 osób, młodzi rodzice, współlokatorzy, pary - każdy kto dzieli gospodarstwo domowe i potrzebuje koordynacji.

### What Makes This Special

**"Jeden hub zamiast 10 apek"**

MyHome eliminuje "app fatigue" przez:
- **Konsolidację:** Wszystkie funkcje domowe w jednym miejscu, eliminując przełączanie kontekstu
- **Real-time Sync:** Natychmiastowa synchronizacja zmian między wszystkimi członkami rodziny
- **Unified Experience:** Spójny interface dla wszystkich funkcji vs mozaika różnych apek
- **Family-First Design:** Zaprojektowane dla współpracy rodziny, nie individual productivity

Unikalna wartość: Zamiast fragmentacji → koordynacja. Zamiast opóźnień → real-time. Zamiast złożoności → prostota.

---

## Project Classification

**Technical Type:** Web App (Progressive Web App → React Native)
**Domain:** General Consumer (Family Management)
**Complexity:** Low (brak regulatory requirements)

**Klasyfikacja techniczna:**
- **Phase 1 (MVP):** Progressive Web App (PWA) - instalowalna w przeglądarce, działa na web + mobile
- **Phase 2:** React Native - natywna aplikacja mobilna dla iOS/Android z pełnym dostępem do funkcji urządzenia
- **Core Technology:** Next.js 15 (App Router), Supabase (PostgreSQL + Realtime + Auth), Vercel (hosting)

**Project Type Characteristics:**
- **Browser Support:** Modern browsers (Chrome, Safari, Firefox, Edge)
- **Responsive Design:** Mobile-first, dostosowane do desktop
- **Real-time:** WebSocket-based synchronization (Supabase Realtime)
- **Offline Capability:** Request queueing dla podstawowych operacji
- **Installation:** PWA installable via "Add to Home Screen"
- **SEO:** Not critical (authenticated app, nie public content)
- **Accessibility:** WCAG 2.1 Level AA dla core flows

**Domain:** General consumer family management - brak specyficznych wymagań regulacyjnych (nie healthcare, nie fintech). Standard security i privacy practices.

---

## Success Criteria

MyHome jest sukcesem gdy rodziny:

**Primary Success Indicator - Family Adoption:**
- **100 power users** (rodzin) używających MyHome codziennie w ciągu pierwszych 3 miesięcy po launch
- **Retention:** 70%+ rodzin aktywnych po 30 dniach (wracają co najmniej 3x/tydzień)
- **Multi-member engagement:** Średnio 2.5+ członków rodziny aktywnych per gospodarstwo

**User Experience Success:**
- **Time to value < 5 minut:** Od rejestracji do dodania pierwszego produktu na listę zakupów
- **Real-time latency < 2 sekundy:** Zmiany widoczne u wszystkich członków w ciągu 2 sekund
- **Eliminacja app switching:** Użytkownicy przestają używać 2+ z wcześniejszych apek (WhatsApp for shopping coordination, separate shopping apps, etc.)

**Engagement Metrics:**
- **Daily active families:** 60%+ rodzin korzysta z app codziennie
- **Collaborative actions:** 80%+ households ma więcej niż jednego aktywnego członka
- **Feature adoption:** 90%+ rodzin używa listy zakupów, 40%+ adoption kolejnej funkcji (phase 2)

**Product-Market Fit Signal:**
- **NPS > 40** - rodziny rekomendują MyHome innym
- **Testimonials:** "Nie wyobrażam sobie wrócić do 5 różnych apek"
- **Viral growth:** 20% new users pochodzi z invite codes (family referrals)

**Technical Success:**
- **Availability:** 99.5% uptime (dopuszczalne ~3.6 godzin downtime/miesiąc)
- **Performance:** P95 response time < 500ms dla kluczowych operacji
- **Zero data loss:** Żadne dane użytkownika nie mogą zostać utracone

**Business Context (informacyjnie):**
- Phase 1 jest MVP validation - focus na product-market fit, nie revenue
- Success = udowodnić że rodziny kochają consolidated hub
- Monetization w phase 2+ (freemium model rozważany)

---

## Product Scope

### MVP - Minimum Viable Product

**Core Capability: Collaborative Shopping List z Real-time Sync**

Fundament MyHome - funkcjonalność która musi działać perfekcyjnie aby udowodnić value proposition "jednego hub dla rodziny".

**MVP Features (Phase 1):**

**1. User Authentication & Home Setup**
- Email + password registration i login
- Tworzenie "domu" (gospodarstwa domowego) przy pierwszym logowaniu
- System zaproszeń: 6-znakowy kod do udostępnienia rodzinie
- Użytkownik należy do JEDNEGO domu (constraint dla MVP)

**2. Shopping List - Real-time Collaborative**
- Dodawanie produktów (nazwa, ilość opcjonalnie, kategoria opcjonalnie)
- Edycja i usuwanie produktów
- Zaznaczanie produktów jako "kupione" (toggle)
- Kategoryzacja (predefiniowane: Nabiał, Warzywa, Pieczywo, Mięso, Napoje, Inne)
- **Real-time sync:** Gdy ktoś dodaje/edytuje/oznacza produkt, reszta rodziny widzi zmianę natychmiast
- Sortowanie: produkty niekupione na górze, kupione na dole

**3. Push Notifications**
- Web Push notifications (PWA)
- Powiadomienia o key events:
  - "Mama dodała: Mleko 2L" (nowy produkt)
  - "Tata kupił: Chleb" (oznaczono jako kupione)
- Opt-in pattern (użytkownik musi zaakceptować notifications)
- Frequency limit: max 5 notifications/tydzień aby nie spamować

**4. Home Management (Basic)**
- Podgląd członków domu (lista osób w gospodarstwie)
- Opuszczenie domu (leave home)
- Regeneracja kodu zaproszenia (re-generate invite code)
- Kopiowanie kodu zaproszenia do clipboard

**Out of Scope dla MVP:**
- Multiple homes per user (jedna osoba w wielu gospodarstwach)
- Role-based permissions (wszyscy członkowie mają równe uprawnienia w MVP)
- Advanced notifications (custom rules, scheduling)
- Offline editing conflict resolution (last-write-wins w MVP)
- Desktop-specific features (focus na mobile experience)

**MVP Success Gate:** Rodziny używają MyHome zamiast WhatsApp + separate shopping app do koordynacji zakupów.

### Growth Features (Post-MVP)

**Phase 2.1 - Household Coordination (Q2 post-MVP)**

**Zadania Domowe (Chores):**
- Tworzenie zadań (nazwa, opis, assignee, deadline)
- Przypisywanie obowiązków do członków rodziny
- Rotacja zadań (automatic reassignment co tydzień/miesiąc)
- Gamifikacja: punkty za ukończone zadania, streak tracking
- Przypomnienia przed deadline
- Historia ukończonych zadań

**Kalendarz Rodzinny:**
- Wspólne wydarzenia (urodziny, wizyty lekarskie, spotkania)
- Sync z Google Calendar (read/write)
- Przypomnienia dla całej rodziny lub specific members
- Color-coding per osoba
- Recurring events
- Event categories (medical, social, school, etc.)

**Phase 2.2 - Financial Management (Q3)**

**Finanse Domowe:**
- Rejestrowanie wspólnych wydatków (rachunki, zakupy)
- Split bill - tracking kto ile dołożył
- Podsumowania miesięczne (total spending, breakdown by category)
- Budżet per kategoria (jedzenie, rozrywka, rachunki, transport)
- Debt tracking między członkami ("Ania jest winna Markowi 150 zł")
- Export do CSV/Excel

**Przepisy & Menu Planning:**
- Baza przepisów rodzinnych (własne przepisy + import z linków)
- Plan posiłków na tydzień
- Auto-generowanie listy zakupów z przepisu
- Nutrition tracking (kalorie, makroskładniki) - basic
- Tags i search przepisów
- Favorites i ratings

**Phase 2.3 - Knowledge Base (Q4)**

**Notatki & Dokumenty:**
- Wspólne notatki (hasła do WiFi, numery alarmowe, instrukcje)
- Upload dokumentów (ubezpieczenia, warranty, instrukcje urządzeń)
- Quick notes (zostawianie wiadomości dla rodziny)
- Organizacja w foldery
- Search functionality
- PIN-protection dla sensitive notes

**Inwentarz Domowy:**
- Tracking co mamy w lodówce/spiżarni
- Daty ważności produktów
- Automatic reminder przed wygaśnięciem
- Sugestie przepisów na podstawie available ingredients
- Integration z shopping list (auto-remove z inventory gdy kupione)

### Vision (Future)

**Phase 3 - Smart Integrations & AI (Rok 2)**

**Integracje:**
- Google Calendar sync (two-way)
- WhatsApp notifications backup
- Alexa/Google Home voice commands ("Add milk to shopping list")
- Smart home devices (termostat settings, smart locks)
- Bank account integration (auto-track expenses)

**AI & Automation:**
- Smart shopping suggestions ("You usually buy milk every 5 days, want to add it?")
- Budget predictions ("At current rate, you'll exceed food budget by 200 zł")
- Meal planning recommendations based on dietary preferences i inventory
- Chore assignment optimization (fair distribution, skill matching)
- Anomaly detection (unusual spending, forgotten tasks)

**Advanced Modules:**

**Pet Care:**
- Schedule karmienia
- Wizyty u weta tracking
- Szczepienia & medication reminders
- Pet expenses tracking

**Home Maintenance:**
- Harmonogram konserwacji (wymiana filtrów, przeglądy)
- Historia napraw i kosztów
- Kontakty do fachowców (plumber, electrician, etc.)
- Warranty tracking dla urządzeń

**Lokalizacja & Dostępność:**
- Status członków ("w domu", "w pracy", "w drodze", "dostępny/zajęty")
- Location sharing (opt-in, privacy-focused)
- ETA do domu (based on location)
- Geofencing notifications ("Mama weszła do sklepu - remind shopping list")

**Strategic Vision:** MyHome staje się **operating system dla rodziny** - zastępuje 10+ apek, integruje z external services, używa AI do proactive assistance, i staje się niezbędnym narzędziem dla nowoczesnych gospodarstw domowych.

---

## Web App Specific Requirements

MyHome jest budowane jako **Progressive Web App (PWA)** w Phase 1, z migracją do React Native w Phase 2.

### Platform Support

**Phase 1 (MVP) - Progressive Web App:**
- **Browser Compatibility:**
  - Chrome 90+ (primary target)
  - Safari 14+ (iOS support critical)
  - Firefox 88+
  - Edge 90+
  - Mobile browsers (iOS Safari, Chrome Android)
- **Minimum Screen Sizes:**
  - Mobile: 320px width (iPhone SE)
  - Tablet: 768px width (iPad)
  - Desktop: 1024px width (optional, mobile-first)

**Phase 2 - React Native:**
- iOS 14+ (iPhone 8 and newer)
- Android 10+ (API level 29+)
- Published w Google Play Store i Apple App Store

### Responsive Design Strategy

**Mobile-First Approach:**
- Primary experience optimized dla mobile devices (phones 320-428px)
- Tablet layout (768-1024px) adapts with larger touch targets
- Desktop (1024px+) provides expanded view ale nie core focus dla MVP

**Key Breakpoints:**
- **Mobile:** < 768px - single column, bottom navigation, full-width components
- **Tablet:** 768-1024px - two-column gdzie sensowne, side navigation option
- **Desktop:** > 1024px - multi-column layout, persistent navigation

### PWA Requirements

**Installation:**
- Web App Manifest (name, icons, theme_color, display: standalone)
- Service Worker dla offline capability i caching
- "Add to Home Screen" prompt po 2-3 visits (non-intrusive)
- App icons: 192x192, 512x512, maskable icons dla iOS

**Offline Capability (Phase 1):**
- Request queueing - mutations queued gdy offline, synced gdy online
- Last known state displayed - cached data shown with "offline" indicator
- Optimistic updates - immediate UI feedback, background sync
- Service Worker caching strategy:
  - Static assets: cache-first (HTML, CSS, JS, images)
  - API requests: network-first with fallback to cache
  - Realtime updates: network-only (require connection)

**Performance Targets:**
- **First Contentful Paint:** < 1.5s on 3G connection
- **Time to Interactive:** < 3s on 3G
- **Lighthouse PWA Score:** 90+
- **Bundle Size:** < 500KB initial load (after gzip)

### Real-time Architecture

**Technology:** Supabase Realtime (WebSocket over PostgreSQL replication)

**Real-time Features:**
- Shopping list updates (INSERT, UPDATE, DELETE events)
- Home member presence (online/offline status) - Phase 2
- Typing indicators - Phase 2
- Live cursors - Phase 2 optional

**Connection Management:**
- Automatic reconnection on network recovery
- Exponential backoff retry (2s, 4s, 8s, 16s max)
- Connection status indicator ("Syncing...", "Online", "Offline")
- Graceful degradation - app usable without realtime (polling fallback)

### Browser Feature Requirements

**Required Features:**
- **LocalStorage:** Session persistence, offline queue
- **IndexedDB:** Offline data caching (Phase 2 enhancement)
- **Web Push API:** Notifications (requires HTTPS + user consent)
- **Service Workers:** Offline capability + caching
- **WebSocket:** Real-time synchronization
- **Clipboard API:** Copy invite code
- **Geolocation API:** Phase 2 (location features)

**Progressive Enhancement:**
- Core functionality works bez advanced features
- Notifications optional (graceful if denied)
- Offline queuing optional (warns if disabled)
- Realtime falls back to polling if WebSocket unavailable

### Authentication & Session Management

**Authentication Flow:**
- Email + password (Supabase Auth)
- JWT tokens stored in HttpOnly cookies (security)
- Session persistence across browser restarts
- Automatic token refresh (before expiry)
- "Remember me" implicit (session lasts 30 days)

**Security:**
- HTTPS enforced (required dla PWA + Service Workers)
- CORS configured dla Supabase domain only
- XSS protection via React automatic escaping
- CSRF tokens dla mutations (handled by Supabase)
- Row Level Security (RLS) w database dla data isolation

---

## User Experience Principles

MyHome musi **czuć się prosto i szybko** - eliminując mental overhead of managing 10 apps.

### Design Philosophy

**Principle #1: Zero Learning Curve**
- Interfejs tak intuicyjny że rodzice i dziadkowie używają bez instrukcji
- Common patterns (swipe to delete, tap to edit, pull to refresh)
- Minimal onboarding (< 2 ekrany, skip option)
- Contextual hints tylko gdy needed ("Tap + to add item")

**Principle #2: Speed Above All**
- Każda akcja zajmuje < 3 taps
- Dodanie produktu: tap "+" → wpisz nazwę → tap "Dodaj" (2 taps + typing)
- Oznaczenie jako kupione: single tap na checkbox
- No unnecessary confirmations ("Are you sure?" tylko dla destructive actions)

**Principle #3: Family-Friendly**
- Czytelne dla wszystkich age groups (duże fonts, high contrast)
- Neutral aesthetics (nie childish, nie corporate - "home-like")
- Personalizacja (każdy member może mieć avatar/color)
- Positive reinforcement (checkmarks, subtle animations, not overwhelming)

**Principle #4: Real-time Trust**
- Widoczność kto co zrobił ("Mama dodała", "Tata kupił")
- Confidence w sync (immediate updates, no stale data)
- Connection status always visible (nie hidden state)

### Visual Personality

**Mood:** Warm, reliable, uncluttered, family-oriented

**Not:**
- Gamified/playful (nie Duolingo vibes)
- Corporate/sterile (nie enterprise SaaS)
- Minimalist-to-fault (nie hiding functionality)

**But:**
- Clean and organized (like well-managed home)
- Accessible and comfortable (like favorite app you use daily)
- Trustworthy (handles family data, needs to feel secure)

### Key Interactions

**1. Adding Shopping Item (Primary Flow)**
- Tap floating action button "+" (bottom right)
- Modal appears: "Dodaj produkt"
- Input field auto-focused, keyboard appears
- Type name (autocomplete suggests previous items)
- Optional: tap category chip (Nabiał, Warzywa, etc.)
- Optional: add quantity (e.g., "2L", "500g")
- Tap "Dodaj" lub Enter key
- Item appears at top of list immediately (optimistic update)
- Notification sent to family members
- **Total interaction time: ~5-10 seconds**

**2. Marking Item as Purchased**
- Tap checkbox next to item
- Checkbox animates to checked state
- Item moves to "Kupione" section at bottom
- Subtle strikethrough animation
- Family members see update in real-time
- **Total interaction time: < 1 second (single tap)**

**3. Editing Item**
- Tap on item name/row (not checkbox)
- Inline edit mode or modal (TBD in design phase)
- Update name, quantity, or category
- Tap "Zapisz" or Enter
- Changes sync immediately
- **Total interaction time: ~3-5 seconds**

**4. Deleting Item**
- Swipe left on item (iOS pattern) lub long-press (Android)
- Delete button appears in red
- Tap "Usuń"
- Confirmation: "Usunąć [item name]?" (Yes/No)
- Item removed, syncs to all devices
- **Total interaction time: ~2-3 seconds**

**5. Inviting Family Member**
- Navigate to Settings/Home
- Tap "Zaproś członka"
- 6-digit code displayed prominently
- "Kopiuj kod" button
- Share via any method (WhatsApp, SMS, email)
- **Total interaction time: ~10 seconds**

**6. Joining Home via Code**
- New user registers/logs in
- Prompt: "Dołącz do domu" lub "Stwórz nowy dom"
- Select "Dołącz"
- Input field: "Wpisz kod zaproszenia"
- Enter 6-digit code
- Tap "Dołącz"
- Success: "Dołączyłeś do domu [nazwa]!"
- **Total interaction time: ~15-20 seconds**

### Navigation Structure (MVP)

**Bottom Tab Navigation (Mobile):**
1. **Zakupy** (Home) - Shopping list view (default screen)
2. **Dom** (Settings) - Home members, invite code, account settings

**Future Tabs (Phase 2+):**
3. **Zadania** (Chores)
4. **Kalendarz** (Events)
5. **Więcej** (More) - access to Finanse, Przepisy, Notatki, etc.

**Top Bar:**
- Left: Home name ("Dom Kowalskich")
- Right: Notifications bell icon (badge count), Account avatar

---

## Functional Requirements

_This section defines WHAT capabilities MyHome must have. These are the complete inventory of user-facing and system capabilities._

### User Account & Access

**FR1:** Users can create accounts using email and password
**FR2:** Users can log in securely and maintain sessions across browser restarts
**FR3:** Users can reset passwords via email verification link
**FR4:** Users can update account information (name, email, avatar)
**FR5:** Users can delete their account and all associated data
**FR6:** System enforces unique email addresses per user

### Home (Household) Management

**FR7:** Users can create a new home (household) with a unique name
**FR8:** System automatically generates a unique 6-character alphanumeric invite code for each home
**FR9:** Users can join an existing home by entering a valid invite code
**FR10:** Users can belong to exactly one home at a time (MVP constraint)
**FR11:** Users can view all members of their home (names, avatars, join date)
**FR12:** Users can leave their current home (orphans user, must create/join new home)
**FR13:** Home creators can regenerate the invite code (invalidates old code)
**FR14:** Users can copy the invite code to clipboard for sharing

### Shopping List - Core Functionality

**FR15:** Users can add shopping items with a name (required field)
**FR16:** Users can optionally specify quantity for shopping items (e.g., "2L", "500g", "3 szt")
**FR17:** Users can optionally assign a category to shopping items from predefined list
**FR18:** System provides predefined categories: Nabiał, Warzywa, Pieczywo, Mięso, Napoje, Inne
**FR19:** Users can edit existing shopping items (name, quantity, category)
**FR20:** Users can delete shopping items from the list
**FR21:** Users can mark shopping items as "purchased" via checkbox toggle
**FR22:** Users can unmark purchased items (toggle back to "not purchased")
**FR23:** System displays shopping items in two sections: "Do Kupienia" and "Kupione"
**FR24:** System sorts items with "not purchased" at the top, "purchased" at the bottom
**FR25:** System maintains shopping list per home (all members see same list)

### Real-time Synchronization

**FR26:** System synchronizes shopping list changes in real-time across all active users in the same home
**FR27:** When user adds an item, all other home members see it appear within 2 seconds
**FR28:** When user marks item as purchased, all other home members see the status change within 2 seconds
**FR29:** When user edits or deletes an item, all other home members see the change within 2 seconds
**FR30:** System displays connection status indicator (online/offline/syncing)
**FR31:** System automatically reconnects and syncs changes when user comes back online

### Push Notifications

**FR32:** System requests user permission for push notifications (opt-in pattern)
**FR33:** Users can enable or disable push notifications in settings
**FR34:** System sends notification when another family member adds a shopping item
**FR35:** System sends notification when another family member marks an item as purchased
**FR36:** Notifications include relevant context (who did what: "Mama dodała: Mleko 2L")
**FR37:** System limits notifications to maximum 5 per week per user to prevent spam
**FR38:** Users can tap notification to open the app directly to shopping list

### Offline Capability

**FR39:** Users can view last-known shopping list state when offline
**FR40:** Users can add, edit, and mark items when offline (queued for sync)
**FR41:** System queues offline changes and automatically syncs when connection restored
**FR42:** System displays "Offline" indicator when no network connection
**FR43:** System uses optimistic updates for immediate UI feedback (changes shown instantly)

### Data Visibility & Security

**FR44:** Users can only view shopping lists from their own home
**FR45:** Users can only view member lists from their own home
**FR46:** Users cannot access data from homes they don't belong to
**FR47:** System enforces data isolation at database level (Row Level Security)
**FR48:** System tracks who created each shopping item (audit trail)

### User Interface & Experience

**FR49:** Application is installable as Progressive Web App (PWA) on mobile devices
**FR50:** Application provides responsive design for mobile, tablet, and desktop screens
**FR51:** Application works in modern browsers (Chrome, Safari, Firefox, Edge)
**FR52:** Application displays shopping list as primary/home screen after login
**FR53:** Application uses bottom tab navigation for main sections (Zakupy, Dom)
**FR54:** Users can access settings, invite code, and member list from "Dom" tab

### Search & Filtering (Post-MVP consideration, listed for completeness)

**FR55:** Users can search shopping items by name (Phase 2)
**FR56:** Users can filter shopping list by category (Phase 2)
**FR57:** Users can view shopping history (previously purchased items) (Phase 2)

### Item Autocomplete & Suggestions (Post-MVP)

**FR58:** System suggests previously used item names during typing (Phase 2)
**FR59:** System remembers commonly purchased items per home (Phase 2)

---

## Non-Functional Requirements

### Performance

**NFR-P1:** Application must load initial screen (after auth) within 3 seconds on 3G connection
**NFR-P2:** Application must complete user actions (add item, mark purchased) with response time < 500ms (P95)
**NFR-P3:** Real-time updates must propagate to all active clients within 2 seconds (average)
**NFR-P4:** Application must achieve Lighthouse Performance score of 85+ on mobile
**NFR-P5:** Application JavaScript bundle size must not exceed 500KB (gzipped) for initial load
**NFR-P6:** Application must support up to 100 concurrent users per home without degradation
**NFR-P7:** Database queries must complete within 100ms (P95) for standard operations

**Why Performance Matters:**
MyHome is used during daily life moments (grocery shopping, at home) where speed is critical. Slow app = frustration = abandonment. Must feel instant.

### Security

**NFR-S1:** All data transmission must use HTTPS/WSS (TLS 1.2+)
**NFR-S2:** User passwords must be hashed using industry-standard algorithm (bcrypt/Argon2)
**NFR-S3:** Authentication tokens (JWT) must be stored in HttpOnly cookies to prevent XSS
**NFR-S4:** Database must enforce Row Level Security (RLS) policies for all user-facing tables
**NFR-S5:** API endpoints must validate and sanitize all user inputs to prevent injection attacks
**NFR-S6:** System must implement rate limiting on authentication endpoints (max 5 login attempts per minute)
**NFR-S7:** Invite codes must be cryptographically random and unpredictable
**NFR-S8:** System must invalidate all sessions when user changes password
**NFR-S9:** Application must protect against CSRF attacks on mutation operations

**Why Security Matters:**
MyHome handles family data (shopping habits, household members, notifications). Users must trust that their data is private and secure. Breach = loss of trust = product failure.

### Scalability

**NFR-SC1:** System must support at least 1000 concurrent active homes (MVP target)
**NFR-SC2:** Database must handle at least 10,000 shopping list items without performance degradation
**NFR-SC3:** System must support scaling to 10,000 active homes within 6 months post-launch
**NFR-SC4:** Real-time infrastructure must support 5,000+ concurrent WebSocket connections
**NFR-SC5:** System architecture must allow horizontal scaling of application servers
**NFR-SC6:** Database must use connection pooling to prevent connection exhaustion

**Why Scalability Matters:**
If product gains traction, must scale smoothly. Architecture decisions in MVP impact ability to grow. Supabase provides scaling path, but must be designed for it.

### Reliability & Availability

**NFR-R1:** System must maintain 99.5% uptime (max ~3.6 hours downtime per month)
**NFR-R2:** System must perform automated backups of database every 24 hours
**NFR-R3:** System must implement graceful degradation when real-time service unavailable
**NFR-R4:** System must automatically retry failed background operations (max 3 retries with exponential backoff)
**NFR-R5:** Application must handle network interruptions without data loss
**NFR-R6:** System must provide error logging and monitoring for production issues

**Why Reliability Matters:**
Families rely on MyHome for daily coordination. Downtime = frustration + product abandonment. Must be dependable like electricity.

### Usability & Accessibility

**NFR-U1:** Application must be usable without training or documentation (intuitive UI)
**NFR-U2:** Core actions (add item, mark purchased) must be completable in ≤ 3 taps
**NFR-U3:** Application must support minimum font size of 16px for readability
**NFR-U4:** Application must use WCAG 2.1 Level AA contrast ratios for text and interactive elements
**NFR-U5:** Application must provide keyboard navigation for all interactive elements
**NFR-U6:** Application must use semantic HTML for screen reader compatibility
**NFR-U7:** Error messages must be clear and actionable (not technical jargon)
**NFR-U8:** Application must work on small screens (min 320px width - iPhone SE)

**Why Usability Matters:**
Target users include non-technical family members (parents, grandparents). If it's not instantly usable, they won't adopt it. Accessibility ensures inclusion.

### Maintainability & Code Quality

**NFR-M1:** Codebase must use TypeScript for type safety across frontend and backend
**NFR-M2:** Code must follow consistent style guide (ESLint + Prettier)
**NFR-M3:** Critical paths must have automated tests (unit + integration)
**NFR-M4:** Database schema changes must use migrations (versioned, reversible)
**NFR-M5:** Application must use environment variables for configuration (no hardcoded secrets)
**NFR-M6:** Documentation must exist for architecture decisions, API contracts, database schema

**Why Maintainability Matters:**
MyHome is a long-term product (Phase 1 → Phase 2 → Phase 3). Clean code + good practices enable fast iteration and reduce bugs.

### Browser & Device Compatibility

**NFR-C1:** Application must work in Chrome 90+, Safari 14+, Firefox 88+, Edge 90+
**NFR-C2:** Application must function on iOS 14+ (Safari mobile)
**NFR-C3:** Application must function on Android 10+ (Chrome mobile)
**NFR-C4:** Application must degrade gracefully on older browsers (with feature detection)
**NFR-C5:** Progressive Web App features (install, offline) must work on supported platforms
**NFR-C6:** Responsive design must adapt to screen sizes from 320px to 1920px width

**Why Compatibility Matters:**
Families use diverse devices. Must work on mom's iPhone, dad's Android, grandma's tablet. Broken experience on any device = excluded family member.

---

## Summary

MyHome jest **centralnym hubem dla koordynacji rodziny**, zastępującym 10+ fragmentowanych aplikacji jednym unified experience z real-time synchronizacją.

**Phase 1 MVP** dostarcza fundament: collaborative shopping list z instant sync, proving core value proposition że rodziny mogą zarządzać codziennymi zadaniami szybciej i prościej w jednej aplikacji.

**What Makes MyHome Win:**
- **Eliminacja friction:** Jeden hub zamiast przełączania między apkami
- **Real-time coordination:** Wszyscy widzą zmiany natychmiast, nie ma stale data
- **Family-first design:** Zaprojektowane dla współpracy, nie individual productivity
- **Progressive expansion:** Start simple (shopping), expand to całościowego family OS

**Technical Foundation:**
- Progressive Web App (PWA) → React Native evolution path
- Supabase (PostgreSQL + Realtime + Auth + RLS) dla backend
- Next.js 15 dla frontend z Server Components + Server Actions
- Real-time architecture via WebSocket, offline capability via request queue

**Success = Product-Market Fit:**
- 100 power user families w ciągu 3 miesięcy
- 70% retention po 30 dniach
- NPS > 40
- Families saying: "Nie wyobrażam sobie wrócić do 5 różnych apek"

This PRD captures **complete capability contract** dla MyHome MVP - wszystko co UX Designer musi zaprojektować, wszystko co Architect musi wspierać, wszystko co będzie zaimplementowane w epicach i stories.

**Next Phase:** UX Design → Architecture → Epic Breakdown → Implementation

---

_This PRD captures the essence of MyHome - a unified family coordination hub that eliminates app fatigue and brings real-time collaboration to household management._

_Created through collaborative discovery between Mariusz and AI facilitator._
