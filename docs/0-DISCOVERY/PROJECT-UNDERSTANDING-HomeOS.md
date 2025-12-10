# PROJECT-UNDERSTANDING: HomeOS

## Document Info
- **Version:** 1.0
- **Created:** 2025-12-09
- **Discovery Session:** DS-HomeOS-001
- **Clarity Score:** 88%
- **Interview Rounds:** 3 (18 questions total)

## Executive Summary
HomeOS to modularny hub rodzinny rozwiązujący problem koordynacji w rodzinach. Pierwsza wersja (MVP) targetuje polski rynek z planami ekspansji międzynarodowej. Business model: freemium + subscription ($2/msc, $20/rok) + ads dla free users. Tech stack: Vercel (Next.js) + Supabase. MVP w 3 tygodnie: rejestracja → household setup → shopping list.

---

## 1. BUSINESS CONTEXT

### Problem Statement
Rodziny tracą czas i energię na codzienną koordynację:
- **Shopping:** Mama jedzie do sklepu → telefon "co kupić?", zapomina połowy rzeczy
- **Obowiązki:** Kartki na lodówce giną, dzieci "zapominają" o obowiązkach
- **Finanse:** Płatności rozrzucone po różnych miejscach, brak przeglądu
- **Komunikacja:** WhatsApp/SMS rozpraszają, info się gubi

**Current Solutions:**
- Kartki/tablice korkowe → chaos, trzeba być w domu
- WhatsApp/Messenger → info się gubi w konwersacjach
- Trello/Notion → za skomplikowane, wymaga technicznego know-how
- Cozi/OurHome → zbyt zaawansowane lub płatne od dnia 1

### Solution
**HomeOS** - prosty, modularny hub rodzinny:
- Wszystko w jednym miejscu
- Prosty UI (nawet dla 8-latka)
- Modularny: włączasz tylko to, czego używasz
- Real-time sync między urządzeniami (10 min refresh)
- Polski rynek → międzynarodowa ekspansja

### Value Proposition
- **Dla rodziców:** Mniej chaosu, więcej kontroli, oszczędność czasu
- **Dla dzieci:** Przejrzysty system obowiązków, gamifikacja (przyszłość)
- **Dla rodziny:** Lepsza komunikacja, mniej konfliktów

### Competitive Landscape
| Konkurent | Słabe strony | Nasza przewaga |
|-----------|--------------|----------------|
| Cozi | Amerykański, skomplikowany | Polski, prosty |
| OurHome | Płatny od dnia 1 | Freemium |
| Trello | Zbyt generyczny | Dedicated dla rodzin |
| WhatsApp | Chaos w wiadomościach | Ustrukturyzowane dane |

---

## 2. TARGET USERS

### Primary User: Rodzice (30-45 lat)
**Profil:**
- Mają 1-3 dzieci (8-16 lat)
- Pracują zawodowo
- Nie mają czasu na skomplikowane rozwiązania
- Znają się na podstawach tech (smartphone, WhatsApp)

**Pain Points:**
- Brak czasu na planowanie
- Chaos w komunikacji z rodziną
- Zapominanie o płatnościach/zakupach
- Trudność w egzekwowaniu obowiązków u dzieci

**Goals:**
- Mniej chaosu, więcej kontroli
- Szybka synchronizacja z rodziną
- Prosty system, który "po prostu działa"

### Secondary User: Dzieci (8-16 lat)
**Profil:**
- Mają dostęp do smartfona/tabletu
- Znają podstawowe aplikacje
- Potrzebują przejrzystych zasad

**Pain Points:**
- Rodzice "ciągle czepią się o obowiązki"
- Niejasne co jest do zrobienia
- Brak motywacji

**Goals:**
- Wiedzieć czego rodzice oczekują
- Zrobić swoje i mieć spokój
- (Przyszłość: nagrody/gamifikacja)

### Market
- **Primary:** Polska
- **Secondary:** Międzynarodowa ekspansja (stąd PL+EN w MVP)
- **Segment:** Rodziny z dziećmi w wieku szkolnym

---

## 3. BUSINESS MODEL

### Revenue Streams

#### 1. Freemium (Free Tier)
**Included:**
- Shopping list (unlimited)
- Basic tasks/chores
- Up to 6 members per household
- Standard sync (10 min)

**Limitations:**
- Reklamy (non-intrusive banner ads)
- Brak zaawansowanych modułów (expenses, meal planning)

#### 2. Premium Subscription
**Pricing:**
- **Monthly:** $2/msc (~8 PLN)
- **Yearly:** $20/rok (~80 PLN, oszczędność 17%)

**Benefits:**
- No ads
- Unlimited household members
- Advanced modules: Expenses, Meal Planning, Bills Tracker
- Priority support
- Export data (CSV, PDF)

#### 3. Advertising (Free Users)
- Non-intrusive banner ads
- Family-friendly brands (zabawki, ubrania, edukacja)

### Payment Methods
- **MVP:** Stripe (card payments)
- **Phase 1:** BLIK, Przelewy24, PayU (polish preferred methods)

### Monetization Strategy
1. **MVP → 3 miesiące:** 100% free (budowanie community)
2. **Month 4+:** Wprowadzenie Premium tier
3. **Month 6+:** Ads dla free users
4. **Year 2:** Enterprise tier dla większych grup (np. wspólnoty mieszkaniowe?)

---

## 4. MVP SCOPE (3 tygodnie)

### Week 1: Authentication + Household Setup

**Features:**
1. **Registration & Login**
   - Email + password
   - Optional: Google OAuth
   - Email verification

2. **Household Creation**
   - First user = Admin (automatically)
   - Household name + settings

3. **Invite System**
   - Generate: QR code + invite code (e.g., FAMILY-8473)
   - Members scan QR or enter code → join household
   - Children: username + parent approval (no email required)

4. **Basic Dashboard**
   - Welcome screen
   - Navigation to modules
   - Placeholder for upcoming features

### Week 2: Shopping List + Roles

**Features:**
1. **Shopping List (Full Feature)**
   - Add/remove items
   - Categories (dairy, vegetables, bread, meat, etc.)
   - "Pin" frequently bought items
   - Multi-user sync (10 min refresh)
   - Mark items as "bought"
   - Clear completed items

2. **Roles & Permissions**
   - **Admin:** Full control (add/remove members, settings)
   - **Member:** Access all modules, can't delete members
   - **Child:** Limited access (add to shopping list, view own tasks)

### Week 3: Module #3 + Polish

**Features:**
1. **Module Preview** (likely Tasks/Chores - confirm with PM)
   - Basic task creation
   - Assign to member
   - Mark complete

2. **Polish & Bugfixes**
   - UI refinements
   - Performance optimization
   - Bug fixing

3. **Beta Testing**
   - 2-3 families invited
   - Collect feedback
   - Prioritize fixes

### Out of Scope (MVP)
- Meal planning
- Bill tracking
- Expenses
- Calendar
- Location sharing
- Document storage
- Push notifications (może basic email)
- Gamification

---

## 5. HOUSEHOLD STRUCTURE

### Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Admin** | - Add/remove members<br>- Change household settings<br>- Delete household<br>- Full access to all modules | Parent creating family account |
| **Member** | - Access all modules<br>- Cannot remove members<br>- Cannot delete household | Second parent, adult relative |
| **Child** | - Limited module access<br>- Add items to shopping list<br>- View assigned tasks<br>- Cannot change settings | Kids 8-16 years old |

### Setup Flow

**Scenario: Mama creates household, invites tata + 2 dzieci**

1. **Mama (Day 1):**
   - Registers: email + password
   - Creates household: "Rodzina Kowalskich"
   - Status: Admin automatically

2. **Mama invites:**
   - Opens "Invite Members" screen
   - System generates:
     - QR code (displayed on screen)
     - Invite code: `FAMILY-8473`
   - Shares via: WhatsApp, SMS, or show phone

3. **Tata:**
   - Downloads HomeOS app
   - Clicks "Join Household"
   - Scans QR code OR enters `FAMILY-8473`
   - Creates account (email + password)
   - Joined as: Member

4. **Dzieci (Kasia 14 lat, Tomek 10 lat):**
   - Download HomeOS app (on parent's phone or own tablet)
   - Click "Join Household"
   - Enter code: `FAMILY-8473`
   - **No email required:**
     - Enter username: `kasia`, `tomek`
     - Mama receives approval request
     - Mama approves → joined as: Child

### Validation Rules
- **Admin:** Must have email (for password recovery)
- **Member:** Must have email
- **Child:** Username only, no email required
- **Invite codes:** Expire after 7 days (security)
- **Max members (free tier):** 6

---

## 6. ROADMAP

### Phase 1: Post-MVP (1-2 months)

#### 1. Tasks/Chores Module
**Purpose:** "Alternatywa tablicy korkowej"

**Features:**
- Create tasks with:
  - Title, description
  - Assign to member(s)
  - Due date
  - Recurring (daily, weekly)
- View history: co było zaplanowane vs wykonane
- Simple accountability

**Use Case:**
- Mama: "Tomek, pozmywaj naczynia (daily)"
- Tomek widzi task na dashboardzie
- Po wykonaniu: mark complete
- Mama widzi historię compliance

#### 2. Bills Tracker
**Purpose:** "Łatwe, lekkie, użyteczne śledzenie płatności"

**Features:**
- Add bill:
  - Name (e.g., "Internet")
  - Amount + currency (PLN)
  - Due date
  - Recurring (monthly, yearly)
- Reminders: email/push 3 days before due
- Mark as paid
- Simple dashboard: what's due this month

**Use Case:**
- Tata wpisuje: "Prąd, 350 PLN, 10. każdego miesiąca"
- System przypomina 7. każdego miesiąca
- Po opłaceniu: mark paid
- Familia widzi co opłacone, co czeka

### Phase 2: Advanced Features (3-4 months)

#### 3. Expenses Module (ZAAWANSOWANE)
**Purpose:** "Kto ile wydał, na co, z budżetem"

**Features:**
- **Quick Add:**
  - Zdjęcie paragonu → OCR (kwota, sklep, data)
  - Lub manual: kto, opis, kwota
- **Categorization:** Jedzenie, transport, rozrywka, etc.
- **Charts:** Wykresy wydatków (weekly, monthly)
- **Budget Limits:**
  - Set limit per category (e.g., "Rozrywka max 500 PLN/msc")
  - Alert when approaching/exceeding
- **Family view:** Kto ile wydał this month

**Use Case:**
- Mama kupuje zakupy → zdjęcie paragonu → app reads "Biedronka, 287 PLN"
- Tata kupuje benzynę → manual "Shell, 200 PLN"
- Chart shows: "Jedzenie 1200 PLN / 1500 limit", "Transport 600 PLN"
- Alert: "Rozrywka 480 PLN / 500 limit - 20 PLN remaining"

### Phase 3: Future Modules (6+ months)

#### 4. Meal Planning
**Purpose:** "Menu na tydzień → auto shopping list"

**Features:**
- Plan meals for week
- Recipe integration (manual or API)
- Auto-generate shopping list based on recipes
- **Research:** Cookidoo API integration (RESEARCH-AGENT to investigate feasibility)

#### 5. Family Calendar
- Shared events (doctor appointments, school meetings)
- Reminders
- Sync with Google Calendar (optional)

#### 6. Location Sharing (Optional)
- Privacy-focused
- Opt-in per member
- Use case: "Kto jest w domu?", "Mama wraca za 10 min"

#### 7. Document Hub
- Upload & store:
  - Receipts (warranties)
  - Medical records
  - School documents
- Categorize & search

---

## 7. TECHNICAL DECISIONS

### Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Frontend** | Next.js (React) | - SEO-friendly<br>- Fast performance<br>- Vercel-optimized |
| **Hosting** | Vercel | - Fast deployment<br>- Serverless functions<br>- Edge network (global) |
| **Backend** | Supabase | - All-in-one: DB + Auth + Realtime<br>- PostgreSQL (reliable)<br>- Row Level Security<br>- Cost-effective for MVP |
| **Database** | PostgreSQL (via Supabase) | - Relational data model fits household structure<br>- Mature, scalable |
| **Auth** | Supabase Auth | - Email/password built-in<br>- OAuth providers (Google)<br>- Secure token management |
| **Realtime Sync** | Supabase Realtime | - 10 min refresh (balance performance vs cost)<br>- WebSocket support for future |
| **Payments** | Stripe | - Fast MVP setup<br>- Supports subscriptions<br>- Add BLIK/Przelewy24 later via extensions |

### Architecture Principles
1. **Mobile-first:** Responsive design, touch-optimized
2. **Offline-first (future):** Cache data locally, sync when online
3. **Privacy-focused:** Data encrypted, user controls sharing
4. **Modular:** Easy to add/remove modules
5. **Scalable:** Supabase + Vercel scale automatically

### Sync Strategy
- **MVP:** 10 min refresh interval
  - **Why:** Balance between realtime feel and performance/cost
  - **Implementation:** Polling or Supabase Realtime (throttled)
- **Future:** Consider WebSocket for instant sync (if users demand it)

### Internationalization (i18n)
- **MVP:** Polish + English
  - **Polish:** Primary UI language (target market)
  - **English:** Enables international expansion
- **Implementation:** next-i18next or similar
- **Future:** Add more languages based on demand (German, Spanish, etc.)

### Payment Integration
- **MVP:** Stripe card payments
- **Phase 1:** Add Polish methods:
  - BLIK (Stripe extension or direct API)
  - Przelewy24
  - PayU
- **Future:** Invoice system for enterprise tier

---

## 8. SUCCESS METRICS

### MVP Success Criteria (After 3 weeks)

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Registered Users** | 20+ | Supabase auth count |
| **Active Households** | 5+ (2-3 families beta) | Households with >2 members |
| **Feedback Quality** | Positive overall | Beta tester interviews |
| **Bug Count** | <10 critical | Issue tracker |
| **Core Feature Working** | 100% | Shopping list full functionality |

### Phase 1 Success (After 2-3 months)

| Metric | Target | Measurement |
|--------|--------|-------------|
| **MAU (Monthly Active Users)** | 100+ | Login events |
| **Retention (Week 1)** | 60%+ | Users returning after 7 days |
| **Premium Conversions** | 5-10% | Subscription signups |
| **NPS (Net Promoter Score)** | 40+ | User surveys |

### Phase 2 Success (After 6 months)

| Metric | Target | Measurement |
|--------|--------|-------------|
| **MAU** | 500+ | Login events |
| **Retention (Week 4)** | 40%+ | Users active after 30 days |
| **Premium Conversions** | 10-15% | Subscription signups |
| **Revenue** | $500+/month | Stripe dashboard |
| **Churn Rate** | <10%/month | Subscription cancellations |

---

## 9. RISKS & MITIGATIONS

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Supabase limitations for realtime | Medium | Low | Start with 10 min polling, upgrade if needed |
| Mobile performance (large households) | Medium | Medium | Pagination, lazy loading |
| Data sync conflicts (multi-edit) | High | Medium | Implement conflict resolution (last-write-wins or CRDT) |

### Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Low user adoption | High | Medium | Beta testing, iterate based on feedback |
| Competitors copy features | Medium | High | Speed of execution, brand loyalty |
| Payment integration issues (BLIK) | Medium | Low | Start with Stripe, add Polish methods later |
| Privacy concerns | High | Low | Clear privacy policy, GDPR compliance |

### Market Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Polish market too small | High | Low | Plan international expansion from day 1 (EN language) |
| Users prefer free tier only | Medium | Medium | Make premium compelling, limit free tier strategically |
| Economic downturn affects subscriptions | Medium | Medium | Keep pricing low, offer annual discount |

---

## 10. OPEN QUESTIONS & NEXT STEPS

### Open Questions (Non-Blocking)

1. **Cookidoo API Integration**
   - **Question:** Is Cookidoo API available for third-party integration?
   - **Owner:** RESEARCH-AGENT
   - **Priority:** Low (Phase 3 feature)
   - **Action:** Research Cookidoo API documentation, contact if needed

2. **Push Notifications Strategy**
   - **Question:** MVP email-only or add push notifications?
   - **Owner:** PM-AGENT (decide in PRD)
   - **Priority:** Medium
   - **Options:** Email only (MVP), add push in Phase 1

3. **Gamification for Children**
   - **Question:** Points system? Badges? Rewards?
   - **Owner:** UX-DESIGNER + PM-AGENT
   - **Priority:** Low (Phase 2+)
   - **Action:** Research best practices, user testing with kids

### Handoff Checklist

- [x] Business context documented
- [x] Target users identified
- [x] Business model defined
- [x] MVP scope clarified
- [x] Roadmap planned (Phase 1, 2, 3)
- [x] Technical stack decided
- [x] Risks identified
- [x] Success metrics defined
- [x] Open questions listed

### Next Steps

1. **PM-AGENT:** Create PRD based on this document
   - Detailed user stories
   - Acceptance criteria
   - Prioritization framework

2. **ARCHITECT-AGENT:** Design technical architecture
   - Supabase schema (tables, relationships)
   - Auth flow diagrams
   - API design
   - Deployment pipeline

3. **UX-DESIGNER:** Create wireframes
   - Household setup flow
   - Shopping list screens
   - Dashboard layout
   - Mobile-first designs

4. **RESEARCH-AGENT:** Cookidoo API investigation (low priority)

---

## 11. SUMMARY

HomeOS is a **modular family hub** solving coordination chaos for Polish families with children. The MVP (3 weeks) focuses on core functionality: household setup + shopping list. Business model: freemium + $2/msc subscription. Tech stack: Next.js + Supabase + Vercel.

**Clarity Score: 88%** - Ready for PM-AGENT handoff.

**Key Differentiator:** Simple, family-focused, modular - not generic project management tool adapted for families.

---

**Document Status:** COMPLETE ✅
**Ready for Handoff:** PM-AGENT, ARCHITECT-AGENT, UX-DESIGNER
**Next Review:** After PRD creation
