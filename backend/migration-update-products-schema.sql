-- Add new columns to products table for stock and discounts
ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_quantity INT DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS discount_price DECIMAL(10, 2) DEFAULT NULL;
ALTER TABLE products ADD COLUMN IF NOT EXISTS sales_count INT DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS total_revenue DECIMAL(10, 2) DEFAULT 0.00;

-- Add product_id to bnpl_session_items to link sales back to products
ALTER TABLE bnpl_session_items ADD COLUMN IF NOT EXISTS product_id INT DEFAULT NULL;

-- Optional: Add foreign key for data integrity (commented out if you prefer loose coupling or if table is large)
-- ALTER TABLE bnpl_session_items ADD CONSTRAINT fk_product_item FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
