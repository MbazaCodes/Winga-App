-- ============================================================
-- Migration 011: Fix RLS policies for PWA
-- Fixes "permission denied for table requests" error
-- Also ensures all PWA-required columns exist
-- ============================================================

-- ── Fix requests RLS: FOR ALL with only USING doesn't cover INSERT ──────────
-- PostgreSQL: USING applies to SELECT/UPDATE/DELETE row filtering
--             WITH CHECK applies to INSERT/UPDATE row creation
-- The old policy "FOR ALL USING (auth.uid() = customer_id)" 
-- does NOT allow INSERT because there's no WITH CHECK clause

DROP POLICY IF EXISTS "requests_customer_own"    ON public.requests;
DROP POLICY IF EXISTS "requests_winga_assigned"  ON public.requests;
DROP POLICY IF EXISTS "requests_winga_searching" ON public.requests;
DROP POLICY IF EXISTS "requests_winga_update"    ON public.requests;
DROP POLICY IF EXISTS "requests_admin"           ON public.requests;

-- Customer: full access to their own requests
CREATE POLICY "requests_customer_select" ON public.requests
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "requests_customer_insert" ON public.requests
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "requests_customer_update" ON public.requests
  FOR UPDATE USING (auth.uid() = customer_id);

-- Winga: see requests assigned to them OR open 'searching' requests  
CREATE POLICY "requests_winga_view" ON public.requests
  FOR SELECT USING (
    status = 'searching'
    OR winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );

-- Winga: update requests assigned to them (accept, shopping, complete)
CREATE POLICY "requests_winga_update" ON public.requests
  FOR UPDATE USING (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  ) WITH CHECK (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );

-- Admin: full access
CREATE POLICY "requests_admin" ON public.requests
  FOR ALL USING (public.is_admin());

-- ── Fix wingas INSERT/UPDATE: PWA registers Wingas directly ──────────────────
DROP POLICY IF EXISTS "wingas_insert"    ON public.wingas;
DROP POLICY IF EXISTS "wingas_own"       ON public.wingas;
DROP POLICY IF EXISTS "wingas_admin_all" ON public.wingas;

-- Public: read active verified wingas
CREATE POLICY "wingas_public_read" ON public.wingas
  FOR SELECT USING (
    status = 'active' AND verification_status = 'verified'
    OR user_id = auth.uid()
    OR public.is_admin()
  );

-- Winga: insert their own record
CREATE POLICY "wingas_insert" ON public.wingas
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Winga: update their own record
CREATE POLICY "wingas_own_update" ON public.wingas
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Admin: full access
CREATE POLICY "wingas_admin" ON public.wingas
  FOR ALL USING (public.is_admin());

-- ── Fix users: allow upsert from PWA registration ────────────────────────────
DROP POLICY IF EXISTS "users_insert"   ON public.users;
DROP POLICY IF EXISTS "users_own_read" ON public.users;

CREATE POLICY "users_own_read" ON public.users
  FOR SELECT USING (auth.uid() = id OR public.is_admin());

CREATE POLICY "users_insert" ON public.users
  FOR INSERT WITH CHECK (true);  -- anyone can register

CREATE POLICY "users_upsert" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- ── Ensure all columns exist (safe ADD COLUMN IF NOT EXISTS) ─────────────────

-- requests: columns added in 009
ALTER TABLE public.requests
  ADD COLUMN IF NOT EXISTS location_id  UUID REFERENCES public.locations(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS city         TEXT,
  ADD COLUMN IF NOT EXISTS area         TEXT,
  ADD COLUMN IF NOT EXISTS request_lat  NUMERIC(10,7),
  ADD COLUMN IF NOT EXISTS request_lng  NUMERIC(10,7),
  ADD COLUMN IF NOT EXISTS total_price  INT;        -- alias for estimated_price, used by PWA

-- wingas: columns added in 007, 009
ALTER TABLE public.wingas
  ADD COLUMN IF NOT EXISTS total_points    INT     NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS rated_trips     INT     NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS point_rate      NUMERIC(5,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS winga_score     NUMERIC(6,4) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_top_rated    BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS current_city    TEXT,
  ADD COLUMN IF NOT EXISTS current_area    TEXT,
  ADD COLUMN IF NOT EXISTS current_lat     NUMERIC(10,7),
  ADD COLUMN IF NOT EXISTS current_lng     NUMERIC(10,7),
  ADD COLUMN IF NOT EXISTS bio             TEXT;

-- users: wallet balance added in 009
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS wallet_balance INT NOT NULL DEFAULT 0;

-- ── tips table (from 009) ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tips (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id     UUID NOT NULL REFERENCES public.requests(id),
  customer_id    UUID NOT NULL REFERENCES public.users(id),
  winga_id       UUID NOT NULL REFERENCES public.wingas(id),
  amount         INT NOT NULL CHECK (amount > 0),
  payment_method TEXT NOT NULL DEFAULT 'wallet',
  provider_ref   TEXT,
  status         TEXT NOT NULL DEFAULT 'success',
  message        TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uniq_tip_per_request UNIQUE (request_id)
);

ALTER TABLE public.tips ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "tips_customer_own" ON public.tips;
DROP POLICY IF EXISTS "tips_winga_view"   ON public.tips;
CREATE POLICY "tips_customer_own" ON public.tips FOR ALL   USING (auth.uid() = customer_id);
CREATE POLICY "tips_winga_view"   ON public.tips FOR SELECT USING (
  winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
);
GRANT SELECT, INSERT ON public.tips TO authenticated;

-- ── locations table (from 009) ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.locations (
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

ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "locations_public" ON public.locations;
CREATE POLICY "locations_public" ON public.locations FOR SELECT USING (is_active = TRUE);
GRANT SELECT ON public.locations TO anon, authenticated;

-- Seed Tanzania locations if empty
INSERT INTO public.locations (country, region, city, area, lat, lng, sort_order)
SELECT * FROM (VALUES
  ('Tanzania','Dar es Salaam','Dar es Salaam','Kariakoo',       -6.8161, 39.2894, 1),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Mwenge',          -6.7780, 39.2630, 2),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Mnazi Mmoja',     -6.8193, 39.2884, 3),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Ilala',           -6.8235, 39.2695, 4),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Kinondoni',       -6.7834, 39.2707, 5),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Temeke',          -6.8726, 39.2990, 6),
  ('Tanzania','Dar es Salaam','Dar es Salaam','Tabata',          -6.8416, 39.2534, 7),
  ('Tanzania','Arusha','Arusha','Arusha CBD',                   -3.3869, 36.6830, 10),
  ('Tanzania','Kilimanjaro','Moshi','Moshi Market',              -3.3531, 37.3403, 20),
  ('Tanzania','Mwanza','Mwanza','Mwanza Market',                 -2.5164, 32.9175, 30),
  ('Tanzania','Dodoma','Dodoma','Dodoma Market',                 -6.1731, 35.7395, 40),
  ('Tanzania','Zanzibar','Zanzibar City','Darajani Market',      -6.1622, 39.1894, 50),
  ('Tanzania','Zanzibar','Zanzibar City','Stone Town',           -6.1630, 39.1900, 51)
) AS t(country,region,city,area,lat,lng,sort_order)
WHERE NOT EXISTS (SELECT 1 FROM public.locations LIMIT 1);

-- ── Grant permissions ─────────────────────────────────────────────────────────
GRANT SELECT ON public.wingas    TO anon;
GRANT SELECT ON public.wingas    TO authenticated;
GRANT INSERT, UPDATE ON public.wingas    TO authenticated;
GRANT SELECT ON public.requests  TO authenticated;
GRANT INSERT, UPDATE ON public.requests  TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;
GRANT SELECT ON public.verification_tiers TO anon, authenticated;
GRANT SELECT ON public.locations TO anon, authenticated;

-- ── rate_winga function grant (points RPC) ────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.rate_winga(UUID, INT, TEXT) TO authenticated;

