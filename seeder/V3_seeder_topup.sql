INSERT INTO topup_read.wallet_status_projection (wallet_id, status, updated_at)
VALUES
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'ACTIVE',    now()),
  ('bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'SUSPENDED', now())
ON CONFLICT (wallet_id) DO UPDATE
SET status = EXCLUDED.status,
    updated_at = EXCLUDED.updated_at;

INSERT INTO topup_oltp.transactions (id, wallet_id, trx_id, type, amount, currency, status, initiated_by, created_at, updated_at)
VALUES
  ('33333333-3333-3333-3333-333333333331', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'TU-20251011-0001', 'TOPUP', 1500000.00, 'IDR', 'SUCCEEDED', '11111111-1111-1111-1111-111111111111', now() - interval '2 days', now() - interval '2 days'),
  ('33333333-3333-3333-3333-333333333332', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'TU-20251011-0002', 'TOPUP',  500000.00, 'IDR', 'PROCESSING','11111111-1111-1111-1111-111111111111', now() - interval '1 day',  now() - interval '12 hours')
ON CONFLICT (id) DO UPDATE
SET wallet_id = EXCLUDED.wallet_id,
    trx_id    = EXCLUDED.trx_id,
    type      = EXCLUDED.type,
    amount    = EXCLUDED.amount,
    currency  = EXCLUDED.currency,
    status    = EXCLUDED.status,
    initiated_by = EXCLUDED.initiated_by,
    created_at= EXCLUDED.created_at,
    updated_at= EXCLUDED.updated_at;

INSERT INTO topup_read.transactions (id, wallet_id, trx_id, type, amount, currency, status, initiated_by, created_at, updated_at)
SELECT id, wallet_id, trx_id, type, amount, currency, status, initiated_by, created_at, updated_at
FROM topup_oltp.transactions
ON CONFLICT (id) DO UPDATE
SET wallet_id = EXCLUDED.wallet_id,
    trx_id    = EXCLUDED.trx_id,
    type      = EXCLUDED.type,
    amount    = EXCLUDED.amount,
    currency  = EXCLUDED.currency,
    status    = EXCLUDED.status,
    initiated_by = EXCLUDED.initiated_by,
    created_at= EXCLUDED.created_at,
    updated_at= EXCLUDED.updated_at;
