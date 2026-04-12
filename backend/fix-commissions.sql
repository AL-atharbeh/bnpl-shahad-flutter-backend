-- ==========================================================
-- سكريبت تصحيح العمولات (تفعيل الـ 5% للعمليات القديمة)
-- هذا السكريبت يحول العمليات من (1.5% / 1.0%) إلى (3% / 2%)
-- ==========================================================

-- 1. تحديث سجلات الدفعات (Payments) لتحمل النسب والعمولات الصحيحة
UPDATE payments 
SET bank_commission_rate = 3.00, 
    platform_commission_rate = 2.00, 
    commission = amount * 0.05, 
    store_amount = amount * 0.95
WHERE bank_commission_rate = 1.50 
  AND platform_commission_rate = 1.00;

-- 2. تحديث سجلات المتاجر (Stores) لتصبح العمولات الافتراضية هي 5%
UPDATE stores 
SET bank_commission_rate = 3.00, 
    platform_commission_rate = 2.00, 
    commission_rate = 5.00 
WHERE bank_commission_rate = 1.50 
  AND platform_commission_rate = 1.00;

-- 3. التأكد من جدول إعدادات العمولات الرئيسي (Commission Settings)
-- سنقوم بتحديث الصف الأول (أو إضافته) ليكون هو المرجع العالمي
INSERT INTO commission_settings (bankCommission, platformCommission, storeDiscount, effectiveFrom, createdAt, updatedAt)
VALUES (0.0300, 0.0200, 0.0500, NOW(), NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    bankCommission = 0.0300, 
    platformCommission = 0.0200, 
    storeDiscount = 0.0500, 
    updatedAt = NOW();

-- تحقق من النتائج:
-- SELECT id, order_id, bank_commission_rate, platform_commission_rate, commission FROM payments LIMIT 10;
