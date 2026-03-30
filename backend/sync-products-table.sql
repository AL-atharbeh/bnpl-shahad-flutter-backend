-- SQL to sync the products table with the latest backend requirements
-- Run these commands in your database console

ALTER TABLE products ADD COLUMN stock_quantity INT DEFAULT 0;
ALTER TABLE products ADD COLUMN discount_price DECIMAL(10, 2) DEFAULT NULL;
ALTER TABLE products ADD COLUMN sales_count INT DEFAULT 0;
ALTER TABLE products ADD COLUMN total_revenue DECIMAL(10, 2) DEFAULT 0.00;

-- If you get a "Duplicate column name" error, it means the column already exists. 
-- That's fine, just move to the next one.
