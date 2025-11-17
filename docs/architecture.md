# MyHome - System Architecture Document

**Author:** BMad Architect
**Date:** 2025-11-17
**Version:** 1.0
**Phase:** MVP (Phase 1)
**Stack:** Next.js 15 + Supabase + PWA

---

## Executive Summary

This document defines the complete system architecture for **MyHome Phase 1 MVP** - a Progressive Web App enabling collaborative family shopping lists with real-time synchronization.

**Architecture Goals:**
1. **Real-time by default** - Sub-2-second sync across all family members
2. **Secure multi-tenancy** - Database-level isolation via Row Level Security (RLS)
3. **Mobile-first performance** - < 3s load time on 3G, < 500ms P95 response
4. **Offline resilient** - Request queuing + optimistic updates
5. **Scalable foundation** - 1,000 homes MVP → 10,000 homes (6 months)

**Key Architectural Decisions:**
- **Frontend:** Next.js 15 App Router (React Server Components + Server Actions)
- **Backend:** Supabase (PostgreSQL + Realtime + Auth + Edge Functions)
- **Real-time:** Supabase Realtime (WebSocket over Postgres WAL)
- **Auth:** Supabase Auth (JWT + HttpOnly cookies)
- **Hosting:** Vercel (frontend), Supabase Cloud (backend)
- **Database:** PostgreSQL 15+ with Row Level Security
- **Offline:** Custom request queue (localStorage + optimistic updates)

---

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │  Mobile     │  │   Tablet     │  │    Desktop     │ │
│  │  Browser    │  │   Browser    │  │    Browser     │ │
│  │ (iOS/And)   │  │   (iPad)     │  │  (Chrome/etc)  │ │
│  └──────┬──────┘  └───────┬──────┘  └────────┬───────┘ │
└─────────┼──────────────────┼───────────────────┼─────────┘
          │                  │                   │
          └──────────────────┴───────────────────┘
                             │
                             │ HTTPS/WSS
                             ▼
┌─────────────────────────────────────────────────────────┐
│                  NEXT.JS 15 (VERCEL)                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │  APP ROUTER (React Server Components)             │ │
│  │  ┌──────────────┐  ┌───────────────────────────┐  │ │
│  │  │  Server      │  │  Client Components        │  │ │
│  │  │  Components  │  │  - Realtime subscriptions │  │ │
│  │  │  - SSR       │  │  - Interactive UI         │  │ │
│  │  │  - Data load │  │  - State management       │  │ │
│  │  └──────────────┘  └───────────────────────────┘  │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  SERVER ACTIONS                              │ │ │
│  │  │  - addShoppingItem()                         │ │ │
│  │  │  - updateItem(), deleteItem()                │ │ │
│  │  │  - createHome(), joinHome()                  │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  MIDDLEWARE                                  │ │ │
│  │  │  - Auth session refresh                      │ │ │
│  │  │  - Rate limiting                             │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  PWA FEATURES                                      │ │
│  │  - Service Worker (offline caching)               │ │
│  │  - Web App Manifest                               │ │
│  │  - Offline Request Queue                          │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────┬───────────────────────────────────┘
                       │
                       │ @supabase/ssr
                       ▼
┌─────────────────────────────────────────────────────────┐
│                  SUPABASE (CLOUD)                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │  POSTGRESQL 15+ DATABASE                          │ │
│  │  ┌──────────────┐  ┌──────────────────────────┐   │ │
│  │  │  Tables:     │  │  Row Level Security      │   │ │
│  │  │  - homes     │  │  - auth.uid() policies   │   │ │
│  │  │  - members   │  │  - Data isolation        │   │ │
│  │  │  - items     │  │  - home_id filtering     │   │ │
│  │  │  - notifs    │  │  - Automatic enforcement │   │ │
│  │  └──────────────┘  └──────────────────────────┘   │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  SUPABASE REALTIME (WebSocket)                    │ │
│  │  - Postgres WAL replication                       │ │
│  │  - Phoenix Channels (Elixir)                      │ │
│  │  - Broadcast: INSERT, UPDATE, DELETE              │ │
│  │  - Per-home channel filtering                     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  SUPABASE AUTH                                     │ │
│  │  - Email + Password                               │ │
│  │  - JWT token generation                           │ │
│  │  - Session management                             │ │
│  │  - Password reset flow                            │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  EDGE FUNCTIONS (Optional Phase 2)                │ │
│  │  - Notification dispatch                          │ │
│  │  - Scheduled cleanup                              │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Component Responsibilities

**Client (Browser):**
- Render UI (React components)
- Handle user interactions
- Manage local state (React state, Zustand optional)
- Subscribe to realtime updates (Supabase Realtime)
- Queue offline requests (localStorage)
- Cache static assets (Service Worker)

**Next.js Server (Vercel):**
- Server-side rendering (React Server Components)
- Execute Server Actions (mutations)
- Authenticate requests (middleware)
- Rate limiting (middleware)
- Serve static assets
- Handle PWA manifest + Service Worker

**Supabase (Backend):**
- Store data (PostgreSQL)
- Enforce data isolation (RLS)
- Real-time synchronization (Postgres WAL → WebSocket)
- User authentication (Supabase Auth)
- Session management (JWT)
- Database backups

---

## Database Schema

### Entity Relationship Diagram

```
┌──────────────────┐
│   auth.users     │  (Managed by Supabase Auth)
│──────────────────│
│ id (UUID) PK     │
│ email            │
│ encrypted_pass   │
│ created_at       │
└────────┬─────────┘
         │
         │ 1:1 profile
         │
         ▼
┌──────────────────┐       ┌──────────────────┐
│   profiles       │       │      homes       │
│──────────────────│       │──────────────────│
│ id (UUID) PK     │       │ id (UUID) PK     │
│ user_id FK ──────┼──┐    │ name             │
│ display_name     │  │    │ invite_code      │
│ avatar_url       │  │    │ created_at       │
│ created_at       │  │    │ created_by FK    │───┐
└──────────────────┘  │    └────────┬─────────┘   │
                      │             │              │
                      │             │ 1:N members  │
                      │             │              │
                      │             ▼              │
         ┌────────────┴───────────────────┐       │
         │       home_members             │       │
         │────────────────────────────────│       │
         │ id (UUID) PK                   │       │
         │ user_id (UUID) FK              │───────┘
         │ home_id (UUID) FK              │───────┐
         │ role (enum)                    │       │
         │ joined_at                      │       │
         └────────────────────────────────┘       │
                                                  │
                                    1:N items     │
                                                  │
                      ┌───────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────┐
         │   shopping_list_items          │
         │────────────────────────────────│
         │ id (UUID) PK                   │
         │ home_id (UUID) FK              │
         │ name (TEXT) NOT NULL           │
         │ quantity (TEXT)                │
         │ category (TEXT)                │
         │ is_purchased (BOOL)            │
         │ created_by (UUID) FK           │
         │ created_at (TIMESTAMPTZ)       │
         │ updated_at (TIMESTAMPTZ)       │
         └────────────────────────────────┘

         ┌────────────────────────────────┐
         │   push_subscriptions           │
         │────────────────────────────────│
         │ id (UUID) PK                   │
         │ user_id (UUID) FK              │
         │ token (TEXT) NOT NULL          │
         │ platform (TEXT)                │
         │ created_at (TIMESTAMPTZ)       │
         └────────────────────────────────┘
```

### Table Definitions

#### 1. profiles

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_profiles_id ON profiles(id);

-- RLS Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Trigger: Auto-create profile on user signup
CREATE OR REPLACE FUNCTION create_profile_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_profile_for_user();
```

#### 2. homes

```sql
CREATE TABLE homes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL DEFAULT generate_invite_code(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_homes_id ON homes(id);
CREATE UNIQUE INDEX idx_homes_invite_code ON homes(invite_code);
CREATE INDEX idx_homes_created_by ON homes(created_by);

-- Function: Generate unique 6-char invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- No confusing chars (0,O,1,I)
  result TEXT := '';
  i INT;
  max_attempts INT := 10;
  attempt INT := 0;
BEGIN
  WHILE attempt < max_attempts LOOP
    result := '';
    FOR i IN 1..6 LOOP
      result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;

    -- Check uniqueness
    IF NOT EXISTS (SELECT 1 FROM homes WHERE invite_code = result) THEN
      RETURN result;
    END IF;

    attempt := attempt + 1;
  END LOOP;

  RAISE EXCEPTION 'Could not generate unique invite code after % attempts', max_attempts;
END;
$$ LANGUAGE plpgsql;

-- RLS Policies
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their home"
  ON homes FOR SELECT
  USING (
    id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create homes"
  ON homes FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Home creators can update home"
  ON homes FOR UPDATE
  USING (created_by = auth.uid());

-- Trigger: Update updated_at
CREATE TRIGGER homes_updated_at
  BEFORE UPDATE ON homes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

#### 3. home_members

```sql
CREATE TYPE member_role AS ENUM ('admin', 'member');

CREATE TABLE home_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  role member_role NOT NULL DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, home_id)
);

-- Indexes
CREATE INDEX idx_home_members_user_id ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);
CREATE UNIQUE INDEX idx_home_members_user_home ON home_members(user_id, home_id);

-- Constraint: User can belong to max 1 home (MVP)
CREATE UNIQUE INDEX idx_home_members_one_home_per_user ON home_members(user_id);

-- RLS Policies
ALTER TABLE home_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view members of their home"
  ON home_members FOR SELECT
  USING (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join a home"
  ON home_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can leave their home"
  ON home_members FOR DELETE
  USING (user_id = auth.uid());

-- Trigger: Auto-add creator as admin member when home created
CREATE OR REPLACE FUNCTION add_creator_as_member()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO home_members (user_id, home_id, role)
  VALUES (NEW.created_by, NEW.id, 'admin');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_home_created
  AFTER INSERT ON homes
  FOR EACH ROW
  EXECUTE FUNCTION add_creator_as_member();
```

#### 4. shopping_list_items

```sql
CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity TEXT,
  category TEXT,
  is_purchased BOOLEAN DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
CREATE INDEX idx_shopping_items_is_purchased ON shopping_list_items(is_purchased);
CREATE INDEX idx_shopping_items_created_at ON shopping_list_items(created_at DESC);
CREATE INDEX idx_shopping_items_created_by ON shopping_list_items(created_by);

-- RLS Policies
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;

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
    AND created_by = auth.uid()
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

-- Trigger: Update updated_at
CREATE TRIGGER shopping_items_updated_at
  BEFORE UPDATE ON shopping_list_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE shopping_list_items;
ALTER TABLE shopping_list_items REPLICA IDENTITY FULL;
```

#### 5. push_subscriptions

```sql
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('web', 'mobile')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, token)
);

-- Indexes
CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);
CREATE INDEX idx_push_subscriptions_platform ON push_subscriptions(platform);

-- RLS Policies
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own subscriptions"
  ON push_subscriptions FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

### Utility Functions

```sql
-- Function: Update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Get user's home_id (helper for RLS)
CREATE OR REPLACE FUNCTION get_user_home_id()
RETURNS UUID AS $$
  SELECT home_id FROM home_members WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE;
```

### Database Migrations Strategy

**Migration Tool:** Supabase Migrations (SQL files)

**Migration Files:**
```
supabase/migrations/
├── 20250101_initial_schema.sql      # Tables, indexes, functions
├── 20250102_rls_policies.sql        # All RLS policies
├── 20250103_realtime_setup.sql      # Enable realtime on tables
└── 20250104_seed_categories.sql     # Seed data (optional)
```

**Migration Best Practices:**
- Version controlled (Git)
- Reversible when possible (DOWN migrations)
- Tested in staging before production
- Applied automatically via Supabase CLI

---

## API Design (Server Actions)

### Server Action Contracts

Server Actions replace traditional REST API endpoints dla mutations. They execute on the server, have automatic CSRF protection, i return typed responses.

#### File Structure

```
app/
├── actions/
│   ├── auth.ts              # Authentication actions
│   ├── home.ts              # Home management
│   ├── shopping.ts          # Shopping list CRUD
│   └── notifications.ts     # Push notification management
```

#### 1. Authentication Actions (app/actions/auth.ts)

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const SignUpSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  displayName: z.string().min(2, 'Name must be at least 2 characters').optional(),
});

export async function signUp(formData: FormData) {
  const supabase = createServerClient();

  const parsed = SignUpSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
    displayName: formData.get('displayName'),
  });

  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors };
  }

  const { email, password, displayName } = parsed.data;

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        name: displayName || email.split('@')[0],
      },
    },
  });

  if (error) {
    return { error: error.message };
  }

  redirect('/onboarding'); // Create/join home
}

export async function signIn(formData: FormData) {
  const supabase = createServerClient();

  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return { error: error.message };
  }

  redirect('/'); // Shopping list
}

export async function signOut() {
  const supabase = createServerClient();
  await supabase.auth.signOut();
  redirect('/login');
}

export async function resetPassword(email: string) {
  const supabase = createServerClient();

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/reset-password`,
  });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}
```

#### 2. Home Management Actions (app/actions/home.ts)

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const CreateHomeSchema = z.object({
  name: z.string().min(2, 'Home name must be at least 2 characters').max(50),
});

export async function createHome(formData: FormData) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  const parsed = CreateHomeSchema.safeParse({
    name: formData.get('name'),
  });

  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors };
  }

  const { name } = parsed.data;

  // Create home (trigger auto-adds creator as member)
  const { data: home, error } = await supabase
    .from('homes')
    .insert({ name, created_by: user.id })
    .select()
    .single();

  if (error) throw error;

  revalidatePath('/');
  return { home };
}

export async function joinHome(inviteCode: string) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  // Validate invite code
  const { data: home, error: homeError } = await supabase
    .from('homes')
    .select('id, name')
    .eq('invite_code', inviteCode.toUpperCase())
    .single();

  if (homeError || !home) {
    return { error: 'Invalid invite code' };
  }

  // Check if user already in a home
  const { data: existing } = await supabase
    .from('home_members')
    .select('id')
    .eq('user_id', user.id)
    .single();

  if (existing) {
    return { error: 'You already belong to a home. Leave your current home first.' };
  }

  // Join home
  const { error: joinError } = await supabase
    .from('home_members')
    .insert({
      user_id: user.id,
      home_id: home.id,
      role: 'member',
    });

  if (joinError) throw joinError;

  revalidatePath('/');
  return { home };
}

export async function leaveHome() {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  const { error } = await supabase
    .from('home_members')
    .delete()
    .eq('user_id', user.id);

  if (error) throw error;

  revalidatePath('/');
  return { success: true };
}

export async function regenerateInviteCode(homeId: string) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  // Generate new code
  const { data, error } = await supabase
    .rpc('generate_invite_code')
    .single();

  if (error) throw error;

  const newCode = data as string;

  // Update home
  const { error: updateError } = await supabase
    .from('homes')
    .update({ invite_code: newCode })
    .eq('id', homeId)
    .eq('created_by', user.id); // Only creator can regenerate

  if (updateError) throw updateError;

  revalidatePath('/settings');
  return { inviteCode: newCode };
}
```

#### 3. Shopping List Actions (app/actions/shopping.ts)

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const AddItemSchema = z.object({
  name: z.string().min(1, 'Item name is required').max(100),
  quantity: z.string().max(50).optional(),
  category: z.string().max(50).optional(),
});

export async function addShoppingItem(formData: FormData) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  // Get user's home
  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .single();

  if (!member) {
    return { error: 'You must join a home first' };
  }

  const parsed = AddItemSchema.safeParse({
    name: formData.get('name'),
    quantity: formData.get('quantity'),
    category: formData.get('category'),
  });

  if (!parsed.success) {
    return { error: parsed.error.flatten().fieldErrors };
  }

  const { name, quantity, category } = parsed.data;

  // Insert item (RLS enforced)
  const { data: item, error } = await supabase
    .from('shopping_list_items')
    .insert({
      home_id: member.home_id,
      name,
      quantity,
      category,
      created_by: user.id,
      is_purchased: false,
    })
    .select()
    .single();

  if (error) throw error;

  // TODO: Send push notification to home members (Phase 2)

  revalidatePath('/');
  return { item };
}

export async function updateShoppingItem(
  itemId: string,
  updates: { name?: string; quantity?: string; category?: string }
) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  const { data, error } = await supabase
    .from('shopping_list_items')
    .update(updates)
    .eq('id', itemId)
    .select()
    .single();

  if (error) throw error;

  revalidatePath('/');
  return { item: data };
}

export async function toggleItemPurchased(itemId: string, isPurchased: boolean) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  const { data, error } = await supabase
    .from('shopping_list_items')
    .update({ is_purchased: isPurchased })
    .eq('id', itemId)
    .select()
    .single();

  if (error) throw error;

  // TODO: Send push notification (Phase 2)

  revalidatePath('/');
  return { item: data };
}

export async function deleteShoppingItem(itemId: string) {
  const supabase = createServerClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  const { error } = await supabase
    .from('shopping_list_items')
    .delete()
    .eq('id', itemId);

  if (error) throw error;

  revalidatePath('/');
  return { success: true };
}
```

---

## Real-time Architecture

### Supabase Realtime Setup

**Technology:** Supabase Realtime (Phoenix Channels over WebSocket)

**Flow:**
```
1. Database Change (INSERT/UPDATE/DELETE on shopping_list_items)
   ↓
2. PostgreSQL Write-Ahead Log (WAL) emits event
   ↓
3. Supabase Realtime (Elixir/Phoenix) reads WAL
   ↓
4. Realtime broadcasts event to subscribed clients (per-channel filtering)
   ↓
5. Client receives event via WebSocket
   ↓
6. React component updates local state
   ↓
7. UI re-renders with new data
```

### Client-Side Realtime Implementation

**File:** `app/components/ShoppingListRealtime.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { createBrowserClient } from '@/lib/supabase/client';
import type { RealtimePostgresChangesPayload } from '@supabase/supabase-js';

type ShoppingItem = {
  id: string;
  name: string;
  quantity: string | null;
  category: string | null;
  is_purchased: boolean;
  created_by: string;
  created_at: string;
};

export default function ShoppingListRealtime({
  initialItems,
  homeId,
}: {
  initialItems: ShoppingItem[];
  homeId: string;
}) {
  const [items, setItems] = useState<ShoppingItem[]>(initialItems);
  const [connectionStatus, setConnectionStatus] = useState<'connecting' | 'connected' | 'disconnected'>('connecting');
  const supabase = createBrowserClient();

  useEffect(() => {
    // Subscribe to realtime changes
    const channel = supabase
      .channel(`shopping-${homeId}`)
      .on(
        'postgres_changes',
        {
          event: '*', // Listen to INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'shopping_list_items',
          filter: `home_id=eq.${homeId}`, // Server-side filtering!
        },
        (payload: RealtimePostgresChangesPayload<ShoppingItem>) => {
          console.log('Realtime event:', payload);

          if (payload.eventType === 'INSERT') {
            setItems((prev) => [payload.new, ...prev]);
          } else if (payload.eventType === 'UPDATE') {
            setItems((prev) =>
              prev.map((item) =>
                item.id === payload.new.id ? payload.new : item
              )
            );
          } else if (payload.eventType === 'DELETE') {
            setItems((prev) =>
              prev.filter((item) => item.id !== payload.old.id)
            );
          }
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          setConnectionStatus('connected');
        } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
          setConnectionStatus('disconnected');
        }
      });

    // Cleanup
    return () => {
      channel.unsubscribe();
    };
  }, [homeId, supabase]);

  // Separate items by purchased status
  const activeItems = items.filter((item) => !item.is_purchased);
  const purchasedItems = items.filter((item) => item.is_purchased);

  return (
    <div>
      {/* Connection Status */}
      <div className="status-indicator">
        {connectionStatus === 'connected' && '● Online'}
        {connectionStatus === 'connecting' && '○ Connecting...'}
        {connectionStatus === 'disconnected' && '● Offline'}
      </div>

      {/* Active Items */}
      <section>
        <h2>DO KUPIENIA ({activeItems.length})</h2>
        {activeItems.map((item) => (
          <ShoppingItemCard key={item.id} item={item} />
        ))}
      </section>

      {/* Purchased Items */}
      <section>
        <h2>KUPIONE ({purchasedItems.length})</h2>
        {purchasedItems.map((item) => (
          <ShoppingItemCard key={item.id} item={item} purchased />
        ))}
      </section>
    </div>
  );
}
```

### Realtime Performance Optimization

**Best Practices:**

1. **Server-side filtering:** Use `filter` parameter dla per-home isolation
2. **Selective subscriptions:** Only subscribe when screen active (cleanup on unmount)
3. **Debounce updates:** Batch rapid changes (300ms debounce)
4. **Optimistic updates:** Update UI immediately, rollback on error
5. **Connection monitoring:** Display status, auto-reconnect on failure

---

## Authentication Flow

### Supabase Auth + Next.js SSR

**Session Management:** JWT tokens stored in HttpOnly cookies (secure, XSS-safe)

**Libraries:**
- `@supabase/ssr` - Server-side session handling
- `@supabase/supabase-js` - Client-side auth

**Configuration:**

**File:** `lib/supabase/server.ts`
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

**File:** `lib/supabase/client.ts`
```typescript
import { createBrowserClient } from '@supabase/ssr';

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

**Middleware:** `middleware.ts`
```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({ name, value, ...options });
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          });
          response.cookies.set({ name, value, ...options });
        },
        remove(name: string, options: CookieOptions) {
          request.cookies.set({ name, value: '', ...options });
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          });
          response.cookies.set({ name, value: '', ...options });
        },
      },
    }
  );

  // Refresh session if expired
  await supabase.auth.getUser();

  return response;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
```

### Auth Flow Diagram

```
┌─────────────┐
│ User visits │
│   /login    │
└──────┬──────┘
       │
       ▼
┌──────────────────────────┐
│  Login Form              │
│  - Email input           │
│  - Password input        │
│  - Submit button         │
└──────┬───────────────────┘
       │ Submit
       ▼
┌──────────────────────────┐
│  Server Action           │
│  signIn(formData)        │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Supabase Auth           │
│  .signInWithPassword()   │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  JWT Token Generated     │
│  Stored in HttpOnly      │
│  cookie                  │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Redirect to /           │
│  (Shopping List)         │
└──────────────────────────┘

Subsequent Requests:
┌──────────────────────────┐
│  User navigates          │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Middleware              │
│  - Read cookie           │
│  - Refresh token if exp  │
│  - Attach to request     │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Server Components       │
│  - createServerClient()  │
│  - Access auth.getUser() │
│  - RLS auto-enforced     │
└──────────────────────────┘
```

---

## Offline Architecture

### Offline Request Queue

**Strategy:** Queue mutations locally when offline, sync when online

**Implementation:** `lib/offline-queue.ts`

```typescript
interface QueuedOperation {
  id: string;
  type: 'insert' | 'update' | 'delete';
  table: string;
  data: any;
  timestamp: number;
}

class OfflineQueue {
  private queue: QueuedOperation[] = [];
  private isOnline: boolean = true;

  constructor() {
    this.loadQueue();
    this.setupEventListeners();
  }

  private loadQueue() {
    if (typeof window === 'undefined') return;
    const stored = localStorage.getItem('offline-queue');
    this.queue = stored ? JSON.parse(stored) : [];
  }

  private saveQueue() {
    if (typeof window === 'undefined') return;
    localStorage.setItem('offline-queue', JSON.stringify(this.queue));
  }

  async enqueue(operation: Omit<QueuedOperation, 'id' | 'timestamp'>) {
    const op: QueuedOperation = {
      ...operation,
      id: crypto.randomUUID(),
      timestamp: Date.now(),
    };

    this.queue.push(op);
    this.saveQueue();

    // Try sync immediately if online
    if (this.isOnline) {
      await this.sync();
    }
  }

  async sync() {
    if (!this.isOnline || this.queue.length === 0) return;

    const operations = [...this.queue];

    for (const op of operations) {
      try {
        // Execute operation via Server Action or direct Supabase call
        await this.executeOperation(op);

        // Remove from queue on success
        this.queue = this.queue.filter((o) => o.id !== op.id);
        this.saveQueue();
      } catch (error) {
        console.error('Sync failed for operation:', op, error);
        break; // Stop on first error
      }
    }
  }

  private async executeOperation(op: QueuedOperation) {
    const supabase = createBrowserClient();

    if (op.type === 'insert') {
      await supabase.from(op.table).insert(op.data);
    } else if (op.type === 'update') {
      await supabase.from(op.table).update(op.data).eq('id', op.data.id);
    } else if (op.type === 'delete') {
      await supabase.from(op.table).delete().eq('id', op.data.id);
    }
  }

  private setupEventListeners() {
    if (typeof window === 'undefined') return;

    window.addEventListener('online', () => {
      this.isOnline = true;
      this.sync();
    });

    window.addEventListener('offline', () => {
      this.isOnline = false;
    });

    // Initial online status
    this.isOnline = navigator.onLine;
  }
}

export const offlineQueue = new OfflineQueue();
```

**Usage in Component:**

```typescript
async function handleAddItem(name: string) {
  // Optimistic update
  const tempItem = {
    id: crypto.randomUUID(),
    name,
    is_purchased: false,
    created_at: new Date().toISOString(),
  };

  setItems((prev) => [tempItem, ...prev]);

  // Queue for sync
  await offlineQueue.enqueue({
    type: 'insert',
    table: 'shopping_list_items',
    data: tempItem,
  });
}
```

---

## Deployment Architecture

### Hosting Stack

**Frontend:** Vercel (Next.js hosting)
- **Region:** Auto (closest to user)
- **Plan:** Hobby (free) → Pro ($20/mo when > 100 families)
- **Features:** Auto HTTPS, global CDN, edge functions, preview deployments

**Backend:** Supabase Cloud
- **Region:** EU Central (GDPR compliance) or US East (closer to US users)
- **Plan:** Free tier → Pro ($25/mo when > 1000 homes)
- **Features:** PostgreSQL, Realtime, Auth, Backups, Monitoring

### Deployment Pipeline

```
┌─────────────────────────────────────────────────────────┐
│  DEVELOPMENT                                             │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Local Development                                 │ │
│  │  - Next.js dev server (localhost:3000)            │ │
│  │  - Supabase local (supabase start)                │ │
│  │  - Local PostgreSQL + Realtime                    │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │ git push
                       ▼
┌─────────────────────────────────────────────────────────┐
│  STAGING / PREVIEW                                       │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Vercel Preview Deployment                        │ │
│  │  - Auto-deploy on PR                              │ │
│  │  - Unique URL per branch                          │ │
│  │  - Connected to Supabase Staging project         │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │ Merge to main
                       ▼
┌─────────────────────────────────────────────────────────┐
│  PRODUCTION                                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Vercel Production                                 │ │
│  │  - myhome.app (custom domain)                     │ │
│  │  - Auto-deploy on main branch push                │ │
│  │  - Edge functions globally distributed            │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Supabase Production                               │ │
│  │  - PostgreSQL database                             │ │
│  │  - Daily automated backups                         │ │
│  │  - Point-in-time recovery (7 days)                │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Environment Variables

**Vercel (.env.production):**
```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...
NEXT_PUBLIC_SITE_URL=https://myhome.app
```

**Local (.env.local):**
```bash
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...local
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

### Database Backups

**Supabase Automated Backups:**
- **Frequency:** Daily (Free tier), Hourly (Pro tier)
- **Retention:** 7 days (Free), 30 days (Pro)
- **Point-in-time Recovery:** Last 7 days
- **Manual Backups:** Via Supabase Dashboard or CLI

**Backup Strategy:**
- Daily automated backups (Supabase)
- Weekly manual export to S3 (Phase 2)
- Pre-deployment snapshot before migrations

---

## Architecture Decision Records (ADRs)

### ADR-001: Next.js App Router (vs Pages Router)

**Status:** ✅ Accepted

**Context:**
Next.js 15 offers two routing paradigms - App Router (new) and Pages Router (legacy).

**Decision:** Use App Router with React Server Components

**Rationale:**
- **Server-first:** Server Components reduce client JS bundle size
- **Server Actions:** Built-in mutations without API routes
- **Streaming:** Progressive rendering improves perceived performance
- **Future-proof:** App Router is the future of Next.js
- **Simplified data fetching:** async components, no getServerSideProps

**Trade-offs:**
- ✅ Smaller client bundle, faster loading
- ✅ Simplified architecture (no separate API routes)
- ✅ Better SEO (server rendering by default)
- ❌ Learning curve (newer pattern)
- ❌ Some libraries not yet compatible (rare)

**Implementation Impact:**
- All pages are React Server Components by default
- Client components only when needed ('use client' directive)
- Server Actions replace REST API for mutations

---

### ADR-002: Supabase (vs Firebase, Custom Backend)

**Status:** ✅ Accepted

**Context:**
Need backend with database, real-time, auth, scalability.

**Decision:** Supabase

**Alternatives Considered:**
1. Firebase (NoSQL, Realtime Database)
2. Custom backend (Node.js + PostgreSQL + Socket.io)
3. Appwrite

**Rationale:**
- **PostgreSQL:** Relational model fits shopping list structure (homes → members → items)
- **RLS Built-in:** Row Level Security enforces multi-tenant isolation at DB level
- **Realtime:** WebSocket over Postgres WAL (no separate infrastructure)
- **Auth:** Built-in JWT authentication with session management
- **DX:** Excellent TypeScript support, auto-generated types
- **Cost:** Free tier generous (50,000 MAU, 500MB DB, unlimited API requests)
- **Open Source:** Can self-host if needed (vendor lock-in mitigation)

**Trade-offs:**
- ✅ Strong data consistency (ACID transactions)
- ✅ Multi-tenant security (RLS)
- ✅ Integrated stack (DB + Auth + Realtime + Storage)
- ✅ Affordable scaling
- ❌ Newer than Firebase (smaller community)
- ❌ Postgres learning curve (vs NoSQL)

---

### ADR-003: PWA First (vs React Native from start)

**Status:** ✅ Accepted

**Context:**
Need mobile access but limited timeline (6-8 weeks MVP).

**Decision:** Progressive Web App (PWA) dla Phase 1, React Native dla Phase 2

**Rationale:**
- **Time to market:** PWA ready in 6-8 weeks vs 10-12 weeks dla React Native
- **Single codebase:** Next.js serves both web + mobile
- **Lower risk:** Validate product-market fit before React Native investment
- **Installation:** PWA installable via "Add to Home Screen" (Android/iOS)
- **Instant updates:** No App Store approval delays
- **Migration path:** Can reuse types, API contracts, business logic when migrating

**Trade-offs:**
- ✅ Fastest MVP delivery
- ✅ Lowest initial cost
- ✅ Instant updates
- ❌ Limited device features (Phase 1)
- ❌ No App Store presence
- ❌ Migration effort later (mitigated by architecture)

---

### ADR-004: Custom Offline Queue (vs PowerSync, RxDB)

**Status:** ✅ Accepted dla MVP

**Context:**
Need offline capability dla grocery shopping use case.

**Decision:** Custom request queue (localStorage + optimistic updates)

**Alternatives Considered:**
1. PowerSync ($99/mo, full offline-first sync)
2. RxDB (open source, complex setup)
3. No offline support

**Rationale:**
- **Simple:** 1-2 days implementation
- **Free:** No additional service cost
- **Sufficient:** Shopping list offline needs are basic (< 5 min offline typical)
- **Upgradeable:** Can migrate to PowerSync dla Phase 2 if extended offline needed

**Trade-offs:**
- ✅ Simple, fast implementation
- ✅ No additional costs
- ✅ Sufficient dla use case
- ❌ Last-write-wins (no conflict resolution)
- ❌ Not suitable dla extended offline (> 5 min)

**Phase 2 Consideration:** If users need extended offline (e.g., no signal in store), migrate to PowerSync.

---

### ADR-005: Server Actions (vs REST API, GraphQL)

**Status:** ✅ Accepted

**Context:**
Need API layer dla mutations (add item, create home, etc.).

**Decision:** Next.js Server Actions

**Alternatives Considered:**
1. REST API (Express routes)
2. GraphQL (Apollo Server)
3. tRPC

**Rationale:**
- **Integrated:** Built into Next.js, no separate API server
- **Type-safe:** TypeScript end-to-end (client → server)
- **Automatic CSRF:** Built-in protection
- **Simple:** No API route boilerplate
- **Revalidation:** Integrated with Next.js cache (`revalidatePath`)

**Trade-offs:**
- ✅ Simplified architecture (no API layer)
- ✅ Type safety without codegen
- ✅ Built-in security (CSRF, validation)
- ✅ Faster development
- ❌ Less flexible than REST (harder to expose public API later)
- ❌ Coupled to Next.js (can't reuse dla mobile native later)

**Mitigation:** If public API needed (Phase 3), add REST endpoints alongside Server Actions.

---

## Security Architecture

### Security Layers

**1. Transport Security**
- **HTTPS:** Enforced via Vercel (TLS 1.3)
- **WSS:** WebSocket over TLS dla Realtime
- **HSTS:** HTTP Strict Transport Security headers
- **CSP:** Content Security Policy headers

**2. Authentication Security**
- **Password Hashing:** bcrypt via Supabase Auth
- **JWT:** Signed tokens with short expiry (1 hour)
- **HttpOnly Cookies:** Prevent XSS attacks
- **Refresh Tokens:** Secure refresh flow
- **Rate Limiting:** 5 login attempts per minute per IP

**3. Authorization Security**
- **Row Level Security:** Database-level enforcement
- **home_id Filtering:** All queries scoped to user's home
- **RLS Policies:** Verified on every query (cannot bypass)
- **Principle of Least Privilege:** Users only access their data

**4. Input Validation**
- **Zod Schemas:** Type-safe validation on server
- **SQL Injection:** Prevented by Supabase client (parameterized queries)
- **XSS:** Prevented by React automatic escaping
- **CSRF:** Prevented by Server Actions (automatic tokens)

**5. Data Security**
- **Encryption at Rest:** Supabase encrypts all data
- **Encryption in Transit:** TLS 1.3
- **Backup Encryption:** Encrypted backups
- **Secret Management:** Environment variables, never committed to Git

### Threat Model & Mitigations

| Threat | Mitigation |
|--------|------------|
| **SQL Injection** | Supabase client uses parameterized queries |
| **XSS** | React automatic escaping, CSP headers |
| **CSRF** | Server Actions built-in tokens |
| **Session Hijacking** | HttpOnly cookies, short JWT expiry |
| **MITM** | HTTPS/TLS enforced, HSTS headers |
| **Unauthorized Data Access** | RLS policies, home_id filtering |
| **Brute Force Login** | Rate limiting (5 attempts/min) |
| **Password Leaks** | bcrypt hashing, password strength requirements |

---

## Performance Optimization

### Frontend Performance

**Bundle Optimization:**
- **Code Splitting:** Automatic via Next.js dynamic imports
- **Tree Shaking:** Unused code eliminated
- **Image Optimization:** Next.js `<Image>` component (WebP, lazy loading)
- **Font Optimization:** Next.js `next/font` (self-hosted, preloading)

**Runtime Performance:**
- **React Server Components:** Reduce client JS (70% reduction expected)
- **Streaming:** Progressive rendering (TTI < 3s)
- **Memoization:** `useMemo`, `useCallback` dla expensive operations
- **Virtualization:** React Window dla long lists (Phase 2)

**Caching Strategy:**
- **Static Assets:** Immutable cache (1 year)
- **HTML:** No cache (always fresh)
- **API Data:** Stale-while-revalidate
- **Service Worker:** Cache-first dla assets, network-first dla data

### Database Performance

**Indexing:**
- **Primary Keys:** UUIDs indexed by default
- **Foreign Keys:** Indexed (home_id, user_id, created_by)
- **Query Patterns:** Indexes on `is_purchased`, `created_at DESC`

**Query Optimization:**
- **SELECT Specific Columns:** Avoid `SELECT *`
- **Limit Results:** Pagination (50 items per page)
- **Connection Pooling:** Supabase Supavisor (automatic)

**RLS Performance:**
- **Index RLS Filters:** home_id indexed
- **Cached auth.uid():** Wrapped in SELECT dla caching
- **Monitor Slow Queries:** Supabase Dashboard

### Real-time Performance

**Subscription Optimization:**
- **Server-side Filtering:** `filter: home_id=eq.X` (reduce broadcasts)
- **Selective Events:** Subscribe to INSERT, UPDATE only (skip DELETE if not needed)
- **Cleanup:** Unsubscribe on component unmount
- **Debounce:** 300ms debounce dla rapid updates

---

## Monitoring & Observability

### Logging

**Application Logs:**
- **Vercel:** Built-in logs (stdout/stderr)
- **Error Tracking:** Sentry integration (Phase 2)
- **Structured Logging:** JSON format dla machine parsing

**Database Logs:**
- **Supabase:** Slow query logs (> 100ms)
- **RLS Violations:** Logged automatically
- **Connection Metrics:** Supabase Dashboard

### Metrics

**Frontend Metrics:**
- **Lighthouse:** Performance, Accessibility, PWA scores
- **Web Vitals:** LCP, FID, CLS tracking
- **Bundle Size:** Monitored via Vercel analytics

**Backend Metrics:**
- **Response Time:** P50, P95, P99 latencies
- **Error Rate:** 5xx errors per minute
- **Database:** Query time, connection count, cache hit ratio

**Business Metrics:**
- **Daily Active Families:** Track engagement
- **Real-time Success Rate:** Message delivery rate
- **Offline Queue:** Queue length, sync success rate

---

## Testing Strategy

### Unit Tests

**Framework:** Vitest (faster than Jest dla Vite/Next.js)

**Coverage:**
- Server Actions (input validation, error handling)
- Utility functions (offline queue, helpers)
- React hooks (custom hooks)

**Example:**
```typescript
// __tests__/actions/shopping.test.ts
import { describe, it, expect, vi } from 'vitest';
import { addShoppingItem } from '@/actions/shopping';

describe('addShoppingItem', () => {
  it('should validate input', async () => {
    const formData = new FormData();
    formData.set('name', ''); // Invalid: empty name

    const result = await addShoppingItem(formData);
    expect(result.error).toBeDefined();
  });
});
```

### Integration Tests

**Framework:** Playwright (E2E testing)

**Critical Paths:**
1. User signup → Create home → Add first item
2. User login → View shopping list → Mark item purchased
3. Invite flow → Join home via code
4. Real-time sync → Add item on device A, see on device B

**Example:**
```typescript
// e2e/shopping-flow.spec.ts
import { test, expect } from '@playwright/test';

test('user can add shopping item', async ({ page }) => {
  await page.goto('/');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  await page.waitForURL('/');
  await page.click('[data-testid="add-item-button"]');
  await page.fill('[name="name"]', 'Mleko 2L');
  await page.click('button[type="submit"]');

  await expect(page.locator('text=Mleko 2L')).toBeVisible();
});
```

### Performance Tests

**Tool:** Lighthouse CI (automated)

**Thresholds:**
- Performance: > 85
- Accessibility: > 90
- PWA: > 90

---

## Phase 2 Considerations

### React Native Migration

**When to Migrate:** When product validated + need native features

**Migration Strategy:**
1. **Shared Code:** Extract API client, types, utils to `packages/shared`
2. **Monorepo:** Use Turborepo dla web + mobile
3. **UI Rebuild:** Rebuild components z React Native
4. **Platform-Specific:** Use `Platform.OS` dla iOS/Android differences

**Retained:**
- TypeScript types
- API contracts (Server Actions → REST API)
- Business logic
- Supabase client usage

**Rebuilt:**
- UI components (React → React Native)
- Navigation (Next.js router → React Navigation)
- Styling (Tailwind → StyleSheet)

### Scalability Enhancements

**Database:**
- Read replicas dla read-heavy workloads
- Partitioning shopping_list_items by home_id (when > 1M items)
- Materialized views dla analytics

**Caching:**
- Redis dla session storage (reduce DB load)
- CDN caching dla static assets (already via Vercel)

**Real-time:**
- Dedicated Realtime instance (Supabase Pro)
- Message queue dla notifications (BullMQ)

---

## Appendix

### Technology Stack Summary

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Frontend Framework** | Next.js | 15.x | React framework, SSR, App Router |
| **UI Library** | React | 19.x | Component library |
| **Language** | TypeScript | 5.x | Type safety |
| **Styling** | Tailwind CSS | 3.x | Utility-first CSS |
| **Components** | Shadcn/ui | Latest | Pre-built components |
| **Backend** | Supabase | Cloud | PostgreSQL + Realtime + Auth |
| **Database** | PostgreSQL | 15+ | Relational database |
| **Real-time** | Supabase Realtime | Built-in | WebSocket over Postgres WAL |
| **Auth** | Supabase Auth | Built-in | JWT authentication |
| **Validation** | Zod | 3.x | Schema validation |
| **Testing** | Vitest + Playwright | Latest | Unit + E2E tests |
| **Hosting** | Vercel | Cloud | Next.js hosting |
| **Monitoring** | Vercel Analytics | Built-in | Web Vitals tracking |

### File Structure

```
my-home/
├── app/                          # Next.js App Router
│   ├── (auth)/                   # Auth routes (login, signup)
│   │   ├── login/page.tsx
│   │   └── signup/page.tsx
│   ├── (app)/                    # Main app routes
│   │   ├── page.tsx              # Shopping list (home)
│   │   ├── settings/page.tsx     # Home settings
│   │   └── onboarding/page.tsx   # Create/join home
│   ├── actions/                  # Server Actions
│   │   ├── auth.ts
│   │   ├── home.ts
│   │   └── shopping.ts
│   ├── layout.tsx                # Root layout
│   └── middleware.ts             # Auth middleware
├── components/                   # React components
│   ├── ui/                       # Shadcn components
│   ├── ShoppingList.tsx          # Server Component
│   └── ShoppingListRealtime.tsx  # Client Component
├── lib/                          # Utilities
│   ├── supabase/
│   │   ├── client.ts             # Browser client
│   │   └── server.ts             # Server client
│   ├── offline-queue.ts          # Offline sync
│   └── utils.ts                  # Helpers
├── public/                       # Static assets
│   ├── icons/                    # PWA icons
│   └── manifest.json             # PWA manifest
├── supabase/                     # Supabase config
│   └── migrations/               # SQL migrations
├── .env.local                    # Local env vars
├── next.config.js                # Next.js config
├── tailwind.config.ts            # Tailwind config
├── tsconfig.json                 # TypeScript config
└── package.json                  # Dependencies
```

---

## Version History

**v1.0 (2025-11-17)** - Initial Architecture Document
- System architecture overview
- Complete database schema z RLS policies
- API design (Server Actions)
- Real-time architecture (Supabase Realtime)
- Authentication flow (Supabase Auth + Next.js SSR)
- Offline architecture (custom queue)
- Deployment pipeline (Vercel + Supabase)
- 5 Architecture Decision Records
- Security, performance, testing strategies

---

_This Architecture Document serves as the technical blueprint dla MyHome MVP implementation. All architectural decisions are documented i justified via ADRs._

**Created by:** BMad Architect
**Based on:** PRD v1.0, UX Design v1.0, Technical Research 2025-11-17
**For:** Phase 1 MVP - Collaborative Shopping List PWA