-- Notices for merchants: review decisions, new sales and settlements.
-- Safe to run more than once.

CREATE TABLE IF NOT EXISTS vendor_notifications (
  id serial PRIMARY KEY,
  vendor_id integer NOT NULL,
  store_id integer,
  type varchar(50) NOT NULL,
  title varchar(255) NOT NULL,
  body text NOT NULL,
  title_en varchar(255) NOT NULL,
  body_en text NOT NULL,
  data jsonb,
  read_at timestamp,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "IDX_vendor_notifications_vendor_created"
  ON vendor_notifications (vendor_id, created_at);

SELECT count(*) AS vendor_notifications_ready
  FROM information_schema.tables WHERE table_name = 'vendor_notifications';
