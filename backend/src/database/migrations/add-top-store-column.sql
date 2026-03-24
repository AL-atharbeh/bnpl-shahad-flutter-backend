-- Add top_store column to stores table
-- This column determines if a store should appear in the Top Stores section
-- 1 = show in Top Stores, 0 = don't show

ALTER TABLE stores 
ADD COLUMN top_store TINYINT(1) DEFAULT 0 NOT NULL 
AFTER is_active;

-- Update existing stores: set top_store = 1 for stores with highest ratings
-- This is optional - you can manually set which stores should be top stores
UPDATE stores 
SET top_store = 1 
WHERE rating >= 4.5 AND is_active = 1
LIMIT 10;

