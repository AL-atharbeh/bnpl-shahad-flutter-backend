-- Migration Script: Create Banners Table
-- This script creates the banners table for managing promotional banners

USE bnpl_db;

-- Step 1: Create Banners Table
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
  INDEX idx_start_end_date (start_date, end_date),
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 2: Insert sample banners
-- Note: Using NULL for category_id to show banners on all pages (home page)
-- You can change category_id to specific category IDs if needed
INSERT INTO banners (title, title_ar, image_url, link_type, category_id, is_active, sort_order) VALUES
('Fashion Sale', 'عرض الأزياء', 'assets/images/banner1.jpg', 'category', NULL, TRUE, 1),
('Electronics Offer', 'عرض الإلكترونيات', 'assets/images/banner2.jpg', 'category', NULL, TRUE, 2),
('Sports Collection', 'مجموعة الرياضة', 'assets/images/banner3.jpg', 'category', NULL, TRUE, 3)
ON DUPLICATE KEY UPDATE title = VALUES(title), title_ar = VALUES(title_ar);

-- Step 3: Verify the table was created
SELECT 'Banners table created successfully!' AS message;
SELECT COUNT(*) AS total_banners FROM banners;
SELECT * FROM banners ORDER BY sort_order;

