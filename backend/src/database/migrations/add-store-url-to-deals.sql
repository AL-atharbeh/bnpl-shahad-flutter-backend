-- إضافة عمود store_url إلى جدول deals
ALTER TABLE deals ADD COLUMN store_url TEXT NULL AFTER image_url;

