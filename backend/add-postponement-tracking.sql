-- Add postponement tracking columns to users table
USE bnpl_db;

-- Add free_postponement_count column (number of times user used free postponement)
SET @col_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'free_postponement_count'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE users ADD COLUMN free_postponement_count INT DEFAULT 0 AFTER avatar_url',
    'SELECT "Column free_postponement_count already exists!" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add days_since_last_postponement column (days counter since last postponement)
SET @col_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'days_since_last_postponement'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE users ADD COLUMN days_since_last_postponement INT DEFAULT 0 AFTER free_postponement_count',
    'SELECT "Column days_since_last_postponement already exists!" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'Migration completed successfully!' AS message;

