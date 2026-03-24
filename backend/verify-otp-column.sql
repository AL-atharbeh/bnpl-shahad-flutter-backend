-- استعلامات للتحقق من عمود OTP في TablePlus
-- Copy these queries into TablePlus and run them

-- 1. التحقق النهائي - يجب أن ترى otp في القائمة (الموضع 22)
SELECT COLUMN_NAME, ORDINAL_POSITION, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'users'
ORDER BY ORDINAL_POSITION;

-- 2. عرض البيانات مع عمود otp - يجب أن ترى عمود otp في النتائج
SELECT id, phone, otp, is_phone_verified 
FROM users 
LIMIT 5;

-- 3. عرض جميع الأعمدة
SHOW FULL COLUMNS FROM users;

-- إذا ظهر otp في النتائج أعلاه، فهو موجود فعلياً
-- المشكلة فقط في TablePlus interface

