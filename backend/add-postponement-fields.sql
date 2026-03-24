-- Add postponement fields to payments table
USE bnpl_db;

-- Check if columns exist before adding
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'payments' 
    AND COLUMN_NAME = 'is_postponed'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE payments 
     ADD COLUMN is_postponed BOOLEAN DEFAULT FALSE AFTER extension_days,
     ADD COLUMN postponed_days INT NULL AFTER is_postponed,
     ADD COLUMN postponed_due_date TIMESTAMP NULL AFTER postponed_days',
    'SELECT "Postponement columns already exist!" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'Migration completed successfully!' AS message;

