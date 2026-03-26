-- Add vendor_id, status, gender_category_id and store_url columns to stores table
ALTER TABLE stores ADD COLUMN vendor_id INT NULL;
ALTER TABLE stores ADD COLUMN status VARCHAR(20) DEFAULT 'approved';
ALTER TABLE stores ADD COLUMN gender_category_id INT NULL;
ALTER TABLE stores ADD COLUMN store_url TEXT NULL;

-- Set existing stores to approved
UPDATE stores SET status = 'approved';

-- Optional: Add foreign key for vendor_id (ensure vendors table exists)
-- ALTER TABLE stores ADD FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL;
