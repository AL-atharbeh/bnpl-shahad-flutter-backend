-- Add Sample Banners to Database
-- This script adds sample banner data for the home page
-- Run this script to populate the banners table

USE bnpl_db;

-- Check if banners table exists, if not create it first
CREATE TABLE IF NOT EXISTS banners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NULL COMMENT 'Banner title (optional)',
  title_ar VARCHAR(255) NULL COMMENT 'Banner title in Arabic (optional)',
  image_url VARCHAR(500) NOT NULL COMMENT 'Banner image URL',
  link_url VARCHAR(500) NULL COMMENT 'URL to navigate when banner is clicked',
  link_type ENUM('category', 'store', 'product', 'external', 'none') DEFAULT 'none' COMMENT 'Type of link',
  link_id INT NULL COMMENT 'ID of linked entity (category_id, store_id, etc.)',
  category_id INT NULL COMMENT 'Filter: Show banner only for this category',
  description TEXT NULL COMMENT 'Banner description',
  description_ar TEXT NULL COMMENT 'Banner description in Arabic',
  is_active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
  sort_order INT DEFAULT 0 COMMENT 'Display order',
  start_date DATETIME NULL COMMENT 'Start date for banner display',
  end_date DATETIME NULL COMMENT 'End date for banner display',
  click_count INT DEFAULT 0 COMMENT 'Number of clicks',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_is_active (is_active),
  INDEX idx_category_id (category_id),
  INDEX idx_sort_order (sort_order),
  INDEX idx_start_end_date (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clear existing banners (optional - remove this if you want to keep existing data)
-- DELETE FROM banners;

-- Insert sample banners
-- Using assets/images paths (local images) or you can use external URLs
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
-- Banner 1: General Home Banner
(
  'Special Offer', 
  'عرض خاص', 
  'assets/images/banner1.jpg', 
  'none', 
  NULL,
  NULL, -- Shows on all pages (home page)
  'Limited time offer - Shop now!',
  'عرض لفترة محدودة - تسوق الآن!',
  TRUE, 
  1,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 60 DAY),
  0
),
-- Banner 2: Fashion Banner
(
  'Fashion Sale', 
  'عرض الأزياء', 
  'assets/images/banner2.jpg', 
  'category', 
  1, -- link_id: links to category 1 (if exists)
  NULL, -- Shows on all pages
  'Discover the latest fashion trends',
  'اكتشف أحدث صيحات الموضة',
  TRUE, 
  2,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 30 DAY),
  0
),
-- Banner 3: Electronics Banner
(
  'Electronics Offer', 
  'عرض الإلكترونيات', 
  'assets/images/banner3.jpg', 
  'category', 
  2, -- link_id: links to category 2 (if exists)
  NULL, -- Shows on all pages
  'Best deals on electronics',
  'أفضل العروض على الإلكترونيات',
  TRUE, 
  3,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 30 DAY),
  0
),
-- Banner 4: External Link Example
(
  'Visit Our Website', 
  'زر موقعنا', 
  'assets/images/banner1.jpg', 
  'external', 
  NULL,
  NULL,
  'Click to visit our website',
  'انقر لزيارة موقعنا',
  TRUE, 
  4,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 90 DAY),
  0
);

-- Verify the banners were inserted
SELECT '✅ Sample banners inserted successfully!' AS message;
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
  click_count,
  created_at
FROM banners 
ORDER BY sort_order, id;

-- Show count
SELECT COUNT(*) AS total_banners FROM banners WHERE is_active = TRUE;

