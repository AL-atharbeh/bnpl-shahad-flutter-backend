SET NAMES utf8mb4;
USE bnpl_db;

INSERT INTO products (
  store_id,
  name,
  name_ar,
  description,
  description_ar,
  price,
  currency,
  category,
  category_id,
  image_url,
  images,
  in_stock,
  rating,
  reviews_count,
  is_active
) VALUES
  (1, 'Classic Fit Blazer', 'بلايزر كلاسيك', 'Tailored blazer for formal occasions.', 'بلايزر مصمم خصيصًا للمناسبات الرسمية.', 129.99, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800'), 1, 4.6, 120, 1),
  (1, 'Premium Denim Jeans', 'جينز دينم فاخر', 'High-quality denim jeans with comfortable stretch.', 'جينز عالي الجودة مع مرونة مريحة.', 69.50, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'), 1, 4.7, 95, 1),
  (2, 'Lightweight Hoodie', 'هودي خفيف', 'Soft cotton hoodie perfect for everyday wear.', 'هودي قطني ناعم مثالي للاستخدام اليومي.', 49.99, 'JOD', 'Fashion & Clothing', 1, 'https://images.unsplash.com/photo-1525171254930-643fc658b64e?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1525171254930-643fc658b64e?w=800'), 1, 4.4, 80, 1),
  (3, 'Wireless Earbuds', 'سماعات أذن لاسلكية', 'Noise-cancelling earbuds with long battery life.', 'سماعات أذن بإلغاء الضوضاء وبطارية طويلة الأمد.', 89.99, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=800'), 1, 4.8, 210, 1),
  (3, 'Smartphone Gimbal', 'مثبت للهاتف الذكي', 'Stabilizer gimbal for smooth mobile videography.', 'مثبت للهاتف الذكي لتصوير فيديو سلس.', 119.00, 'JOD', 'Electronics', 2, 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'), 1, 4.5, 64, 1),
  (4, 'Modern Sofa', 'أريكة عصرية', 'Three-seat sofa with premium fabric and cushions.', 'أريكة بثلاثة مقاعد مع قماش فاخر ووسائد.', 499.00, 'JOD', 'Home & Furniture', 3, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800'), 1, 4.3, 40, 1),
  (5, 'Luxury Skincare Set', 'مجموعة عناية فاخرة بالبشرة', 'Complete skincare routine kit with premium ingredients.', 'مجموعة كاملة للعناية بالبشرة بمكونات فاخرة.', 159.00, 'JOD', 'Beauty & Cosmetics', 4, 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800'), 1, 4.7, 105, 1),
  (6, 'Trail Running Shoes', 'حذاء للجري في الطرق الوعرة', 'Lightweight shoes designed for trail running.', 'حذاء خفيف مصمم للجري في الطرق الوعرة.', 119.99, 'JOD', 'Sports & Outdoors', 5, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600', JSON_ARRAY('https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'), 1, 4.6, 73, 1);

UPDATE stores SET products_count = (
  SELECT COUNT(*) FROM products WHERE products.store_id = stores.id AND products.is_active = 1
);
