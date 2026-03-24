-- Migration: Add OTP column to users table
-- Run this script if you already have a users table and want to add the OTP column
-- Safe to run multiple times - checks if column exists before adding

USE bnpl_db;

-- Add OTP column only if it doesn't exist
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'users' 
    AND COLUMN_NAME = 'otp'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE users ADD COLUMN otp VARCHAR(6) NULL AFTER employer',
    'SELECT "Column otp already exists!" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Success message
SELECT 'Migration completed successfully!' AS message;

