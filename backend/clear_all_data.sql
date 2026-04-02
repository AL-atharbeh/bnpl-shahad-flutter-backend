-- This script clears all data from the BNPL database while maintaining the table structure.
-- It disables foreign key checks to allow truncating tables with relationships.

SET FOREIGN_KEY_CHECKS = 0;

-- Dependent/Child Tables
TRUNCATE TABLE `reward_points`;
TRUNCATE TABLE `postponements`;
TRUNCATE TABLE `payments`;
TRUNCATE TABLE `notifications`;
TRUNCATE TABLE `in_app_notifications`;
TRUNCATE TABLE `user_security_settings`;
TRUNCATE TABLE `otp_codes`;
TRUNCATE TABLE `deals`;
TRUNCATE TABLE `bnpl_session_items`;
TRUNCATE TABLE `bnpl_sessions`;
TRUNCATE TABLE `settlements`;
TRUNCATE TABLE `bank_transfers`;
TRUNCATE TABLE `promo_notifications`;

-- Main/Parent Tables
TRUNCATE TABLE `products`;
TRUNCATE TABLE `banners`;
TRUNCATE TABLE `stores`;
TRUNCATE TABLE `vendors`;
TRUNCATE TABLE `contact_messages`;
TRUNCATE TABLE `contact_settings`;
TRUNCATE TABLE `categories`;
TRUNCATE TABLE `users`;
TRUNCATE TABLE `commission_settings`;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'All tables truncated successfully!' AS message;
