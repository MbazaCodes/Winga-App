-- ============================================================
-- Winga App — COMPLETE DATABASE SETUP (All-in-One)
-- Run this ENTIRE file in Supabase SQL Editor
-- https://supabase.com/dashboard/project/kevdbsyiqelksxvmuped/sql/new
-- Safe to re-run multiple times
-- ============================================================

-- ============================================================
-- Winga App — Migration 001: Initial Schema
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Users ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.users (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone             TEXT UNIQUE NOT NULL,
  email             TEXT UNIQUE,
  name              TEXT,
  profile_image_url TEXT,
  user_type         TEXT NOT NULL DEFAULT 'customer'
                    CHECK (user_type IN ('customer', 'winga', 'admin')),
  is_verified       BOOLEAN NOT NULL DEFAULT FALSE,
  fcm_token         TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── User Credentials (bypass auth — dev & production OTP alternative) ─────
CREATE TABLE IF NOT EXISTS public.user_credentials (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  phone         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Winga Verification Fee Tiers ──────────────────────────────────────────
-- Starter: TZS 5,000/month  — basic listing
-- Mid:     TZS 15,000/month — priority listing + badge
-- Verified:TZS 30,000/month — top listing + gold badge + featured

CREATE TABLE IF NOT EXISTS public.verification_tiers (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT UNIQUE NOT NULL CHECK (name IN ('Starter', 'Mid', 'Verified')),
  monthly_fee  INT NOT NULL,
  description  TEXT NOT NULL,
  features     JSONB NOT NULL DEFAULT '[]',
  badge_color  TEXT NOT NULL,
  sort_order   INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed tiers
INSERT INTO public.verification_tiers (name, monthly_fee, description, badge_color, sort_order, features) VALUES
  ('Starter',  5000,  'Basic verified listing on Winga platform',
   '#CD7F32',  1,
   '["Verified badge","Listed on platform","Basic profile","Customer requests"]'::jsonb),
  ('Mid',      15000, 'Priority listing with enhanced visibility',
   '#C0C0C0',  2,
   '["Mid badge","Priority search listing","Enhanced profile","Analytics dashboard","Priority support"]'::jsonb),
  ('Verified', 30000, 'Top-tier featured Winga with gold badge',
   '#F9A825',  3,
   '["Verified gold badge","Top search placement","Featured on home screen","Full analytics","Dedicated support","Marketing boost"]'::jsonb)
ON CONFLICT (name) DO NOTHING;

-- ── Wingas ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.wingas (
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
  national_id_doc_url TEXT,
  face_photo_url      TEXT,
  police_clearance_url TEXT,
  address_proof_url   TEXT,

  -- Verification
  verification_status TEXT NOT NULL DEFAULT 'unverified'
                      CHECK (verification_status IN (
                        'unverified','documents_submitted','payment_pending',
                        'under_review','verified','suspended','rejected'
                      )),
  verification_tier   TEXT CHECK (verification_tier IN ('Starter','Mid','Verified')),
  tier_id             UUID REFERENCES public.verification_tiers(id),
  verified_at         TIMESTAMPTZ,
  verified_by         UUID REFERENCES public.users(id),
  verification_notes  TEXT,
  rejection_reason    TEXT,

  -- Badge
  badge               TEXT NOT NULL DEFAULT 'none'
                      CHECK (badge IN ('none','Starter','Mid','Verified')),
  badge_assigned_at   TIMESTAMPTZ,
  badge_assigned_by   UUID REFERENCES public.users(id),
  badge_expires_at    TIMESTAMPTZ,

  -- Subscription
  subscription_active    BOOLEAN NOT NULL DEFAULT FALSE,
  subscription_start     TIMESTAMPTZ,
  subscription_end       TIMESTAMPTZ,
  last_payment_date      TIMESTAMPTZ,
  last_payment_amount    INT,
  next_payment_due       TIMESTAMPTZ,

  -- Stats
  rating              NUMERIC(3,2) NOT NULL DEFAULT 5.00,
  total_trips         INT NOT NULL DEFAULT 0,
  completion_rate     NUMERIC(5,2) NOT NULL DEFAULT 100.00,
  total_earnings      INT NOT NULL DEFAULT 0,

  -- Status
  is_online           BOOLEAN NOT NULL DEFAULT FALSE,
  status              TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('active','inactive','suspended','pending')),

  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Verification Payments ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.verification_payments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  winga_id        UUID NOT NULL REFERENCES public.wingas(id) ON DELETE CASCADE,
  tier_id         UUID NOT NULL REFERENCES public.verification_tiers(id),
  amount          INT NOT NULL,
  payment_method  TEXT NOT NULL CHECK (payment_method IN ('mpesa','airtel','tigo','halopesa','card')),
  mobile_number   TEXT,
  provider_ref    TEXT,
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','success','failed','refunded')),
  paid_at         TIMESTAMPTZ,
  month_covered   DATE NOT NULL DEFAULT DATE_TRUNC('month', NOW()),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Winga Documents (submitted for verification) ──────────────────────────
CREATE TABLE IF NOT EXISTS public.winga_documents (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  winga_id      UUID NOT NULL REFERENCES public.wingas(id) ON DELETE CASCADE,
  doc_type      TEXT NOT NULL CHECK (doc_type IN (
                  'national_id','face_photo','police_clearance',
                  'address_proof','business_license','other'
                )),
  file_url      TEXT NOT NULL,
  file_name     TEXT,
  status        TEXT NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','approved','rejected')),
  reviewed_by   UUID REFERENCES public.users(id),
  reviewed_at   TIMESTAMPTZ,
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Requests ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.requests (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id     UUID NOT NULL REFERENCES public.users(id),
  winga_id        UUID REFERENCES public.wingas(id),
  category        TEXT NOT NULL,
  meeting_point   TEXT NOT NULL,
  shopping_area   TEXT NOT NULL DEFAULT 'Kariakoo Market',
  service_type    TEXT NOT NULL DEFAULT 'hourly'
                  CHECK (service_type IN ('hourly','half_day','full_day','custom')),
  delivery_method TEXT NOT NULL DEFAULT 'with_client'
                  CHECK (delivery_method IN ('with_client','deliver','pickup')),
  estimated_price INT NOT NULL,
  final_price     INT,
  status          TEXT NOT NULL DEFAULT 'searching'
                  CHECK (status IN ('searching','accepted','shopping','completed','cancelled')),
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at     TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  cancelled_at    TIMESTAMPTZ,
  cancel_reason   TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Transactions ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id      UUID NOT NULL REFERENCES public.requests(id),
  winga_id        UUID NOT NULL REFERENCES public.wingas(id),
  customer_id     UUID NOT NULL REFERENCES public.users(id),
  gross_amount    INT NOT NULL,
  platform_fee    INT NOT NULL,
  winga_payout    INT NOT NULL,
  tax             INT NOT NULL,
  payment_method  TEXT NOT NULL
                  CHECK (payment_method IN ('mpesa','airtel','tigo','halopesa','wallet','card','bank')),
  mobile_number   TEXT,
  provider_ref    TEXT,
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('success','pending','failed','refunded')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Reviews ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reviews (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id  UUID NOT NULL REFERENCES public.requests(id),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  winga_id    UUID NOT NULL REFERENCES public.wingas(id),
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Notifications ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT NOT NULL DEFAULT 'info'
              CHECK (type IN ('info','success','warning','error','request','payment','verification')),
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  data        JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Admin Audit Log ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id    UUID NOT NULL REFERENCES public.users(id),
  action      TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id   UUID NOT NULL,
  details     JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_wingas_status          ON public.wingas(status);
CREATE INDEX IF NOT EXISTS idx_wingas_verification    ON public.wingas(verification_status);
CREATE INDEX IF NOT EXISTS idx_wingas_badge           ON public.wingas(badge);
CREATE INDEX IF NOT EXISTS idx_wingas_online          ON public.wingas(is_online);
CREATE INDEX IF NOT EXISTS idx_requests_customer      ON public.requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_requests_winga         ON public.requests(winga_id);
CREATE INDEX IF NOT EXISTS idx_requests_status        ON public.requests(status);
CREATE INDEX IF NOT EXISTS idx_transactions_winga     ON public.transactions(winga_id);
CREATE INDEX IF NOT EXISTS idx_ver_payments_winga     ON public.verification_payments(winga_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user     ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_winga_docs_winga       ON public.winga_documents(winga_id);
-- ============================================================
-- Winga App — Migration 002: RLS Policies
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_credentials    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wingas              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_tiers  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.winga_documents     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_log     ENABLE ROW LEVEL SECURITY;

-- ── Helper: is current user an admin ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND user_type = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ── Users ─────────────────────────────────────────────────────────────────
CREATE POLICY "users_own_read"   ON public.users FOR SELECT USING (auth.uid() = id OR public.is_admin());
CREATE POLICY "users_own_update" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "users_insert"     ON public.users FOR INSERT WITH CHECK (true); -- registration
CREATE POLICY "admin_all_users"  ON public.users FOR ALL USING (public.is_admin());

-- ── Verification Tiers (public read) ─────────────────────────────────────
CREATE POLICY "tiers_public_read" ON public.verification_tiers FOR SELECT USING (true);
CREATE POLICY "tiers_admin_write" ON public.verification_tiers FOR ALL USING (public.is_admin());

-- ── Wingas ────────────────────────────────────────────────────────────────
-- Public can see active verified wingas
CREATE POLICY "wingas_public_active" ON public.wingas
  FOR SELECT USING (status = 'active' AND verification_status = 'verified');

-- Winga sees own profile
CREATE POLICY "wingas_own" ON public.wingas
  FOR ALL USING (auth.uid() = user_id);

-- Admin sees all
CREATE POLICY "wingas_admin_all" ON public.wingas
  FOR ALL USING (public.is_admin());

-- Insert for registration
CREATE POLICY "wingas_insert" ON public.wingas
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ── Verification Payments ─────────────────────────────────────────────────
CREATE POLICY "ver_payments_own" ON public.verification_payments
  FOR SELECT USING (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );
CREATE POLICY "ver_payments_insert" ON public.verification_payments
  FOR INSERT WITH CHECK (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );
CREATE POLICY "ver_payments_admin" ON public.verification_payments
  FOR ALL USING (public.is_admin());

-- ── Winga Documents ───────────────────────────────────────────────────────
CREATE POLICY "docs_own" ON public.winga_documents
  FOR ALL USING (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );
CREATE POLICY "docs_admin" ON public.winga_documents
  FOR ALL USING (public.is_admin());

-- ── Requests ──────────────────────────────────────────────────────────────
CREATE POLICY "requests_customer_own" ON public.requests
  FOR ALL USING (auth.uid() = customer_id);

CREATE POLICY "requests_winga_assigned" ON public.requests
  FOR SELECT USING (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );

CREATE POLICY "requests_winga_searching" ON public.requests
  FOR SELECT USING (status = 'searching');

CREATE POLICY "requests_winga_update" ON public.requests
  FOR UPDATE USING (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );

CREATE POLICY "requests_admin" ON public.requests
  FOR ALL USING (public.is_admin());

-- ── Transactions ──────────────────────────────────────────────────────────
CREATE POLICY "tx_customer" ON public.transactions
  FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "tx_winga" ON public.transactions
  FOR SELECT USING (
    winga_id IN (SELECT id FROM public.wingas WHERE user_id = auth.uid())
  );
CREATE POLICY "tx_admin" ON public.transactions
  FOR ALL USING (public.is_admin());

-- ── Reviews ───────────────────────────────────────────────────────────────
CREATE POLICY "reviews_public_read"  ON public.reviews FOR SELECT USING (true);
CREATE POLICY "reviews_customer_own" ON public.reviews
  FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "reviews_admin" ON public.reviews FOR ALL USING (public.is_admin());

-- ── Notifications ─────────────────────────────────────────────────────────
CREATE POLICY "notifs_own" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);

-- ── Admin Audit Log ───────────────────────────────────────────────────────
CREATE POLICY "audit_admin_only" ON public.admin_audit_log
  FOR ALL USING (public.is_admin());

-- Grant execute to anon/authenticated
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;
-- ============================================================
-- Winga App — Migration 003: Triggers & DB Functions
-- ============================================================

-- ── Auto-generate Winga ID (WNGA00001) ───────────────────────────────────
CREATE SEQUENCE IF NOT EXISTS winga_id_seq START 10001;

CREATE OR REPLACE FUNCTION public.generate_winga_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.winga_id IS NULL OR NEW.winga_id = '' THEN
    NEW.winga_id = 'WNGA' || LPAD(nextval('winga_id_seq')::TEXT, 5, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_winga_id ON public.wingas;
CREATE TRIGGER set_winga_id
  BEFORE INSERT ON public.wingas
  FOR EACH ROW EXECUTE FUNCTION public.generate_winga_id();

-- ── Auto-update updated_at ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at_users ON public.users;
CREATE TRIGGER set_updated_at_users
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_wingas ON public.wingas;
CREATE TRIGGER set_updated_at_wingas
  BEFORE UPDATE ON public.wingas
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_requests ON public.requests;
CREATE TRIGGER set_updated_at_requests
  BEFORE UPDATE ON public.requests
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Recalculate Winga rating after review ────────────────────────────────
CREATE OR REPLACE FUNCTION public.update_winga_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.wingas
  SET rating = (
    SELECT ROUND(AVG(rating)::NUMERIC, 2)
    FROM public.reviews WHERE winga_id = NEW.winga_id
  ),
  total_trips = (
    SELECT COUNT(*) FROM public.requests
    WHERE winga_id = NEW.winga_id AND status = 'completed'
  ),
  completion_rate = (
    SELECT ROUND(
      COUNT(*) FILTER (WHERE status = 'completed') * 100.0 /
      NULLIF(COUNT(*) FILTER (WHERE status IN ('completed','cancelled')), 0),
      2
    )
    FROM public.requests WHERE winga_id = NEW.winga_id
  )
  WHERE id = NEW.winga_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS recalculate_winga_rating ON public.reviews;
CREATE TRIGGER recalculate_winga_rating
  AFTER INSERT OR UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_winga_rating();

-- ── Check & expire subscriptions daily ───────────────────────────────────
CREATE OR REPLACE FUNCTION public.expire_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE public.wingas
  SET
    subscription_active = FALSE,
    badge = 'none',
    verification_status = CASE
      WHEN verification_status = 'verified' THEN 'suspended'
      ELSE verification_status
    END,
    status = CASE
      WHEN status = 'active' THEN 'inactive'
      ELSE status
    END
  WHERE
    subscription_active = TRUE
    AND subscription_end < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── RPC: Admin verify winga ───────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.admin_verify_winga(
  p_winga_id     UUID,
  p_tier         TEXT,   -- 'Starter' | 'Mid' | 'Verified'
  p_notes        TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_admin_id UUID;
  v_tier_id  UUID;
  v_winga    RECORD;
BEGIN
  -- Must be admin
  v_admin_id := auth.uid();
  IF NOT public.is_admin() THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unauthorized — admin only');
  END IF;

  -- Get tier
  SELECT id INTO v_tier_id FROM public.verification_tiers WHERE name = p_tier;
  IF v_tier_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid tier: ' || p_tier);
  END IF;

  -- Get winga
  SELECT * INTO v_winga FROM public.wingas WHERE id = p_winga_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Winga not found');
  END IF;

  -- Update winga
  UPDATE public.wingas SET
    verification_status  = 'verified',
    verification_tier    = p_tier,
    tier_id              = v_tier_id,
    badge                = p_tier,
    verified_at          = NOW(),
    verified_by          = v_admin_id,
    verification_notes   = p_notes,
    status               = 'active',
    badge_assigned_at    = NOW(),
    badge_assigned_by    = v_admin_id,
    badge_expires_at     = NOW() + INTERVAL '30 days'
  WHERE id = p_winga_id;

  -- Also mark user as verified
  UPDATE public.users SET is_verified = TRUE
  WHERE id = v_winga.user_id;

  -- Log admin action
  INSERT INTO public.admin_audit_log (admin_id, action, target_type, target_id, details)
  VALUES (v_admin_id, 'verify_winga', 'winga', p_winga_id,
    jsonb_build_object('tier', p_tier, 'notes', p_notes));

  -- Notify winga
  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES (
    v_winga.user_id,
    '🎉 Hongera! Umeidhinishwa kama Winga',
    'Akaunti yako imeidhinishwa kama ' || p_tier || ' Winga. Sasa unaweza kupokea maombi!',
    'verification',
    jsonb_build_object('tier', p_tier, 'winga_id', p_winga_id)
  );

  RETURN jsonb_build_object('success', true, 'tier', p_tier, 'winga_id', p_winga_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── RPC: Admin reject winga ───────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.admin_reject_winga(
  p_winga_id UUID,
  p_reason   TEXT
)
RETURNS JSONB AS $$
DECLARE
  v_winga RECORD;
BEGIN
  IF NOT public.is_admin() THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
  END IF;

  SELECT * INTO v_winga FROM public.wingas WHERE id = p_winga_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Winga not found');
  END IF;

  UPDATE public.wingas SET
    verification_status = 'rejected',
    rejection_reason    = p_reason,
    badge               = 'none'
  WHERE id = p_winga_id;

  INSERT INTO public.admin_audit_log (admin_id, action, target_type, target_id, details)
  VALUES (auth.uid(), 'reject_winga', 'winga', p_winga_id,
    jsonb_build_object('reason', p_reason));

  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES (
    v_winga.user_id,
    'Maombi ya Uthibitisho Yamekataliwa',
    'Ombi lako la uthibitisho limekataliwa. Sababu: ' || p_reason || '. Tafadhali wasiliana nasi.',
    'verification',
    jsonb_build_object('reason', p_reason)
  );

  RETURN jsonb_build_object('success', true, 'winga_id', p_winga_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── RPC: Admin assign / change badge ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.admin_assign_badge(
  p_winga_id UUID,
  p_badge    TEXT   -- 'Starter' | 'Mid' | 'Verified'
)
RETURNS JSONB AS $$
DECLARE
  v_winga RECORD;
BEGIN
  IF NOT public.is_admin() THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
  END IF;

  IF p_badge NOT IN ('Starter', 'Mid', 'Verified') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid badge. Use: Starter, Mid, Verified');
  END IF;

  SELECT * INTO v_winga FROM public.wingas WHERE id = p_winga_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Winga not found');
  END IF;

  UPDATE public.wingas SET
    badge             = p_badge,
    badge_assigned_at = NOW(),
    badge_assigned_by = auth.uid(),
    badge_expires_at  = NOW() + INTERVAL '30 days'
  WHERE id = p_winga_id;

  INSERT INTO public.admin_audit_log (admin_id, action, target_type, target_id, details)
  VALUES (auth.uid(), 'assign_badge', 'winga', p_winga_id,
    jsonb_build_object('badge', p_badge, 'previous_badge', v_winga.badge));

  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES (
    v_winga.user_id,
    'Badge Yako Imesasishwa — ' || p_badge,
    'Hongera! Umepewa badge ya ' || p_badge || ' kwenye Winga App.',
    'verification',
    jsonb_build_object('badge', p_badge)
  );

  RETURN jsonb_build_object('success', true, 'badge', p_badge, 'winga_id', p_winga_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── RPC: Confirm verification payment ────────────────────────────────────
CREATE OR REPLACE FUNCTION public.confirm_verification_payment(
  p_winga_id       UUID,
  p_tier_name      TEXT,
  p_payment_method TEXT,
  p_mobile_number  TEXT DEFAULT NULL,
  p_provider_ref   TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_tier      RECORD;
  v_winga     RECORD;
  v_payment   UUID;
BEGIN
  SELECT * INTO v_tier FROM public.verification_tiers WHERE name = p_tier_name;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid tier');
  END IF;

  SELECT * INTO v_winga FROM public.wingas WHERE id = p_winga_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Winga not found');
  END IF;

  -- Record payment
  INSERT INTO public.verification_payments
    (winga_id, tier_id, amount, payment_method, mobile_number, provider_ref, status, paid_at)
  VALUES
    (p_winga_id, v_tier.id, v_tier.monthly_fee, p_payment_method, p_mobile_number, p_provider_ref, 'success', NOW())
  RETURNING id INTO v_payment;

  -- Update winga subscription & set to under_review
  UPDATE public.wingas SET
    verification_status  = 'under_review',
    verification_tier    = p_tier_name,
    tier_id              = v_tier.id,
    subscription_active  = TRUE,
    subscription_start   = NOW(),
    subscription_end     = NOW() + INTERVAL '30 days',
    next_payment_due     = NOW() + INTERVAL '30 days',
    last_payment_date    = NOW(),
    last_payment_amount  = v_tier.monthly_fee
  WHERE id = p_winga_id;

  -- Notify winga
  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES (
    v_winga.user_id,
    'Malipo Yamefanikiwa ✓',
    'Malipo ya TZS ' || v_tier.monthly_fee || ' kwa tier ya ' || p_tier_name || ' yamefanikiwa. Akaunti yako iko chini ya ukaguzi.',
    'payment',
    jsonb_build_object('tier', p_tier_name, 'amount', v_tier.monthly_fee, 'payment_id', v_payment)
  );

  -- Notify admin
  INSERT INTO public.notifications (user_id, title, body, type, data)
  SELECT id, 
    'Winga Amewasilisha Malipo — ' || v_winga.name,
    p_tier_name || ' tier · TZS ' || v_tier.monthly_fee || ' · Anahitaji uthibitisho',
    'verification',
    jsonb_build_object('winga_id', p_winga_id, 'tier', p_tier_name, 'payment_id', v_payment)
  FROM public.users WHERE user_type = 'admin';

  RETURN jsonb_build_object(
    'success', true,
    'payment_id', v_payment,
    'tier', p_tier_name,
    'amount', v_tier.monthly_fee,
    'status', 'under_review'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.admin_verify_winga(UUID, TEXT, TEXT)    TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_reject_winga(UUID, TEXT)           TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_assign_badge(UUID, TEXT)           TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_verification_payment(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.expire_subscriptions()                   TO service_role;
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
-- Drop views first (safe re-run)
DROP VIEW IF EXISTS public.v_dashboard_stats CASCADE;
DROP VIEW IF EXISTS public.v_pending_verifications CASCADE;
DROP VIEW IF EXISTS public.v_earnings_summary CASCADE;
DROP VIEW IF EXISTS public.v_winga_leaderboard CASCADE;
DROP VIEW IF EXISTS public.v_recent_activity CASCADE;

-- ============================================================
-- Winga App — Migration 005: Admin Views & Helper Queries
-- For use in Admin Panel (Next.js)
-- ============================================================

-- ── Dashboard Stats View ──────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.v_dashboard_stats AS
SELECT
  (SELECT COUNT(*) FROM public.requests)                                          AS total_requests,
  (SELECT COUNT(*) FROM public.requests WHERE status = 'completed')               AS completed_requests,
  (SELECT COUNT(*) FROM public.requests WHERE status IN ('accepted','shopping'))   AS in_progress,
  (SELECT COUNT(*) FROM public.requests WHERE status = 'cancelled')               AS cancelled,
  (SELECT COUNT(*) FROM public.wingas WHERE status = 'active')                    AS active_wingas,
  (SELECT COUNT(*) FROM public.users WHERE user_type = 'customer')                AS total_clients,
  (SELECT COUNT(*) FROM public.wingas WHERE verification_status = 'under_review') AS pending_verifications,
  (SELECT COALESCE(SUM(winga_payout), 0) FROM public.transactions WHERE status = 'success') AS total_earnings,
  (SELECT COALESCE(SUM(tax), 0) FROM public.transactions WHERE status = 'success')          AS total_tax_collected,
  (SELECT COUNT(*) FROM public.wingas WHERE badge = 'Verified')  AS verified_wingas,
  (SELECT COUNT(*) FROM public.wingas WHERE badge = 'Mid')       AS mid_wingas,
  (SELECT COUNT(*) FROM public.wingas WHERE badge = 'Starter')   AS starter_wingas;

GRANT SELECT ON public.v_dashboard_stats TO authenticated, service_role;

-- ── Pending Verifications View ────────────────────────────────────────────
CREATE OR REPLACE VIEW public.v_pending_verifications AS
SELECT
  w.id,
  w.winga_id,
  w.name,
  w.phone,
  w.email,
  w.specialty,
  w.home_location,
  w.verification_status,
  w.verification_tier,
  w.badge,
  w.created_at,
  vp.amount       AS payment_amount,
  vp.payment_method,
  vp.paid_at,
  vt.name         AS tier_requested,
  vt.monthly_fee  AS tier_fee,
  (SELECT COUNT(*) FROM public.winga_documents wd WHERE wd.winga_id = w.id) AS doc_count,
  (SELECT COUNT(*) FROM public.winga_documents wd WHERE wd.winga_id = w.id AND wd.status = 'approved') AS approved_docs
FROM public.wingas w
LEFT JOIN public.verification_payments vp ON vp.winga_id = w.id AND vp.status = 'success'
  AND vp.paid_at = (SELECT MAX(paid_at) FROM public.verification_payments WHERE winga_id = w.id AND status = 'success')
LEFT JOIN public.verification_tiers vt ON vt.id = vp.tier_id
WHERE w.verification_status IN ('documents_submitted','payment_pending','under_review')
ORDER BY w.created_at ASC;

GRANT SELECT ON public.v_pending_verifications TO authenticated, service_role;

-- ── Earnings Summary View ─────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.v_earnings_summary AS
SELECT
  DATE_TRUNC('day', created_at)   AS day,
  DATE_TRUNC('week', created_at)  AS week,
  DATE_TRUNC('month', created_at) AS month,
  SUM(gross_amount)               AS gross,
  SUM(platform_fee)               AS platform_fee,
  SUM(winga_payout)               AS winga_payout,
  SUM(tax)                        AS tax,
  COUNT(*)                        AS transaction_count
FROM public.transactions
WHERE status = 'success'
GROUP BY 1, 2, 3
ORDER BY 1 DESC;

GRANT SELECT ON public.v_earnings_summary TO authenticated, service_role;

-- ── Winga Leaderboard View ────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.v_winga_leaderboard AS
SELECT
  w.id,
  w.winga_id,
  w.name,
  w.specialty,
  w.badge,
  w.rating,
  w.total_trips,
  w.completion_rate,
  w.total_earnings,
  w.status,
  w.is_online,
  RANK() OVER (ORDER BY w.total_earnings DESC) AS earnings_rank,
  RANK() OVER (ORDER BY w.rating DESC, w.total_trips DESC) AS rating_rank
FROM public.wingas w
WHERE w.status = 'active'
ORDER BY w.total_earnings DESC;

GRANT SELECT ON public.v_winga_leaderboard TO authenticated, service_role;

-- ── Recent Activity View (for admin dashboard feed) ───────────────────────
CREATE OR REPLACE VIEW public.v_recent_activity AS
  SELECT 'request' AS type, r.id, r.created_at,
    u.name AS actor, r.category AS detail, r.status
  FROM public.requests r
  JOIN public.users u ON u.id = r.customer_id
UNION ALL
  SELECT 'payment', p.id, p.created_at,
    w.name AS actor, vt.name AS detail, p.status
  FROM public.verification_payments p
  JOIN public.wingas w ON w.id = p.winga_id
  JOIN public.verification_tiers vt ON vt.id = p.tier_id
UNION ALL
  SELECT 'transaction', t.id, t.created_at,
    u.name AS actor, 'TZS ' || t.gross_amount::TEXT AS detail, t.status
  FROM public.transactions t
  JOIN public.users u ON u.id = t.customer_id
ORDER BY created_at DESC
LIMIT 50;

GRANT SELECT ON public.v_recent_activity TO authenticated, service_role;

-- ── RPC: Get dashboard stats (safe for anon with RLS) ─────────────────────
CREATE OR REPLACE FUNCTION public.get_dashboard_stats()
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_requests',         (SELECT COUNT(*) FROM public.requests),
    'completed_requests',     (SELECT COUNT(*) FROM public.requests WHERE status = 'completed'),
    'in_progress',            (SELECT COUNT(*) FROM public.requests WHERE status IN ('accepted','shopping')),
    'cancelled',              (SELECT COUNT(*) FROM public.requests WHERE status = 'cancelled'),
    'active_wingas',          (SELECT COUNT(*) FROM public.wingas WHERE status = 'active'),
    'total_clients',          (SELECT COUNT(*) FROM public.users WHERE user_type = 'customer'),
    'pending_verifications',  (SELECT COUNT(*) FROM public.wingas WHERE verification_status = 'under_review'),
    'total_earnings',         (SELECT COALESCE(SUM(winga_payout),0) FROM public.transactions WHERE status = 'success'),
    'total_tax',              (SELECT COALESCE(SUM(tax),0) FROM public.transactions WHERE status = 'success'),
    'verified_wingas',        (SELECT COUNT(*) FROM public.wingas WHERE badge = 'Verified'),
    'mid_wingas',             (SELECT COUNT(*) FROM public.wingas WHERE badge = 'Mid'),
    'starter_wingas',         (SELECT COUNT(*) FROM public.wingas WHERE badge = 'Starter'),
    'new_wingas_this_week',   (SELECT COUNT(*) FROM public.wingas WHERE created_at >= NOW() - INTERVAL '7 days'),
    'new_clients_this_week',  (SELECT COUNT(*) FROM public.users WHERE user_type = 'customer' AND created_at >= NOW() - INTERVAL '7 days')
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_dashboard_stats() TO authenticated, service_role;
-- ============================================================
-- Winga App — Migration 006: Storage Buckets
-- For document uploads (Winga verification docs, profile photos)
-- ============================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('avatars',   'avatars',   true,  5242880,  -- 5MB
   ARRAY['image/jpeg','image/png','image/webp']),
  ('documents', 'documents', false, 10485760, -- 10MB (private)
   ARRAY['image/jpeg','image/png','image/pdf']),
  ('app-assets','app-assets', true,  5242880,
   ARRAY['image/jpeg','image/png','image/svg+xml','image/webp'])
ON CONFLICT (id) DO NOTHING;

-- ── Storage RLS Policies ──────────────────────────────────────────────────

-- Avatars: public read, owner write
CREATE POLICY "avatars_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "avatars_owner_upload"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "avatars_owner_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Documents: private — only owner and admin
CREATE POLICY "documents_owner_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'documents' AND (
    auth.uid()::text = (storage.foldername(name))[1]
    OR public.is_admin()
  ));

CREATE POLICY "documents_owner_upload"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);

-- App assets: public read, admin write
CREATE POLICY "app_assets_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'app-assets');

CREATE POLICY "app_assets_admin_write"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'app-assets' AND public.is_admin());
