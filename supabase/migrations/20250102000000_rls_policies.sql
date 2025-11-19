-- MyHome Row Level Security Policies
-- Migration: 20250102000000_rls_policies.sql
-- Story: 1-2 Supabase Project Setup

-- =============================================================================
-- ENABLE RLS ON ALL TABLES
-- =============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- PROFILES POLICIES
-- =============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (for edge cases)
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can view profiles of home members
CREATE POLICY "Users can view home member profiles"
  ON profiles FOR SELECT
  USING (
    id IN (
      SELECT hm.user_id
      FROM home_members hm
      WHERE hm.home_id = get_user_home_id()
    )
  );

-- =============================================================================
-- HOMES POLICIES
-- =============================================================================

-- Users can view homes they belong to
CREATE POLICY "Users can view their homes"
  ON homes FOR SELECT
  USING (
    id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

-- Users can create homes
CREATE POLICY "Users can create homes"
  ON homes FOR INSERT
  WITH CHECK (auth.uid() = created_by);

-- Home creators can update their homes
CREATE POLICY "Home creators can update homes"
  ON homes FOR UPDATE
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- Home creators can delete their homes
CREATE POLICY "Home creators can delete homes"
  ON homes FOR DELETE
  USING (auth.uid() = created_by);

-- =============================================================================
-- HOME_MEMBERS POLICIES
-- =============================================================================

-- Users can view members of their home
CREATE POLICY "Users can view home members"
  ON home_members FOR SELECT
  USING (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

-- Users can join homes (insert themselves)
CREATE POLICY "Users can join homes"
  ON home_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can leave homes (delete themselves)
CREATE POLICY "Users can leave homes"
  ON home_members FOR DELETE
  USING (auth.uid() = user_id);

-- Admins can remove members from their home
CREATE POLICY "Admins can remove home members"
  ON home_members FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM home_members
      WHERE user_id = auth.uid()
      AND home_id = home_members.home_id
      AND role = 'admin'
    )
  );

-- =============================================================================
-- SHOPPING_LIST_ITEMS POLICIES
-- =============================================================================

-- Users can view items from their home
CREATE POLICY "Users can view items from their home"
  ON shopping_list_items FOR SELECT
  USING (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

-- Users can add items to their home
CREATE POLICY "Users can add items to their home"
  ON shopping_list_items FOR INSERT
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
    AND auth.uid() = created_by
  );

-- Users can update items in their home
CREATE POLICY "Users can update items in their home"
  ON shopping_list_items FOR UPDATE
  USING (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

-- Users can delete items from their home
CREATE POLICY "Users can delete items from their home"
  ON shopping_list_items FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members WHERE user_id = auth.uid()
    )
  );

-- =============================================================================
-- PUSH_SUBSCRIPTIONS POLICIES
-- =============================================================================

-- Users can view their own subscriptions
CREATE POLICY "Users can view own push subscriptions"
  ON push_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create their own subscriptions
CREATE POLICY "Users can create push subscriptions"
  ON push_subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own subscriptions
CREATE POLICY "Users can delete push subscriptions"
  ON push_subscriptions FOR DELETE
  USING (auth.uid() = user_id);
