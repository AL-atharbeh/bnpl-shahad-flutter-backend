-- SQL to ensure the required columns exist in the products table
-- Run this in your database console if you suspect columns are missing

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS stock_quantity INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_price DECIMAL(10, 2) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS category_id INT DEFAULT NULL;

-- If your MySQL version doesn't support IF NOT EXISTS, use these:
-- ALTER TABLE products ADD COLUMN stock_quantity INT DEFAULT 0;
-- ALTER TABLE products ADD COLUMN discount_price DECIMAL(10, 2) DEFAULT NULL;
-- ALTER TABLE products ADD COLUMN category_id INT DEFAULT NULL;
