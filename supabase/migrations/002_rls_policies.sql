-- HomeOS Database Schema - Row Level Security Policies
-- Migration: 002_rls_policies.sql
-- Date: 2025-12-09

-- ============================================
-- RLS: homes
-- ============================================
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

-- ============================================
-- RLS: home_members
-- ============================================
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

-- ============================================
-- RLS: home_invites
-- ============================================
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
-- Tylko zalogowani uzytkownicy moga walidowac kody zaproszen
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

-- ============================================
-- RLS: categories
-- ============================================
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

-- ============================================
-- RLS: shopping_lists
-- ============================================
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

-- ============================================
-- RLS: shopping_list_items
-- ============================================
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

-- ============================================
-- RLS: tasks
-- ============================================
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

-- ============================================
-- RLS: push_subscriptions
-- ============================================
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their subscriptions"
  ON push_subscriptions FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ============================================
-- RLS: user_settings
-- ============================================
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their settings"
  ON user_settings FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
