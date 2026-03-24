-- Migration: Change pin_hash to pin (plain text)
-- Run this SQL in your MySQL database

-- Step 1: Add new column 'pin' if it doesn't exist (exactly 4 digits)
ALTER TABLE `user_security_settings` 
ADD COLUMN IF NOT EXISTS `pin` VARCHAR(4) NULL AFTER `user_id`;

-- Add constraint to ensure PIN is exactly 4 digits
ALTER TABLE `user_security_settings`
ADD CONSTRAINT `chk_pin_length` CHECK (LENGTH(`pin`) = 4 OR `pin` IS NULL);

-- Step 2: Copy data from pin_hash to pin (if needed)
-- Note: This will only work if pin_hash contains plain text (4 digits)
-- If pin_hash contains hashed values, you'll need to reset PINs
UPDATE `user_security_settings` 
SET `pin` = `pin_hash` 
WHERE `pin_hash` IS NOT NULL 
  AND `pin_hash` REGEXP '^[0-9]{4}$';

-- Step 3: Drop old column
ALTER TABLE `user_security_settings` 
DROP COLUMN IF EXISTS `pin_hash`;

-- Step 4: Verify the change
SELECT 
    id,
    user_id,
    pin,
    pin_enabled,
    biometric_enabled
FROM `user_security_settings`
LIMIT 5;

