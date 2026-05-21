-- ============================================================
-- CONSTRUCTION MANAGER — SUPABASE SCHEMA
-- Run this in your Supabase project → SQL Editor
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. WORKERS
-- ============================================================
CREATE TABLE IF NOT EXISTS workers (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  phone       TEXT NOT NULL,
  gender      TEXT NOT NULL,
  state       TEXT NOT NULL,
  role        TEXT NOT NULL,
  work_type   TEXT NOT NULL,
  rate_6_6    NUMERIC(10,2) DEFAULT 0,
  rate_10_6   NUMERIC(10,2) DEFAULT 0,
  rate_6_10   NUMERIC(10,2) DEFAULT 0,
  rate_6_2    NUMERIC(10,2) DEFAULT 0,
  rate_10_2   NUMERIC(10,2) DEFAULT 0,
  rate_2_6    NUMERIC(10,2) DEFAULT 0,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage workers"
  ON workers FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 2. ATTENDANCE
-- ============================================================
CREATE TABLE IF NOT EXISTS attendance (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id        UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
  site_id          UUID,
  date             TIMESTAMPTZ NOT NULL,
  date_key         TEXT NOT NULL,
  attendance_type  TEXT NOT NULL,
  wage             NUMERIC(10,2) DEFAULT 0,
  advance          NUMERIC(10,2) DEFAULT 0,
  payment_mode     TEXT DEFAULT 'Cash',
  payment_ref      TEXT,
  balance_after    NUMERIC(10,2) DEFAULT 0,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS attendance_worker_date ON attendance(worker_id, date_key);

ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage attendance"
  ON attendance FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 3. SITES
-- ============================================================
CREATE TABLE IF NOT EXISTS sites (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_name         TEXT NOT NULL,
  site_name_search  TEXT NOT NULL,
  location          TEXT,
  owner_name        TEXT,
  owner_phone       TEXT,
  start_date        TEXT,
  budget            NUMERIC(12,2) DEFAULT 0,
  floors_count      INT DEFAULT 1,
  status            TEXT DEFAULT 'Active',
  notes             TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage sites"
  ON sites FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 4. PRIVATE WORKERS
-- ============================================================
CREATE TABLE IF NOT EXISTS private_workers (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  work_type   TEXT NOT NULL,
  phone       TEXT NOT NULL,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE private_workers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage private_workers"
  ON private_workers FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 5. PRIVATE WORK
-- ============================================================
CREATE TABLE IF NOT EXISTS private_work (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id      UUID NOT NULL REFERENCES private_workers(id) ON DELETE CASCADE,
  worker_name    TEXT NOT NULL,
  work_type      TEXT NOT NULL,
  site_id        UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  site_name      TEXT NOT NULL,
  work_date      TEXT NOT NULL,
  price_charged  NUMERIC(10,2) DEFAULT 0,
  amount_paid    NUMERIC(10,2) DEFAULT 0,
  status         TEXT DEFAULT 'Active',
  notes          TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE private_work ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage private_work"
  ON private_work FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 6. PRIVATE WORKER PAYMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS private_worker_payments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id   UUID NOT NULL REFERENCES private_workers(id) ON DELETE CASCADE,
  amount      NUMERIC(10,2) NOT NULL,
  direction   TEXT NOT NULL,  -- 'dad_to_worker' or 'worker_to_dad'
  mode        TEXT NOT NULL,  -- 'Cash' or 'Online'
  date        TEXT NOT NULL,
  notes       TEXT,
  source      TEXT DEFAULT 'manual',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE private_worker_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage private_worker_payments"
  ON private_worker_payments FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 7. SITE AGREEMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS site_agreements (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id     UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  file_path   TEXT NOT NULL,
  file_name   TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE site_agreements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage site_agreements"
  ON site_agreements FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 8. SITE FLOOR FILES
-- ============================================================
CREATE TABLE IF NOT EXISTS site_floor_files (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id      UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  floor_no     INT NOT NULL,
  file_name    TEXT NOT NULL,
  file_path    TEXT NOT NULL,
  uploaded_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE site_floor_files ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage site_floor_files"
  ON site_floor_files FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 9. SITE ELEVATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS site_elevations (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id     UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  file_name   TEXT NOT NULL,
  file_path   TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE site_elevations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage site_elevations"
  ON site_elevations FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- STORAGE BUCKET  (run separately in Supabase Storage UI
--  OR uncomment below if using service_role key)
-- ============================================================
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('construction-files', 'construction-files', true)
-- ON CONFLICT DO NOTHING;

-- Storage policy example (run in SQL editor):
-- CREATE POLICY "Authenticated uploads"
--   ON storage.objects FOR INSERT
--   TO authenticated
--   WITH CHECK (bucket_id = 'construction-files');
--
-- CREATE POLICY "Public read"
--   ON storage.objects FOR SELECT
--   TO public
--   USING (bucket_id = 'construction-files');
--
-- CREATE POLICY "Authenticated delete"
--   ON storage.objects FOR DELETE
--   TO authenticated
--   USING (bucket_id = 'construction-files');
