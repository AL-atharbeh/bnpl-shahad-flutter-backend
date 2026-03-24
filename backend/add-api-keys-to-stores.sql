-- Add API authentication fields to stores table
ALTER TABLE stores
ADD COLUMN api_key VARCHAR(64) UNIQUE NULL,
ADD COLUMN api_secret VARCHAR(128) NULL,
ADD COLUMN webhook_url TEXT NULL,
ADD COLUMN is_api_enabled BOOLEAN DEFAULT FALSE,
ADD COLUMN api_created_at TIMESTAMP NULL;

CREATE INDEX idx_api_key ON stores(api_key);
