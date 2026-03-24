-- Add gender_type field to categories table
-- This will classify categories as Women, Men, Kids, or All

USE bnpl_db;

-- Step 1: Add gender_type column to categories table
ALTER TABLE categories 
ADD COLUMN gender_type ENUM('Women', 'Men', 'Kids', 'All') NULL DEFAULT 'All' AFTER name_ar,
ADD INDEX idx_gender_type (gender_type);

-- Step 2: Update existing categories with gender_type
-- Fashion & Clothing -> Women (can be updated later)
UPDATE categories 
SET gender_type = 'Women' 
WHERE name = 'Fashion & Clothing';

-- Electronics -> All (for everyone)
UPDATE categories 
SET gender_type = 'All' 
WHERE name = 'Electronics';

-- Home & Furniture -> All
UPDATE categories 
SET gender_type = 'All' 
WHERE name = 'Home & Furniture';

-- Beauty & Cosmetics -> Women
UPDATE categories 
SET gender_type = 'Women' 
WHERE name = 'Beauty & Cosmetics';

-- Sports & Outdoors -> All
UPDATE categories 
SET gender_type = 'All' 
WHERE name = 'Sports & Outdoors';

-- Toys & Games -> Kids
UPDATE categories 
SET gender_type = 'Kids' 
WHERE name = 'Toys & Games';

-- Show results
SELECT 
  id,
  name,
  name_ar,
  gender_type
FROM categories
WHERE is_active = TRUE
ORDER BY gender_type, sort_order;

