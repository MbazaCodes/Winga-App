-- ============================================================
-- Winga App — COMPLETE DATABASE SETUP (V3)
-- This file contains the entire schema, functions, and policies.
-- Safe to re-run: it will reset the public schema.
-- ============================================================

-- ── 0. RESET ──────────────────────────────────────────────────────────────
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON SCHEMA public TO public;

-- ── 1. EXTENSIONS ─────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── 2. TABLES ─────────────────────────────────────────────────────────────

-- Users
CREATE TABLE public.users (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone             TEXT UNIQUE NOT NULL,
  email             TEXT UNIQUE,
  name              TEXT,
  profile_image_url TEXT,
  user_type         TEXT NOT NULL DEFAULT 'customer' CHECK (user_type IN ('customer', 'winga', 'admin')),
  is_verified       BOOLEAN NOT NULL DEFAULT FALSE,
  wallet_balance    INT NOT NULL DEFAULT 0,
  fcm_token         TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Credentials (for dev/production alternative)
CREATE TABLE public.user_credentials (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  phone         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tiers
CREATE TABLE public.verification_tiers (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT UNIQUE NOT NULL CHECK (name IN ('Starter', 'Mid', 'Verified')),
  monthly_fee  INT NOT NULL,
  description  TEXT NOT NULL,
  features     JSONB NOT NULL DEFAULT '[]',
  badge_color  TEXT NOT NULL,
  sort_order   INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Locations
CREATE TABLE public.locations (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  country     TEXT NOT NULL DEFAULT 'Tanzania',
  region      TEXT NOT NULL,
  city        TEXT NOT NULL,
  area        TEXT,
  lat         NUMERIC(10,7),
  lng         NUMERIC(10,7),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Wingas
CREATE TABLE public.wingas (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  winga_id            TEXT UNIQUE NOT NULL,
  user_id             UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  phone               TEXT NOT NULL,
  email               TEXT,
  specialty           TEXT NOT NULL DEFAULT 'General',
  bio                 TEXT,
  home_location       TEXT,
  national_id         TEXT,
  tin_number          TEXT,
  profile_photo_url   TEXT,

  -- Social
  instagram           TEXT,
  facebook            TEXT,
  tiktok              TEXT,
  twitter             TEXT,
  whatsapp            TEXT,

  -- Verification
  verification_status TEXT NOT NULL DEFAULT 'unverified'
                      CHECK (verification_status IN ('unverified','documents_submitted','payment_pending','under_review','verified','suspended','rejected')),
  verification_tier   TEXT CHECK (verification_tier IN ('Starter','Mid','Verified')),
  tier_id             UUID REFERENCES public.verification_tiers(id),
  verified_at         TIMESTAMPTZ,
  verified_by         UUID REFERENCES public.users(id),

  -- Badge
  badge               TEXT NOT NULL DEFAULT 'none' CHECK (badge IN ('none','Starter','Mid','Verified')),
  badge_assigned_at   TIMESTAMPTZ,
  badge_expires_at    TIMESTAMPTZ,

  -- Stats
  rating              NUMERIC(3,2) NOT NULL DEFAULT 5.00,
  total_points        INT NOT NULL DEFAULT 0,
  rated_trips         INT NOT NULL DEFAULT 0,
  winga_score         NUMERIC(6,4) NOT NULL DEFAULT 0,
  is_top_rated        BOOLEAN NOT NULL DEFAULT FALSE,
  total_trips         INT NOT NULL DEFAULT 0,
  completion_rate     NUMERIC(5,2) NOT NULL DEFAULT 100.00,
  total_earnings      INT NOT NULL DEFAULT 0,

  -- Status
  is_online           BOOLEAN NOT NULL DEFAULT FALSE,
  status              TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('active','inactive','suspended','pending')),
  profile_complete    BOOLEAN NOT NULL DEFAULT FALSE,
  current_city        TEXT,
  current_area        TEXT,

  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Requests
CREATE TABLE public.requests (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id     UUID NOT NULL REFERENCES public.users(id),
  winga_id        UUID REFERENCES public.wingas(id),
  category        TEXT NOT NULL,
  meeting_point   TEXT NOT NULL,
  shopping_area   TEXT NOT NULL DEFAULT 'Kariakoo Market',
  service_type    TEXT NOT NULL DEFAULT 'hourly' CHECK (service_type IN ('hourly','half_day','full_day','custom')),
  delivery_method TEXT NOT NULL DEFAULT 'with_client' CHECK (delivery_method IN ('with_client','deliver','pickup')),
  estimated_price INT NOT NULL,
  total_price     INT,
  final_price     INT,
  status          TEXT NOT NULL DEFAULT 'searching' CHECK (status IN ('searching','accepted','shopping','completed','cancelled')),
  note            TEXT,
  location_id     UUID REFERENCES public.locations(id),
  city            TEXT,
  area            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at     TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Messages
CREATE TABLE public.messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id  UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
  sender_id   UUID NOT NULL REFERENCES public.users(id),
  sender_type TEXT NOT NULL CHECK (sender_type IN ('customer','winga','system')),
  type        TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text','photo','substitution','system','tip','location')),
  body        TEXT,
  photo_url   TEXT,
  metadata    JSONB,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Points/Ratings
CREATE TABLE public.winga_points (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  winga_id    UUID NOT NULL REFERENCES public.wingas(id) ON DELETE CASCADE,
  request_id  UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES public.users(id),
  point       INT  NOT NULL CHECK (point IN (0, 1)),
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uniq_point_per_request UNIQUE (request_id)
);

-- Tips
CREATE TABLE public.tips (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id     UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
  customer_id    UUID NOT NULL REFERENCES public.users(id),
  winga_id       UUID NOT NULL REFERENCES public.wingas(id),
  amount         INT NOT NULL CHECK (amount > 0),
  payment_method TEXT NOT NULL DEFAULT 'wallet',
  status         TEXT NOT NULL DEFAULT 'success',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uniq_tip_per_request UNIQUE (request_id)
);

-- Transactions
CREATE TABLE public.transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id      UUID NOT NULL REFERENCES public.requests(id),
  winga_id        UUID NOT NULL REFERENCES public.wingas(id),
  customer_id     UUID NOT NULL REFERENCES public.users(id),
  gross_amount    INT NOT NULL,
  platform_fee    INT NOT NULL,
  winga_payout    INT NOT NULL,
  tax             INT NOT NULL,
  payment_method  TEXT NOT NULL CHECK (payment_method IN ('mpesa','airtel','tigo','halopesa','wallet','card','bank')),
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('success','pending','failed','refunded')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notifications
CREATE TABLE public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT NOT NULL DEFAULT 'info' CHECK (type IN ('info','success','warning','error','request','payment','verification')),
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  data        JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audit Log
CREATE TABLE public.admin_audit_log (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id    UUID REFERENCES public.users(id),
  action      TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id   UUID NOT NULL,
  details     JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3. SEED DATA ──────────────────────────────────────────────────────────

-- Tiers
INSERT INTO public.verification_tiers (name, monthly_fee, description, badge_color, sort_order, features) VALUES
  ('Starter',  5000,  'Basic verified listing on Winga platform', '#CD7F32', 1, '["Verified badge","Basic profile"]'::jsonb),
  ('Mid',      15000, 'Priority listing with enhanced visibility', '#C0C0C0', 2, '["Mid badge","Priority listing"]'::jsonb),
  ('Verified', 30000, 'Top-tier featured Winga with gold badge', '#F9A825', 3, '["Verified gold badge","Top search placement"]'::jsonb)
ON CONFLICT DO NOTHING;

-- Locations
INSERT INTO public.locations (country, region, city, area, sort_order) VALUES
  ('Tanzania','Dar es Salaam','Dar es Salaam','Kariakoo', 1),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Mwenge', 2),
  ('Tanzania','Arusha','Arusha','Arusha CBD', 10),
  ('Tanzania','Kilimanjaro','Moshi','Moshi Market', 20)
ON CONFLICT DO NOTHING;

-- Admin User (public table side)
INSERT INTO public.users (id, phone, email, name, user_type, is_verified)
VALUES ('a4224bfa-2604-4695-8e02-becd5242cf5f', '+255000000000', 'support@winga.com', 'Winga Support', 'admin', TRUE)
ON CONFLICT (phone) DO NOTHING;

-- ── 4. VIEWS ──────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW public.v_dashboard_stats AS
SELECT
  (SELECT COUNT(*) FROM public.requests) AS total_requests,
  (SELECT COUNT(*) FROM public.requests WHERE status = 'completed') AS completed_requests,
  (SELECT COUNT(*) FROM public.requests WHERE status IN ('accepted','shopping')) AS in_progress,
  (SELECT COUNT(*) FROM public.wingas WHERE status = 'active') AS active_wingas,
  (SELECT COUNT(*) FROM public.users WHERE user_type = 'customer') AS total_clients;

CREATE OR REPLACE VIEW public.v_winga_leaderboard AS
SELECT
  w.id, w.winga_id, w.name, w.specialty, w.badge, w.rating, w.total_trips, w.winga_score, w.is_online
FROM public.wingas w
WHERE w.status = 'active'
ORDER BY w.winga_score DESC;

-- ── 5. FUNCTIONS & TRIGGERS ───────────────────────────────────────────────

-- Winga ID Sequence
CREATE SEQUENCE IF NOT EXISTS winga_id_seq START 10001;
GRANT USAGE, SELECT ON SEQUENCE public.winga_id_seq TO authenticated, anon;

-- Auto Winga ID Generator
CREATE OR REPLACE FUNCTION public.generate_winga_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.winga_id IS NULL OR NEW.winga_id = '' THEN
    NEW.winga_id = 'WNGA' || LPAD(nextval('winga_id_seq')::TEXT, 5, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER set_winga_id BEFORE INSERT ON public.wingas FOR EACH ROW EXECUTE FUNCTION public.generate_winga_id();

-- Wilson Score Function
CREATE OR REPLACE FUNCTION public.wilson_score(good INT, total INT)
RETURNS NUMERIC AS $$
DECLARE z CONSTANT NUMERIC := 1.96; phat NUMERIC;
BEGIN
  IF total <= 0 THEN RETURN 0; END IF;
  phat := good::NUMERIC / total::NUMERIC;
  RETURN ROUND((phat + (z*z)/(2*total) - z*SQRT((phat*(1-phat)+(z*z)/(4*total))/total))/(1+(z*z)/total), 4);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Profile Completion Calculator
CREATE OR REPLACE FUNCTION public.calc_winga_completion(p_id UUID)
RETURNS INT AS $$
DECLARE w RECORD; s INT := 0;
BEGIN
  SELECT * INTO w FROM public.wingas WHERE id = p_id;
  IF NOT FOUND THEN RETURN 0; END IF;
  IF w.name IS NOT NULL AND trim(w.name) <> '' THEN s := s + 15; END IF;
  IF w.phone IS NOT NULL AND trim(w.phone) <> '' THEN s := s + 15; END IF;
  IF w.specialty IS NOT NULL AND trim(w.specialty) <> '' THEN s := s + 15; END IF;
  IF w.current_city IS NOT NULL AND trim(w.current_city) <> '' THEN s := s + 10; END IF;
  IF w.national_id IS NOT NULL AND trim(w.national_id) <> '' THEN s := s + 20; END IF;
  IF w.profile_photo_url IS NOT NULL AND trim(w.profile_photo_url) <> '' THEN s := s + 15; END IF;
  IF w.tin_number IS NOT NULL AND trim(w.tin_number) <> '' THEN s := s + 10; END IF;
  RETURN LEAST(s, 100);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Recalculate Points & Auto-Promote
CREATE OR REPLACE FUNCTION public.recalc_winga_points()
RETURNS TRIGGER AS $$
DECLARE
  v_winga UUID := COALESCE(NEW.winga_id, OLD.winga_id);
  v_good  INT;
  v_total INT;
  v_score NUMERIC;
  v_new_badge TEXT;
  v_pct INT;
BEGIN
  SELECT COALESCE(SUM(point), 0), COUNT(*) INTO v_good, v_total FROM public.winga_points WHERE winga_id = v_winga;
  v_score := public.wilson_score(v_good, v_total);

  IF v_total >= 30 AND v_score >= 0.80 THEN v_new_badge := 'Verified';
  ELSIF v_total >= 10 AND v_score >= 0.60 THEN v_new_badge := 'Mid';
  ELSE v_new_badge := 'Starter'; END IF;

  v_pct := public.calc_winga_completion(v_winga);

  UPDATE public.wingas SET
    total_points = v_good,
    rated_trips  = v_total,
    winga_score  = v_score,
    badge = v_new_badge,
    verification_tier = v_new_badge,
    profile_complete = (v_pct >= 75)
  WHERE id = v_winga;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_recalc_points AFTER INSERT OR UPDATE OR DELETE ON public.winga_points FOR EACH ROW EXECUTE FUNCTION public.recalc_winga_points();

-- ── 5. RLS & POLICIES ─────────────────────────────────────────────────────
ALTER TABLE public.users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wingas              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.winga_points        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tips                ENABLE ROW LEVEL SECURITY;

-- Helper
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND user_type = 'admin');
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Policies
CREATE POLICY "users_access" ON public.users FOR ALL USING (auth.uid() = id OR public.is_admin());
CREATE POLICY "wingas_read" ON public.wingas FOR SELECT USING (true);
CREATE POLICY "wingas_own" ON public.wingas FOR ALL USING (auth.uid() = user_id OR public.is_admin());
CREATE POLICY "requests_customer" ON public.requests FOR ALL USING (auth.uid() = customer_id OR public.is_admin());
CREATE POLICY "requests_winga" ON public.requests FOR ALL USING (winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid()) OR (status = 'searching' AND winga_id IS NULL));
CREATE POLICY "messages_access" ON public.messages FOR ALL USING (request_id IN (SELECT id FROM public.requests WHERE customer_id = auth.uid() OR winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())));
CREATE POLICY "notifs_own" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- Grants
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON public.wingas, public.locations, public.verification_tiers TO anon;

-- ── 6. REALTIME ───────────────────────────────────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.messages, public.requests, public.wingas;
  END IF;
END $$;
