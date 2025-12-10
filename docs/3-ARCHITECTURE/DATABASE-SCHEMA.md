# HomeOS - Database Schema

**Wersja:** 1.1
**Data:** 2025-12-09
**Database:** PostgreSQL 15 (Supabase)
**Architecture Ref:** @docs/3-ARCHITECTURE/ARCHITECTURE.md

---

## 1. Entity Relationship Diagram

```
+------------------+       +------------------+       +------------------+
|   auth.users     |       |      homes       |       |    categories    |
|------------------|       |------------------|       |------------------|
| id (PK)          |       | id (PK)          |<------| home_id (FK)     |
| email            |       | name             |       | id (PK)          |
| created_at       |       | created_by (FK)  |------>| name             |
|                  |       | created_at       |       | icon             |
+--------+---------+       +--------+---------+       | is_default       |
         |                          |                 | sort_order       |
         |                          |                 +------------------+
         |                          |
         |   +----------------------+
         |   |
         v   v
+------------------+       +------------------+       +------------------+
|  home_members    |       | shopping_lists   |       |      tasks       |
|------------------|       |------------------|       |------------------|
| id (PK)          |       | id (PK)          |       | id (PK)          |
| user_id (FK)     |------>| home_id (FK)     |       | home_id (FK)     |
| home_id (FK)     |       | name             |       | title            |
| role             |       | created_by (FK)  |       | description      |
| display_name     |       | created_at       |       | assigned_to (FK) |
| avatar_url       |       +--------+---------+       | is_completed     |
| joined_at        |                |                 | created_by (FK)  |
| invites_sent     |                |                 | created_at       |
+------------------+                |                 +------------------+
         |                          |
         |                          v
         |                 +------------------+
         |                 |shopping_list_    |
         |                 |items             |
         |                 |------------------|
         |                 | id (PK)          |
         +---------------->| list_id (FK)     |
                          | home_id (FK)     |
                          | name             |
                          | quantity         |
                          | unit             |
                          | category_id (FK) |
                          | is_purchased     |
                          | purchased_by(FK) |
                          | assigned_to (FK) |
                          | sort_order       |
                          | created_by (FK)  |
                          | created_at       |
                          | updated_at       |
                          +------------------+

+------------------+       +------------------+
|push_subscriptions|       |   user_settings  |
|------------------|       |------------------|
| id (PK)          |       | user_id (PK, FK) |
| user_id (FK)     |       | theme            |
| endpoint         |       | language         |
| p256dh           |       | notifications    |
| auth             |       | updated_at       |
| platform         |       +------------------+
| created_at       |
+------------------+

+------------------+
|  home_invites    |  <-- JEDYNE ZRODLO PRAWDY DLA ZAPROSZEN
|------------------|      (homes.invite_code USUNIETE - patrz ADR-005)
| id (PK)          |
| home_id (FK)     |
| invite_code (UQ) |  <-- 6-znakowy kod zaproszenia
| created_by (FK)  |
| role             |
| expires_at       |
| used_at          |
| used_by (FK)     |
| created_at       |
+------------------+
```

**UWAGA: Dlaczego invite_code jest w home_invites, a nie w homes?**

Decyzja architektoniczna (ADR-005): Przeniesilismy `invite_code` z tabeli `homes` do `home_invites` aby:
1. Umozliwic wiele aktywnych zaproszen z roznymi rolami (member/child)
2. Sledzic kto utworzyl zaproszenie i kiedy zostalo uzyte
3. Obsluzyc wygasanie zaproszen (expires_at)
4. Uniknac konfliktow miedzy statycznym kodem a dynamicznymi zaproszeniami

---

## 2. Table Definitions

### 2.1 homes (Gospodarstwa Domowe)

```sql
CREATE TABLE homes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 50),
  -- UWAGA: invite_code USUNIETE - zaproszenia obsluguje tabela home_invites
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_homes_created_by ON homes(created_by);

-- Trigger for updated_at
CREATE TRIGGER homes_updated_at
  BEFORE UPDATE ON homes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their homes"
  ON homes FOR SELECT
  USING (
    id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can create homes"
  ON homes FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Admins can update their homes"
  ON homes FOR UPDATE
  USING (
    id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete their homes"
  ON homes FOR DELETE
  USING (
    id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );
```

### 2.2 home_members (Czlonkowie Gospodarstwa)

```sql
CREATE TABLE home_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'member', 'child')) DEFAULT 'member',
  display_name TEXT CHECK (char_length(display_name) <= 30),
  avatar_url TEXT,
  invites_sent INTEGER NOT NULL DEFAULT 0,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, home_id)
);

-- Indexes
CREATE INDEX idx_home_members_user_id ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);
CREATE INDEX idx_home_members_role ON home_members(role);

-- RLS
ALTER TABLE home_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view members of their homes"
  ON home_members FOR SELECT
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can join homes (insert self)"
  ON home_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can update members"
  ON home_members FOR UPDATE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can remove members"
  ON home_members FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR user_id = auth.uid() -- Users can leave
  );
```

### 2.3 shopping_lists (Listy Zakupow)

```sql
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_shopping_lists_home_id ON shopping_lists(home_id);
CREATE INDEX idx_shopping_lists_created_at ON shopping_lists(created_at DESC);

-- Trigger
CREATE TRIGGER shopping_lists_updated_at
  BEFORE UPDATE ON shopping_lists
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view lists from their home"
  ON shopping_lists FOR SELECT
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Members can create lists"
  ON shopping_lists FOR INSERT
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "Members can update lists"
  ON shopping_lists FOR UPDATE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
  );

CREATE POLICY "Members can delete lists"
  ON shopping_lists FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
  );
```

### 2.4 shopping_list_items (Produkty)

```sql
CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 200),
  quantity TEXT CHECK (char_length(quantity) <= 20),
  unit TEXT CHECK (char_length(unit) <= 20),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  is_purchased BOOLEAN NOT NULL DEFAULT FALSE,
  purchased_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  purchased_at TIMESTAMPTZ,
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_shopping_items_list_id ON shopping_list_items(list_id);
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
CREATE INDEX idx_shopping_items_is_purchased ON shopping_list_items(is_purchased);
CREATE INDEX idx_shopping_items_category_id ON shopping_list_items(category_id);
CREATE INDEX idx_shopping_items_sort_order ON shopping_list_items(list_id, sort_order);

-- Trigger
CREATE TRIGGER shopping_items_updated_at
  BEFORE UPDATE ON shopping_list_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view items from their home"
  ON shopping_list_items FOR SELECT
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Members can add items"
  ON shopping_list_items FOR INSERT
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "All members can update items (check off)"
  ON shopping_list_items FOR UPDATE
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Members can delete items"
  ON shopping_list_items FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
  );
```

### 2.5 categories (Kategorie)

```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID REFERENCES homes(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 50),
  name_en TEXT CHECK (char_length(name_en) <= 50),
  icon TEXT CHECK (char_length(icon) <= 10),
  color TEXT CHECK (char_length(color) <= 20),
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index
CREATE INDEX idx_categories_home_id ON categories(home_id);
CREATE INDEX idx_categories_is_default ON categories(is_default);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view default and home categories"
  ON categories FOR SELECT
  USING (
    is_default = TRUE
    OR home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Admins can create custom categories"
  ON categories FOR INSERT
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    AND is_default = FALSE
  );

CREATE POLICY "Admins can update custom categories"
  ON categories FOR UPDATE
  USING (
    is_default = FALSE
    AND home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete custom categories"
  ON categories FOR DELETE
  USING (
    is_default = FALSE
    AND home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );
```

### 2.6 tasks (Zadania - Preview)

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (char_length(title) >= 1 AND char_length(title) <= 200),
  description TEXT CHECK (char_length(description) <= 1000),
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  completed_at TIMESTAMPTZ,
  due_date DATE,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_tasks_home_id ON tasks(home_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_is_completed ON tasks(is_completed);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- Trigger
CREATE TRIGGER tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view tasks from their home"
  ON tasks FOR SELECT
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Members can create tasks"
  ON tasks FOR INSERT
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
    AND created_by = auth.uid()
  );

CREATE POLICY "All members can update tasks (complete)"
  ON tasks FOR UPDATE
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Members can delete tasks"
  ON tasks FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
  );
```

### 2.7 push_subscriptions (Subskrypcje Push)

```sql
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  endpoint TEXT NOT NULL,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('web', 'android', 'ios')) DEFAULT 'web',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, endpoint)
);

-- Indexes
CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);

-- RLS
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their subscriptions"
  ON push_subscriptions FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

### 2.8 user_settings (Ustawienia Uzytkownika)

```sql
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  theme TEXT NOT NULL CHECK (theme IN ('light', 'dark', 'system')) DEFAULT 'system',
  language TEXT NOT NULL CHECK (language IN ('pl', 'en')) DEFAULT 'pl',
  notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  notification_new_item BOOLEAN NOT NULL DEFAULT TRUE,
  notification_assigned BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger
CREATE TRIGGER user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their settings"
  ON user_settings FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

### 2.9 home_invites (Zaproszenia) - JEDYNE ZRODLO PRAWDY

```sql
-- UWAGA: Ta tabela jest JEDYNYM zrodlem prawdy dla zaproszen.
-- Pole homes.invite_code zostalo USUNIETE aby uniknac konfliktow.
-- Kazde zaproszenie ma swoj unikalny kod, moze wygasac i sledzic uzycie.

CREATE TABLE home_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  invite_code TEXT UNIQUE NOT NULL DEFAULT generate_invite_code(),
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  intended_role TEXT NOT NULL CHECK (intended_role IN ('member', 'child')) DEFAULT 'member',
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  used_at TIMESTAMPTZ,
  used_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_home_invites_home_id ON home_invites(home_id);
CREATE INDEX idx_home_invites_invite_code ON home_invites(invite_code);
CREATE INDEX idx_home_invites_expires_at ON home_invites(expires_at);

-- RLS
ALTER TABLE home_invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view invites for their home"
  ON home_invites FOR SELECT
  USING (
    home_id IN (SELECT home_id FROM home_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Members can create invites"
  ON home_invites FOR INSERT
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role IN ('admin', 'member')
    )
    AND created_by = auth.uid()
  );

-- Walidacja kodu przez zalogowanych uzytkownikow (nie anonimowo!)
-- UWAGA: Usunieto "Anyone can validate" - security risk
CREATE POLICY "Authenticated users can validate invite codes"
  ON home_invites FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND used_at IS NULL
    AND expires_at > NOW()
  );

-- Admini moga aktualizowac zaproszenia (np. zmiana roli przed uzyciem)
CREATE POLICY "Admins can update invites"
  ON home_invites FOR UPDATE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Admini moga usuwac zaproszenia
CREATE POLICY "Admins can delete invites"
  ON home_invites FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );
```

---

## 3. Helper Functions

### 3.1 generate_invite_code()

```sql
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::INTEGER, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;
```

### 3.2 update_updated_at_column()

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 3.3 get_user_home_id()

```sql
CREATE OR REPLACE FUNCTION get_user_home_id(p_user_id UUID)
RETURNS UUID AS $$
  SELECT home_id FROM home_members WHERE user_id = p_user_id LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```

### 3.4 check_member_invite_limit()

```sql
CREATE OR REPLACE FUNCTION check_member_invite_limit()
RETURNS TRIGGER AS $$
DECLARE
  member_role TEXT;
  invite_count INTEGER;
BEGIN
  SELECT role, invites_sent INTO member_role, invite_count
  FROM home_members
  WHERE user_id = NEW.created_by AND home_id = NEW.home_id;

  -- Null check: uzytkownik musi byc czlonkiem gospodarstwa
  IF member_role IS NULL THEN
    RAISE EXCEPTION 'Uzytkownik nie jest czlonkiem tego gospodarstwa';
  END IF;

  -- Child nie moze tworzyc zaproszen
  IF member_role = 'child' THEN
    RAISE EXCEPTION 'Dzieci nie moga tworzyc zaproszen';
  END IF;

  IF member_role = 'member' AND invite_count >= 3 THEN
    RAISE EXCEPTION 'Member has reached invite limit (3)';
  END IF;

  -- Increment counter
  UPDATE home_members
  SET invites_sent = invites_sent + 1
  WHERE user_id = NEW.created_by AND home_id = NEW.home_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_invite_limit
  BEFORE INSERT ON home_invites
  FOR EACH ROW
  EXECUTE FUNCTION check_member_invite_limit();
```

### 3.5 validate_and_use_invite()

```sql
-- Funkcja do walidacji i uzycia zaproszenia w jednej transakcji
CREATE OR REPLACE FUNCTION validate_and_use_invite(
  p_invite_code TEXT,
  p_user_id UUID
)
RETURNS TABLE (
  home_id UUID,
  intended_role TEXT,
  home_name TEXT
) AS $$
DECLARE
  v_invite RECORD;
BEGIN
  -- Znajdz wazne zaproszenie
  SELECT hi.*, h.name as home_name INTO v_invite
  FROM home_invites hi
  JOIN homes h ON h.id = hi.home_id
  WHERE hi.invite_code = UPPER(p_invite_code)
    AND hi.used_at IS NULL
    AND hi.expires_at > NOW();

  IF v_invite IS NULL THEN
    RAISE EXCEPTION 'Invalid or expired invite code';
  END IF;

  -- Oznacz zaproszenie jako uzyte
  UPDATE home_invites
  SET used_at = NOW(), used_by = p_user_id
  WHERE id = v_invite.id;

  RETURN QUERY SELECT v_invite.home_id, v_invite.intended_role, v_invite.home_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3.6 create_invite_with_code()

```sql
-- Tworzy zaproszenie z automatycznie wygenerowanym kodem
CREATE OR REPLACE FUNCTION create_invite_with_code(
  p_home_id UUID,
  p_created_by UUID,
  p_intended_role TEXT DEFAULT 'member',
  p_expires_days INTEGER DEFAULT 7
)
RETURNS TABLE (
  invite_id UUID,
  invite_code TEXT,
  expires_at TIMESTAMPTZ
) AS $$
DECLARE
  v_code TEXT;
  v_id UUID;
  v_expires TIMESTAMPTZ;
BEGIN
  -- Generuj unikalny kod
  LOOP
    v_code := generate_invite_code();
    EXIT WHEN NOT EXISTS (SELECT 1 FROM home_invites WHERE home_invites.invite_code = v_code);
  END LOOP;

  v_expires := NOW() + (p_expires_days || ' days')::INTERVAL;

  INSERT INTO home_invites (home_id, invite_code, created_by, intended_role, expires_at)
  VALUES (p_home_id, v_code, p_created_by, p_intended_role, v_expires)
  RETURNING id INTO v_id;

  RETURN QUERY SELECT v_id, v_code, v_expires;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 4. Default Data (Seed)

### 4.1 Default Categories

```sql
INSERT INTO categories (id, home_id, name, name_en, icon, is_default, sort_order) VALUES
  (gen_random_uuid(), NULL, 'Nabial', 'Dairy', '1f95b', TRUE, 1),
  (gen_random_uuid(), NULL, 'Warzywa', 'Vegetables', '1f96c', TRUE, 2),
  (gen_random_uuid(), NULL, 'Owoce', 'Fruits', '1f34e', TRUE, 3),
  (gen_random_uuid(), NULL, 'Pieczywo', 'Bakery', '1f35e', TRUE, 4),
  (gen_random_uuid(), NULL, 'Mieso', 'Meat', '1f969', TRUE, 5),
  (gen_random_uuid(), NULL, 'Ryby', 'Fish', '1f41f', TRUE, 6),
  (gen_random_uuid(), NULL, 'Napoje', 'Beverages', '1f964', TRUE, 7),
  (gen_random_uuid(), NULL, 'Mrozonki', 'Frozen', '1f9ca', TRUE, 8),
  (gen_random_uuid(), NULL, 'Slodycze', 'Sweets', '1f36b', TRUE, 9),
  (gen_random_uuid(), NULL, 'Chemia', 'Household', '1f9f9', TRUE, 10),
  (gen_random_uuid(), NULL, 'Inne', 'Other', '1f4e6', TRUE, 99);
```

---

## 5. TypeScript Types

```typescript
// lib/supabase/types.ts
export type Database = {
  public: {
    Tables: {
      homes: {
        Row: {
          id: string;
          name: string;
          created_by: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          created_by: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          updated_at?: string;
        };
      };
      home_members: {
        Row: {
          id: string;
          user_id: string;
          home_id: string;
          role: 'admin' | 'member' | 'child';
          display_name: string | null;
          avatar_url: string | null;
          invites_sent: number;
          joined_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          home_id: string;
          role?: 'admin' | 'member' | 'child';
          display_name?: string | null;
          avatar_url?: string | null;
          invites_sent?: number;
          joined_at?: string;
        };
        Update: {
          role?: 'admin' | 'member' | 'child';
          display_name?: string | null;
          avatar_url?: string | null;
          invites_sent?: number;
        };
      };
      home_invites: {
        Row: {
          id: string;
          home_id: string;
          invite_code: string;
          created_by: string;
          intended_role: 'member' | 'child';
          expires_at: string;
          used_at: string | null;
          used_by: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          home_id: string;
          invite_code?: string;
          created_by: string;
          intended_role?: 'member' | 'child';
          expires_at?: string;
          used_at?: string | null;
          used_by?: string | null;
          created_at?: string;
        };
        Update: {
          intended_role?: 'member' | 'child';
          expires_at?: string;
          used_at?: string | null;
          used_by?: string | null;
        };
      };
      shopping_lists: {
        Row: {
          id: string;
          home_id: string;
          name: string;
          is_archived: boolean;
          created_by: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          home_id: string;
          name: string;
          is_archived?: boolean;
          created_by: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          is_archived?: boolean;
          updated_at?: string;
        };
      };
      shopping_list_items: {
        Row: {
          id: string;
          list_id: string;
          home_id: string;
          name: string;
          quantity: string | null;
          unit: string | null;
          category_id: string | null;
          is_purchased: boolean;
          purchased_by: string | null;
          purchased_at: string | null;
          assigned_to: string | null;
          sort_order: number;
          created_by: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          list_id: string;
          home_id: string;
          name: string;
          quantity?: string | null;
          unit?: string | null;
          category_id?: string | null;
          is_purchased?: boolean;
          purchased_by?: string | null;
          purchased_at?: string | null;
          assigned_to?: string | null;
          sort_order?: number;
          created_by: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          quantity?: string | null;
          unit?: string | null;
          category_id?: string | null;
          is_purchased?: boolean;
          purchased_by?: string | null;
          purchased_at?: string | null;
          assigned_to?: string | null;
          sort_order?: number;
          updated_at?: string;
        };
      };
      categories: {
        Row: {
          id: string;
          home_id: string | null;
          name: string;
          name_en: string | null;
          icon: string | null;
          color: string | null;
          is_default: boolean;
          sort_order: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          home_id?: string | null;
          name: string;
          name_en?: string | null;
          icon?: string | null;
          color?: string | null;
          is_default?: boolean;
          sort_order?: number;
          created_at?: string;
        };
        Update: {
          name?: string;
          name_en?: string | null;
          icon?: string | null;
          color?: string | null;
          sort_order?: number;
        };
      };
      tasks: {
        Row: {
          id: string;
          home_id: string;
          title: string;
          description: string | null;
          assigned_to: string | null;
          is_completed: boolean;
          completed_by: string | null;
          completed_at: string | null;
          due_date: string | null;
          created_by: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          home_id: string;
          title: string;
          description?: string | null;
          assigned_to?: string | null;
          is_completed?: boolean;
          completed_by?: string | null;
          completed_at?: string | null;
          due_date?: string | null;
          created_by: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          title?: string;
          description?: string | null;
          assigned_to?: string | null;
          is_completed?: boolean;
          completed_by?: string | null;
          completed_at?: string | null;
          due_date?: string | null;
          updated_at?: string;
        };
      };
      user_settings: {
        Row: {
          user_id: string;
          theme: 'light' | 'dark' | 'system';
          language: 'pl' | 'en';
          notifications_enabled: boolean;
          notification_new_item: boolean;
          notification_assigned: boolean;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          theme?: 'light' | 'dark' | 'system';
          language?: 'pl' | 'en';
          notifications_enabled?: boolean;
          notification_new_item?: boolean;
          notification_assigned?: boolean;
          updated_at?: string;
        };
        Update: {
          theme?: 'light' | 'dark' | 'system';
          language?: 'pl' | 'en';
          notifications_enabled?: boolean;
          notification_new_item?: boolean;
          notification_assigned?: boolean;
          updated_at?: string;
        };
      };
      push_subscriptions: {
        Row: {
          id: string;
          user_id: string;
          endpoint: string;
          p256dh: string;
          auth: string;
          platform: 'web' | 'android' | 'ios';
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          endpoint: string;
          p256dh: string;
          auth: string;
          platform?: 'web' | 'android' | 'ios';
          created_at?: string;
        };
        Update: {
          endpoint?: string;
          p256dh?: string;
          auth?: string;
          platform?: 'web' | 'android' | 'ios';
        };
      };
    };
    Functions: {
      generate_invite_code: {
        Args: Record<string, never>;
        Returns: string;
      };
      get_user_home_id: {
        Args: { p_user_id: string };
        Returns: string | null;
      };
      validate_and_use_invite: {
        Args: { p_invite_code: string; p_user_id: string };
        Returns: { home_id: string; intended_role: string; home_name: string }[];
      };
    };
  };
};

// Convenience types
export type Home = Database['public']['Tables']['homes']['Row'];
export type HomeMember = Database['public']['Tables']['home_members']['Row'];
export type HomeInvite = Database['public']['Tables']['home_invites']['Row'];
export type ShoppingList = Database['public']['Tables']['shopping_lists']['Row'];
export type ShoppingItem = Database['public']['Tables']['shopping_list_items']['Row'];
export type Category = Database['public']['Tables']['categories']['Row'];
export type Task = Database['public']['Tables']['tasks']['Row'];
export type UserSettings = Database['public']['Tables']['user_settings']['Row'];

export type Role = 'admin' | 'member' | 'child';
export type Theme = 'light' | 'dark' | 'system';
export type Language = 'pl' | 'en';

// Result type for validate_and_use_invite() function
export type InviteValidationResult = {
  home_id: string;
  intended_role: 'member' | 'child';
  home_name: string;
};

// Result type for create_invite_with_code() function
export type InviteCreationResult = {
  invite_id: string;
  invite_code: string;
  expires_at: string;
};
```

---

## 6. Migration Strategy

### 6.1 Initial Setup

```bash
# 1. Create Supabase project
# 2. Run migrations in order:
supabase db push

# Or manually:
# migrations/001_initial_schema.sql
# migrations/002_rls_policies.sql
# migrations/003_functions.sql
# migrations/004_seed_categories.sql
```

### 6.2 Schema Changes

Wszystkie zmiany schematu przez migracje:

```
supabase/migrations/
├── 001_initial_schema.sql
├── 002_rls_policies.sql
└── 003_functions.sql
```

---

**Document Version:** 1.1
**Last Updated:** 2025-12-09
**Author:** Architect Agent
**Changes:**
- Usunieto homes.invite_code (konflikt z home_invites)
- Dodano invite_code do home_invites jako jedyne zrodlo prawdy
- Dodano funkcje validate_and_use_invite()
- Zaktualizowano TypeScript types
