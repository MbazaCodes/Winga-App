-- ============================================================
-- Winga App — Supabase Database Schema
-- Migration 001: Initial Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Users ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone         TEXT UNIQUE NOT NULL,
  email         TEXT UNIQUE,
  name          TEXT,
  profile_image_url TEXT,
  user_type     TEXT NOT NULL DEFAULT 'customer' CHECK (user_type IN ('customer', 'winga', 'admin')),
  is_verified   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── User Credentials (bypass auth for dev) ───────────────────
CREATE TABLE IF NOT EXISTS public.user_credentials (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  phone         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,  -- base64(password) for dev only
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Wingas ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.wingas (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  winga_id          TEXT UNIQUE NOT NULL,  -- e.g. WNGA12345
  user_id           UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  phone             TEXT NOT NULL,
  email             TEXT,
  specialty         TEXT NOT NULL DEFAULT 'General',
  rating            NUMERIC(3,2) NOT NULL DEFAULT 5.00,
  total_trips       INT NOT NULL DEFAULT 0,
  completion_rate   NUMERIC(5,2) NOT NULL DEFAULT 100.00,
  total_earnings    INT NOT NULL DEFAULT 0,  -- in TZS
  status            TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('active', 'inactive', 'suspended', 'pending')),
  badge             TEXT NOT NULL DEFAULT 'bronze'
                    CHECK (badge IN ('bronze', 'silver', 'gold')),
  is_verified       BOOLEAN NOT NULL DEFAULT FALSE,
  national_id       TEXT,
  home_location     TEXT,
  bio               TEXT,
  joined_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Requests ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.requests (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id     UUID NOT NULL REFERENCES public.users(id),
  winga_id        UUID REFERENCES public.wingas(id),
  category        TEXT NOT NULL,
  meeting_point   TEXT NOT NULL,
  shopping_area   TEXT NOT NULL DEFAULT 'Kariakoo Market',
  service_type    TEXT NOT NULL DEFAULT 'hourly'
                  CHECK (service_type IN ('hourly', 'half_day', 'full_day', 'custom')),
  delivery_method TEXT NOT NULL DEFAULT 'with_client'
                  CHECK (delivery_method IN ('with_client', 'deliver', 'pickup')),
  estimated_price INT NOT NULL,
  final_price     INT,
  status          TEXT NOT NULL DEFAULT 'searching'
                  CHECK (status IN ('searching', 'accepted', 'shopping', 'completed', 'cancelled')),
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at     TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Transactions ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id      UUID NOT NULL REFERENCES public.requests(id),
  winga_id        UUID NOT NULL REFERENCES public.wingas(id),
  customer_id     UUID NOT NULL REFERENCES public.users(id),
  gross_amount    INT NOT NULL,
  platform_fee    INT NOT NULL,   -- 20%
  winga_payout    INT NOT NULL,   -- 80% - tax
  tax             INT NOT NULL,   -- 3–5%
  payment_method  TEXT NOT NULL   CHECK (payment_method IN ('mpesa','airtel','tigo','halopesa','wallet','card','bank')),
  mobile_number   TEXT,
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('success', 'pending', 'failed', 'refunded')),
  provider_ref    TEXT,           -- mobile money reference
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Reviews ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reviews (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id  UUID NOT NULL REFERENCES public.requests(id),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  winga_id    UUID NOT NULL REFERENCES public.wingas(id),
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Notifications ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT NOT NULL DEFAULT 'info'
              CHECK (type IN ('info', 'success', 'warning', 'error', 'request', 'payment')),
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  data        JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_requests_customer  ON public.requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_requests_winga     ON public.requests(winga_id);
CREATE INDEX IF NOT EXISTS idx_requests_status    ON public.requests(status);
CREATE INDEX IF NOT EXISTS idx_transactions_winga ON public.transactions(winga_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);

-- ── RLS Policies ─────────────────────────────────────────────
ALTER TABLE public.users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wingas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users: see own row
CREATE POLICY "users_own" ON public.users
  FOR ALL USING (auth.uid() = id);

-- Wingas: see own row, all can read active wingas
CREATE POLICY "wingas_read_active" ON public.wingas
  FOR SELECT USING (status = 'active');
CREATE POLICY "wingas_own" ON public.wingas
  FOR ALL USING (auth.uid() = user_id);

-- Requests: customer sees own, winga sees assigned + searching
CREATE POLICY "requests_customer" ON public.requests
  FOR ALL USING (auth.uid() = customer_id);
CREATE POLICY "requests_winga_view" ON public.requests
  FOR SELECT USING (status = 'searching' OR auth.uid()::text = winga_id::text);

-- Transactions: own only
CREATE POLICY "transactions_customer" ON public.transactions
  FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "transactions_winga" ON public.transactions
  FOR SELECT USING (auth.uid()::text = winga_id::text);

-- Notifications: own only
CREATE POLICY "notifications_own" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);

-- ── Winga ID Generator ────────────────────────────────────────
CREATE SEQUENCE IF NOT EXISTS winga_id_seq START 12345;

CREATE OR REPLACE FUNCTION generate_winga_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.winga_id IS NULL OR NEW.winga_id = '' THEN
    NEW.winga_id = 'WNGA' || LPAD(nextval('winga_id_seq')::TEXT, 5, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_winga_id
  BEFORE INSERT ON public.wingas
  FOR EACH ROW EXECUTE FUNCTION generate_winga_id();

-- ── Update Winga stats after review ──────────────────────────
CREATE OR REPLACE FUNCTION update_winga_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.wingas
  SET rating = (
    SELECT ROUND(AVG(rating)::numeric, 2)
    FROM public.reviews
    WHERE winga_id = NEW.winga_id
  )
  WHERE id = NEW.winga_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recalculate_winga_rating
  AFTER INSERT OR UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_winga_rating();
