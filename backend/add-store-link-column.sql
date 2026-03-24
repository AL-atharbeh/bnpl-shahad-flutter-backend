USE bnpl_db;

ALTER TABLE stores
  ADD COLUMN store_url TEXT NULL AFTER website_url;

UPDATE stores
SET store_url = website_url
WHERE (store_url IS NULL OR store_url = '')
  AND website_url IS NOT NULL;

