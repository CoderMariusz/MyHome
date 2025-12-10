# HomeOS - Project Understanding

**Data:** 2025-12-09
**Clarity Score:** 95%
**Status:** ✅ COMPLETE - Gotowe do PRD

---

## 1. Wizja i Cel

### Problem
Istniejące aplikacje do zarządzania domem są:
- Rozproszone (osobne apki do list, zadań, rachunków)
- Drogie (Cozi $30-39/rok, FamilyWall $60/rok)
- Zepsute (powiadomienia nie działają, bugi)
- Przestarzałe (UI z 2010 roku)

### Rozwiązanie
**HomeOS** - modularna aplikacja do zarządzania domem dla polskich rodzin.
- Jedna apka = wszystkie potrzeby domowe
- Przystępna cena (~8 PLN/msc)
- Nowoczesny mobile-first UX
- Niezawodne powiadomienia

### Cel Biznesowy
- Side income (nie full business na start)
- Walidacja rynkowa → dostosowanie cen
- MVP w 3 tygodnie

---

## 2. Użytkownicy Docelowi

### Główna Grupa
Polskie rodziny z dziećmi

### Role w Systemie

| Rola | Uprawnienia | Przykład |
|------|-------------|----------|
| **Admin** | Pełne uprawnienia, zarządzanie household | Rodzic |
| **Member** | Dodawanie/edycja, może zapraszać (max 3) | Nastolatek 15+ |
| **Child** | Ograniczone, konfigurowalne w settings | Dziecko 8-14 |

### Scenariusz Użycia
Mama zakłada konto → zaprasza Tatę (QR/kod) → dodaje dzieci (username + parent approval)

---

## 3. MVP Scope (3 tygodnie)

### Tydzień 1: Fundament
- [ ] Rejestracja (email/password)
- [ ] **Google OAuth** ("Sign in with Google")
- [ ] Household creation
- [ ] Invite system (QR code + kod tekstowy)
- [ ] Roles & permissions (basic)
- [ ] Dashboard (pusty placeholder)

### Tydzień 2: Shopping List (pełna)
- [ ] Tworzenie wielu list
- [ ] **Kategorie predefiniowane** (Mleczne, Warzywa, Pieczywo, Mięso, Napoje, Inne) + własne
- [ ] **Sortowanie:** wybór użytkownika (drag & drop LUB wg kategorii)
- [ ] Checkoff items
- [ ] Multi-user sync (10 min refresh)
- [ ] Przypisywanie do osób
- [ ] **Basic push notifications**

### Tydzień 3: Tasks Preview + Polish
- [ ] **Tasks/Chores module (PREVIEW)**
  - UI gotowe
  - Basic CRUD
  - Przypisywanie do osób
  - Podgląd co było zaplanowane
- [ ] Bugfixy
- [ ] Polish UI
- [ ] Deploy na Vercel
- [ ] Beta testing (2-3 rodziny)

### Wymagania Techniczne MVP
- **Offline:** Wymaga internetu ("No connection" screen)
- **Multi-household:** NIE (1 user = 1 household)
- **Dark mode:** TAK (toggle light/dark)
- **Export danych:** NIE w MVP (Phase 1, tylko Premium)
- **Język:** Polski + Angielski (i18n)
- **Płatności:** Stripe (BLIK później)

---

## 4. Roadmap (Phase 1, 2, 3)

### Phase 1 (1-2 miesiące po MVP)
| Moduł | Opis | Priorytet |
|-------|------|-----------|
| **Tasks/Chores (pełny)** | Alternatywa tablicy zadań, accountability | 🔴 HIGH |
| **Bills Tracker** | Kiedy co płacić, przypomnienia | 🔴 HIGH |
| **Offline cache** | Działa bez internetu, sync później | 🔴 HIGH |
| **Conflict resolution** | Merge changes (Mama + Tata = oba zostają) | 🟡 MEDIUM |
| **Export danych** | JSON/CSV, tylko Premium | 🟡 MEDIUM |

### Phase 2 (3-4 miesiące)
| Moduł | Opis | Priorytet |
|-------|------|-----------|
| **Expenses (zaawansowany)** | Zdjęcie rachunku, szybka rejestracja (osoba, opis, kwota) | 🔴 HIGH |
| **Wykresy wydatków** | Wizualizacja, limit z alertem | 🔴 HIGH |
| **Price tracking** | Śledzenie cen w shopping list | 🟡 MEDIUM |
| **Real-time sync** | Zamiast 10 min refresh | 🟡 MEDIUM |
| **BLIK payments** | Polski payment method | 🟡 MEDIUM |

### Phase 3 (5-6 miesięcy)
| Moduł | Opis | Priorytet |
|-------|------|-----------|
| **Meal Planning** | Menu tygodniowe → auto shopping list | 🟡 MEDIUM |
| **Recipe API** | Spoonacular/Edamam (NIE Cookidoo - brak API) | 🟡 MEDIUM |
| **Family Calendar** | Shared events | 🟡 MEDIUM |
| **Allowance** | Chores → pocket money dla dzieci | 🟢 LOW |
| **Home maintenance** | Kiedy zmienić filtr, etc. | 🟢 LOW |
| **Emergency contacts** | Lekarze, szkoły, opiekunki | 🟢 LOW |

---

## 5. Model Biznesowy

### Pricing

| Tier | Cena | Funkcje |
|------|------|---------|
| **Free** | 0 PLN | Pełne funkcje z limitami + reklamy (nieinwazyjne) |
| **Premium** | **~8 PLN/msc** lub **~80 PLN/rok** | Bez reklam, unlimited, export, AI suggestions |

### Free Tier Limits
| Zasob | Limit |
|-------|-------|
| Listy zakupow | Max 12 |
| Produkty per lista | Max 50 |
| Czlonkowie gospodarstwa | Max 10 |

### Monetyzacja
1. **Freemium** - darmowy tier z limitami
2. **Subscription** - miesięczna/roczna
3. **Ads** - nieinwazyjne w free tier

### Konkurencyjne Ceny
- Cozi: $30-39/rok (~120-160 PLN)
- FamilyWall: $60/rok (~240 PLN)
- **HomeOS: ~80 PLN/rok** ← 2x tańszy!

---

## 6. Stack Techniczny

### Confirmed
- **Frontend:** Next.js (mobile-first, PWA)
- **Backend:** Supabase (auth, database, real-time)
- **Hosting:** Vercel
- **Payments:** Stripe (start), BLIK (Phase 2)
- **Auth:** Email/password + Google OAuth
- **Notifications:** Basic push (MVP)

### Later
- Native iOS app (React Native lub Swift)
- Recipe API (Spoonacular/Edamam)
- AI suggestions

---

## 7. Metryki Sukcesu MVP

| Metryka | Cel |
|---------|-----|
| Użytkownicy | 20 osób |
| Feedback | Pozytywny, konstruktywny |
| Poprawki | Zaimplementowane |
| Timeline | 3 tygodnie |

---

## 8. Decyzje Techniczne (Szczegóły)

### Shopping List
- **Kategorie:** Predefiniowane + własne
- **Sortowanie:** Wybór użytkownika (drag & drop lub wg kategorii)
- **Sync:** 10 min refresh (MVP), real-time (Phase 2)

### Offline & Sync
- **MVP:** Wymaga internetu
- **Post-MVP:** Offline cache z sync
- **Conflict resolution:** Merge changes (Phase 1)

### Multi-household
- **MVP:** NIE (1 user = 1 household)
- **Later:** Rozważyć switcher

### Theme
- **Dark mode:** TAK w MVP (toggle)

### Data Export
- **MVP:** NIE
- **Phase 1:** TAK, tylko Premium

---

## 9. Branding

- **Nazwa:** HomeOS
- **Ton:** Professional/practical + emoji/smaczki (nie za sucha)
- **Język:** Polski + Angielski
- **Target:** Polskie rodziny z dziećmi

---

## 10. Ryzyka i Mitygacja

| Ryzyko | Mitygacja |
|--------|-----------|
| 3 tygodnie za krótko | Scope MVP minimalny, Tasks tylko preview |
| Konkurencja (Cozi, etc.) | Niższa cena, polski rynek, bills tracking |
| Push notifications zawodne | Testować wcześnie, backup email |
| Offline wymagany | Dodać zaraz po MVP feedback |

---

## 11. Następne Kroki

1. ✅ Discovery complete (95% clarity)
2. ⏳ **PM-AGENT** → PRD
3. ⏳ **ARCHITECT-AGENT** → Technical Architecture
4. ⏳ **UX-DESIGNER** → Wireframes
5. ⏳ Development starts

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Author:** Discovery Agent (Mary)
**Approved by:** User ✅
