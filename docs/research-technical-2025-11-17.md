# Badanie Techniczne: Architektura MyHome

**Data:** 2025-11-17
**Projekt:** MyHome - Aplikacja do zarządzania domem z listą zakupów
**Typ badania:** Technical Research
**Autor:** BMad Research Workflow

---

## Streszczenie Wykonawcze

To badanie techniczne analizuje optymalne rozwiązania architektoniczne dla aplikacji MyHome - aplikacji webowej i mobilnej do zarządzania listą zakupów dla rodzin z funkcją real-time synchronizacji.

### Kluczowe Wnioski

**Rekomendowany Stack:**
- ✅ **Supabase** (PostgreSQL + Realtime + Auth + RLS) - optymalne dla multi-tenant real-time apps
- ✅ **Next.js 15** z App Router - server-first rendering z React Server Components
- ✅ **PWA w Phase 1** → React Native w Phase 2 - minimalizacja ryzyka, szybszy time-to-market
- ✅ **Web Push API** (PWA) → **Expo Notifications** (React Native)
- ✅ **PowerSync** lub custom queue dla offline-first capability

### Kluczowe Decyzje Architektoniczne

1. **Real-time Sync**: Supabase Realtime (WebSocket) z selective table subscriptions
2. **Security**: Row Level Security (RLS) z auth.uid() dla izolacji multi-tenant
3. **Mobile Strategy**: Start z PWA, migracja do React Native gdy funkcjonalność się rozrośnie
4. **Offline Handling**: Custom request queue w Phase 1, PowerSync w Phase 2 jeśli potrzebne
5. **Notifications**: Web Push API z opt-in pattern, migracja do Expo Notifications

---

## 1. Kontekst Projektu i Wymagania

### 1.1 Pytanie Techniczne

Jak zaprojektować architekturę aplikacji MyHome (lista zakupów z real-time sync dla rodzin) wykorzystując:
- Supabase (baza danych + realtime + auth)
- Next.js 15 + TypeScript
- PWA z późniejszą migracją do React Native
- Push notifications

### 1.2 Kontekst Projektu

- **Typ:** Greenfield (nowy projekt)
- **Platforma:** Web (Next.js) + Mobile (PWA → React Native w Phase 2)
- **Use case:** Multi-user collaborative shopping lists dla gospodarstw domowych
- **Kluczowe wymagania:** Real-time sync, Row Level Security (RLS), system zaproszeń, offline capability
- **Stack:** Next.js 15, TypeScript, Tailwind CSS, Shadcn/ui, Supabase, Vercel

### 1.3 Wymagania Funkcjonalne

1. **Autentykacja użytkowników** (email + hasło)
2. **System zaproszeń** (kod 6-znakowy do udostępnienia rodzinie)
3. **Multi-tenancy** (wiele "domów", użytkownik należy do jednego domu)
4. **CRUD operacje** na liście zakupów (dodawanie, edycja, usuwanie, oznaczanie jako kupione)
5. **Real-time synchronizacja** między użytkownikami tego samego domu
6. **Push notifications** o zmianach (dodanie produktu, oznaczenie jako kupione)
7. **Kategoryzacja produktów**
8. **Offline capability** (kolejkowanie requestów gdy brak sieci)

### 1.4 Wymagania Niefunkcjonalne

- **Performance:**
  - Real-time update < 2 sekundy
  - Dodanie produktu < 5 sekund
- **Scalability:**
  - Start: ~100 rodzin
  - Docelowo: 1000+ rodzin
- **Security:**
  - Izolacja danych między domami (Row Level Security)
  - Bezpieczna autentykacja z JWT
- **Availability:**
  - Web (desktop/mobile browser)
  - Instalowalna PWA
- **Future-proofing:**
  - Łatwa migracja do React Native w Phase 2

### 1.5 Ograniczenia Techniczne

- **Stack:** Next.js 15, TypeScript, Supabase (wymagane)
- **Hosting:** Vercel (frontend), Supabase Cloud (backend)
- **Budget:**
  - Start: Free tier (Supabase Free + Vercel Hobby = 0 zł/miesiąc)
  - Wzrost: Supabase Pro (~100 zł) + Vercel Pro (~80 zł) = ~180 zł/miesiąc
- **Timeline:** 6-8 tygodni do Phase 1
- **Skill level:** Intermediate
- **Język dokumentacji:** Polski

---

## 2. Badanie Technologii

### 2.1 Supabase Realtime - Best Practices 2025

**Źródła:** [Verified 2025]
- https://supabase.com/docs/guides/realtime
- https://github.com/orgs/supabase/discussions/21995
- https://www.supadex.app/blog/building-real-time-apps-with-supabase-a-step-by-step-guide

#### Przegląd

Supabase Realtime to warstwa WebSocket nad PostgreSQL zapewniająca real-time synchronizację danych. Wykorzystuje Postgres replication slot i Elixir Phoenix dla skalowania WebSocket connections.

#### Kluczowe Cechy (2025)

- **Postgres Changes:** Subscription na INSERT/UPDATE/DELETE w tabelach
- **Broadcast:** Custom events między klientami
- **Presence:** Tracking online users w real-time
- **Performance:** Obsługuje tysiące concurrent connections na standardowym tier

#### Best Practices - Performance Optimization

✅ **Enable real-time tylko na niezbędnych tabelach**
```sql
-- Włącz replication tylko dla shopping_list_items
ALTER TABLE shopping_list_items REPLICA IDENTITY FULL;
```

✅ **Selective event triggers** - redukuj niepotrzebne broadcasts
```typescript
// Subskrybuj tylko INSERT i UPDATE, pomiń DELETE jeśli nie potrzebujesz
const subscription = supabase
  .channel('shopping-changes')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'shopping_list_items' },
    handleInsert
  )
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'shopping_list_items' },
    handleUpdate
  )
  .subscribe();
```

✅ **Batch lub debounce client updates** - redukuj re-rendering UI
```typescript
// Debounce rapid updates
const debouncedUpdate = useMemo(
  () => debounce((payload) => {
    updateLocalState(payload);
  }, 300),
  []
);
```

#### Best Practices - Connection Management

✅ **Cleanup subscriptions** - zapobiegaj connection leaks
```typescript
useEffect(() => {
  const channel = supabase.channel('shopping-changes');
  // ... setup subscriptions

  return () => {
    channel.unsubscribe(); // Cleanup!
  };
}, []);
```

✅ **Jedna connection per browser tab** - wszystkie channels dzielą connection

#### Best Practices - Data Consistency

⚠️ **KRYTYCZNE:** Najpierw query current state, potem subscribe
```typescript
// 1. Load current data
const { data } = await supabase
  .from('shopping_list_items')
  .select('*')
  .eq('home_id', homeId);

// 2. Then subscribe to changes
const subscription = supabase
  .channel('shopping-changes')
  .on('postgres_changes', ...)
  .subscribe();
```

To zapobiega race condition gdzie zmiana następuje między load a subscription.

#### Scaling Considerations [High Confidence]

**Bottleneck:** Każdy change event musi być sprawdzony przez RLS policies
- 100 użytkowników subskrybujących tabelę = 100 "reads" per INSERT
- Database performance jest kluczowy dla authorization checks
- **Mitigation:** Proper indexing na kolumnach używanych w RLS policies

**Benchmarks** (źródło: https://supabase.com/docs/guides/realtime/benchmarks):
- 2,000 concurrent users z 50KB payload: stabilne performance
- Median latency: < 100ms dla standardowych operacji

#### Rekomendacje dla MyHome

✅ **Enable Realtime tylko na:** `shopping_list_items`
✅ **Subscribe selectively:** tylko INSERT i UPDATE (nie DELETE)
✅ **Filter by home_id** na poziomie subscription:
```typescript
.on('postgres_changes', {
  event: '*',
  schema: 'public',
  table: 'shopping_list_items',
  filter: `home_id=eq.${currentHomeId}` // Server-side filtering!
})
```

---

### 2.2 Supabase Row Level Security - Multi-Tenant Patterns 2025

**Źródła:** [Verified 2025]
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://www.antstack.com/blog/multi-tenant-applications-with-rls-on-supabase-postgress/
- https://dev.to/blackie360/-enforcing-row-level-security-in-supabase-a-deep-dive-into-lockins-multi-tenant-architecture-4hd2

#### Przegląd

Row Level Security (RLS) w PostgreSQL enforcement security policies bezpośrednio w bazie danych, zapewniając że użytkownicy widzą tylko swoje dane. To **defense-in-depth** - nawet jeśli aplikacja ma bug, baza danych blokuje unauthorized access.

#### Multi-Tenant Pattern dla MyHome

**Architektura:**
```
User (auth.users)
  → home_members (relacja user_id ↔ home_id)
    → homes (gospodarstwa)
      → shopping_list_items (produkty z home_id)
```

#### RLS Policies - Best Practices

✅ **Enable RLS na wszystkich tabelach z user data:**
```sql
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;
```

✅ **Policy dla shopping_list_items:**
```sql
-- SELECT: Użytkownik może widzieć produkty ze swojego domu
CREATE POLICY "Users can view items from their home"
ON shopping_list_items
FOR SELECT
USING (
  home_id IN (
    SELECT home_id
    FROM home_members
    WHERE user_id = auth.uid()
  )
);

-- INSERT: Użytkownik może dodawać produkty do swojego domu
CREATE POLICY "Users can insert items to their home"
ON shopping_list_items
FOR INSERT
WITH CHECK (
  home_id IN (
    SELECT home_id
    FROM home_members
    WHERE user_id = auth.uid()
  )
);

-- UPDATE: Użytkownik może edytować produkty ze swojego domu
CREATE POLICY "Users can update items in their home"
ON shopping_list_items
FOR UPDATE
USING (
  home_id IN (
    SELECT home_id
    FROM home_members
    WHERE user_id = auth.uid()
  )
);

-- DELETE: Użytkownik może usuwać produkty ze swojego domu
CREATE POLICY "Users can delete items from their home"
ON shopping_list_items
FOR DELETE
USING (
  home_id IN (
    SELECT home_id
    FROM home_members
    WHERE user_id = auth.uid()
  )
);
```

#### Performance Optimization [High Confidence]

⚠️ **KRYTYCZNY:** Index kolumny używane w RLS policies

```sql
-- Index for fast RLS lookups
CREATE INDEX idx_home_members_user_id ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
```

✅ **Wrap funkcje w SELECT** - umożliwia caching przez Postgres:
```sql
-- ZAMIAST: auth.uid() = user_id
-- UŻYJ: user_id = (SELECT auth.uid())
-- To pozwala Postgres cache wyniku auth.uid()
```

✅ **Materialized views** dla złożonych queries (jeśli potrzebne w przyszłości)

#### Challenges i Mitigations

**Challenge:** RLS może wprowadzić performance overhead przy dużych datasets
**Mitigation:** Proper indexing + query optimization + monitoring slow queries

**Challenge:** Debugowanie RLS policies może być trudne
**Mitigation:** Test policies w Supabase SQL Editor:
```sql
-- Test as specific user
SET request.jwt.claim.sub = 'user-uuid-here';
SELECT * FROM shopping_list_items; -- Should only return user's home items
```

#### Rekomendacje dla MyHome

✅ **Enable RLS** na wszystkich tabelach od startu
✅ **Index all RLS filter columns** (user_id, home_id)
✅ **Test policies** w SQL Editor przed deployment
✅ **Monitor performance** przez Supabase Dashboard (slow queries)

---

### 2.3 Next.js 15 + Supabase Integration - Patterns 2025

**Źródła:** [Verified 2025]
- https://supabase.com/docs/guides/realtime/realtime-with-nextjs
- https://medium.com/@livenapps/next-js-15-app-router-a-complete-senior-level-guide-0554a2b820f7
- https://medium.com/@sureshdotariya/next-js-15-in-practice-10-patterns-that-actually-ship-64dc27c041b3

#### Przegląd Next.js 15 (2025)

Next.js 15 wprowadza **App Router** jako default z:
- **React Server Components (RSC)** by default
- **Server Actions** dla mutations (bez API routes)
- **Streaming** by default dla lepszego UX
- **Improved caching semantics**

#### Pattern: Server Components + Client Components dla Real-time

✅ **Recommended Architecture:**

```
app/
├── layout.tsx                 # Server Component (root)
├── page.tsx                   # Server Component (initial load)
├── components/
│   ├── ShoppingList.tsx      # Server Component (fetch initial data)
│   └── ShoppingListRealtime.tsx  # Client Component (realtime subscription)
```

**ShoppingList.tsx (Server Component):**
```typescript
// Server Component - fetches initial data
import { createServerClient } from '@/lib/supabase/server';
import ShoppingListRealtime from './ShoppingListRealtime';

export default async function ShoppingList({ homeId }: { homeId: string }) {
  const supabase = createServerClient();

  // Server-side data fetch (fast, SEO-friendly)
  const { data: items } = await supabase
    .from('shopping_list_items')
    .select('*')
    .eq('home_id', homeId)
    .order('created_at', { ascending: false });

  // Pass initial data to client component
  return <ShoppingListRealtime initialItems={items || []} homeId={homeId} />;
}
```

**ShoppingListRealtime.tsx (Client Component):**
```typescript
'use client'; // Client Component for interactivity

import { useEffect, useState } from 'react';
import { createBrowserClient } from '@/lib/supabase/client';

export default function ShoppingListRealtime({
  initialItems,
  homeId
}: {
  initialItems: ShoppingItem[];
  homeId: string;
}) {
  const [items, setItems] = useState(initialItems);
  const supabase = createBrowserClient();

  useEffect(() => {
    // Subscribe to realtime changes
    const channel = supabase
      .channel('shopping-changes')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'shopping_list_items',
        filter: `home_id=eq.${homeId}`
      }, (payload) => {
        if (payload.eventType === 'INSERT') {
          setItems(prev => [payload.new, ...prev]);
        } else if (payload.eventType === 'UPDATE') {
          setItems(prev => prev.map(item =>
            item.id === payload.new.id ? payload.new : item
          ));
        } else if (payload.eventType === 'DELETE') {
          setItems(prev => prev.filter(item => item.id !== payload.old.id));
        }
      })
      .subscribe();

    return () => {
      channel.unsubscribe();
    };
  }, [homeId, supabase]);

  return (
    <div>
      {items.map(item => (
        <ShoppingItem key={item.id} item={item} />
      ))}
    </div>
  );
}
```

#### Pattern: Server Actions dla Mutations

✅ **Server Actions eliminują potrzebę API routes:**

**actions/shopping.ts:**
```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';

export async function addShoppingItem(formData: FormData) {
  const supabase = createServerClient();

  const name = formData.get('name') as string;
  const quantity = formData.get('quantity') as string;
  const category = formData.get('category') as string;

  // Get current user's home
  const { data: { user } } = await supabase.auth.getUser();
  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user?.id)
    .single();

  // Insert with RLS enforcement
  const { data, error } = await supabase
    .from('shopping_list_items')
    .insert({
      name,
      quantity,
      category,
      home_id: member?.home_id,
      created_by: user?.id,
      is_purchased: false
    })
    .select()
    .single();

  if (error) throw error;

  revalidatePath('/shopping'); // Revalidate cache
  return data;
}
```

**Component usage:**
```typescript
'use client';

import { addShoppingItem } from '@/actions/shopping';

export default function AddItemForm() {
  return (
    <form action={addShoppingItem}>
      <input name="name" required />
      <input name="quantity" />
      <select name="category">
        <option value="nabiał">Nabiał</option>
        <option value="warzywa">Warzywa</option>
      </select>
      <button type="submit">Dodaj</button>
    </form>
  );
}
```

#### Supabase Client Setup (Next.js 15)

**lib/supabase/client.ts (Browser):**
```typescript
import { createBrowserClient } from '@supabase/ssr';

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

**lib/supabase/server.ts (Server):**
```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { cookies } from 'next/headers';

export function createClient() {
  const cookieStore = cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options });
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.delete({ name, ...options });
        },
      },
    }
  );
}
```

#### Rekomendacje dla MyHome

✅ **Server Components** dla initial data loading (SEO, performance)
✅ **Client Components** tylko dla interactivity (realtime, forms)
✅ **Server Actions** dla mutations (add, update, delete items)
✅ **@supabase/ssr** package dla session management przez cookies

---

### 2.4 PWA → React Native Migration Strategy 2025

**Źródła:** [Verified 2025]
- https://touchlane.com/how-to-migrate-to-react-native-from-pwa-2025-ultimate-guide/
- https://pagepro.co/blog/migration-to-react-native-from-pwa/
- https://medium.com/@ziaulrehman/part-1-converting-react-native-app-to-react-native-web-react-pwa-in-monorepo-architecture-34b43cad74b8

#### Strategic Recommendation: Start PWA, Migrate Later

**Rationale:**
- ✅ **Faster time-to-market:** PWA gotowe w 6-8 tygodni (Phase 1)
- ✅ **Lower risk:** Validate product-market fit przed investment w React Native
- ✅ **Single codebase initially:** Jeden kod dla web + mobile
- ✅ **Installation:** PWA instalowalna na Android/iOS przez browser

**When to migrate:** Gdy funkcjonalność się rozrośnie i potrzebujesz:
- Native device features (camera, contacts, advanced notifications)
- Better performance dla złożonych UI
- App Store presence

#### Migration Strategy - Code Sharing

**What to reuse:**
✅ **Backend logic:** API integration, data processing, business rules
✅ **Type definitions:** TypeScript interfaces/types
✅ **State management:** Zustand/Redux logic (platform-agnostic)
✅ **Utilities:** Date formatting, validation, helpers

**What to rebuild:**
❌ **UI Components:** Next.js components → React Native components
❌ **Navigation:** Next.js routing → React Navigation
❌ **Styling:** Tailwind CSS → React Native StyleSheet
❌ **Platform-specific features:** Web APIs → Native modules

#### Architecture Pattern: Monorepo (Optional Phase 2)

```
my-home/
├── packages/
│   ├── shared/              # Shared code
│   │   ├── types/           # TypeScript definitions
│   │   ├── utils/           # Helper functions
│   │   ├── hooks/           # Platform-agnostic hooks
│   │   └── api/             # Supabase client logic
│   ├── web/                 # Next.js PWA
│   └── mobile/              # React Native (Expo)
└── package.json
```

**Tools:** Turborepo lub Nx dla monorepo management

#### Migration Milestones

**Phase 1 (Weeks 1-8): PWA Foundation**
- Build Next.js app z PWA manifest
- Implement core features
- Deploy i validate z użytkownikami

**Phase 2 (When needed): React Native Prep**
- Extract shared logic do `packages/shared`
- Decouple UI from business logic
- Document platform-specific dependencies

**Phase 3: React Native Build**
- Setup Expo project
- Rebuild UI z React Native components
- Implement native notifications (Expo Notifications)
- Test na real devices
- Deploy do Google Play / App Store

#### Key Differences: PWA vs React Native

| Feature | PWA | React Native |
|---------|-----|--------------|
| **Performance** | Good (web) | Excellent (native) |
| **UI/UX** | Web-like | Native feel |
| **Installation** | Add to Home Screen | App Store install |
| **Notifications** | Web Push API (limited) | Full native notifications |
| **Device Access** | Limited (Web APIs) | Full (camera, contacts, etc.) |
| **Offline** | Service Workers | Full native storage |
| **Updates** | Instant (web) | App Store approval |

#### Rekomendacje dla MyHome

✅ **Phase 1:** Start z PWA (Next.js + Tailwind + Shadcn/ui)
✅ **Architecture:** Separate business logic od UI od startu (łatwiejsza migracja)
✅ **Phase 2 trigger:** Gdy potrzebujesz native features lub lepszego UX
✅ **Migration path:** Monorepo z shared package dla API/utils/types

---

### 2.5 Push Notifications - Web Push API + Expo 2025

**Źródła:** [Verified 2025]
- https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Tutorials/js13kGames/Re-engageable_Notifications_Push
- https://www.magicbell.com/blog/using-push-notifications-in-pwas
- https://docs.expo.dev/versions/latest/sdk/notifications/

#### Phase 1: Web Push API (PWA)

**Prerequisites:**
- ✅ HTTPS (required - Vercel provides this)
- ✅ Service Worker
- ✅ Web Push protocol support (Chrome, Firefox, Edge)

**Best Practices (2025):**

✅ **Opt-in pattern** - request permission po user action
```typescript
// ❌ BAD: Request immediately on load
useEffect(() => {
  Notification.requestPermission(); // Intrusive!
}, []);

// ✅ GOOD: Request after user clicks button
const handleSubscribe = async () => {
  const permission = await Notification.requestPermission();
  if (permission === 'granted') {
    // Setup push subscription
  }
};

<button onClick={handleSubscribe}>
  🔔 Włącz powiadomienia
</button>
```

✅ **Frequency limits:** Max 3-5 notifications per week
```typescript
// Track notification count
const canSendNotification = (lastSent: Date) => {
  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);

  const notificationsThisWeek = getNotificationCount(weekAgo);
  return notificationsThisWeek < 5; // Limit to 5/week
};
```

✅ **Personalization i timing:**
```typescript
// Send notifications at strategic times
const notification = {
  title: `${userName} dodał: ${itemName}`,
  body: `Zobacz zaktualizowaną listę zakupów`,
  timestamp: Date.now(),
  tag: `shopping-update-${itemId}`, // Prevent duplicates
  requireInteraction: false, // Auto-dismiss after few seconds
};
```

**Implementation (Firebase Cloud Messaging):**

```typescript
// Request permission and get token
import { getMessaging, getToken } from 'firebase/messaging';

const messaging = getMessaging();
const token = await getToken(messaging, {
  vapidKey: process.env.NEXT_PUBLIC_VAPID_KEY
});

// Save token to Supabase
await supabase
  .from('push_subscriptions')
  .insert({
    user_id: currentUser.id,
    token: token,
    platform: 'web'
  });
```

**Send notification (Server Action):**
```typescript
'use server';

import admin from 'firebase-admin';

export async function sendNotification(homeId: string, message: string) {
  // Get all tokens for home members
  const { data: subscriptions } = await supabase
    .from('push_subscriptions')
    .select('token')
    .in('user_id', (
      await supabase
        .from('home_members')
        .select('user_id')
        .eq('home_id', homeId)
    ).data.map(m => m.user_id));

  // Send via FCM
  await admin.messaging().sendMulticast({
    tokens: subscriptions.map(s => s.token),
    notification: {
      title: 'MyHome',
      body: message
    },
    webpush: {
      notification: {
        icon: '/icon-192.png',
        badge: '/badge-72.png'
      }
    }
  });
}
```

#### Phase 2: Expo Notifications (React Native)

**Setup:**
```bash
npx expo install expo-notifications expo-device expo-constants
```

**Request permissions (iOS/Android):**
```typescript
import * as Notifications from 'expo-notifications';

const { status } = await Notifications.requestPermissionsAsync();
if (status !== 'granted') {
  alert('Potrzebujemy uprawnień do powiadomień!');
  return;
}

// Get Expo push token
const token = (await Notifications.getExpoPushTokenAsync()).data;

// Save to Supabase
await supabase
  .from('push_subscriptions')
  .insert({
    user_id: currentUser.id,
    token: token,
    platform: 'mobile'
  });
```

**Configure notification handler:**
```typescript
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});
```

**Listen for notifications:**
```typescript
useEffect(() => {
  // Foreground notification listener
  const subscription = Notifications.addNotificationReceivedListener(notification => {
    console.log('Notification received:', notification);
  });

  // User tapped notification
  const responseSubscription = Notifications.addNotificationResponseReceivedListener(response => {
    // Navigate to shopping list
    router.push('/shopping');
  });

  return () => {
    subscription.remove();
    responseSubscription.remove();
  };
}, []);
```

**Send via Expo Push Service:**
```typescript
'use server';

export async function sendExpoNotification(homeId: string, message: string) {
  const { data: subscriptions } = await supabase
    .from('push_subscriptions')
    .select('token')
    .eq('platform', 'mobile')
    .in('user_id', ...); // Get home members

  const messages = subscriptions.map(sub => ({
    to: sub.token,
    sound: 'default',
    title: 'MyHome',
    body: message,
    data: { homeId }
  }));

  await fetch('https://exp.host/--/api/v2/push/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(messages),
  });
}
```

#### Unified Notification System (Phase 2)

**Database schema:**
```sql
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('web', 'mobile')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own subscriptions"
ON push_subscriptions
FOR ALL
USING (user_id = auth.uid());
```

**Universal send function:**
```typescript
export async function sendNotificationToHome(
  homeId: string,
  title: string,
  body: string
) {
  const { data: subscriptions } = await supabase
    .from('push_subscriptions')
    .select('token, platform')
    .in('user_id', /* home members */);

  // Split by platform
  const webTokens = subscriptions.filter(s => s.platform === 'web');
  const mobileTokens = subscriptions.filter(s => s.platform === 'mobile');

  // Send to web (FCM)
  if (webTokens.length > 0) {
    await sendWebPush(webTokens, title, body);
  }

  // Send to mobile (Expo)
  if (mobileTokens.length > 0) {
    await sendExpoPush(mobileTokens, title, body);
  }
}
```

#### Rekomendacje dla MyHome

✅ **Phase 1 (PWA):** Web Push API z Firebase Cloud Messaging
✅ **Opt-in pattern:** Request permission po user click, nie automatycznie
✅ **Frequency:** Max 5 notifications/week, personalizowane messages
✅ **Phase 2 (React Native):** Expo Notifications z unified send function
✅ **Database:** Centralna tabela `push_subscriptions` dla obu platform

---

### 2.6 Offline-First Patterns z Supabase 2025

**Źródła:** [Verified 2025]
- https://www.powersync.com/blog/bringing-offline-first-to-supabase
- https://github.com/marceljuenemann/rxdb-supabase
- https://docs.powersync.com/integration-guides/supabase-+-powersync

#### Opcje Offline-First dla MyHome

#### Opcja 1: Custom Request Queue (Phase 1 - Recommended)

**Concept:** Queue mutations locally, sync when online

**Implementation:**
```typescript
// lib/offline-queue.ts
interface QueuedOperation {
  id: string;
  type: 'insert' | 'update' | 'delete';
  table: string;
  data: any;
  timestamp: number;
}

class OfflineQueue {
  private queue: QueuedOperation[] = [];

  async enqueue(operation: Omit<QueuedOperation, 'id' | 'timestamp'>) {
    const op: QueuedOperation = {
      ...operation,
      id: crypto.randomUUID(),
      timestamp: Date.now()
    };

    // Save to localStorage
    this.queue.push(op);
    localStorage.setItem('offline-queue', JSON.stringify(this.queue));

    // Try to sync immediately
    await this.sync();
  }

  async sync() {
    if (!navigator.onLine) return;

    const operations = [...this.queue];

    for (const op of operations) {
      try {
        if (op.type === 'insert') {
          await supabase.from(op.table).insert(op.data);
        } else if (op.type === 'update') {
          await supabase.from(op.table).update(op.data).eq('id', op.data.id);
        } else if (op.type === 'delete') {
          await supabase.from(op.table).delete().eq('id', op.data.id);
        }

        // Remove from queue on success
        this.queue = this.queue.filter(o => o.id !== op.id);
      } catch (error) {
        console.error('Sync failed:', error);
        break; // Stop on first error
      }
    }

    localStorage.setItem('offline-queue', JSON.stringify(this.queue));
  }
}

export const offlineQueue = new OfflineQueue();

// Listen for online event
window.addEventListener('online', () => {
  offlineQueue.sync();
});
```

**Usage:**
```typescript
async function addItem(name: string) {
  // Optimistic update
  const tempItem = {
    id: crypto.randomUUID(),
    name,
    is_purchased: false,
    created_at: new Date().toISOString()
  };

  setItems(prev => [tempItem, ...prev]);

  // Queue for sync
  await offlineQueue.enqueue({
    type: 'insert',
    table: 'shopping_list_items',
    data: tempItem
  });
}
```

**Pros:**
- ✅ Simple implementation
- ✅ Full control
- ✅ No external dependencies
- ✅ Works dla basic offline needs

**Cons:**
- ❌ No conflict resolution (last-write-wins)
- ❌ Manual implementation effort
- ❌ Limited dla complex scenarios

#### Opcja 2: PowerSync (Phase 2 - If Needed)

**Concept:** Postgres ↔ SQLite sync layer

**How it works:**
1. PowerSync reads Postgres WAL (Write Ahead Log)
2. Streams changes to local SQLite database
3. Client reads/writes to local SQLite
4. Mutations queued i synced back via Supabase client

**Setup:**
```typescript
import { PowerSyncDatabase } from '@journeyapps/powersync-sdk-react-native';

const db = new PowerSyncDatabase({
  schema: appSchema, // Define your schema
  database: {
    dbFilename: 'myhome.db'
  }
});

// Connect to PowerSync service
await db.connect({
  powerSyncUrl: process.env.POWERSYNC_URL,
  token: supabaseSession.access_token
});

// Query local SQLite (instant, works offline)
const items = await db.getAll('SELECT * FROM shopping_list_items WHERE home_id = ?', [homeId]);

// Insert (queued for upload)
await db.execute(
  'INSERT INTO shopping_list_items (name, home_id) VALUES (?, ?)',
  [name, homeId]
);
```

**Pros:**
- ✅ Full offline capability
- ✅ Automatic conflict resolution
- ✅ Instant reads from local SQLite
- ✅ Battle-tested solution

**Cons:**
- ❌ Additional service dependency (PowerSync Cloud)
- ❌ Cost: $99/month dla production
- ❌ More complex setup
- ❌ Overkill dla simple use cases

#### Opcja 3: RxDB + Supabase (Alternative)

**Concept:** Offline-first database z replication

**Pros:**
- ✅ Open source
- ✅ Custom conflict resolution strategies
- ✅ Two-way sync

**Cons:**
- ❌ Complex setup
- ❌ Larger bundle size
- ❌ Learning curve

#### Rekomendacje dla MyHome

**Phase 1:** Custom Request Queue
- Prosty i wystarczający dla MVP
- Queue requests gdy offline, sync gdy online
- Optimistic updates dla lepszego UX

**Phase 2 (jeśli potrzebne):** PowerSync
- Tylko jeśli potrzebujesz true offline-first (extended offline usage)
- Gdy conflict resolution staje się critical
- Gdy masz budget ($99/month)

**Decision criteria:** Czy użytkownicy będą często pracować offline > 5 minut?
- **NIE:** Custom queue wystarczy
- **TAK:** Rozważ PowerSync

---

## 3. Analiza Porównawcza

### 3.1 Real-time Sync Solutions

| Feature | Supabase Realtime | Firebase Realtime DB | Pusher | Socket.io |
|---------|-------------------|---------------------|--------|-----------|
| **Architecture** | Postgres + WebSocket | NoSQL + WebSocket | Managed WebSocket | Custom WebSocket |
| **Pricing (100 rodzin)** | Free tier | Free tier | $49/mo | Self-hosted ($20-40/mo) |
| **Pricing (1000 rodzin)** | ~$100/mo (Pro) | ~$150/mo | $299/mo | $80-150/mo |
| **RLS Built-in** | ✅ Yes | ❌ Rules only | ❌ No | ❌ Manual |
| **Postgres Compatible** | ✅ Yes | ❌ NoSQL | ❌ N/A | ❌ N/A |
| **Latency** | < 100ms | < 50ms | < 50ms | Varies |
| **Scalability** | High | Very High | Very High | Manual |
| **Developer Experience** | Excellent | Good | Good | Complex |
| **Learning Curve** | Low | Medium | Low | High |
| **Best For** | Postgres + realtime | Mobile-first | Quick MVP | Full control |

**Winner dla MyHome:** ✅ **Supabase Realtime**
- Integrated z Postgres (już wybrane)
- Built-in RLS dla security
- Free tier dla start, affordable scale
- Excellent DX

### 3.2 Mobile Strategy Comparison

| Approach | PWA First → RN Later | React Native First | React Native Web (Monorepo) |
|----------|---------------------|-------------------|----------------------------|
| **Time to Market** | ✅ Fast (6-8 weeks) | Medium (10-12 weeks) | Slow (12-16 weeks) |
| **Initial Cost** | ✅ Low | Medium | High |
| **Code Sharing** | Limited initially | N/A | ✅ High |
| **Installation** | Add to Home Screen | App Store | Both |
| **Native Features** | Limited (Phase 1) | ✅ Full | ✅ Full |
| **Updates** | ✅ Instant | App Store approval | Mixed |
| **Performance** | Good (web) | ✅ Excellent | Excellent |
| **Risk** | ✅ Low (validate first) | Higher (upfront investment) | Medium |
| **Maintenance** | Single codebase (Phase 1) | Mobile only | ✅ Shared codebase |

**Winner dla MyHome:** ✅ **PWA First → RN Later**
- Lowest risk: validate product-market fit
- Fastest time to market
- Can migrate when needed (Phase 2)
- Budget-friendly dla start

### 3.3 Notification Solutions

| Solution | Web Push (PWA) | Expo Notifications | OneSignal | Firebase CM |
|----------|----------------|-------------------|-----------|-------------|
| **Platform** | Web only | Mobile only | Web + Mobile | Web + Mobile |
| **Setup Complexity** | Medium | ✅ Easy | ✅ Easy | Medium |
| **Pricing (1000 users)** | ✅ Free (FCM) | ✅ Free | Free tier | ✅ Free |
| **Features** | Basic | Rich (native) | Rich + Segmentation | Rich |
| **Delivery Rate** | 85-90% | ✅ 95%+ | 95%+ | 95%+ |
| **Opt-in Required** | ✅ Yes (best practice) | ✅ Yes | Yes | Yes |
| **Analytics** | Limited | Basic | ✅ Advanced | Good |
| **Personalization** | Manual | Manual | ✅ Built-in | Manual |

**Winner dla MyHome:**
- **Phase 1 (PWA):** Web Push + Firebase Cloud Messaging
- **Phase 2 (RN):** Expo Notifications
- **Alternative:** OneSignal dla unified solution (jeśli potrzebujesz advanced analytics)

### 3.4 Offline Strategy Comparison

| Approach | Custom Queue | PowerSync | RxDB + Supabase | IndexedDB Only |
|----------|--------------|-----------|-----------------|----------------|
| **Complexity** | ✅ Low | Medium | High | Low |
| **Cost** | ✅ Free | $99/mo | Free | Free |
| **Conflict Resolution** | Last-write-wins | ✅ Automatic | ✅ Customizable | Manual |
| **Offline Duration** | Short (< 5 min) | ✅ Extended | Extended | Short |
| **Setup Time** | ✅ 1-2 days | 3-5 days | 5-7 days | 1 day |
| **Reliability** | Good | ✅ Excellent | Good | Fair |
| **Best For** | Simple cases | ✅ Production offline | Custom needs | Read-only |

**Winner dla MyHome:**
- **Phase 1:** Custom Queue (simple, free, sufficient)
- **Phase 2:** PowerSync (if extended offline needed)

---

## 4. Rekomendacje i Wzorce Architektoniczne

### 4.1 Rekomendowana Architektura dla MyHome

#### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        USERS                                 │
│  (Desktop Browser, Mobile Browser, PWA, React Native App)   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   NEXT.JS 15 (Vercel)                        │
│  ┌────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Server         │  │ Client          │  │ Server       │ │
│  │ Components     │  │ Components      │  │ Actions      │ │
│  │ (Initial Load) │  │ (Interactivity) │  │ (Mutations)  │ │
│  └────────────────┘  └─────────────────┘  └──────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  SUPABASE (Cloud)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ PostgreSQL   │  │ Realtime     │  │ Auth         │      │
│  │ + RLS        │  │ (WebSocket)  │  │ (JWT)        │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ Edge         │  │ Storage      │                        │
│  │ Functions    │  │ (Images)     │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

#### Database Schema

```sql
-- Users (Supabase Auth)
-- auth.users - managed by Supabase

-- Homes (Gospodarstwa domowe)
CREATE TABLE homes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL DEFAULT generate_invite_code(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users NOT NULL
);

-- Home Members (Relacja user ↔ home)
CREATE TABLE home_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  home_id UUID REFERENCES homes NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, home_id)
);

-- Shopping List Items
CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  home_id UUID REFERENCES homes NOT NULL,
  name TEXT NOT NULL,
  quantity TEXT,
  category TEXT,
  is_purchased BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Push Subscriptions
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('web', 'mobile')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_home_members_user_id ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
CREATE INDEX idx_shopping_items_is_purchased ON shopping_list_items(is_purchased);
CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);

-- Function to generate invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Bez 0,O,1,I
  result TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER shopping_items_updated_at
BEFORE UPDATE ON shopping_list_items
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();
```

#### Row Level Security Policies

```sql
-- Enable RLS on all tables
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- Homes policies
CREATE POLICY "Users can view their own home"
ON homes FOR SELECT
USING (
  id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
);

CREATE POLICY "Users can create homes"
ON homes FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Home creator can update home"
ON homes FOR UPDATE
USING (created_by = auth.uid());

-- Home Members policies
CREATE POLICY "Users can view members of their home"
ON home_members FOR SELECT
USING (
  home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
);

CREATE POLICY "Users can join a home"
ON home_members FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can leave their home"
ON home_members FOR DELETE
USING (user_id = auth.uid());

-- Shopping List Items policies (same as shown earlier)
CREATE POLICY "Users can view items from their home"
ON shopping_list_items FOR SELECT
USING (
  home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
);

CREATE POLICY "Users can insert items to their home"
ON shopping_list_items FOR INSERT
WITH CHECK (
  home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  AND created_by = auth.uid()
);

CREATE POLICY "Users can update items in their home"
ON shopping_list_items FOR UPDATE
USING (
  home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
);

CREATE POLICY "Users can delete items from their home"
ON shopping_list_items FOR DELETE
USING (
  home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
);

-- Push Subscriptions policies
CREATE POLICY "Users manage their own subscriptions"
ON push_subscriptions FOR ALL
USING (user_id = auth.uid());
```

#### Realtime Setup

```sql
-- Enable realtime only on shopping_list_items
ALTER PUBLICATION supabase_realtime ADD TABLE shopping_list_items;

-- Set replica identity (required for realtime)
ALTER TABLE shopping_list_items REPLICA IDENTITY FULL;
```

### 4.2 Architecture Patterns

#### Pattern 1: Optimistic UI Updates

**Problem:** Real-time updates mogą mieć latency
**Solution:** Optimistic updates + rollback on error

```typescript
async function togglePurchased(itemId: string, currentValue: boolean) {
  const newValue = !currentValue;

  // 1. Optimistic update (instant UI feedback)
  setItems(prev => prev.map(item =>
    item.id === itemId ? { ...item, is_purchased: newValue } : item
  ));

  try {
    // 2. Persist to database
    const { error } = await supabase
      .from('shopping_list_items')
      .update({ is_purchased: newValue })
      .eq('id', itemId);

    if (error) throw error;

    // 3. Send notification (async)
    await sendNotificationToHome(
      currentHomeId,
      'Zakupy',
      `${userName} ${newValue ? 'kupił' : 'cofnął'}: ${itemName}`
    );
  } catch (error) {
    // 4. Rollback on error
    setItems(prev => prev.map(item =>
      item.id === itemId ? { ...item, is_purchased: currentValue } : item
    ));
    toast.error('Nie udało się zaktualizować. Spróbuj ponownie.');
  }
}
```

#### Pattern 2: Realtime Subscription with Filtering

**Problem:** Receiving updates dla wszystkich homes (security + performance)
**Solution:** Server-side filtering w subscription

```typescript
useEffect(() => {
  if (!currentHomeId) return;

  const channel = supabase
    .channel(`shopping-${currentHomeId}`)
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'shopping_list_items',
      filter: `home_id=eq.${currentHomeId}` // Server-side filter!
    }, (payload) => {
      handleRealtimeUpdate(payload);
    })
    .subscribe();

  return () => {
    channel.unsubscribe();
  };
}, [currentHomeId]);
```

#### Pattern 3: Server Actions dla Mutations

**Problem:** Traditional API routes są verbose
**Solution:** Server Actions dla clean mutations

```typescript
// actions/shopping.ts
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { sendNotificationToHome } from './notifications';

export async function addShoppingItem(
  homeId: string,
  name: string,
  quantity?: string,
  category?: string
) {
  const supabase = createServerClient();

  // Get current user
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  // Verify user belongs to home (RLS will also check, but explicit is better)
  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .eq('home_id', homeId)
    .single();

  if (!member) throw new Error('Not a member of this home');

  // Insert item (RLS enforced)
  const { data: item, error } = await supabase
    .from('shopping_list_items')
    .insert({
      home_id: homeId,
      name,
      quantity,
      category,
      created_by: user.id,
      is_purchased: false
    })
    .select()
    .single();

  if (error) throw error;

  // Send notification to home members
  await sendNotificationToHome(
    homeId,
    'Nowy produkt',
    `${user.user_metadata.name || 'Ktoś'} dodał: ${name}`
  );

  revalidatePath('/shopping');
  return item;
}
```

#### Pattern 4: Invite Code System

**Problem:** Jak bezpiecznie zaprosić użytkowników do domu?
**Solution:** Unique 6-char code z validation

```typescript
// actions/home.ts
'use server';

export async function joinHomeByCode(inviteCode: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  // Find home by invite code
  const { data: home, error: homeError } = await supabase
    .from('homes')
    .select('id, name')
    .eq('invite_code', inviteCode.toUpperCase())
    .single();

  if (homeError || !home) {
    throw new Error('Nieprawidłowy kod zaproszenia');
  }

  // Check if user already member
  const { data: existing } = await supabase
    .from('home_members')
    .select('id')
    .eq('user_id', user.id)
    .single();

  if (existing) {
    throw new Error('Należysz już do domu. Opuść obecny dom, aby dołączyć do nowego.');
  }

  // Join home
  const { error: joinError } = await supabase
    .from('home_members')
    .insert({
      user_id: user.id,
      home_id: home.id
    });

  if (joinError) throw joinError;

  revalidatePath('/');
  return { homeId: home.id, homeName: home.name };
}

export async function regenerateInviteCode(homeId: string) {
  const supabase = createServerClient();

  const { data, error } = await supabase
    .from('homes')
    .update({ invite_code: await generateNewCode() })
    .eq('id', homeId)
    .select('invite_code')
    .single();

  if (error) throw error;

  revalidatePath('/settings');
  return data.invite_code;
}

async function generateNewCode(): Promise<string> {
  const { data } = await supabase.rpc('generate_invite_code');
  return data;
}
```

### 4.3 Implementation Roadmap

#### Phase 1: MVP (Weeks 1-8)

**Week 1-2: Foundation**
- ✅ Setup Next.js 15 project z App Router
- ✅ Configure Supabase (database, auth)
- ✅ Implement database schema + RLS policies
- ✅ Setup authentication (email/password)
- ✅ Create home on first login

**Week 3-4: Core Features**
- ✅ Shopping list CRUD (Server Actions)
- ✅ Real-time sync (Supabase Realtime)
- ✅ Invite system (code generation + joining)
- ✅ Categories dla produktów
- ✅ Basic UI z Shadcn/ui

**Week 5-6: Enhancement**
- ✅ Web Push notifications setup
- ✅ Offline queue implementation
- ✅ PWA manifest + service worker
- ✅ Settings page (members, invite code)
- ✅ Error handling + loading states

**Week 7-8: Polish & Deploy**
- ✅ UI/UX improvements
- ✅ Performance optimization
- ✅ Testing (podstawowe ścieżki)
- ✅ Deploy to Vercel
- ✅ Production monitoring setup

#### Phase 2: Mobile Native (When Needed)

**Week 9-10: Preparation**
- ✅ Extract shared logic to `/packages/shared`
- ✅ Document platform-specific code
- ✅ Setup Expo project + monorepo (optional)

**Week 11-14: React Native Build**
- ✅ Rebuild UI z React Native components
- ✅ Implement React Navigation
- ✅ Expo Notifications setup
- ✅ Native offline support (PowerSync if needed)
- ✅ Test na real devices

**Week 15-16: Deploy**
- ✅ Build dla Android (Google Play)
- ✅ Build dla iOS (App Store) - optional
- ✅ Production testing
- ✅ Gradual rollout

### 4.4 Risk Mitigation

#### Risk 1: Supabase Real-time Performance Bottleneck

**Risk:** 100+ users subscribed → database authorization overhead
**Mitigation:**
- ✅ Proper indexing (done in schema)
- ✅ Monitor slow queries via Supabase Dashboard
- ✅ Filter subscriptions server-side (`filter: home_id=eq.X`)
- ✅ Upgrade to Pro tier when > 500 families

#### Risk 2: Offline Sync Conflicts

**Risk:** Dwa użytkowników edytują ten sam produkt offline
**Mitigation:**
- ✅ Last-write-wins w Phase 1 (acceptable dla shopping list)
- ✅ Display "Zaktualizowano przez X" message
- ✅ PowerSync w Phase 2 dla advanced conflict resolution (jeśli potrzebne)

#### Risk 3: Notification Permission Denial

**Risk:** Użytkownicy odrzucają permission → missed updates
**Mitigation:**
- ✅ Opt-in pattern: pokazuj value proposition przed request
- ✅ In-app notifications jako fallback
- ✅ Badge counts na PWA icon
- ✅ Real-time updates działają bez notifications

#### Risk 4: PWA → React Native Migration Effort

**Risk:** Migration może być costly i time-consuming
**Mitigation:**
- ✅ Separate business logic od UI od startu
- ✅ Use TypeScript types dla API contracts
- ✅ Document platform-specific code clearly
- ✅ Start migration incrementally (monorepo approach)

---

## 5. Architecture Decision Record (ADR)

### ADR-001: Supabase jako Backend Platform

**Status:** ✅ Accepted

**Context:**
Potrzebujemy backend platform zapewniającego:
- PostgreSQL database
- Real-time synchronization
- Authentication
- Row Level Security
- Łatwy scaling

**Decision Drivers:**
- Time to market
- Cost efficiency
- Developer experience
- Scalability
- Security (RLS built-in)

**Considered Options:**
1. Supabase (Postgres + Realtime + Auth)
2. Firebase (Firestore + Realtime + Auth)
3. Custom backend (Node.js + PostgreSQL + Socket.io)
4. Appwrite

**Decision:** Supabase

**Rationale:**
- ✅ PostgreSQL (relational) lepsze dla structured data (homes, members, items)
- ✅ Built-in RLS dla multi-tenant isolation
- ✅ Realtime via WebSocket integrated
- ✅ Free tier dla start, $25/mo Pro dla scale
- ✅ Excellent developer experience
- ✅ @supabase/ssr package dla Next.js 15

**Consequences:**

**Positive:**
- Fast development (built-in auth, realtime, storage)
- Strong security via RLS
- Cost-effective scaling
- Great community + documentation

**Negative:**
- Vendor lock-in (mitigation: Postgres compatible, can migrate)
- Limited customization vs custom backend
- Dependent on Supabase uptime (mitigation: 99.9% SLA on Pro)

**References:**
- https://supabase.com/docs
- https://supabase.com/pricing

---

### ADR-002: PWA First, React Native Later

**Status:** ✅ Accepted

**Context:**
Potrzebujemy mobile access ale mamy ograniczony timeline (6-8 weeks) i budget.

**Decision Drivers:**
- Time to market (critical)
- Risk mitigation (validate product-market fit)
- Budget constraints
- Future flexibility

**Considered Options:**
1. PWA first → React Native later
2. React Native first (Expo)
3. React Native Web monorepo from start

**Decision:** PWA First → React Native Later

**Rationale:**
- ✅ Fastest path to market (6-8 weeks vs 10-12 weeks)
- ✅ Single codebase initially (Next.js)
- ✅ Lower risk: validate idea before heavy React Native investment
- ✅ PWA instalowalna na Android/iOS
- ✅ Can migrate when product validated + budget allows

**Consequences:**

**Positive:**
- Minimal time to market
- Single codebase to maintain initially
- Instant updates (no App Store approval)
- Lower initial cost
- Validate product-market fit first

**Negative:**
- Limited native features w Phase 1 (acceptable)
- Migration effort later (mitigated by architecture)
- No App Store presence initially (acceptable for MVP)

**Implementation Notes:**
- Separate business logic od UI layers
- Use TypeScript dla clear API contracts
- Document platform-specific dependencies
- Plan monorepo migration path dla Phase 2

**References:**
- https://touchlane.com/how-to-migrate-to-react-native-from-pwa-2025-ultimate-guide/
- https://web.dev/progressive-web-apps/

---

### ADR-003: Custom Offline Queue (Phase 1)

**Status:** ✅ Accepted

**Context:**
Aplikacja powinna działać gdy użytkownik czasowo straci connection (np. w sklepie).

**Decision Drivers:**
- Simplicity dla MVP
- Cost (free)
- Time to implement
- Sufficient dla use case

**Considered Options:**
1. Custom request queue (localStorage)
2. PowerSync (Postgres ↔ SQLite sync)
3. RxDB + Supabase replication
4. No offline support

**Decision:** Custom Request Queue (Phase 1)

**Rationale:**
- ✅ Simple implementation (1-2 days)
- ✅ Free (no external service)
- ✅ Sufficient dla shopping list use case
- ✅ Optimistic updates dla lepszego UX
- ✅ Can upgrade to PowerSync w Phase 2 jeśli potrzebne

**Consequences:**

**Positive:**
- Quick to implement
- Full control over logic
- No additional costs
- Works dla basic offline scenarios (< 5 min)

**Negative:**
- No conflict resolution (last-write-wins)
- Limited dla extended offline usage
- Manual implementation effort

**Neutral:**
- Can migrate to PowerSync later jeśli extended offline needed

**Implementation Notes:**
```typescript
// Queue operations w localStorage
// Sync when online
// Optimistic updates dla UX
```

**References:**
- https://web.dev/offline-cookbook/

---

## 6. Następne Kroki

### Immediate Actions (Po tym badaniu)

1. **Review findings** z zespołem / stakeholderami
2. **Validate assumptions** - czy offline queue wystarczy? Czy PWA to ok start?
3. **Setup development environment:**
   - Next.js 15 project
   - Supabase project (free tier)
   - Vercel account

### Architecture Phase (Przed implementation)

1. **Create detailed architecture document** based na tym research
2. **Define API contracts** (TypeScript types)
3. **Plan database migrations** strategy
4. **Setup monitoring** (Supabase Dashboard, Vercel Analytics)

### Development Phase (Weeks 1-8)

Wykonaj roadmap opisany w sekcji 4.3.

### Optional: Deep Dive Research

Jeśli potrzebujesz więcej szczegółów:
1. **Proof of Concept:** Build mini prototype (Supabase Realtime + Next.js)
2. **Performance Testing:** Benchmark RLS performance z 100+ concurrent users
3. **Notification Testing:** Test Web Push delivery rates w różnych browsers
4. **Migration Planning:** Detailed PWA → RN migration checklist

---

## 7. Referencje

### Official Documentation
- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime) - Official guide
- [Supabase RLS Docs](https://supabase.com/docs/guides/database/postgres/row-level-security) - Row Level Security
- [Next.js 15 Docs](https://nextjs.org/docs) - App Router, Server Components
- [Expo Notifications](https://docs.expo.dev/versions/latest/sdk/notifications/) - React Native notifications
- [Web Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API) - MDN reference

### Best Practices & Guides (2025)
- [Building Real-Time Apps with Supabase](https://www.supadex.app/blog/building-real-time-apps-with-supabase-a-step-by-step-guide)
- [Multi-Tenant Apps with RLS](https://www.antstack.com/blog/multi-tenant-applications-with-rls-on-supabase-postgress/)
- [Next.js 15 Best Practices](https://medium.com/@livenapps/next-js-15-app-router-a-complete-senior-level-guide-0554a2b820f7)
- [PWA to React Native Migration Guide](https://touchlane.com/how-to-migrate-to-react-native-from-pwa-2025-ultimate-guide/)

### Performance & Benchmarks
- [Supabase Realtime Benchmarks](https://supabase.com/docs/guides/realtime/benchmarks)
- [Supabase vs Appwrite Performance](https://markaicode.com/supabase-vs-appwrite-performance-comparison/)

### Community Discussions
- [Supabase Realtime Best Practices Discussion](https://github.com/orgs/supabase/discussions/21995)
- [Next.js 15 Server Components Discussion](https://github.com/orgs/community/discussions/149922)

### Tools & Libraries
- [@supabase/ssr](https://www.npmjs.com/package/@supabase/ssr) - Next.js SSR package
- [PowerSync](https://www.powersync.com/) - Offline-first sync dla Supabase
- [Expo](https://expo.dev/) - React Native framework

---

## Podsumowanie

To badanie techniczne dostarcza **kompleksowy przewodnik** dla budowania aplikacji MyHome z:

✅ **Proven technology stack:** Supabase + Next.js 15 + PWA
✅ **Clear architecture patterns:** RLS, real-time, offline, notifications
✅ **Risk mitigation strategies:** PWA first, simple offline, scalable path
✅ **Detailed implementation roadmap:** 8-week plan do MVP
✅ **Future-proof migration path:** PWA → React Native w Phase 2

**Kluczowe zalecenia:**
1. Start z PWA (Next.js 15 + Supabase)
2. Implement custom offline queue dla MVP
3. Use Row Level Security dla multi-tenant isolation
4. Enable Realtime tylko na shopping_list_items
5. Migrate to React Native gdy product validated i budget allows

**Next steps:**
1. Review z zespołem
2. Setup development environment
3. Begin Phase 1 implementation (Week 1)

---

**Raport wygenerowany:** 2025-11-17
**Źródła:** Verified 2025 (WebSearch)
**Workflow:** BMad Method - Technical Research
