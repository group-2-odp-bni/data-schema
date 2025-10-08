CREATE SCHEMA IF NOT EXISTS auth_oltp;

DO $$ BEGIN
  CREATE TYPE auth_oltp.user_status AS ENUM ('ACTIVE', 'SUSPENDED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS auth_oltp.users (
  id UUID PRIMARY KEY,
  email VARCHAR(320) NOT NULL UNIQUE,
  nik VARCHAR(32) NOT NULL,
  phone VARCHAR(32),
  name VARCHAR(200),
  status auth_oltp.user_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS auth_oltp.otp_sessions (
  otp_id UUID PRIMARY KEY,
  phone_number VARCHAR(32) NOT NULL,
  otp_code VARCHAR(12) NOT NULL,
  purpose VARCHAR(64) NOT NULL,         
  expires_at TIMESTAMPTZ NOT NULL,
  is_used BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON auth_oltp.users (email);
CREATE INDEX IF NOT EXISTS idx_otp_phone_purpose ON auth_oltp.otp_sessions (phone_number, purpose);
