CREATE SCHEMA IF NOT EXISTS topup_read;

CREATE TABLE IF NOT EXISTS topup_read.transactions (
  id UUID PRIMARY KEY,
  wallet_id UUID NOT NULL,
  trx_id VARCHAR NOT NULL,
  type tx_type NOT NULL,
  amount NUMERIC NOT NULL,
  currency VARCHAR NOT NULL DEFAULT 'IDR',
  status tx_status NOT NULL DEFAULT 'PENDING',
  initiated_by UUID,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);
