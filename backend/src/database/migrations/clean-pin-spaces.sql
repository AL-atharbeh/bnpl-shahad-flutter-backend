-- Migration: Clean PIN spaces and ensure exactly 4 digits
-- Run this SQL in your MySQL database

-- Step 1: Trim all PINs and ensure they are exactly 4 digits
UPDATE `user_security_settings` 
SET `pin` = TRIM(`pin`)
WHERE `pin` IS NOT NULL;

-- Step 2: Disable PIN for any invalid entries (not exactly 4 digits)
UPDATE `user_security_settings` 
SET `pin` = NULL, `pin_enabled` = 0
WHERE `pin` IS NOT NULL 
  AND (LENGTH(TRIM(`pin`)) != 4 OR `pin` NOT REGEXP '^[0-9]{4}$');

-- Step 3: Verify all PINs are exactly 4 digits
SELECT 
    id,
    user_id,
    pin,
    LENGTH(pin) as pin_length,
    pin_enabled,
    CASE 
        WHEN pin IS NULL THEN 'NULL'
        WHEN LENGTH(TRIM(pin)) = 4 AND pin REGEXP '^[0-9]{4}$' THEN 'VALID'
        ELSE 'INVALID'
    END as pin_status
FROM `user_security_settings`
WHERE pin IS NOT NULL;

-- Step 4: Show summary
SELECT 
    COUNT(*) as total_settings,
    SUM(CASE WHEN pin IS NOT NULL THEN 1 ELSE 0 END) as pins_set,
    SUM(CASE WHEN pin IS NOT NULL AND LENGTH(TRIM(pin)) = 4 AND pin REGEXP '^[0-9]{4}$' THEN 1 ELSE 0 END) as valid_pins,
    SUM(CASE WHEN pin IS NOT NULL AND (LENGTH(TRIM(pin)) != 4 OR pin NOT REGEXP '^[0-9]{4}$') THEN 1 ELSE 0 END) as invalid_pins
FROM `user_security_settings`;

