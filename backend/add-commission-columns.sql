-- إضافة أعمدة العمولات الجديدة لجدول المتاجر والمدفوعات
-- Add commission columns to stores and payments tables

-- 1. تحديث جدول المتاجر (Stores)
ALTER TABLE stores ADD COLUMN IF NOT EXISTS bank_commission_rate DECIMAL(5,2) DEFAULT 1.5 AFTER commission_rate;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS platform_commission_rate DECIMAL(5,2) DEFAULT 1.0 AFTER bank_commission_rate;

-- 2. تحديث جدول المدفوعات (Payments) لتتبع النسب وقت العملية
ALTER TABLE payments ADD COLUMN IF NOT EXISTS bank_commission_rate DECIMAL(5,2) DEFAULT 1.5 AFTER store_amount;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS platform_commission_rate DECIMAL(5,2) DEFAULT 1.0 AFTER bank_commission_rate;
