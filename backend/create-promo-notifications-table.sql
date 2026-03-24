-- Migration Script: Create Promo Notifications Table
-- This script creates the promo_notifications table for managing promotional notifications
-- like "Price Compare" and "Pay Less" that appear on the home page
-- These notifications can be linked to categories (filters)

USE bnpl_db;

-- Step 1: Create Promo Notifications Table
CREATE TABLE IF NOT EXISTS promo_notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL COMMENT 'Notification title (English)',
  title_ar VARCHAR(255) NOT NULL COMMENT 'Notification title (Arabic)',
  subtitle VARCHAR(255) NULL COMMENT 'Notification subtitle (English)',
  subtitle_ar VARCHAR(255) NULL COMMENT 'Notification subtitle (Arabic)',
  icon VARCHAR(100) NULL COMMENT 'Icon name or identifier',
  background_color VARCHAR(50) DEFAULT '#10B981' COMMENT 'Background color (hex)',
  text_color VARCHAR(50) DEFAULT '#FFFFFF' COMMENT 'Text color (hex)',
  category_id INT NULL COMMENT 'Filter: Show notification only for this category (NULL = show on all pages)',
  link_type ENUM('category', 'store', 'product', 'external', 'none') DEFAULT 'none' COMMENT 'Type of link',
  link_id INT NULL COMMENT 'ID of linked entity (category_id, store_id, etc.)',
  link_url VARCHAR(500) NULL COMMENT 'URL to navigate when notification is clicked',
  is_active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
  sort_order INT DEFAULT 0 COMMENT 'Display order',
  start_date DATETIME NULL COMMENT 'Start date for notification display',
  end_date DATETIME NULL COMMENT 'End date for notification display',
  click_count INT DEFAULT 0 COMMENT 'Number of clicks',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_is_active (is_active),
  INDEX idx_category_id (category_id),
  INDEX idx_sort_order (sort_order),
  INDEX idx_start_end_date (start_date, end_date),
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 2: Insert sample notifications
-- Note: category_id = NULL means show on all pages (home page)
-- If category_id is set, notification will only show when that category is selected
INSERT INTO promo_notifications (
  title,
  title_ar,
  subtitle,
  subtitle_ar,
  icon,
  background_color,
  text_color,
  category_id,
  link_type,
  link_id,
  is_active,
  sort_order,
  start_date,
  end_date,
  click_count
) VALUES
-- Notification 1: Price Compare (shows on all pages)
(
  'Price Compare',
  'قارن الأسعار',
  'Compare prices across stores',
  'قارن الأسعار بين المتاجر',
  'compare_arrows',
  '#10B981',
  '#FFFFFF',
  NULL, -- Shows on all pages (home page)
  'none',
  NULL,
  TRUE,
  1,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 365 DAY),
  0
),
-- Notification 2: Pay Less (shows on all pages)
(
  'Pay Less',
  'ادفع أقل',
  'Save more with our deals',
  'وفر أكثر مع عروضنا',
  'savings',
  '#34D399',
  '#FFFFFF',
  NULL, -- Shows on all pages (home page)
  'none',
  NULL,
  TRUE,
  2,
  NOW(),
  DATE_ADD(NOW(), INTERVAL 365 DAY),
  0
)
ON DUPLICATE KEY UPDATE 
  title = VALUES(title),
  title_ar = VALUES(title_ar),
  subtitle = VALUES(subtitle),
  subtitle_ar = VALUES(subtitle_ar);

-- Step 3: Verify the table was created
SELECT 'Promo notifications table created successfully!' AS message;
SELECT COUNT(*) AS total_notifications FROM promo_notifications WHERE is_active = TRUE;
SELECT 
  id,
  title,
  title_ar,
  subtitle,
  subtitle_ar,
  category_id,
  is_active,
  sort_order
FROM promo_notifications 
ORDER BY sort_order, id;

