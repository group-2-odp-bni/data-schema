INSERT INTO transfer_read.wallet_status_projection (wallet_id, status, updated_at)
VALUES
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'ACTIVE',    now()),
  ('bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'SUSPENDED', now())
ON CONFLICT (wallet_id) DO UPDATE
SET status = EXCLUDED.status,
    updated_at = EXCLUDED.updated_at;

INSERT INTO transfer_oltp.transactions (id, wallet_id, trx_id, type, amount, currency, status, initiated_by, created_at, updated_at)
VALUES
  ('44444444-4444-4444-4444-444444444441', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'TR-20251011-0001', 'TRANSFER', 200000.00, 'IDR', 'SUCCEEDED', '11111111-1111-1111-1111-111111111111', now() - interval '18 hours', now() - interval '17 hours'),
  ('44444444-4444-4444-4444-444444444442', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'TR-20251011-0002', 'TRANSFER',  75000.00,  'IDR', 'PENDING',   '11111111-1111-1111-1111-111111111111', now() - interval '3 hours',  now() - interval '3 hours')
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

INSERT INTO transfer_read.transactions (id, wallet_id, trx_id, type, amount, currency, status, initiated_by, created_at, updated_at)
SELECT id, wallet_id, trx_id, type, amount, currency, status, initiated_by, created_at, updated_at
FROM transfer_oltp.transactions
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
