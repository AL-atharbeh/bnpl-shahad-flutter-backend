-- استعلامات SQL لتنفيذها في TablePlus
-- Copy and paste these queries into TablePlus

-- 1. التحقق من وجود عمود OTP
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'users'
ORDER BY ORDINAL_POSITION;

-- 2. عرض جميع الأعمدة (يجب أن ترى otp في الموضع 22)
SHOW FULL COLUMNS FROM users;

-- 3. التحقق من وجود otp مباشرة
SELECT COUNT(*) as otp_exists
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'users' 
  AND COLUMN_NAME = 'otp';

-- 4. عرض بيانات مع عمود otp
SELECT id, phone, otp, is_phone_verified FROM users LIMIT 5;

