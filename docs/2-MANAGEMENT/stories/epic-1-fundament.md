# Epic 1: Fundament (Auth + Household)

**Epic ID:** E1
**Tydzien:** 1
**Priorytet:** Must Have
**Status:** Draft

**PRD Traces:** US-01, US-02, US-03, US-04, US-05, US-06, US-06a, US-07
**FR Traces:** FR-01, FR-02, FR-03, FR-04, FR-05, FR-06

---

## Podsumowanie

| Story | Tytul | Complexity | Priorytet | Status |
|-------|-------|------------|-----------|--------|
| 1-1 | Setup projektu Next.js + Supabase | M | Must Have | Draft |
| 1-2 | Rejestracja Email z weryfikacja | M | Must Have | Draft |
| 1-3 | Logowanie Google OAuth | M | Must Have | Draft |
| 1-4 | Account Linking (Email + OAuth) | M | Must Have | Draft |
| 1-5 | Tworzenie Gospodarstwa Domowego | S | Must Have | Draft |
| 1-6 | Generowanie i wyswietlanie QR/kodu zaproszenia | M | Must Have | Draft |
| 1-7 | Dolaczanie do Gospodarstwa (kod/QR) | M | Must Have | Draft |
| 1-8 | Zarzadzanie Rolami (Admin Panel) | M | Should Have | Draft |
| 1-9 | Rejestracja Dziecka (Child Account) | M | Must Have | Draft |
| 1-10 | Dashboard (Placeholder) | S | Must Have | Draft |

---

## Story 1-1: Setup projektu Next.js + Supabase

### User Story
Jako **developer**
Chce **miec skonfigurowany projekt z Next.js i Supabase**
Zeby **moc zaczac implementacje funkcjonalnosci**

### Complexity: M (Medium)
### Type: Infra

### Acceptance Criteria
- [ ] AC1: Projekt Next.js 15 z App Router zainicjalizowany
- [ ] AC2: TypeScript skonfigurowany ze strict mode
- [ ] AC3: Tailwind CSS zainstalowany i skonfigurowany
- [ ] AC4: Supabase client (browser + server) skonfigurowany
- [ ] AC5: Middleware dla auth sprawdza sesje na protected routes
- [ ] AC6: Environment variables (.env.local) skonfigurowane
- [ ] AC7: Projekt deplowalny na Vercel (basic)
- [ ] AC8: ESLint + Prettier skonfigurowane

### Technical Notes
- Next.js 15.x z App Router
- @supabase/ssr dla SSR-friendly client
- Struktura folderow zgodna z ARCHITECTURE.md
- Middleware pattern z dokumentacji Supabase

### Dependencies
- Brak (pierwszy story)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] `npm run dev` dziala bez bledow
- [ ] `npm run build` przechodzi
- [ ] Deployment na Vercel Preview dziala
- [ ] Code review zaliczone

---

## Story 1-2: Rejestracja Email z weryfikacja

### User Story
Jako **nowy uzytkownik**
Chce **zarejestrowac sie przez email i haslo**
Zeby **miec konto w aplikacji**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Formularz z polami: email, haslo, potwierdzenie hasla
- [ ] AC2: Walidacja client-side: email format, haslo min 8 znakow
- [ ] AC3: Walidacja server-side: email unikalny
- [ ] AC4: Po rejestracji wysylany magic link na email
- [ ] AC5: Komunikaty bledow wyswietlane po polsku
- [ ] AC6: Po weryfikacji email -> redirect do /setup-home
- [ ] AC7: Loading state podczas rejestracji

### Technical Notes
- Supabase `signUp` z `emailRedirectTo`
- Server Action dla rejestracji
- Zod dla walidacji
- Route: `/register`
- Callback route: `/auth/callback`

### Dependencies
- Story 1-1 (Setup projektu)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Testy manualne: happy path + error cases
- [ ] Email weryfikacyjny dostarczany
- [ ] Code review zaliczone

---

## Story 1-3: Logowanie Google OAuth

### User Story
Jako **uzytkownik**
Chce **zalogowac sie przez Google**
Zeby **nie musiec pamietac kolejnego hasla**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Przycisk "Zaloguj przez Google" na stronie logowania
- [ ] AC2: Klikniecie otwiera popup/redirect do Google
- [ ] AC3: Po zalogowaniu -> redirect do dashboard lub setup-home
- [ ] AC4: Blad przy anulowaniu wyswietla komunikat
- [ ] AC5: Blad sieci wyswietla komunikat
- [ ] AC6: Automatyczne tworzenie profilu uzytkownika w bazie

### Technical Notes
- Supabase `signInWithOAuth` provider: 'google'
- Google OAuth credentials w Supabase Dashboard
- Callback route: `/auth/callback`
- Sprawdzenie czy user ma home_id -> redirect

### Dependencies
- Story 1-1 (Setup projektu)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Google OAuth skonfigurowany w Supabase
- [ ] Testy manualne: happy path + cancel + error
- [ ] Code review zaliczone

---

## Story 1-4: Account Linking (Email + OAuth)

### User Story
Jako **uzytkownik z istniejacym kontem email**
Chce **moc zalogowac sie przez Google (ten sam email)**
Zeby **miec jeden profil niezaleznie od metody logowania**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Jesli email Google juz istnieje (metoda email) -> komunikat "Konto istnieje"
- [ ] AC2: Opcja "Polacz konta" wymaga weryfikacji hasla
- [ ] AC3: Po polaczeniu -> oba sposoby logowania dzialaja
- [ ] AC4: Jesli email z rejestracji istnieje (metoda OAuth) -> analogiczny flow
- [ ] AC5: Po polaczeniu -> jeden profil uzytkownika

### Technical Notes
- Supabase `linkIdentity` API
- Modal do weryfikacji hasla
- Server Action dla linkowania
- Error handling dla konfliktu email

### Dependencies
- Story 1-2 (Rejestracja Email)
- Story 1-3 (Google OAuth)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Testy manualne: oba kierunki linkowania
- [ ] Code review zaliczone

---

## Story 1-5: Tworzenie Gospodarstwa Domowego

### User Story
Jako **nowy uzytkownik (po weryfikacji)**
Chce **utworzyc gospodarstwo domowe**
Zeby **moc zaprosic rodzine**

### Complexity: S (Small)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Formularz z polem: nazwa gospodarstwa (max 50 znakow)
- [ ] AC2: Walidacja: nazwa wymagana, min 1 znak
- [ ] AC3: Po utworzeniu: uzytkownik staje sie Adminem
- [ ] AC4: Redirect do dashboard po utworzeniu
- [ ] AC5: Toast "Gospodarstwo utworzone pomyslnie"

### Technical Notes
- Route: `/setup-home`
- Server Action: `createHome()`
- Tworzenie rekordu w `homes` + `home_members`
- RLS: tylko auth user moze tworzyc

### Dependencies
- Story 1-2 lub 1-3 (Auth)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Rekord w DB poprawny (home + member)
- [ ] Code review zaliczone

---

## Story 1-6: Generowanie i wyswietlanie QR/kodu zaproszenia

### User Story
Jako **Admin gospodarstwa**
Chce **wygenerowac kod zaproszenia i QR**
Zeby **zaprosic czlonkow rodziny**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Przycisk "Zapros" na dashboard lub w ustawieniach
- [ ] AC2: Wyswietlenie QR code (256x256)
- [ ] AC3: Wyswietlenie kodu tekstowego (6 znakow, uppercase)
- [ ] AC4: Przycisk "Kopiuj kod" -> clipboard
- [ ] AC5: Przycisk "Udostepnij" -> Web Share API (jesli dostepne)
- [ ] AC6: Informacja: "Zaproszenie wazne 7 dni"
- [ ] AC7: Member moze wyslac max 3 zaproszenia

### Technical Notes
- Biblioteka `qrcode` dla QR
- Server Action: `createInvite()`
- Tabela `home_invites` z `invite_code`
- URL format: `https://homeos.app/join/{code}`

### Dependencies
- Story 1-5 (Tworzenie Gospodarstwa)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] QR code renderuje sie poprawnie
- [ ] Limit zaproszen dla Member dziala
- [ ] Code review zaliczone

---

## Story 1-7: Dolaczanie do Gospodarstwa (kod/QR)

### User Story
Jako **zaproszony uzytkownik**
Chce **dolaczyc do gospodarstwa przez kod lub QR**
Zeby **byc czescia rodzinnej organizacji**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Strona `/join` z polem na kod (6 znakow)
- [ ] AC2: Strona `/join/[code]` - auto-wypelnienie kodu z URL
- [ ] AC3: Skanowanie QR otwiera URL -> `/join/[code]`
- [ ] AC4: Walidacja kodu: poprawnosc formatu, waznosc
- [ ] AC5: Blad "Nieprawidlowy lub wygasly kod" jesli invalid
- [ ] AC6: Po dolaczeniu -> Admin wybiera role (pending state)
- [ ] AC7: Ekran "Czekam na akceptacje..." dla zaproszonego

### Technical Notes
- Server Action: `validateAndJoinHome()`
- Funkcja DB: `validate_and_use_invite()`
- Status member: `pending` do akceptacji przez Admina
- Push notification do Admina o nowym zaproszeniu

### Dependencies
- Story 1-6 (Generowanie zaproszenia)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Happy path: kod -> join -> pending
- [ ] Error path: invalid code
- [ ] Code review zaliczone

---

## Story 1-8: Zarzadzanie Rolami (Admin Panel)

### User Story
Jako **Admin**
Chce **zarzadzac rolami czlonkow**
Zeby **kontrolowac uprawnienia w gospodarstwie**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Lista czlonkow z ich rolami i statusem
- [ ] AC2: Pending members widoczni z przyciskiem "Akceptuj"
- [ ] AC3: Przy akceptacji Admin wybiera role: Member lub Child
- [ ] AC4: Mozliwosc zmiany roli istniejacego czlonka
- [ ] AC5: Mozliwosc usuwania czlonkow (nie siebie)
- [ ] AC6: Wyswietlanie ile zaproszen wyslal kazdy Member

### Technical Notes
- Route: `/settings/members`
- Server Actions: `acceptMember()`, `changeRole()`, `removeMember()`
- RLS: tylko Admin moze modyfikowac
- UI: lista z akcjami inline

### Dependencies
- Story 1-7 (Dolaczanie)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Admin moze akceptowac/zmieniac/usuwac
- [ ] Non-admin nie widzi opcji
- [ ] Code review zaliczone

---

## Story 1-9: Rejestracja Dziecka (Child Account)

### User Story
Jako **rodzic (Admin)**
Chce **utworzyc konto dla dziecka**
Zeby **dziecko moglo korzystac z aplikacji bez podawania emaila**

### Complexity: M (Medium)
### Type: Full-stack

### Acceptance Criteria
- [ ] AC1: Przycisk "Dodaj dziecko" w panelu czlonkow
- [ ] AC2: Formularz: username (unikalny w gospodarstwie), haslo
- [ ] AC3: Walidacja: username min 3 znaki, haslo min 6 znakow
- [ ] AC4: Brak wymogu emaila (prywatnosc dziecka)
- [ ] AC5: Automatyczne przypisanie roli Child
- [ ] AC6: Dziecko loguje sie przez username + haslo
- [ ] AC7: Rodzic moze zresetowac haslo dziecka
- [ ] AC8: Rodzic moze usunac konto dziecka

### Technical Notes
- Custom auth flow dla child (nie Supabase OAuth)
- Tabela `child_accounts` lub rozszerzenie `auth.users`
- Server Action: `createChildAccount()`
- Route logowania: `/login/child`

### Dependencies
- Story 1-5 (Tworzenie Gospodarstwa)
- Story 1-8 (Zarzadzanie Rolami)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Child moze sie zalogowac przez username/haslo
- [ ] Admin moze resetowac/usuwac
- [ ] Code review zaliczone

---

## Story 1-10: Dashboard (Placeholder)

### User Story
Jako **zalogowany uzytkownik**
Chce **widziec glowny ekran aplikacji**
Zeby **miec dostep do wszystkich funkcji**

### Complexity: S (Small)
### Type: Frontend

### Acceptance Criteria
- [ ] AC1: Naglowek z nazwa gospodarstwa
- [ ] AC2: Wyswietlanie nazwy uzytkownika i roli
- [ ] AC3: Nawigacja do "Listy zakupow"
- [ ] AC4: Nawigacja do "Zadania" (z badge "Preview")
- [ ] AC5: Nawigacja do "Ustawienia"
- [ ] AC6: Przycisk wylogowania
- [ ] AC7: Bottom navigation na mobile

### Technical Notes
- Route: `/dashboard`
- Layout z Header + BottomNav
- Protected route (middleware)
- Server Component z pobieraniem danych home

### Dependencies
- Story 1-5 (Tworzenie Gospodarstwa)

### Definition of Done
- [ ] Kod zaimplementowany zgodnie z AC
- [ ] Responsive design (mobile + desktop)
- [ ] Nawigacja dziala
- [ ] Code review zaliczone

---

## Diagram Zaleznosci Stories

```
1-1 (Setup)
    |
    +---> 1-2 (Email Auth) ---+
    |                         |
    +---> 1-3 (Google OAuth) -+---> 1-4 (Account Linking)
                              |
                              v
                         1-5 (Create Home)
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
         1-6 (Invite)    1-10 (Dashboard)  1-9 (Child)
              |                               |
              v                               |
         1-7 (Join)                           |
              |                               |
              v                               |
         1-8 (Roles) <------------------------+
```

---

## Changelog

### v1.0 (2025-12-09)
- Initial story breakdown
- 10 stories dla Epic 1

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Epic Status:** Draft
