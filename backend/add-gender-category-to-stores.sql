-- Add gender category field to stores table
-- This will classify stores as Women, Men, or Kids

USE bnpl_db;

-- Step 1: Add gender categories if they don't exist
INSERT INTO categories (name, name_ar, icon, description, description_ar, is_active, sort_order) VALUES
('Women', 'نساء', 'face', 'Stores and products for women', 'متاجر ومنتجات للنساء', TRUE, 0),
('Men', 'رجال', 'person', 'Stores and products for men', 'متاجر ومنتجات للرجال', TRUE, 0),
('Kids', 'أطفال', 'child_care', 'Stores and products for kids', 'متاجر ومنتجات للأطفال', TRUE, 0)
ON DUPLICATE KEY UPDATE 
  name = VALUES(name),
  name_ar = VALUES(name_ar),
  icon = VALUES(icon),
  description = VALUES(description),
  description_ar = VALUES(description_ar);

-- Step 2: Add gender_category_id column to stores table (if not exists)
SET @col_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'bnpl_db' 
    AND TABLE_NAME = 'stores' 
    AND COLUMN_NAME = 'gender_category_id'
);

SET @sql = IF(@col_exists = 0,
  'ALTER TABLE stores ADD COLUMN gender_category_id INT NULL AFTER category_id, ADD INDEX idx_gender_category_id (gender_category_id)',
  'SELECT "Column gender_category_id already exists" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 3: Add foreign key constraint (if not exists)
SET @fk_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
  WHERE TABLE_SCHEMA = 'bnpl_db' 
    AND TABLE_NAME = 'stores' 
    AND CONSTRAINT_NAME = 'fk_stores_gender_category'
);

SET @sql = IF(@fk_exists = 0,
  'ALTER TABLE stores ADD CONSTRAINT fk_stores_gender_category FOREIGN KEY (gender_category_id) REFERENCES categories(id) ON DELETE SET NULL',
  'SELECT "Foreign key fk_stores_gender_category already exists" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 4: Get gender category IDs
SET @women_category_id = (SELECT id FROM categories WHERE name = 'Women' LIMIT 1);
SET @men_category_id = (SELECT id FROM categories WHERE name = 'Men' LIMIT 1);
SET @kids_category_id = (SELECT id FROM categories WHERE name = 'Kids' LIMIT 1);

-- Step 5: Link existing stores to gender categories
-- Fashion stores (Zara, H&M) - link to Women as example
UPDATE stores 
SET gender_category_id = @women_category_id 
WHERE category_id = 1 AND id IN (1, 2); -- Zara and H&M (Fashion & Clothing)

-- You can update more stores as needed:
-- UPDATE stores SET gender_category_id = @men_category_id WHERE id = X;
-- UPDATE stores SET gender_category_id = @kids_category_id WHERE id = Y;

-- Show results
SELECT 
  s.id,
  s.name,
  s.name_ar,
  c.name as category_name,
  gc.name as gender_category_name
FROM stores s
LEFT JOIN categories c ON s.category_id = c.id
LEFT JOIN categories gc ON s.gender_category_id = gc.id
WHERE s.is_active = TRUE
ORDER BY s.id;

