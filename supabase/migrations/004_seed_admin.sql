-- ============================================================
-- Winga App — Migration 004: Seed Admin User
-- ============================================================
-- IMPORTANT: Login uses Supabase Auth (signInWithPassword).
-- The admin user MUST exist in BOTH:
--   1. Supabase Auth (Authentication → Users)
--   2. public.users table (below) — with user_type = 'admin'
-- ============================================================

-- Grant admin access to support@winga.com
INSERT INTO public.users (id, phone, email, name, user_type, is_verified)
VALUES (
  'a4224bfa-2604-4695-8e02-becd5242cf5f',
  '+255000000000',
  'support@winga.com',
  'Winga Support',
  'admin',
  TRUE
)
ON CONFLICT (phone) DO UPDATE SET
  id      = EXCLUDED.id,
  email   = EXCLUDED.email,
  name    = EXCLUDED.name,
  user_type = EXCLUDED.user_type,
  is_verified = EXCLUDED.is_verified;