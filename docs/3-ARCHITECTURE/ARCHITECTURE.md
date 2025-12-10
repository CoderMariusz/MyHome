# HomeOS - Technical Architecture Document

**Wersja:** 1.1
**Data:** 2025-12-09
**Autor:** Architect Agent
**Status:** Draft
**PRD Ref:** @docs/1-BASELINE/PRD.md
**Technical Research Ref:** @docs/1-BASELINE/research/technical-research.md

---

## 1. System Overview

### 1.1 Architektura Wysokopoziomowa

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|   Mobile/Web     |     |    Vercel Edge   |     |    Supabase      |
|   (PWA Client)   |<--->|    (Next.js 15)  |<--->|    (Backend)     |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        |                        |                        |
   +----v----+              +----v----+              +----v----+
   |  React  |              | Server  |              |PostgreSQL|
   |Components|              | Actions |              |   + RLS  |
   +---------+              +---------+              +----------+
        |                        |                        |
   +----v----+              +----v----+              +----v----+
   |  Zustand |              | API     |              | Realtime |
   |  State   |              | Routes  |              | (Phase 2)|
   +---------+              +---------+              +----------+
```

### 1.2 Warstwy Systemu

```
+-----------------------------------------------------------------------+
|                           PRESENTATION LAYER                           |
|  +------------------+  +------------------+  +------------------+       |
|  |   Pages (RSC)    |  |  Components      |  |  Layouts         |      |
|  |   - Dashboard    |  |  - ShoppingList  |  |  - AuthLayout    |      |
|  |   - Shopping     |  |  - TaskList      |  |  - AppLayout     |      |
|  |   - Tasks        |  |  - Invite        |  |  - SettingsLayout|      |
|  +------------------+  +------------------+  +------------------+       |
+-----------------------------------------------------------------------+
                                    |
+-----------------------------------------------------------------------+
|                           APPLICATION LAYER                            |
|  +------------------+  +------------------+  +------------------+       |
|  | Server Actions   |  | Hooks            |  | Context          |      |
|  | - addItem()      |  | - useAuth()      |  | - ThemeContext   |      |
|  | - toggleItem()   |  | - useHome()      |  | - I18nContext    |      |
|  | - createHome()   |  | - useShopping()  |  | - AuthContext    |      |
|  +------------------+  +------------------+  +------------------+       |
+-----------------------------------------------------------------------+
                                    |
+-----------------------------------------------------------------------+
|                           DATA ACCESS LAYER                            |
|  +------------------+  +------------------+  +------------------+       |
|  | Supabase Client  |  | Type Definitions |  | Query Functions  |      |
|  | - Server Client  |  | - Database Types |  | - getItems()     |      |
|  | - Browser Client |  | - API Types      |  | - getHome()      |      |
|  | - Middleware     |  | - Form Types     |  | - getMembers()   |      |
|  +------------------+  +------------------+  +------------------+       |
+-----------------------------------------------------------------------+
                                    |
+-----------------------------------------------------------------------+
|                           INFRASTRUCTURE LAYER                         |
|  +------------------+  +------------------+  +------------------+       |
|  | Supabase         |  | Vercel           |  | External APIs    |      |
|  | - PostgreSQL     |  | - Edge Runtime   |  | - Google OAuth   |      |
|  | - Auth           |  | - CDN            |  | - Web Push       |      |
|  | - Storage        |  | - Analytics      |  | - QR Generator   |      |
|  +------------------+  +------------------+  +------------------+       |
+-----------------------------------------------------------------------+
```

### 1.3 Request Flow

```
User Action
    |
    v
[Browser/PWA] ---> [Vercel Edge] ---> [Next.js Middleware]
                                              |
                                    +---------+---------+
                                    |                   |
                              [Authenticated]    [Not Authenticated]
                                    |                   |
                                    v                   v
                            [Server Component]    [Redirect /login]
                                    |
                                    v
                            [Server Action / API Route]
                                    |
                                    v
                            [Supabase Client (Server)]
                                    |
                                    v
                            [PostgreSQL + RLS]
                                    |
                                    v
                            [Response -> Client]
```

---

## 2. Tech Stack

### 2.1 Frontend

| Technologia | Wersja | Uzasadnienie |
|-------------|--------|--------------|
| **Next.js** | 15.x | App Router, Server Components, Server Actions |
| **React** | 19.x | Concurrent features, Server Components |
| **TypeScript** | 5.x | Type safety, DX |
| **Tailwind CSS** | 3.x | Utility-first, mobile-first design |
| **Zustand** | 4.x | Lightweight state management |
| **dnd-kit** | 6.x | Drag & drop (accessible, performant) |
| **next-intl** | 3.x | i18n (PL/EN) |
| **next-themes** | 0.3.x | Dark mode |
| **qrcode** | 1.5.x | Generowanie QR code dla zaproszen |

### 2.2 Backend

| Technologia | Wersja | Uzasadnienie |
|-------------|--------|--------------|
| **Supabase** | Latest | PostgreSQL + Auth + Realtime + RLS |
| **PostgreSQL** | 15.x | ACID, JSON support, RLS |
| **Supabase Auth** | - | Email + Google OAuth |
| **Supabase RLS** | - | Row Level Security |

### 2.3 Infrastructure

| Technologia | Uzasadnienie |
|-------------|--------------|
| **Vercel** | Edge deployment, automatic scaling, Preview deployments |
| **Supabase Cloud** | Managed PostgreSQL, free tier |
| **GitHub** | Version control, CI/CD integration |

### 2.4 Development Tools

| Narzedzie | Cel |
|-----------|-----|
| **ESLint** | Code quality |
| **Prettier** | Code formatting |
| **Husky** | Git hooks |
| **Vitest** | Unit testing |
| **Playwright** | E2E testing |

---

## 3. Environment Variables

```bash
# .env.local (development)
# .env.production (Vercel)

# === REQUIRED ===

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx

# Server-only (NIE PUBLIKOWAC!)
SUPABASE_SERVICE_ROLE_KEY=eyJxxx

# Site URL
NEXT_PUBLIC_SITE_URL=https://homeos.app

# === OPTIONAL ===

# Web Push (Phase 1)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=xxx
VAPID_PRIVATE_KEY=xxx
```

**Wazne:**
- `NEXT_PUBLIC_*` - dostepne w przegladarce
- Bez prefixu - tylko server-side
- `SUPABASE_SERVICE_ROLE_KEY` - NIGDY nie eksponowac klientowi!

---

## 4. Project Structure

```
homeos/
├── app/                          # Next.js App Router
│   ├── (auth)/                   # Auth group (login, register)
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── register/
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   ├── (app)/                    # Authenticated app group
│   │   ├── dashboard/
│   │   │   └── page.tsx
│   │   ├── shopping/
│   │   │   ├── page.tsx          # Lists overview
│   │   │   └── [listId]/
│   │   │       └── page.tsx      # Single list
│   │   ├── tasks/
│   │   │   └── page.tsx
│   │   ├── settings/
│   │   │   └── page.tsx
│   │   ├── invite/
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   ├── join/                     # Public: join by code
│   │   └── [code]/
│   │       └── page.tsx
│   ├── api/                      # API Routes (minimal)
│   │   ├── auth/
│   │   │   └── callback/
│   │   │       └── route.ts
│   │   └── push/
│   │       └── subscribe/
│   │           └── route.ts
│   ├── layout.tsx                # Root layout
│   ├── page.tsx                  # Landing / redirect
│   ├── manifest.ts               # PWA manifest
│   └── globals.css
│
├── components/                   # React Components
│   ├── ui/                       # Shadcn/ui primitives
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── card.tsx
│   │   └── ...
│   ├── shopping/
│   │   ├── ShoppingLists.tsx
│   │   ├── ShoppingListClient.tsx
│   │   ├── ShoppingItem.tsx
│   │   ├── AddItemForm.tsx
│   │   └── CategoryFilter.tsx
│   ├── tasks/
│   │   ├── TaskList.tsx
│   │   ├── TaskItem.tsx
│   │   └── AddTaskForm.tsx
│   ├── home/
│   │   ├── CreateHomeForm.tsx
│   │   ├── JoinHomeForm.tsx
│   │   ├── InviteCode.tsx
│   │   ├── InviteQRCode.tsx
│   │   └── MembersList.tsx
│   ├── layout/
│   │   ├── Header.tsx
│   │   ├── BottomNav.tsx
│   │   ├── Sidebar.tsx
│   │   └── PageContainer.tsx
│   └── common/
│       ├── LoadingSpinner.tsx
│       ├── ErrorBoundary.tsx
│       ├── NoConnection.tsx
│       └── Avatar.tsx
│
├── lib/                          # Utilities & Core Logic
│   ├── supabase/
│   │   ├── client.ts             # Browser client
│   │   ├── server.ts             # Server client
│   │   ├── middleware.ts         # Auth middleware helper
│   │   └── types.ts              # Generated DB types
│   ├── actions/                  # Server Actions
│   │   ├── shopping.ts
│   │   ├── tasks.ts
│   │   ├── home.ts
│   │   ├── auth.ts
│   │   └── notifications.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useHome.ts
│   │   ├── useShoppingList.ts
│   │   └── useRefresh.ts
│   ├── stores/
│   │   ├── shopping-store.ts
│   │   └── ui-store.ts
│   ├── i18n/
│   │   ├── config.ts
│   │   └── messages/
│   │       ├── pl.json
│   │       └── en.json
│   ├── utils/
│   │   ├── cn.ts                 # classnames helper
│   │   ├── format.ts
│   │   ├── qr.ts                 # QR code generation
│   │   └── validation.ts
│   └── constants/
│       ├── categories.ts
│       └── roles.ts
│
├── public/
│   ├── icons/
│   │   ├── icon-192.png
│   │   └── icon-512.png
│   └── sw.js                     # Service Worker (basic)
│
├── supabase/
│   └── migrations/
│       ├── 001_initial_schema.sql
│       ├── 002_rls_policies.sql
│       └── 003_functions.sql
│
├── middleware.ts                 # Next.js Middleware (auth)
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
└── package.json
```

---

## 5. QR Code System

### 5.1 Format URL Zaproszenia

```
https://homeos.app/join/{invite_code}

Przyklad:
https://homeos.app/join/ABC123
```

### 5.2 Generowanie QR Code

Biblioteka: `qrcode` (npm package)

```typescript
// lib/utils/qr.ts
import QRCode from 'qrcode';

export async function generateInviteQR(inviteCode: string): Promise<string> {
  const url = `${process.env.NEXT_PUBLIC_SITE_URL}/join/${inviteCode}`;

  // Generuj jako Data URL (base64)
  const qrDataUrl = await QRCode.toDataURL(url, {
    width: 256,
    margin: 2,
    color: {
      dark: '#000000',
      light: '#FFFFFF',
    },
  });

  return qrDataUrl;
}

// Alternatywnie: SVG string
export async function generateInviteQRSvg(inviteCode: string): Promise<string> {
  const url = `${process.env.NEXT_PUBLIC_SITE_URL}/join/${inviteCode}`;
  return QRCode.toString(url, { type: 'svg' });
}
```

### 5.3 Komponent QR Code

```typescript
// components/home/InviteQRCode.tsx
'use client';

import { useEffect, useState } from 'react';
import { generateInviteQR } from '@/lib/utils/qr';

interface InviteQRCodeProps {
  inviteCode: string;
}

export function InviteQRCode({ inviteCode }: InviteQRCodeProps) {
  const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);

  useEffect(() => {
    generateInviteQR(inviteCode).then(setQrDataUrl);
  }, [inviteCode]);

  if (!qrDataUrl) {
    return <div className="w-64 h-64 animate-pulse bg-gray-200" />;
  }

  return (
    <div className="flex flex-col items-center gap-4">
      <img src={qrDataUrl} alt="QR Code zaproszenia" className="w-64 h-64" />
      <p className="text-sm text-gray-500">
        Zeskanuj lub uzyj kodu: <strong>{inviteCode}</strong>
      </p>
    </div>
  );
}
```

---

## 6. Error Handling Strategy

### 6.1 Typy Bledow

| Typ | UI Element | Przyklad |
|-----|------------|----------|
| **Non-blocking** | Toast notification | "Produkt dodany do listy" |
| **Form validation** | Inline error | "Nazwa jest wymagana" |
| **Blocking** | Full-screen error | "Brak polaczenia z internetem" |
| **Server error** | Toast + retry | "Cos poszlo nie tak. Sprobuj ponownie" |

### 6.2 Implementacja

```typescript
// lib/utils/errors.ts
export type ErrorType = 'toast' | 'inline' | 'blocking';

export interface AppError {
  type: ErrorType;
  message: string;
  code?: string;
  retry?: () => void;
}

// Komunikaty w jezyku polskim
export const ERROR_MESSAGES = {
  // Auth
  AUTH_INVALID_CREDENTIALS: 'Nieprawidlowy email lub haslo',
  AUTH_EMAIL_IN_USE: 'Ten email jest juz zarejestrowany',
  AUTH_WEAK_PASSWORD: 'Haslo musi miec minimum 8 znakow',

  // Home
  HOME_ALREADY_MEMBER: 'Nalezysz juz do gospodarstwa domowego',
  HOME_INVALID_INVITE: 'Nieprawidlowy lub wygasly kod zaproszenia',
  HOME_INVITE_LIMIT: 'Osiagnieto limit zaproszen (3)',

  // Shopping
  SHOPPING_ITEM_NOT_FOUND: 'Produkt nie istnieje',
  SHOPPING_LIST_NOT_FOUND: 'Lista nie istnieje',

  // Network
  NETWORK_OFFLINE: 'Brak polaczenia z internetem',
  NETWORK_TIMEOUT: 'Przekroczono czas oczekiwania',

  // Generic
  GENERIC_ERROR: 'Cos poszlo nie tak. Sprobuj ponownie',
  PERMISSION_DENIED: 'Nie masz uprawnien do tej akcji',
} as const;
```

### 6.3 Toast Component

```typescript
// components/common/Toast.tsx
'use client';

import { Toaster, toast } from 'sonner';

export function ToastProvider({ children }: { children: React.ReactNode }) {
  return (
    <>
      {children}
      <Toaster
        position="bottom-center"
        toastOptions={{
          className: 'text-sm',
        }}
      />
    </>
  );
}

// Uzycie:
// toast.success('Produkt dodany');
// toast.error('Cos poszlo nie tak');
// toast.loading('Zapisywanie...');
```

### 6.4 Blocking Error Screen

```typescript
// components/common/NoConnection.tsx
'use client';

export function NoConnection({ onRetry }: { onRetry: () => void }) {
  return (
    <div className="fixed inset-0 flex flex-col items-center justify-center bg-white dark:bg-gray-900">
      <WifiOffIcon className="w-16 h-16 text-gray-400 mb-4" />
      <h1 className="text-xl font-semibold mb-2">Brak polaczenia</h1>
      <p className="text-gray-500 mb-6">Sprawdz polaczenie z internetem</p>
      <button
        onClick={onRetry}
        className="px-4 py-2 bg-primary text-white rounded-lg"
      >
        Sprobuj ponownie
      </button>
    </div>
  );
}
```

---

## 7. Authentication Flow

### 7.1 Email + Password Registration

```
+----------+     +----------+     +----------+     +----------+
|  User    |     |  Next.js |     | Supabase |     |  Email   |
|          |     |  Server  |     |   Auth   |     | Provider |
+----+-----+     +----+-----+     +----+-----+     +----+-----+
     |                |                |                |
     | 1. Submit form |                |                |
     |--------------->|                |                |
     |                | 2. signUp()    |                |
     |                |--------------->|                |
     |                |                | 3. Send magic  |
     |                |                |    link email  |
     |                |                |--------------->|
     |                |<---------------|                |
     |<---------------|                |                |
     | 4. Show "check email" message   |                |
     |                |                |                |
     | 5. Click magic link             |                |
     |--------------------------------------------------->
     |                |                |                |
     |<---------------| 6. Redirect to |                |
     |                |    /auth/callback               |
     |                |                |                |
     | 7. Redirect to /dashboard or /setup-home         |
     |<---------------|                |                |
```

### 7.2 Google OAuth Flow

```
+----------+     +----------+     +----------+     +----------+
|  User    |     |  Next.js |     | Supabase |     |  Google  |
|          |     |  Server  |     |   Auth   |     |   OAuth  |
+----+-----+     +----+-----+     +----+-----+     +----+-----+
     |                |                |                |
     | 1. Click "Sign in with Google"  |                |
     |--------------->|                |                |
     |                | 2. signInWithOAuth()            |
     |                |--------------->|                |
     |                |                | 3. Redirect    |
     |<---------------|-----------------+--------------->|
     |                |                |                |
     | 4. Google consent screen        |                |
     |<------------------------------------------------>|
     |                |                |                |
     | 5. Callback with code           |                |
     |--------------------------------------------------->
     |                |                | 6. Exchange    |
     |                |                |    code        |
     |                |                |<---------------|
     |                |<---------------|                |
     | 7. Redirect to /dashboard       |                |
     |<---------------|                |                |
```

### 7.3 Session Management

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr';
import { NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const response = NextResponse.next();

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get: (name) => request.cookies.get(name)?.value,
        set: (name, value, options) => response.cookies.set({ name, value, ...options }),
        remove: (name, options) => response.cookies.set({ name, value: '', ...options }),
      },
    }
  );

  // UWAGA: getUser() zamiast getSession() - bezpieczniejsze
  const { data: { user } } = await supabase.auth.getUser();

  // Protected routes
  if (request.nextUrl.pathname.startsWith('/dashboard') && !user) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return response;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\..*).*)'],
};
```

---

## 8. Security Architecture

### 8.1 Row Level Security (RLS)

Wszystkie tabele maja wlaczony RLS. Uzytkownik widzi TYLKO dane swojego gospodarstwa.

**Diagram dostepow:**

```
+------------------+
|  auth.users      |
|  (Supabase Auth) |
+--------+---------+
         |
         | user_id
         v
+------------------+          +------------------+
|  home_members    |--------->|      homes       |
|  - user_id (FK)  |  home_id |  - id            |
|  - home_id (FK)  |          +--------+---------+
|  - role          |                   |
+--------+---------+                   | home_id
         |                             |
         | auth.uid() =                v
         | user_id           +------------------+
         |                   | shopping_list_   |
         +------------------>| items            |
                            | - home_id (FK)   |
                            +------------------+
```

### 8.2 Role Permissions Matrix

| Akcja | Admin | Member | Child |
|-------|-------|--------|-------|
| Create home | Yes | No | No |
| Delete home | Yes | No | No |
| Invite members | Yes | Yes (max 3) | No |
| Remove members | Yes | No | No |
| Change roles | Yes | No | No |
| Create shopping list | Yes | Yes | Configurable |
| Add items | Yes | Yes | Configurable |
| Check off items | Yes | Yes | Yes |
| Delete items | Yes | Yes | No |
| Create tasks | Yes | Yes | No |
| Complete tasks | Yes | Yes | Yes |

### 8.3 Security Checklist

- [x] HTTPS only (Vercel default)
- [x] RLS on all tables
- [x] Auth token in httpOnly cookies
- [x] CSRF protection (Server Actions)
- [x] Input validation (Zod)
- [x] SQL injection prevention (Supabase client)
- [x] XSS prevention (React default escaping)
- [ ] Rate limiting (Phase 1)
- [ ] Content Security Policy (Phase 1)

---

## 9. Synchronization Strategy

### 9.1 MVP: 10-Minute Refresh

```
+----------+                    +----------+                    +----------+
|  User A  |                    |  Server  |                    |  User B  |
+----+-----+                    +----+-----+                    +----+-----+
     |                               |                               |
     | 1. Add item "Milk"            |                               |
     |------------------------------>|                               |
     |                               |                               |
     |<------------------------------|                               |
     | 2. Optimistic UI update       |                               |
     |                               |                               |
     |                               |    [10 min later]             |
     |                               |                               |
     |                               |<------------------------------|
     |                               | 3. Auto-refresh query         |
     |                               |------------------------------>|
     |                               | 4. Return items (incl. Milk)  |
     |                               |                               |
```

**Implementacja:**

```typescript
// hooks/useRefresh.ts
export function useAutoRefresh<T>(
  queryFn: () => Promise<T>,
  intervalMs: number = 10 * 60 * 1000 // 10 min
) {
  const [data, setData] = useState<T | null>(null);
  const [lastRefresh, setLastRefresh] = useState<Date>(new Date());

  useEffect(() => {
    // Initial fetch
    queryFn().then(setData);

    // Set up interval
    const interval = setInterval(async () => {
      const result = await queryFn();
      setData(result);
      setLastRefresh(new Date());
    }, intervalMs);

    return () => clearInterval(interval);
  }, [queryFn, intervalMs]);

  const manualRefresh = async () => {
    const result = await queryFn();
    setData(result);
    setLastRefresh(new Date());
  };

  return { data, lastRefresh, manualRefresh };
}
```

### 9.2 Phase 2: Supabase Realtime

```typescript
// Upgrade path
useEffect(() => {
  const channel = supabase
    .channel('shopping-changes')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'shopping_list_items',
      filter: `home_id=eq.${homeId}`
    }, (payload) => {
      handleRealtimeChange(payload);
    })
    .subscribe();

  return () => {
    channel.unsubscribe();
  };
}, [homeId]);
```

---

## 10. Deployment Architecture

### 10.1 Environments

| Environment | URL | Branch | Purpose |
|-------------|-----|--------|---------|
| Production | homeos.app | main | Live users |
| Preview | *.vercel.app | PR branches | Feature testing |
| Local | localhost:3000 | - | Development |

### 10.2 CI/CD Pipeline

```
+----------+     +----------+     +----------+     +----------+
|  GitHub  |     |  Vercel  |     |  Tests   |     |  Deploy  |
|   Push   |---->|   Build  |---->|  (E2E)   |---->|  (Edge)  |
+----------+     +----------+     +----------+     +----------+
     |                |                |                |
     |                |                |                |
   [main]          [build]          [test]          [prod]
   [PR/*]          [build]          [test]          [preview]
```

---

## 11. Performance Targets

### 11.1 Core Web Vitals

| Metric | Target | Measurement |
|--------|--------|-------------|
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse |
| FID (First Input Delay) | < 100ms | Lighthouse |
| CLS (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| TTI (Time to Interactive) | < 3s | Lighthouse |
| Lighthouse Score | > 90 | Lighthouse |

### 11.2 Bundle Size Targets

| Chunk | Target |
|-------|--------|
| Initial JS | < 100KB gzipped |
| First Load JS | < 150KB gzipped |
| Total JS | < 500KB gzipped |

### 11.3 Optimization Strategies

1. **Server Components** - Reduce client JS
2. **Dynamic Imports** - Code splitting
3. **Image Optimization** - next/image
4. **Font Optimization** - next/font with system fonts
5. **Prefetching** - Link prefetch for navigation

---

## 12. Related Documents

| Document | Path | Description |
|----------|------|-------------|
| Database Schema | @docs/3-ARCHITECTURE/DATABASE-SCHEMA.md | Szczegolowy schemat DB |
| API Routes | @docs/3-ARCHITECTURE/API-ROUTES.md | Server Actions & API |
| ADR-001 | @docs/3-ARCHITECTURE/decisions/ADR-001-supabase-backend.md | Wybor Supabase |
| ADR-002 | @docs/3-ARCHITECTURE/decisions/ADR-002-pwa-first.md | PWA strategy |
| ADR-003 | @docs/3-ARCHITECTURE/decisions/ADR-003-polling-sync.md | 10 min refresh |
| ADR-004 | @docs/3-ARCHITECTURE/decisions/ADR-004-server-actions.md | Server Actions |

---

## 13. Traceability Matrix

### Requirements -> Architecture

| Requirement | Architecture Component | Notes |
|-------------|----------------------|-------|
| FR-01 (Email Auth) | Supabase Auth + Server Actions | Magic link |
| FR-02 (Google OAuth) | Supabase Auth | OAuth flow |
| FR-03 (Household CRUD) | homes table + RLS | Multi-tenant |
| FR-04 (Invite System) | home_invites table + QR | 6-char code |
| FR-05 (Roles) | home_members.role + RLS | Admin/Member/Child |
| FR-06 (Shopping Lists CRUD) | shopping_lists table | Per-home |
| FR-07 (Items + Categories) | shopping_list_items + categories | Predefined + custom |
| FR-08 (Drag & Drop) | dnd-kit | Accessible |
| FR-09 (Checkoff + Sync) | is_purchased + useAutoRefresh | 10 min |
| FR-10 (Push Notifications) | Web Push API | Opt-in |
| FR-11 (Tasks Preview) | tasks table | Basic CRUD |
| FR-12 (Dark Mode) | next-themes | System + toggle |
| FR-13 (i18n) | next-intl | PL/EN |

| NFR | Architecture Decision |
|-----|----------------------|
| NFR-01 (TTI < 3s) | Server Components, code splitting |
| NFR-02 (Lighthouse 90+) | Optimization strategies |
| NFR-03 (99% Uptime) | Vercel + Supabase SLA |
| NFR-04 (Token 7 days) | Supabase Auth config |
| NFR-05 (HTTPS) | Vercel default |
| NFR-06 (RLS) | All tables enabled |
| NFR-07 (Mobile-first) | Tailwind responsive |
| NFR-08 (Touch 44px) | Component design |
| NFR-09 (10 min sync) | useAutoRefresh hook |
| NFR-10 (Manual refresh < 2s) | Query optimization |

---

## 14. Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Supabase free tier limits | Medium | High | Monitor usage, upgrade plan ready |
| Push notification reliability | High | Medium | Fallback to email, test early |
| PWA installation issues | Medium | Medium | Clear install prompts, documentation |
| RLS performance | Low | Medium | Proper indexes, query optimization |
| 10 min sync not enough | Medium | Low | Ready upgrade path to Realtime |

---

**Document Version:** 1.1
**Last Updated:** 2025-12-09
**Author:** Architect Agent
**Status:** Draft - Awaiting Review
**Changes:**
- Dodano sekcje Environment Variables
- Dodano sekcje QR Code System
- Dodano sekcje Error Handling Strategy
- Poprawiono getSession() na getUser() w middleware
- Dodano qrcode do tech stack
