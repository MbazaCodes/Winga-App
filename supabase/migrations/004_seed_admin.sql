-- ============================================================
-- Winga App — Migration 004: Seed Admin User
-- ============================================================

-- Insert default super admin (change password after first login)
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

-- Seed admin credentials (password: Admin@Winga2026)
INSERT INTO public.user_credentials (user_id, phone, password_hash)
SELECT 
  id,
  '+255000000000',
  encode(digest('Admin@Winga2026', 'sha256'), 'base64')
FROM public.users 
WHERE phone = '+255000000000'
ON CONFLICT (phone) DO NOTHING;
