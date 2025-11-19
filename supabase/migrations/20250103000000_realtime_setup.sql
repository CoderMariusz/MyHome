-- MyHome Realtime Configuration
-- Migration: 20250103000000_realtime_setup.sql
-- Story: 1-2 Supabase Project Setup

-- =============================================================================
-- ENABLE REALTIME FOR SHOPPING_LIST_ITEMS
-- =============================================================================

-- Add table to realtime publication
-- This enables real-time subscriptions for shopping list changes
ALTER PUBLICATION supabase_realtime ADD TABLE shopping_list_items;

-- Set REPLICA IDENTITY to FULL for complete row data in realtime events
-- This ensures subscribers receive the full row data (including old values) on updates
ALTER TABLE shopping_list_items REPLICA IDENTITY FULL;

-- =============================================================================
-- NOTES
-- =============================================================================
--
-- With this configuration, clients can subscribe to:
-- - INSERT events (new items added)
-- - UPDATE events (items modified, purchased status changed)
-- - DELETE events (items removed)
--
-- The RLS policies still apply to realtime subscriptions,
-- so users will only receive events for items in their home.
