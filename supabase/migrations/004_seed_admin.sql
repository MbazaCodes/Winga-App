-- ============================================================
-- Winga App — Migration 004: Seed Admin User
-- ============================================================
-- IMPORTANT: Login uses Supabase Auth (signInWithPassword).
-- The admin user MUST exist in BOTH:
--   1. Supabase Auth (Authentication → Users) — create the user there first
--   2. public.users table (below) — with user_type = 'admin'
--
-- To set up:
--   1. Go to Supabase Dashboard → Authentication → Users → Create User
--   2. Enter email (e.g. admin@winga.co.tz) and a strong password
--   3. Then run this migration to create the admin record in the users table
--   4. If the Supabase Auth user ID is known, replace uuid_generate_v4() with it
-- ============================================================

-- Insert admin record into users table
-- NOTE: If you already created the user in Supabase Auth, copy their UUID
-- from the Auth Users table and paste it below instead of uuid_generate_v4()
INSERT INTO public.users (id, phone, email, name, user_type, is_verified)
VALUES (
  uuid_generate_v4(),
  '+255000000000',
  'admin@winga.co.tz',
  'Super Admin',
  'admin',
  TRUE
)
ON CONFLICT (phone) DO NOTHING;