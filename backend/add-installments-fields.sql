USE bnpl_db;

-- Check if columns exist before adding
SET @installments_count_exists = (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'payments' 
  AND COLUMN_NAME = 'installments_count'
);

SET @installment_number_exists = (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'payments' 
  AND COLUMN_NAME = 'installment_number'
);

SET @total_amount_exists = (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'payments' 
  AND COLUMN_NAME = 'total_amount'
);

-- Add installments_count if it doesn't exist
SET @sql1 = IF(@installments_count_exists = 0,
  'ALTER TABLE payments ADD COLUMN installments_count INT DEFAULT 1 AFTER currency',
  'SELECT "installments_count already exists" AS message'
);
PREPARE stmt1 FROM @sql1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- Add installment_number if it doesn't exist
SET @sql2 = IF(@installment_number_exists = 0,
  'ALTER TABLE payments ADD COLUMN installment_number INT DEFAULT 1 AFTER installments_count',
  'SELECT "installment_number already exists" AS message'
);
PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- Add total_amount if it doesn't exist
SET @sql3 = IF(@total_amount_exists = 0,
  'ALTER TABLE payments ADD COLUMN total_amount DECIMAL(10,2) NULL AFTER installment_number',
  'SELECT "total_amount already exists" AS message'
);
PREPARE stmt3 FROM @sql3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

-- Update existing payments to have default values
UPDATE payments
SET 
  installments_count = COALESCE(installments_count, 1),
  installment_number = COALESCE(installment_number, 1),
  total_amount = COALESCE(total_amount, amount)
WHERE installments_count IS NULL OR installment_number IS NULL OR total_amount IS NULL;

-- Add indexes for better query performance (ignore errors if they already exist)
ALTER TABLE payments ADD INDEX idx_installment_number (installment_number);
ALTER TABLE payments ADD INDEX idx_installments_count (installments_count);
