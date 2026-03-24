-- Add Sample Banners to Database
-- This script adds sample banner data for testing
-- IMPORTANT: Make sure categories table exists and has data before running this script

USE bnpl_db;

-- Step 1: Check if categories table exists and get category IDs
-- Default categories (based on create-categories-table.sql):
-- 1. Fashion & Clothing (الأزياء والملابس)
-- 2. Electronics (الإلكترونيات)
-- 3. Home & Furniture (المنزل والأثاث)
-- 4. Beauty & Cosmetics (الجمال ومستحضرات التجميل)
-- 5. Sports & Outdoors (الرياضة والهواء الطلق)
-- 6. Food & Beverages (الطعام والمشروبات)
-- 7. Health & Wellness (الصحة والعافية)
-- 8. Books & Education (الكتب والتعليم)
-- 9. Toys & Games (الألعاب والألعاب)
-- 10. Automotive (السيارات)

-- Step 2: Insert sample banners
-- Note: Using category_id to link to specific categories
-- Set link_id to the same category_id to link the banner to that category

INSERT INTO banners (
  title, 
  title_ar, 
  image_url, 
  link_type, 
  link_id,
  category_id, 
  description,
  description_ar,
  is_active, 
  sort_order,
  start_date,
  end_date,
  click_count
) VALUES
-- Banner 1: Fashion Category (id=1)
(
  'Fashion Sale', 
  'عرض الأزياء', 
  'assets/images/banner1.jpg', 
  'category', 
  1, -- link_id: links to Fashion category
  1, -- category_id: shows for Fashion category pages
  'Discover the latest fashion trends',
  'اكتشف أحدث صيحات الموضة',
  TRUE, 
  1,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 30 DAY),
  0
),
-- Banner 2: Electronics Category (id=2)
(
  'Electronics Offer', 
  'عرض الإلكترونيات', 
  'assets/images/banner2.jpg', 
  'category', 
  2, -- link_id: links to Electronics category
  2, -- category_id: shows for Electronics category pages
  'Best deals on electronics',
  'أفضل العروض على الإلكترونيات',
  TRUE, 
  2,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 30 DAY),
  0
),
-- Banner 3: Sports Category (id=5)
(
  'Sports Collection', 
  'مجموعة الرياضة', 
  'assets/images/banner3.jpg', 
  'category', 
  5, -- link_id: links to Sports category
  5, -- category_id: shows for Sports category pages
  'Get active with sports gear',
  'كن نشطاً مع معدات الرياضة',
  TRUE, 
  3,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 30 DAY),
  0
),
-- Banner 4: General/Home Banner (no specific category - shows everywhere)
(
  'Special Offer', 
  'عرض خاص', 
  'assets/images/banner1.jpg', 
  'none', 
  NULL,
  NULL, -- No category filter - shows on all pages (home page, all stores page, etc.)
  'Limited time offer',
  'عرض لفترة محدودة',
  TRUE, 
  4,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 60 DAY),
  0
)
ON DUPLICATE KEY UPDATE 
  title = VALUES(title),
  title_ar = VALUES(title_ar),
  image_url = VALUES(image_url),
  link_type = VALUES(link_type),
  link_id = VALUES(link_id),
  category_id = VALUES(category_id),
  description = VALUES(description),
  description_ar = VALUES(description_ar),
  is_active = VALUES(is_active),
  sort_order = VALUES(sort_order),
  start_date = VALUES(start_date),
  end_date = VALUES(end_date);

-- Verify the banners were inserted
SELECT 'Sample banners inserted successfully!' AS message;
SELECT 
  id,
  title,
  title_ar,
  image_url,
  link_type,
  link_id,
  category_id,
  is_active,
  sort_order,
  click_count
FROM banners 
ORDER BY sort_order, id;

-- Show count
SELECT COUNT(*) AS total_banners FROM banners WHERE is_active = TRUE;

