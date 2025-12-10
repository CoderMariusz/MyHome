-- HomeOS Database Schema - Functions and Triggers
-- Migration: 003_functions.sql
-- Date: 2025-12-09

-- ============================================
-- FUNCTION: update_updated_at_column()
-- Automatyczna aktualizacja kolumny updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: generate_invite_code()
-- Generuje 6-znakowy kod zaproszenia
-- Znaki: A-Z (bez I,O,L) + 2-9 (bez 0,1)
-- ============================================
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

-- ============================================
-- FUNCTION: get_user_home_id()
-- Zwraca home_id dla podanego user_id
-- ============================================
CREATE OR REPLACE FUNCTION get_user_home_id(p_user_id UUID)
RETURNS UUID AS $$
  SELECT home_id FROM home_members WHERE user_id = p_user_id LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ============================================
-- FUNCTION: check_member_invite_limit()
-- Sprawdza limit zaproszen dla czlonkow (max 3)
-- Admini nie maja limitu
-- ============================================
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
    RAISE EXCEPTION 'Czlonek osiagnal limit zaproszen (3)';
  END IF;

  -- Inkrementuj licznik zaproszen
  UPDATE home_members
  SET invites_sent = invites_sent + 1
  WHERE user_id = NEW.created_by AND home_id = NEW.home_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: validate_and_use_invite()
-- Waliduje kod zaproszenia i oznacza jako uzyte
-- Zwraca dane do dolaczenia do gospodarstwa
-- ============================================
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
    RAISE EXCEPTION 'Nieprawidlowy lub wygasly kod zaproszenia';
  END IF;

  -- Oznacz zaproszenie jako uzyte
  UPDATE home_invites
  SET used_at = NOW(), used_by = p_user_id
  WHERE id = v_invite.id;

  RETURN QUERY SELECT v_invite.home_id, v_invite.intended_role, v_invite.home_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: create_invite_with_code()
-- Tworzy zaproszenie z automatycznie wygenerowanym kodem
-- ============================================
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

-- ============================================
-- TRIGGERS: updated_at
-- ============================================
CREATE TRIGGER homes_updated_at
  BEFORE UPDATE ON homes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER shopping_lists_updated_at
  BEFORE UPDATE ON shopping_lists
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER shopping_items_updated_at
  BEFORE UPDATE ON shopping_list_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TRIGGER: check_invite_limit
-- ============================================
CREATE TRIGGER check_invite_limit
  BEFORE INSERT ON home_invites
  FOR EACH ROW
  EXECUTE FUNCTION check_member_invite_limit();
