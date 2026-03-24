-- إضافة منتجات للمتاجر مع ربطها بالفئات
-- كل متجر سيحصل على 5-6 منتجات مرتبطة بفئته

-- منتجات لمتجر Zara (Fashion & Clothing - category_id = 1)
INSERT INTO products (store_id, name, name_ar, description, description_ar, price, currency, category, category_id, image_url, images, in_stock, rating, reviews_count, is_active, created_at, updated_at)
VALUES
(1, 'Classic White Shirt', 'قميص أبيض كلاسيكي', 'Premium cotton white shirt', 'قميص قطني عالي الجودة', 45.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1594938291221-94f18c8c1ec4?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1594938291221-94f18c8c1ec4?w=400'), 1, 4.5, 25, 1, NOW(), NOW()),
(1, 'Denim Jeans', 'بنطلون جينز', 'Classic blue denim jeans', 'بنطلون جينز أزرق كلاسيكي', 65.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1542272604-787c3835535d?w=400'), 1, 4.3, 18, 1, NOW(), NOW()),
(1, 'Leather Jacket', 'جاكيت جلدي', 'Genuine leather jacket', 'جاكيت جلدي أصلي', 120.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400'), 1, 4.7, 32, 1, NOW(), NOW()),
(1, 'Summer Dress', 'فستان صيفي', 'Light and comfortable summer dress', 'فستان صيفي خفيف ومريح', 55.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400'), 1, 4.6, 28, 1, NOW(), NOW()),
(1, 'Sneakers', 'حذاء رياضي', 'Comfortable running sneakers', 'حذاء رياضي مريح للجري', 75.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'), 1, 4.4, 22, 1, NOW(), NOW()),
(1, 'Winter Coat', 'معطف شتوي', 'Warm winter coat', 'معطف شتوي دافئ', 95.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400'), 1, 4.5, 20, 1, NOW(), NOW());

-- منتجات لمتجر H&M (Fashion & Clothing - category_id = 1)
INSERT INTO products (store_id, name, name_ar, description, description_ar, price, currency, category, category_id, image_url, images, in_stock, rating, reviews_count, is_active, created_at, updated_at)
VALUES
(2, 'Casual T-Shirt', 'قميص كاجوال', 'Comfortable casual t-shirt', 'قميص كاجوال مريح', 25.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'), 1, 4.2, 15, 1, NOW(), NOW()),
(2, 'Black Pants', 'بنطلون أسود', 'Classic black pants', 'بنطلون أسود كلاسيكي', 50.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400'), 1, 4.3, 19, 1, NOW(), NOW()),
(2, 'Hoodie', 'هودي', 'Warm and cozy hoodie', 'هودي دافئ ومريح', 60.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400'), 1, 4.5, 24, 1, NOW(), NOW()),
(2, 'Skirt', 'تنورة', 'Elegant skirt', 'تنورة أنيقة', 40.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400'), 1, 4.4, 17, 1, NOW(), NOW()),
(2, 'Sandals', 'صنادل', 'Comfortable summer sandals', 'صنادل صيفية مريحة', 35.00, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400'), 1, 4.1, 12, 1, NOW(), NOW());

-- منتجات لمتجر TechBox (Electronics - category_id = 2)
INSERT INTO products (store_id, name, name_ar, description, description_ar, price, currency, category, category_id, image_url, images, in_stock, rating, reviews_count, is_active, created_at, updated_at)
VALUES
(3, 'Smartphone', 'هاتف ذكي', 'Latest smartphone with advanced features', 'هاتف ذكي حديث بميزات متقدمة', 350.00, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400'), 1, 4.6, 45, 1, NOW(), NOW()),
(3, 'Laptop', 'لابتوب', 'High-performance laptop', 'لابتوب عالي الأداء', 650.00, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400'), 1, 4.7, 38, 1, NOW(), NOW()),
(3, 'Wireless Headphones', 'سماعات لاسلكية', 'Premium wireless headphones', 'سماعات لاسلكية عالية الجودة', 120.00, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'), 1, 4.5, 30, 1, NOW(), NOW()),
(3, 'Smart Watch', 'ساعة ذكية', 'Feature-rich smartwatch', 'ساعة ذكية غنية بالميزات', 200.00, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400'), 1, 4.4, 25, 1, NOW(), NOW()),
(3, 'Tablet', 'تابلت', '10-inch tablet with high resolution', 'تابلت 10 بوصة بدقة عالية', 280.00, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400'), 1, 4.3, 20, 1, NOW(), NOW());

-- منتجات لمتجر HomePlus (Home & Garden - category_id = 3)
INSERT INTO products (store_id, name, name_ar, description, description_ar, price, currency, category, category_id, image_url, images, in_stock, rating, reviews_count, is_active, created_at, updated_at)
VALUES
(4, 'Coffee Table', 'طاولة قهوة', 'Modern coffee table', 'طاولة قهوة عصرية', 150.00, 'JOD', 'Home & Garden', 3, 'https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=400'), 1, 4.5, 22, 1, NOW(), NOW()),
(4, 'Sofa Set', 'مجموعة أريكة', 'Comfortable 3-seater sofa', 'أريكة 3 مقاعد مريحة', 450.00, 'JOD', 'Home & Garden', 3, 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400'), 1, 4.6, 28, 1, NOW(), NOW()),
(4, 'Bed Frame', 'إطار سرير', 'Queen size bed frame', 'إطار سرير بحجم كوين', 320.00, 'JOD', 'Home & Garden', 3, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400'), 1, 4.4, 19, 1, NOW(), NOW()),
(4, 'Dining Table', 'طاولة طعام', '6-seater dining table', 'طاولة طعام لـ 6 أشخاص', 280.00, 'JOD', 'Home & Garden', 3, 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400'), 1, 4.5, 24, 1, NOW(), NOW()),
(4, 'Garden Chair', 'كرسي حديقة', 'Outdoor garden chair', 'كرسي حديقة خارجي', 85.00, 'JOD', 'Home & Garden', 3, 'https://images.unsplash.com/photo-1581539250439-c96689b516dd?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1581539250439-c96689b516dd?w=400'), 1, 4.3, 15, 1, NOW(), NOW());

-- منتجات لمتجر Glow Beauty (Beauty & Personal Care - category_id = 4)
INSERT INTO products (store_id, name, name_ar, description, description_ar, price, currency, category, category_id, image_url, images, in_stock, rating, reviews_count, is_active, created_at, updated_at)
VALUES
(5, 'Face Cream', 'كريم وجه', 'Moisturizing face cream', 'كريم وجه مرطب', 35.00, 'JOD', 'Beauty & Personal Care', 4, 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400'), 1, 4.5, 30, 1, NOW(), NOW()),
(5, 'Lipstick Set', 'مجموعة أحمر شفاه', '6-color lipstick set', 'مجموعة أحمر شفاه 6 ألوان', 45.00, 'JOD', 'Beauty & Personal Care', 4, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400'), 1, 4.6, 35, 1, NOW(), NOW()),
(5, 'Perfume', 'عطر', 'Luxury perfume 100ml', 'عطر فاخر 100 مل', 85.00, 'JOD', 'Beauty & Personal Care', 4, 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1541643600914-78b084683601?w=400'), 1, 4.7, 42, 1, NOW(), NOW()),
(5, 'Hair Shampoo', 'شامبو', 'Nourishing hair shampoo', 'شامبو مغذي للشعر', 25.00, 'JOD', 'Beauty & Personal Care', 4, 'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=400'), 1, 4.4, 28, 1, NOW(), NOW()),
(5, 'Makeup Brush Set', 'مجموعة فرش مكياج', 'Professional makeup brush set', 'مجموعة فرش مكياج احترافية', 55.00, 'JOD', 'Beauty & Personal Care', 4, 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400'), 1, 4.5, 32, 1, NOW(), NOW());

-- منتجات لمتجر ActiveLife (Sports & Outdoors - category_id = 5)
INSERT INTO products (store_id, name, name_ar, description, description_ar, price, currency, category, category_id, image_url, images, in_stock, rating, reviews_count, is_active, created_at, updated_at)
VALUES
(6, 'Running Shoes', 'حذاء جري', 'Professional running shoes', 'حذاء جري احترافي', 90.00, 'JOD', 'Sports & Outdoors', 5, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'), 1, 4.6, 40, 1, NOW(), NOW()),
(6, 'Yoga Mat', 'سجادة يوغا', 'Premium yoga mat', 'سجادة يوغا عالية الجودة', 45.00, 'JOD', 'Sports & Outdoors', 5, 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400'), 1, 4.5, 25, 1, NOW(), NOW()),
(6, 'Dumbbells Set', 'مجموعة دمبل', 'Adjustable dumbbells set', 'مجموعة دمبل قابلة للتعديل', 120.00, 'JOD', 'Sports & Outdoors', 5, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400'), 1, 4.4, 18, 1, NOW(), NOW()),
(6, 'Basketball', 'كرة سلة', 'Official size basketball', 'كرة سلة بالحجم الرسمي', 35.00, 'JOD', 'Sports & Outdoors', 5, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400'), 1, 4.3, 15, 1, NOW(), NOW()),
(6, 'Tennis Racket', 'مضرب تنس', 'Professional tennis racket', 'مضرب تنس احترافي', 95.00, 'JOD', 'Sports & Outdoors', 5, 'https://images.unsplash.com/photo-1622163642999-202ae431ed6b?w=400', JSON_ARRAY('https://images.unsplash.com/photo-1622163642999-202ae431ed6b?w=400'), 1, 4.5, 22, 1, NOW(), NOW());

-- تحديث عدد المنتجات في كل متجر
UPDATE stores s
SET s.products_count = (
  SELECT COUNT(*)
  FROM products p
  WHERE p.store_id = s.id AND p.is_active = 1
);

