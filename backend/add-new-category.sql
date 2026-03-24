-- Script to add a new category to the database
-- Usage: mysql -u root -p bnpl_db < add-new-category.sql

USE bnpl_db;

-- Example: Add "Jewelry & Watches" category
INSERT INTO categories (name, name_ar, icon, description, description_ar, sort_order, is_active) 
VALUES 
(
  'Jewelry & Watches',
  'المجوهرات والساعات',
  'diamond',
  'Jewelry and watches stores',
  'متاجر المجوهرات والساعات',
  11,
  TRUE
);

-- Or add multiple categories at once:
INSERT INTO categories (name, name_ar, icon, description, description_ar, sort_order, is_active) VALUES
('Pet Supplies', 'مستلزمات الحيوانات الأليفة', 'pets', 'Pet supplies and accessories', 'مستلزمات وملحقات الحيوانات الأليفة', 12, TRUE),
('Baby & Kids', 'الرضع والأطفال', 'child_care', 'Baby and kids products', 'منتجات الرضع والأطفال', 13, TRUE),
('Office Supplies', 'المستلزمات المكتبية', 'business', 'Office supplies and equipment', 'المستلزمات والمعدات المكتبية', 14, TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name), name_ar = VALUES(name_ar);

-- Verify the new category was added
SELECT * FROM categories ORDER BY sort_order;

