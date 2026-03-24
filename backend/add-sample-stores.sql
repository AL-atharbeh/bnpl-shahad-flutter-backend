-- Sample Categories and Stores Seed Script
-- This script inserts sample categories and stores for the All Stores page.
-- It can be re-run safely; existing rows with the same primary key will be updated.

USE bnpl_db;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ===============================
-- 1. Seed Categories
-- ===============================
INSERT INTO categories (id, name, name_ar, icon, image_url, description, description_ar, is_active, sort_order)
VALUES
  (1, 'Fashion & Clothing', 'الأزياء والملابس', 'shopping_bag', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800', 'Trendy fashion brands and clothing stores.', 'أحدث ماركات الأزياء ومحلات الملابس.', TRUE, 1),
  (2, 'Electronics', 'الإلكترونيات', 'devices', 'https://images.unsplash.com/photo-1510552776732-03e61cf4b144?w=800', 'Smartphones, laptops, and gadgets.', 'هواتف ذكية، حواسيب، وأجهزة إلكترونية.', TRUE, 2),
  (3, 'Home & Furniture', 'المنزل والأثاث', 'home', 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800', 'Furniture, decor, and home essentials.', 'أثاث منزلي وديكورات واحتياجات المنزل.', TRUE, 3),
  (4, 'Beauty & Cosmetics', 'الجمال ومستحضرات التجميل', 'face', 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800', 'Beauty products and skincare.', 'منتجات الجمال والعناية بالبشرة.', TRUE, 4),
  (5, 'Sports & Outdoors', 'الرياضة والهواء الطلق', 'sports_soccer', 'https://images.unsplash.com/photo-1526401281623-3596f992e09b?w=800', 'Sports gear and outdoor equipment.', 'معدات رياضية ولوازم الهواء الطلق.', TRUE, 5)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  name_ar = VALUES(name_ar),
  icon = VALUES(icon),
  image_url = VALUES(image_url),
  description = VALUES(description),
  description_ar = VALUES(description_ar),
  is_active = VALUES(is_active),
  sort_order = VALUES(sort_order),
  updated_at = NOW();

-- ===============================
-- 2. Seed Stores
-- ===============================
INSERT INTO stores (
  id,
  name,
  name_ar,
  logo_url,
  description,
  description_ar,
  category,
  category_id,
  rating,
  has_deal,
  deal_description,
  deal_description_ar,
  website_url,
  store_url,
  supported_countries,
  supported_currencies,
  is_active
) VALUES
  (1, 'Zara', 'زارا', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200', 'High-street fashion brand offering clothing for men and women.', 'علامة أزياء عالمية تقدم ملابس للرجال والنساء.', 'Fashion & Clothing', 1, 4.6, TRUE, 'Up to 20% off on new arrivals', 'خصم حتى 20% على الموديلات الجديدة', 'https://www.zara.com', 'https://www.zara.com', JSON_ARRAY('JO', 'AE', 'SA'), JSON_ARRAY('JOD', 'USD'), TRUE),
  (2, 'H&M', 'إتش آند إم', 'https://images.unsplash.com/photo-1520969136020-0fd56e9d7c1c?w=200', 'Global fashion retailer with affordable clothing.', 'متجر أزياء عالمي يوفر ملابس بأسعار معقولة.', 'Fashion & Clothing', 1, 4.4, FALSE, NULL, NULL, 'https://www2.hm.com', 'https://www2.hm.com', JSON_ARRAY('JO'), JSON_ARRAY('JOD'), TRUE),
  (3, 'TechBox', 'تك بوكس', 'https://images.unsplash.com/photo-1512499617640-c2f999098c01?w=200', 'Electronics store for smartphones, laptops, and accessories.', 'متجر إلكترونيات للهواتف الذكية والحواسيب والإكسسوارات.', 'Electronics', 2, 4.8, TRUE, 'Free shipping on orders above 150 JOD', 'توصيل مجاني للطلبات فوق 150 دينار', 'https://www.techbox.example', 'https://www.techbox.example', JSON_ARRAY('JO'), JSON_ARRAY('JOD'), TRUE),
  (4, 'HomePlus', 'هوم بلس', 'https://images.unsplash.com/photo-1505691723518-36a5ac3be353?w=200', 'Furniture and home essentials for modern living.', 'أثاث واحتياجات منزلية للمعيشة العصرية.', 'Home & Furniture', 3, 4.5, FALSE, NULL, NULL, 'https://www.homeplus.example', 'https://www.homeplus.example', JSON_ARRAY('JO'), JSON_ARRAY('JOD'), TRUE),
  (5, 'Glow Beauty', 'جلو بيوتي', 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=200', 'Beauty and skincare store featuring premium brands.', 'متجر جمال وعناية بالبشرة يضم أفضل الماركات.', 'Beauty & Cosmetics', 4, 4.7, TRUE, 'Buy 2 get 1 free on skincare', 'اشترِ 2 واحصل على الثالث مجانًا للعناية بالبشرة', 'https://www.glowbeauty.example', 'https://www.glowbeauty.example', JSON_ARRAY('JO'), JSON_ARRAY('JOD'), TRUE),
  (6, 'ActiveLife', 'أكتف لايف', 'https://images.unsplash.com/photo-1526401281623-3596f992e09b?w=200', 'Sports and outdoor gear for all activities.', 'معدات رياضية ولوازم للأنشطة الخارجية.', 'Sports & Outdoors', 5, 4.3, FALSE, NULL, NULL, 'https://www.activelife.example', 'https://www.activelife.example', JSON_ARRAY('JO'), JSON_ARRAY('JOD'), TRUE)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  name_ar = VALUES(name_ar),
  logo_url = VALUES(logo_url),
  description = VALUES(description),
  description_ar = VALUES(description_ar),
  category = VALUES(category),
  category_id = VALUES(category_id),
  rating = VALUES(rating),
  has_deal = VALUES(has_deal),
  deal_description = VALUES(deal_description),
  deal_description_ar = VALUES(deal_description_ar),
  website_url = VALUES(website_url),
  store_url = VALUES(store_url),
  supported_countries = VALUES(supported_countries),
  supported_currencies = VALUES(supported_currencies),
  is_active = VALUES(is_active),
  updated_at = NOW();

-- ===============================
-- 3. Update categories stores_count
-- ===============================
UPDATE categories c
SET stores_count = (
  SELECT COUNT(*)
  FROM stores s
  WHERE s.category_id = c.id
    AND s.is_active = TRUE
);

-- ===============================
-- 4. Update stores products_count
-- ===============================
UPDATE stores s
SET products_count = (
  SELECT COUNT(*)
  FROM products p
  WHERE p.store_id = s.id
    AND p.is_active = TRUE
);
 
 
