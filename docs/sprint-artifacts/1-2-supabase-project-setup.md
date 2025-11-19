# Story 1.2: Supabase Project Setup

Status: ready-for-dev

## Story

As a **developer**,
I want **to set up Supabase project with database schema**,
so that **the backend infrastructure is ready for authentication and data storage**.

## Acceptance Criteria

1. **AC1: Database Tables Created**
   - Given a Supabase project (local or cloud)
   - When the database migrations are applied
   - Then the following tables should exist:
     - profiles (id, display_name, avatar_url, created_at, updated_at)
     - homes (id, name, invite_code, created_by, created_at, updated_at)
     - home_members (id, user_id, home_id, role, joined_at)
     - shopping_list_items (id, home_id, name, quantity, category, is_purchased, created_by, created_at, updated_at)
     - push_subscriptions (id, user_id, token, platform, created_at)

2. **AC2: Row Level Security Enabled**
   - Given all tables are created
   - When examining RLS policies
   - Then all tables should have RLS enabled with appropriate policies:
     - profiles: users can only view/update own profile
     - homes: users can only view homes they belong to
     - home_members: users can only view members of their home
     - shopping_list_items: users can only CRUD items from their home
     - push_subscriptions: users can only manage own subscriptions

3. **AC3: Helper Functions Exist**
   - Given the database setup
   - When examining functions
   - Then the following should exist:
     - generate_invite_code() - generates unique 6-char code
     - update_updated_at_column() - trigger for updated_at
     - create_profile_for_user() - auto-create profile on signup
     - get_user_home_id() - helper for RLS

4. **AC4: Triggers Configured**
   - Given the database functions
   - When examining triggers
   - Then the following should be configured:
     - on_auth_user_created: auto-create profile
     - on_home_created: auto-add creator as admin member
     - homes_updated_at: update timestamp on change
     - shopping_items_updated_at: update timestamp on change

5. **AC5: Realtime Enabled**
   - Given the shopping_list_items table
   - When examining publication settings
   - Then realtime should be enabled:
     - Table added to supabase_realtime publication
     - REPLICA IDENTITY set to FULL

## Tasks / Subtasks

- [ ] **Task 1: Initialize Supabase Project** (AC: 1)
  - [ ] Run `supabase init` in project root
  - [ ] Run `supabase start` for local development
  - [ ] Verify Supabase Studio accessible at localhost:54323
  - [ ] Note local credentials (URL, anon key)

- [ ] **Task 2: Create Initial Migration** (AC: 1, 3)
  - [ ] Create migration file: `supabase/migrations/20250101_initial_schema.sql`
  - [ ] Add member_role enum type
  - [ ] Create profiles table with indexes
  - [ ] Create homes table with indexes
  - [ ] Create home_members table with unique constraints
  - [ ] Create shopping_list_items table with indexes
  - [ ] Create push_subscriptions table
  - [ ] Add helper functions (generate_invite_code, update_updated_at_column)

- [ ] **Task 3: Create Profile Trigger** (AC: 3, 4)
  - [ ] Create create_profile_for_user() function
  - [ ] Create on_auth_user_created trigger on auth.users
  - [ ] Test: signup creates profile automatically

- [ ] **Task 4: Create Home Triggers** (AC: 3, 4)
  - [ ] Create add_creator_as_member() function
  - [ ] Create on_home_created trigger
  - [ ] Create updated_at triggers for homes and items

- [ ] **Task 5: Apply RLS Policies** (AC: 2)
  - [ ] Create migration: `supabase/migrations/20250102_rls_policies.sql`
  - [ ] Enable RLS on all tables
  - [ ] Add profiles policies (SELECT, UPDATE, INSERT own)
  - [ ] Add homes policies (SELECT members, INSERT creator, UPDATE creator)
  - [ ] Add home_members policies (SELECT same home, INSERT self, DELETE self)
  - [ ] Add shopping_list_items policies (full CRUD for home members)
  - [ ] Add push_subscriptions policies (manage own)

- [ ] **Task 6: Enable Realtime** (AC: 5)
  - [ ] Create migration: `supabase/migrations/20250103_realtime_setup.sql`
  - [ ] Add shopping_list_items to supabase_realtime publication
  - [ ] Set REPLICA IDENTITY FULL on shopping_list_items

- [ ] **Task 7: Test Migrations Locally** (AC: 1-5)
  - [ ] Run `supabase db reset` to apply all migrations
  - [ ] Verify all tables exist in Supabase Studio
  - [ ] Verify RLS policies are active
  - [ ] Test invite code generation function

## Dev Notes

### Architecture Reference

Complete SQL schemas available in [Source: docs/architecture.md#Database-Schema]:

**Key Tables:**

```sql
-- profiles (auto-created on signup)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- homes (with unique invite code)
CREATE TABLE homes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL DEFAULT generate_invite_code(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- home_members (one home per user in MVP)
CREATE TABLE home_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  role member_role NOT NULL DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, home_id)
);
-- Constraint: one home per user
CREATE UNIQUE INDEX idx_home_members_one_home_per_user ON home_members(user_id);

-- shopping_list_items (main data table)
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
```

### Invite Code Generation

```sql
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- No confusing chars
  result TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

### RLS Policy Pattern

```sql
-- Example: Users can only view items from their home
CREATE POLICY "Users can view items from their home"
  ON shopping_list_items FOR SELECT
  USING (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );
```

### Project Structure Notes

Migration files location:
```
supabase/
├── config.toml           # Supabase config
├── migrations/
│   ├── 20250101_initial_schema.sql
│   ├── 20250102_rls_policies.sql
│   └── 20250103_realtime_setup.sql
└── seed.sql              # Optional seed data
```

### Testing Notes

- Test locally with `supabase start`
- Use Supabase Studio (localhost:54323) to verify tables
- Test RLS by creating test users and checking data isolation
- Verify realtime by subscribing to changes in Studio

### Prerequisites

- Story 1.1 completed (project initialized)

### References

- [Source: docs/architecture.md#Database-Schema] - Complete table definitions
- [Source: docs/architecture.md#Table-Definitions] - Full SQL with indexes
- [Source: docs/architecture.md#Database-Migrations-Strategy] - Migration approach
- [Source: docs/prd.md#FR47] - Database enforces RLS requirement

## Dev Agent Record

### Context Reference

<!-- Path(s) to story context XML will be added here by context workflow -->

### Agent Model Used

<!-- Will be filled by dev agent -->

### Debug Log References

<!-- Will be filled during implementation -->

### Completion Notes List

<!-- Will be filled after implementation -->

### File List

<!-- Will be filled after implementation with NEW/MODIFIED/DELETED files -->

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-19 | SM Agent | Initial story draft created |
