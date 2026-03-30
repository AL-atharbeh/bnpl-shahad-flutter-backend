-- SQL to sync the database with the latest backend requirements
-- Run these commands in your database console

-- 1. Sync Products Table
ALTER TABLE products ADD COLUMN stock_quantity INT DEFAULT 0;
ALTER TABLE products ADD COLUMN discount_price DECIMAL(10, 2) DEFAULT NULL;
ALTER TABLE products ADD COLUMN sales_count INT DEFAULT 0;
ALTER TABLE products ADD COLUMN total_revenue DECIMAL(10, 2) DEFAULT 0.00;

-- 2. Sync Stores Table
ALTER TABLE stores ADD COLUMN vendor_id INT DEFAULT NULL;
ALTER TABLE stores ADD COLUMN status VARCHAR(20) DEFAULT 'approved';
ALTER TABLE stores ADD COLUMN top_store TINYINT(1) DEFAULT 0;
ALTER TABLE stores ADD COLUMN gender_category_id INT DEFAULT NULL;
ALTER TABLE stores ADD COLUMN products_count INT DEFAULT 0;

-- Note: If you get "Duplicate column name", that's fine, it means the column is already there.
