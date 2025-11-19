-- MyHome Initial Database Schema
-- Migration: 20250101000000_initial_schema.sql
-- Story: 1-2 Supabase Project Setup

-- =============================================================================
-- ENUM TYPES
-- =============================================================================

CREATE TYPE member_role AS ENUM ('admin', 'member');

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

-- Generate unique 6-character invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- No confusing chars (0, O, I, 1, L)
  result TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Update updated_at column trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Get user's home ID (helper for RLS policies)
CREATE OR REPLACE FUNCTION get_user_home_id()
RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT home_id FROM home_members WHERE user_id = auth.uid() LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- TABLES
-- =============================================================================

-- Profiles table (auto-created on user signup)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for profiles
CREATE INDEX idx_profiles_display_name ON profiles(display_name);

-- Homes table
CREATE TABLE homes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL DEFAULT generate_invite_code(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for homes
CREATE INDEX idx_homes_invite_code ON homes(invite_code);
CREATE INDEX idx_homes_created_by ON homes(created_by);

-- Home members table (junction table)
CREATE TABLE home_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  role member_role NOT NULL DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, home_id)
);

-- Indexes for home_members
-- Constraint: one home per user (MVP requirement)
CREATE UNIQUE INDEX idx_home_members_one_home_per_user ON home_members(user_id);
CREATE INDEX idx_home_members_home_id ON home_members(home_id);

-- Shopping list items table
CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_id UUID NOT NULL REFERENCES homes(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity TEXT,
  category TEXT,
  is_purchased BOOLEAN DEFAULT FALSE NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for shopping_list_items
CREATE INDEX idx_shopping_items_home_id ON shopping_list_items(home_id);
CREATE INDEX idx_shopping_items_category ON shopping_list_items(category);
CREATE INDEX idx_shopping_items_is_purchased ON shopping_list_items(is_purchased);
CREATE INDEX idx_shopping_items_created_at ON shopping_list_items(created_at DESC);

-- Push subscriptions table
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for push_subscriptions
CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);

-- =============================================================================
-- AUTO-CREATE PROFILE TRIGGER
-- =============================================================================

-- Function to create profile when user signs up
CREATE OR REPLACE FUNCTION create_profile_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_profile_for_user();

-- =============================================================================
-- HOME CREATION TRIGGER
-- =============================================================================

-- Function to add home creator as admin member
CREATE OR REPLACE FUNCTION add_creator_as_member()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.home_members (user_id, home_id, role)
  VALUES (NEW.created_by, NEW.id, 'admin');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on homes
CREATE TRIGGER on_home_created
  AFTER INSERT ON homes
  FOR EACH ROW
  WHEN (NEW.created_by IS NOT NULL)
  EXECUTE FUNCTION add_creator_as_member();

-- =============================================================================
-- UPDATED_AT TRIGGERS
-- =============================================================================

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER homes_updated_at
  BEFORE UPDATE ON homes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER shopping_items_updated_at
  BEFORE UPDATE ON shopping_list_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
