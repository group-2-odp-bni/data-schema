CREATE SCHEMA IF NOT EXISTS auth_read;

CREATE MATERIALIZED VIEW IF NOT EXISTS auth_read.user_summary AS
SELECT
  status,
  count(*) AS total_users,
  max(updated_at) AS last_update
FROM auth_oltp.users
GROUP BY status;

CREATE VIEW IF NOT EXISTS auth_read.user_lookup AS
SELECT id, email, phone, name, status FROM auth_oltp.users;
