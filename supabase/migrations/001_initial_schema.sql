-- HomeOS Database Schema - Initial Tables
-- Migration: 001_initial_schema.sql
-- Date: 2025-12-09

-- ============================================
-- EXTENSIONS
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: homes (Gospodarstwa Domowe)
-- ============================================
-- UWAGA: invite_code jest w tabeli home_invites, NIE tutaj
-- Pozwala to na wiele aktywnych zaproszen z roznymi rolami i datami wygasniecia

CREATE TABLE homes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 50),
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_homes_created_by ON homes(created_by);

-- ============================================
-- TABLE: home_members (Czlonkowie Gospodarstwa)
-- ============================================
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

CREATE INDEX idx_home_members_user_id ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);
CREATE INDEX idx_home_members_role ON home_members(role);

-- ============================================
-- TABLE: home_invites (Zaproszenia)
-- JEDYNE ZRODLO PRAWDY dla kodow zaproszen
-- ============================================
CREATE TABLE home_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  invite_code TEXT UNIQUE NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  intended_role TEXT NOT NULL CHECK (intended_role IN ('member', 'child')) DEFAULT 'member',
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  used_at TIMESTAMPTZ,
  used_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_home_invites_home_id ON home_invites(home_id);
CREATE INDEX idx_home_invites_invite_code ON home_invites(invite_code);
CREATE INDEX idx_home_invites_expires_at ON home_invites(expires_at);

-- ============================================
-- TABLE: categories (Kategorie)
-- ============================================
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

CREATE INDEX idx_categories_home_id ON categories(home_id);
CREATE INDEX idx_categories_is_default ON categories(is_default);

-- ============================================
-- TABLE: shopping_lists (Listy Zakupow)
-- ============================================
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shopping_lists_home_id ON shopping_lists(home_id);
CREATE INDEX idx_shopping_lists_created_at ON shopping_lists(created_at DESC);

-- ============================================
-- TABLE: shopping_list_items (Produkty)
-- ============================================
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

CREATE INDEX idx_shopping_items_list_id ON shopping_list_items(list_id);
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
CREATE INDEX idx_shopping_items_is_purchased ON shopping_list_items(is_purchased);
CREATE INDEX idx_shopping_items_category_id ON shopping_list_items(category_id);
CREATE INDEX idx_shopping_items_sort_order ON shopping_list_items(list_id, sort_order);

-- ============================================
-- TABLE: tasks (Zadania)
-- ============================================
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

CREATE INDEX idx_tasks_home_id ON tasks(home_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_is_completed ON tasks(is_completed);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- ============================================
-- TABLE: push_subscriptions (Subskrypcje Push)
-- ============================================
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

CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);

-- ============================================
-- TABLE: user_settings (Ustawienia Uzytkownika)
-- ============================================
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  theme TEXT NOT NULL CHECK (theme IN ('light', 'dark', 'system')) DEFAULT 'system',
  language TEXT NOT NULL CHECK (language IN ('pl', 'en')) DEFAULT 'pl',
  notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  notification_new_item BOOLEAN NOT NULL DEFAULT TRUE,
  notification_assigned BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- SEED: Default Categories
-- ============================================
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
