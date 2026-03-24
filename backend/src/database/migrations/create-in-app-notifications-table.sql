-- Migration: Create In-App Notifications Table
-- جدول منفصل للإشعارات داخل التطبيق مرتبط بجدول notifications

CREATE TABLE IF NOT EXISTS `in_app_notifications` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `notification_id` INT(11) NOT NULL UNIQUE,
  `user_id` INT(11) NOT NULL,
  `is_displayed` TINYINT(1) NOT NULL DEFAULT 0,
  `displayed_at` TIMESTAMP NULL DEFAULT NULL,
  `is_clicked` TINYINT(1) NOT NULL DEFAULT 0,
  `clicked_at` TIMESTAMP NULL DEFAULT NULL,
  `priority` VARCHAR(20) NOT NULL DEFAULT 'medium',
  `category` VARCHAR(50) NULL DEFAULT NULL,
  `action_button_text` VARCHAR(100) NULL DEFAULT NULL,
  `action_url` TEXT NULL DEFAULT NULL,
  `expires_at` TIMESTAMP NULL DEFAULT NULL,
  `metadata` JSON NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_notification_id` (`notification_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_notification_id` (`notification_id`),
  KEY `idx_priority` (`priority`),
  KEY `idx_category` (`category`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `fk_in_app_notification_notification` 
    FOREIGN KEY (`notification_id`) 
    REFERENCES `notifications` (`id`) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
  CONSTRAINT `fk_in_app_notification_user` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add index for better query performance
CREATE INDEX `idx_user_created` ON `in_app_notifications` (`user_id`, `created_at` DESC);
CREATE INDEX `idx_user_displayed` ON `in_app_notifications` (`user_id`, `is_displayed`);

SELECT 'Migration completed successfully! In-App Notifications table created.' AS message;

