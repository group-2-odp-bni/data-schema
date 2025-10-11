CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS domain;
CREATE SCHEMA IF NOT EXISTS topup_oltp;

DO $$ BEGIN
  CREATE TYPE domain.tx_type AS ENUM ('TOPUP');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE domain.tx_status AS ENUM ('PENDING','PROCESSING','SUCCEEDED','FAILED','EXPIRED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE domain.wallet_status AS ENUM ('ACTIVE','SUSPENDED','CLOSED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION domain.set_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TABLE topup_oltp.transactions (
  id           UUID PRIMARY KEY               DEFAULT gen_random_uuid(),
  wallet_id    UUID                  NOT NULL,
  trx_id       VARCHAR               NOT NULL,
  type         domain.tx_type        NOT NULL DEFAULT 'TOPUP',
  amount       NUMERIC(20,2)         NOT NULL,
  currency     VARCHAR               NOT NULL DEFAULT 'IDR',
  status       domain.tx_status      NOT NULL DEFAULT 'PENDING',
  initiated_by UUID,
  created_at   TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ           NOT NULL DEFAULT now(),
  CONSTRAINT chk_topup_amount_positive CHECK (amount > 0)
);

CREATE UNIQUE INDEX uq_topup_trx_id     ON topup_oltp.transactions (trx_id);
CREATE INDEX        idx_topup_wallet_ts ON topup_oltp.transactions (wallet_id, created_at DESC);
CREATE INDEX        idx_topup_status_ts ON topup_oltp.transactions (status, created_at DESC);

CREATE TRIGGER trg_topup_tx_updated_at
BEFORE UPDATE ON topup_oltp.transactions
FOR EACH ROW EXECUTE FUNCTION domain.set_updated_at();

CREATE OR REPLACE FUNCTION topup_oltp.ensure_wallet_active() RETURNS trigger AS $$
DECLARE
  w_status domain.wallet_status;
BEGIN
  SELECT status INTO w_status
  FROM topup_read.wallet_status_projection
  WHERE wallet_id = NEW.wallet_id;

  IF w_status IS NULL THEN
    RAISE EXCEPTION 'Cannot create topup: wallet % status unknown (projection missing)', NEW.wallet_id
      USING ERRCODE = 'check_violation';
  END IF;
  IF w_status <> 'ACTIVE' THEN
    RAISE EXCEPTION 'Cannot create topup: wallet % is %', NEW.wallet_id, w_status
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_topup_guard_wallet_active ON topup_oltp.transactions;
CREATE TRIGGER trg_topup_guard_wallet_active
BEFORE INSERT ON topup_oltp.transactions
FOR EACH ROW EXECUTE FUNCTION topup_oltp.ensure_wallet_active();
