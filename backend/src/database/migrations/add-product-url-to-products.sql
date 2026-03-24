-- إضافة عمود product_url إلى جدول products
ALTER TABLE products ADD COLUMN product_url TEXT NULL AFTER image_url;

