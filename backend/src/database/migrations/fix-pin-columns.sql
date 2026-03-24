-- Migration: Fix PIN columns and constraints
-- Run this SQL in your MySQL database

-- Step 1: Fix pin_enabled column type (should be TINYINT(1) or BOOLEAN)
ALTER TABLE `user_security_settings` 
MODIFY COLUMN `pin_enabled` TINYINT(1) NOT NULL DEFAULT 0;

-- Step 2: Fix biometric_enabled column type
ALTER TABLE `user_security_settings` 
MODIFY COLUMN `biometric_enabled` TINYINT(1) NOT NULL DEFAULT 0;

-- Step 3: Ensure pin column is VARCHAR(4) and can only store 4 digits
ALTER TABLE `user_security_settings` 
MODIFY COLUMN `pin` VARCHAR(4) NULL;

-- Step 4: Add constraint to ensure PIN is exactly 4 digits (if not exists)
-- Note: MySQL doesn't support CHECK constraints in older versions
-- So we'll use a trigger instead
DELIMITER $$

DROP TRIGGER IF EXISTS `check_pin_length`$$

CREATE TRIGGER `check_pin_length` 
BEFORE INSERT ON `user_security_settings`
FOR EACH ROW
BEGIN
    IF NEW.pin IS NOT NULL AND (LENGTH(NEW.pin) != 4 OR NEW.pin NOT REGEXP '^[0-9]{4}$') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PIN must be exactly 4 digits';
    END IF;
END$$

CREATE TRIGGER `check_pin_length_update` 
BEFORE UPDATE ON `user_security_settings`
FOR EACH ROW
BEGIN
    IF NEW.pin IS NOT NULL AND (LENGTH(NEW.pin) != 4 OR NEW.pin NOT REGEXP '^[0-9]{4}$') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PIN must be exactly 4 digits';
    END IF;
END$$

DELIMITER ;

-- Step 5: Clean up any invalid PINs (if any exist)
UPDATE `user_security_settings` 
SET `pin` = NULL, `pin_enabled` = 0 
WHERE `pin` IS NOT NULL 
  AND (LENGTH(`pin`) != 4 OR `pin` NOT REGEXP '^[0-9]{4}$');

-- Step 6: Verify the changes
SELECT 
    id,
    user_id,
    pin,
    LENGTH(pin) as pin_length,
    pin_enabled,
    biometric_enabled
FROM `user_security_settings`
LIMIT 10;

