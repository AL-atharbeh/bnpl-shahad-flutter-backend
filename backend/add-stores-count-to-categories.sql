-- Migration Script: Add stores_count column to categories table
-- This script adds a column to store the count of stores in each category

USE bnpl_db;

-- Step 1: Add stores_count column to categories table
ALTER TABLE categories 
ADD COLUMN stores_count INT DEFAULT 0 COMMENT 'Number of active stores in this category' AFTER sort_order;

-- Step 2: Create index for better performance
CREATE INDEX idx_stores_count ON categories(stores_count);

-- Step 3: Calculate and update stores_count for existing categories
UPDATE categories c
SET stores_count = (
  SELECT COUNT(*) 
  FROM stores s 
  WHERE s.category_id = c.id 
  AND s.is_active = TRUE
);

-- Step 4: Create trigger to automatically update stores_count when stores are added/updated/deleted
DELIMITER $$

-- Trigger: Update stores_count when a store is inserted
CREATE TRIGGER after_store_insert
AFTER INSERT ON stores
FOR EACH ROW
BEGIN
  IF NEW.category_id IS NOT NULL AND NEW.is_active = TRUE THEN
    UPDATE categories 
    SET stores_count = stores_count + 1 
    WHERE id = NEW.category_id;
  END IF;
END$$

-- Trigger: Update stores_count when a store is updated
CREATE TRIGGER after_store_update
AFTER UPDATE ON stores
FOR EACH ROW
BEGIN
  -- If category changed
  IF OLD.category_id != NEW.category_id THEN
    -- Decrease count in old category
    IF OLD.category_id IS NOT NULL THEN
      UPDATE categories 
      SET stores_count = GREATEST(0, stores_count - 1) 
      WHERE id = OLD.category_id;
    END IF;
    
    -- Increase count in new category
    IF NEW.category_id IS NOT NULL AND NEW.is_active = TRUE THEN
      UPDATE categories 
      SET stores_count = stores_count + 1 
      WHERE id = NEW.category_id;
    END IF;
  -- If only active status changed
  ELSEIF OLD.is_active != NEW.is_active THEN
    IF NEW.category_id IS NOT NULL THEN
      IF NEW.is_active = TRUE THEN
        UPDATE categories 
        SET stores_count = stores_count + 1 
        WHERE id = NEW.category_id;
      ELSE
        UPDATE categories 
        SET stores_count = GREATEST(0, stores_count - 1) 
        WHERE id = NEW.category_id;
      END IF;
    END IF;
  END IF;
END$$

-- Trigger: Update stores_count when a store is deleted
CREATE TRIGGER after_store_delete
AFTER DELETE ON stores
FOR EACH ROW
BEGIN
  IF OLD.category_id IS NOT NULL AND OLD.is_active = TRUE THEN
    UPDATE categories 
    SET stores_count = GREATEST(0, stores_count - 1) 
    WHERE id = OLD.category_id;
  END IF;
END$$

DELIMITER ;

-- Step 5: Verify the update
SELECT 
  id, 
  name, 
  name_ar, 
  stores_count,
  (SELECT COUNT(*) FROM stores WHERE category_id = categories.id AND is_active = TRUE) as actual_count
FROM categories
ORDER BY sort_order;

-- Success message
SELECT 'stores_count column added and triggers created successfully!' AS message;

