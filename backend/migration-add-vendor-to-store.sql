-- Add vendor_id and status columns to stores table
ALTER TABLE stores ADD COLUMN vendor_id INT NULL;
ALTER TABLE stores ADD COLUMN status VARCHAR(20) DEFAULT 'approved';

-- Set existing stores to approved
UPDATE stores SET status = 'approved';

-- Optional: Add foreign key for vendor_id (ensure vendors table exists)
-- ALTER TABLE stores ADD FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL;
