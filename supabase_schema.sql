-- ============================================================
-- CONSTRUCTION MANAGER — SUPABASE SCHEMA (COMPLETE RESET)
-- Run this ENTIRE script in Supabase → SQL Editor
-- ============================================================

-- ============================================================
-- STEP 1: DROP EXISTING TABLES (clean slate)
-- ============================================================
DROP TABLE IF EXISTS site_elevations      CASCADE;
DROP TABLE IF EXISTS site_floor_files     CASCADE;
DROP TABLE IF EXISTS site_agreements      CASCADE;
DROP TABLE IF EXISTS private_worker_payments CASCADE;
DROP TABLE IF EXISTS private_work         CASCADE;
DROP TABLE IF EXISTS private_workers      CASCADE;
DROP TABLE IF EXISTS attendance           CASCADE;
DROP TABLE IF EXISTS sites                CASCADE;
DROP TABLE IF EXISTS workers              CASCADE;

-- ============================================================
-- STEP 2: ENABLE UUID EXTENSION
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- STEP 3: GRANT SCHEMA USAGE TO ROLES (fixes permission errors)
-- ============================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- ============================================================
-- 1. WORKERS
-- ============================================================
CREATE TABLE workers (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  phone       TEXT NOT NULL DEFAULT '',
  gender      TEXT NOT NULL DEFAULT 'Male',
  state       TEXT NOT NULL DEFAULT 'Telangana',
  role        TEXT NOT NULL DEFAULT 'Mason',
  work_type   TEXT NOT NULL DEFAULT 'Centring',
  rate_6_6    NUMERIC(10,2) DEFAULT 0,
  rate_10_6   NUMERIC(10,2) DEFAULT 0,
  rate_6_10   NUMERIC(10,2) DEFAULT 0,
  rate_6_2    NUMERIC(10,2) DEFAULT 0,
  rate_10_2   NUMERIC(10,2) DEFAULT 0,
  rate_2_6    NUMERIC(10,2) DEFAULT 0,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.workers TO authenticated;
GRANT SELECT ON public.workers TO anon;
ALTER TABLE workers DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. ATTENDANCE
-- ============================================================
CREATE TABLE attendance (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id        UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
  site_id          UUID,
  date             TIMESTAMPTZ NOT NULL,
  date_key         TEXT NOT NULL,
  attendance_type  TEXT NOT NULL DEFAULT 'Absent',
  wage             NUMERIC(10,2) DEFAULT 0,
  advance          NUMERIC(10,2) DEFAULT 0,
  payment_mode     TEXT DEFAULT 'Cash',
  payment_ref      TEXT,
  balance_after    NUMERIC(10,2) DEFAULT 0,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX attendance_worker_date_idx ON attendance(worker_id, date_key);
GRANT ALL ON public.attendance TO authenticated;
GRANT SELECT ON public.attendance TO anon;
ALTER TABLE attendance DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 3. SITES
-- ============================================================
CREATE TABLE sites (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_name         TEXT NOT NULL,
  site_name_search  TEXT NOT NULL DEFAULT '',
  location          TEXT,
  owner_name        TEXT,
  owner_phone       TEXT,
  start_date        TEXT,
  budget            NUMERIC(14,2) DEFAULT 0,
  floors_count      INT DEFAULT 1,
  status            TEXT DEFAULT 'Active',
  notes             TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.sites TO authenticated;
GRANT SELECT ON public.sites TO anon;
ALTER TABLE sites DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 4. PRIVATE WORKERS
-- ============================================================
CREATE TABLE private_workers (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  work_type   TEXT NOT NULL DEFAULT '',
  phone       TEXT NOT NULL DEFAULT '',
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.private_workers TO authenticated;
GRANT SELECT ON public.private_workers TO anon;
ALTER TABLE private_workers DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 5. PRIVATE WORK
-- ============================================================
CREATE TABLE private_work (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id      UUID NOT NULL REFERENCES private_workers(id) ON DELETE CASCADE,
  worker_name    TEXT NOT NULL DEFAULT '',
  work_type      TEXT NOT NULL DEFAULT '',
  site_id        UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  site_name      TEXT NOT NULL DEFAULT '',
  work_date      TEXT NOT NULL,
  price_charged  NUMERIC(10,2) DEFAULT 0,
  amount_paid    NUMERIC(10,2) DEFAULT 0,
  status         TEXT DEFAULT 'Active',
  notes          TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.private_work TO authenticated;
GRANT SELECT ON public.private_work TO anon;
ALTER TABLE private_work DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 6. PRIVATE WORKER PAYMENTS
-- ============================================================
CREATE TABLE private_worker_payments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id   UUID NOT NULL REFERENCES private_workers(id) ON DELETE CASCADE,
  amount      NUMERIC(10,2) NOT NULL DEFAULT 0,
  direction   TEXT NOT NULL DEFAULT 'dad_to_worker',
  mode        TEXT NOT NULL DEFAULT 'Cash',
  date        TEXT NOT NULL,
  notes       TEXT,
  source      TEXT DEFAULT 'manual',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.private_worker_payments TO authenticated;
GRANT SELECT ON public.private_worker_payments TO anon;
ALTER TABLE private_worker_payments DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 7. SITE AGREEMENTS
-- ============================================================
CREATE TABLE site_agreements (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id     UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  file_path   TEXT NOT NULL DEFAULT '',
  file_name   TEXT NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.site_agreements TO authenticated;
GRANT SELECT ON public.site_agreements TO anon;
ALTER TABLE site_agreements DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 8. SITE FLOOR FILES
-- ============================================================
CREATE TABLE site_floor_files (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id      UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  floor_no     INT NOT NULL DEFAULT 0,
  file_name    TEXT NOT NULL DEFAULT '',
  file_path    TEXT NOT NULL DEFAULT '',
  uploaded_at  TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.site_floor_files TO authenticated;
GRANT SELECT ON public.site_floor_files TO anon;
ALTER TABLE site_floor_files DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- 9. SITE ELEVATIONS
-- ============================================================
CREATE TABLE site_elevations (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id     UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  file_name   TEXT NOT NULL DEFAULT '',
  file_path   TEXT NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
GRANT ALL ON public.site_elevations TO authenticated;
GRANT SELECT ON public.site_elevations TO anon;
ALTER TABLE site_elevations DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 4: GRANT ON SEQUENCES
-- ============================================================
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================================
-- STEP 5: STORAGE BUCKET
-- Run this separately if needed (or create via Supabase UI)
-- Bucket name: construction-files  (set to Public)
-- ============================================================
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('construction-files', 'construction-files', true)
-- ON CONFLICT (id) DO NOTHING;
