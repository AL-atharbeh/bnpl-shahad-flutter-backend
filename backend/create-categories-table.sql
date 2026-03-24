-- Migration Script: Add Categories Table and Update Stores/Products
-- This script creates the categories table and updates existing tables to use foreign keys

USE bnpl_db;

-- Step 1: Create Categories Table
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  name_ar VARCHAR(255) NOT NULL,
  icon VARCHAR(100) NULL COMMENT 'Icon name or identifier',
  image_url VARCHAR(500) NULL COMMENT 'Category image URL',
  description TEXT NULL,
  description_ar TEXT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0 COMMENT 'Display order',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_is_active (is_active),
  INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 2: Insert default categories
INSERT INTO categories (name, name_ar, icon, description, description_ar, sort_order) VALUES
('Fashion & Clothing', 'الأزياء والملابس', 'shopping_bag', 'Fashion and clothing stores', 'متاجر الأزياء والملابس', 1),
('Electronics', 'الإلكترونيات', 'devices', 'Electronics and gadgets', 'الإلكترونيات والأجهزة', 2),
('Home & Furniture', 'المنزل والأثاث', 'home', 'Home and furniture stores', 'متاجر المنزل والأثاث', 3),
('Beauty & Cosmetics', 'الجمال ومستحضرات التجميل', 'face', 'Beauty and cosmetics stores', 'متاجر الجمال ومستحضرات التجميل', 4),
('Sports & Outdoors', 'الرياضة والهواء الطلق', 'sports', 'Sports and outdoor equipment', 'معدات الرياضة والهواء الطلق', 5),
('Food & Beverages', 'الطعام والمشروبات', 'restaurant', 'Food and beverage stores', 'متاجر الطعام والمشروبات', 6),
('Health & Wellness', 'الصحة والعافية', 'favorite', 'Health and wellness products', 'منتجات الصحة والعافية', 7),
('Books & Education', 'الكتب والتعليم', 'book', 'Books and educational materials', 'الكتب والمواد التعليمية', 8),
('Toys & Games', 'الألعاب والألعاب', 'toys', 'Toys and games', 'الألعاب والألعاب', 9),
('Automotive', 'السيارات', 'drive_eta', 'Automotive products and services', 'منتجات وخدمات السيارات', 10)
ON DUPLICATE KEY UPDATE name = VALUES(name), name_ar = VALUES(name_ar);

-- Step 3: Add category_id column to stores table (nullable first, then we'll migrate data)
ALTER TABLE stores 
ADD COLUMN category_id INT NULL AFTER category,
ADD INDEX idx_category_id (category_id);

-- Step 4: Migrate existing category data from stores.category to stores.category_id
-- This will match category names to category IDs
UPDATE stores s
INNER JOIN categories c ON (
  s.category = c.name OR 
  s.category = c.name_ar OR
  LOWER(s.category) = LOWER(c.name) OR
  LOWER(s.category) = LOWER(c.name_ar)
)
SET s.category_id = c.id
WHERE s.category IS NOT NULL AND s.category != '';

-- Step 5: Add foreign key constraint for stores.category_id
ALTER TABLE stores
ADD CONSTRAINT fk_stores_category 
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

-- Step 6: Add category_id column to products table
ALTER TABLE products
ADD COLUMN category_id INT NULL AFTER category,
ADD INDEX idx_category_id (category_id);

-- Step 7: Migrate existing category data from products.category to products.category_id
UPDATE products p
INNER JOIN categories c ON (
  p.category = c.name OR 
  p.category = c.name_ar OR
  LOWER(p.category) = LOWER(c.name) OR
  LOWER(p.category) = LOWER(c.name_ar)
)
SET p.category_id = c.id
WHERE p.category IS NOT NULL AND p.category != '';

-- Step 8: Add foreign key constraint for products.category_id
ALTER TABLE products
ADD CONSTRAINT fk_products_category 
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

-- Step 9: Optionally, we can keep the old category column for backward compatibility
-- or remove it after verifying the migration. For now, we'll keep it.

SELECT 'Categories table created and stores/products tables updated successfully!' AS message;
SELECT COUNT(*) AS total_categories FROM categories;
SELECT COUNT(*) AS stores_with_category FROM stores WHERE category_id IS NOT NULL;
SELECT COUNT(*) AS products_with_category FROM products WHERE category_id IS NOT NULL;

