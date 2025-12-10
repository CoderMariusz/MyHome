# Badanie Techniczne: Architektura HomeOS

**Data oryginalna:** 2025-11-17
**Zaktualizowano:** 2025-12-09
**Projekt:** HomeOS (dawniej MyHome)
**Typ badania:** Technical Research
**Status:** Reference - do użycia przez Architect

---

## Streszczenie Wykonawcze

To badanie techniczne analizuje optymalne rozwiązania architektoniczne dla aplikacji HomeOS - aplikacji webowej i mobilnej do zarządzania domem z funkcją synchronizacji.

### Kluczowe Wnioski

**Rekomendowany Stack:**
- ✅ **Supabase** (PostgreSQL + Realtime + Auth + RLS)
- ✅ **Next.js 15** z App Router
- ✅ **PWA w Phase 1** → React Native w Phase 2+
- ✅ **Web Push API** (PWA) → **Expo Notifications** (React Native)

### Kluczowe Decyzje Architektoniczne

1. **Sync**: 10 min refresh w MVP, Supabase Realtime w Phase 2
2. **Security**: Row Level Security (RLS) z auth.uid()
3. **Mobile Strategy**: Start z PWA, React Native gdy funkcjonalność się rozrośnie
4. **Offline Handling**: "No connection" screen w MVP, cache w Phase 1
5. **Notifications**: Web Push API z opt-in pattern

---

## 1. Supabase Realtime - Best Practices

### Kluczowe Cechy
- **Postgres Changes:** Subscription na INSERT/UPDATE/DELETE
- **Broadcast:** Custom events między klientami
- **Presence:** Tracking online users
- **Performance:** Tysiące concurrent connections

### Best Practices - Performance

✅ **Enable real-time tylko na niezbędnych tabelach**
```sql
ALTER TABLE shopping_list_items REPLICA IDENTITY FULL;
```

✅ **Selective event triggers**
```typescript
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

✅ **Cleanup subscriptions**
```typescript
useEffect(() => {
  const channel = supabase.channel('shopping-changes');
  // ... setup
  return () => {
    channel.unsubscribe();
  };
}, []);
```

✅ **Filter by home_id server-side**
```typescript
.on('postgres_changes', {
  event: '*',
  schema: 'public',
  table: 'shopping_list_items',
  filter: `home_id=eq.${currentHomeId}`
})
```

---

## 2. Row Level Security - Multi-Tenant Patterns

### Architektura
```
User (auth.users)
  → home_members (relacja user_id ↔ home_id)
    → homes (gospodarstwa)
      → shopping_list_items (produkty z home_id)
```

### RLS Policies

```sql
-- Enable RLS
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;

-- Shopping List Items policies
CREATE POLICY "Users can view items from their home"
ON shopping_list_items FOR SELECT
USING (
  home_id IN (
    SELECT home_id FROM home_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert items to their home"
ON shopping_list_items FOR INSERT
WITH CHECK (
  home_id IN (
    SELECT home_id FROM home_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can update items in their home"
ON shopping_list_items FOR UPDATE
USING (
  home_id IN (
    SELECT home_id FROM home_members WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete items from their home"
ON shopping_list_items FOR DELETE
USING (
  home_id IN (
    SELECT home_id FROM home_members WHERE user_id = auth.uid()
  )
);
```

### Performance - Indexy

```sql
CREATE INDEX idx_home_members_user_id ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
```

---

## 3. Database Schema

```sql
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
  role TEXT CHECK (role IN ('admin', 'member', 'child')) DEFAULT 'member',
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
  assigned_to UUID REFERENCES auth.users,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Shopping Lists (kontenery)
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  home_id UUID REFERENCES homes NOT NULL,
  name TEXT NOT NULL,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tasks (Preview w MVP)
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  home_id UUID REFERENCES homes NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  assigned_to UUID REFERENCES auth.users,
  is_completed BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Push Subscriptions
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('web', 'mobile')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories (user-defined)
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  home_id UUID REFERENCES homes NOT NULL,
  name TEXT NOT NULL,
  icon TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to generate invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
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

---

## 4. Next.js 15 + Supabase Integration

### Pattern: Server Components + Client Components

```
app/
├── layout.tsx                 # Server Component (root)
├── page.tsx                   # Server Component (initial load)
├── components/
│   ├── ShoppingList.tsx      # Server Component (fetch initial data)
│   └── ShoppingListClient.tsx # Client Component (interactivity)
```

### Server Component (Initial Load)
```typescript
import { createServerClient } from '@/lib/supabase/server';
import ShoppingListClient from './ShoppingListClient';

export default async function ShoppingList({ homeId }: { homeId: string }) {
  const supabase = createServerClient();

  const { data: items } = await supabase
    .from('shopping_list_items')
    .select('*')
    .eq('home_id', homeId)
    .order('created_at', { ascending: false });

  return <ShoppingListClient initialItems={items || []} homeId={homeId} />;
}
```

### Client Component (Interactivity)
```typescript
'use client';

import { useEffect, useState } from 'react';
import { createBrowserClient } from '@/lib/supabase/client';

export default function ShoppingListClient({
  initialItems,
  homeId
}: {
  initialItems: ShoppingItem[];
  homeId: string;
}) {
  const [items, setItems] = useState(initialItems);
  const supabase = createBrowserClient();

  // Refresh logic (10 min interval w MVP)
  useEffect(() => {
    const interval = setInterval(async () => {
      const { data } = await supabase
        .from('shopping_list_items')
        .select('*')
        .eq('home_id', homeId);
      if (data) setItems(data);
    }, 10 * 60 * 1000); // 10 min

    return () => clearInterval(interval);
  }, [homeId]);

  return (
    <div>
      {items.map(item => (
        <ShoppingItem key={item.id} item={item} />
      ))}
    </div>
  );
}
```

### Server Actions dla Mutations
```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';

export async function addShoppingItem(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user?.id)
    .single();

  const { error } = await supabase
    .from('shopping_list_items')
    .insert({
      name: formData.get('name'),
      quantity: formData.get('quantity'),
      category: formData.get('category'),
      home_id: member?.home_id,
      created_by: user?.id,
    });

  if (error) throw error;
  revalidatePath('/shopping');
}
```

---

## 5. PWA Requirements

### Manifest
```json
{
  "name": "HomeOS",
  "short_name": "HomeOS",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### Performance Targets
- **First Contentful Paint:** < 1.5s on 3G
- **Time to Interactive:** < 3s on 3G
- **Lighthouse PWA Score:** 90+
- **Bundle Size:** < 500KB initial load

---

## 6. Push Notifications (Web Push API)

### Opt-in Pattern
```typescript
const handleSubscribe = async () => {
  const permission = await Notification.requestPermission();
  if (permission === 'granted') {
    // Setup push subscription
    const token = await getToken(messaging, {
      vapidKey: process.env.NEXT_PUBLIC_VAPID_KEY
    });

    await supabase
      .from('push_subscriptions')
      .insert({
        user_id: currentUser.id,
        token: token,
        platform: 'web'
      });
  }
};
```

### Send Notification
```typescript
'use server';

export async function sendNotificationToHome(
  homeId: string,
  title: string,
  body: string
) {
  const { data: subscriptions } = await supabase
    .from('push_subscriptions')
    .select('token')
    .in('user_id', /* home members */);

  // Send via FCM or Web Push
  await Promise.all(
    subscriptions.map(sub =>
      sendWebPush(sub.token, { title, body })
    )
  );
}
```

---

## 7. Architecture Patterns

### Pattern 1: Optimistic UI Updates
```typescript
async function togglePurchased(itemId: string, currentValue: boolean) {
  const newValue = !currentValue;

  // 1. Optimistic update
  setItems(prev => prev.map(item =>
    item.id === itemId ? { ...item, is_purchased: newValue } : item
  ));

  try {
    // 2. Persist
    await supabase
      .from('shopping_list_items')
      .update({ is_purchased: newValue })
      .eq('id', itemId);
  } catch (error) {
    // 3. Rollback on error
    setItems(prev => prev.map(item =>
      item.id === itemId ? { ...item, is_purchased: currentValue } : item
    ));
    toast.error('Nie udało się zaktualizować');
  }
}
```

### Pattern 2: Invite Code System
```typescript
export async function joinHomeByCode(inviteCode: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  const { data: home } = await supabase
    .from('homes')
    .select('id, name')
    .eq('invite_code', inviteCode.toUpperCase())
    .single();

  if (!home) throw new Error('Nieprawidłowy kod zaproszenia');

  const { data: existing } = await supabase
    .from('home_members')
    .select('id')
    .eq('user_id', user.id)
    .single();

  if (existing) throw new Error('Należysz już do domu');

  await supabase
    .from('home_members')
    .insert({ user_id: user.id, home_id: home.id });

  return { homeId: home.id, homeName: home.name };
}
```

---

## 8. ADR Summary

### ADR-001: Supabase jako Backend
**Status:** ✅ Accepted
- PostgreSQL dla structured data
- Built-in RLS dla multi-tenant
- Free tier dla start

### ADR-002: PWA First
**Status:** ✅ Accepted
- Najszybsza droga do rynku
- Walidacja przed inwestycją w React Native

### ADR-003: 10 min Refresh (MVP)
**Status:** ✅ Accepted dla MVP
- Prostsze niż real-time
- Wystarczające dla shopping list
- Real-time w Phase 2

---

## Źródła

- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [Supabase RLS Docs](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Next.js 15 Docs](https://nextjs.org/docs)
- [Web Push API MDN](https://developer.mozilla.org/en-US/docs/Web/API/Push_API)

---

**Raport oryginalny:** 2025-11-17
**Zaktualizowano dla HomeOS:** 2025-12-09
