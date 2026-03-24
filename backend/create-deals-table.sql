USE bnpl_db;

CREATE TABLE IF NOT EXISTS deals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  store_id INT NOT NULL,
  product_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  title_ar VARCHAR(255) NULL,
  description TEXT NULL,
  description_ar TEXT NULL,
  discount_label VARCHAR(120) NULL,
  discount_value VARCHAR(120) NULL,
  image_url TEXT NULL,
  badge_color VARCHAR(12) NULL,
  accent_color VARCHAR(12) NULL,
  start_date DATETIME NULL,
  end_date DATETIME NULL,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_deals_store FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
  CONSTRAINT fk_deals_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO deals (
  store_id,
  product_id,
  title,
  title_ar,
  description,
  description_ar,
  discount_label,
  discount_value,
  image_url,
  badge_color,
  accent_color,
  start_date,
  end_date,
  is_active,
  sort_order
) VALUES
  (1, 296, 'Seasonal Essentials', 'عروض الموسم', 'Save on the latest fashion essentials.', 'وفر على أحدث الصيحات.', '20% OFF', '20%', 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=900', '#D1FAE5', '#10B981', NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), TRUE, 1),
  (1, 297, 'Denim Upgrade', 'ترقية الدنيم', 'Premium denim buy one get one 50% off.', 'جينز فاخر اشتر واحدة واحصل على الثانية بنصف السعر.', 'BOGO 50%', '50%', 'https://images.unsplash.com/photo-1475180098004-ca77a66827be?w=900', '#A7F3D0', '#34D399', NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY), TRUE, 2),
  (2, 298, 'Everyday Comfort', 'راحة يومية', 'Soft hoodies at a special introductory price.', 'هوديات ناعمة بسعر افتتاحي خاص.', 'Intro JD 39', '39', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=900', '#FDE68A', '#F59E0B', NOW(), DATE_ADD(NOW(), INTERVAL 21 DAY), TRUE, 3),
  (3, 299, 'Tech Upgrade', 'ترقية تقنية', 'Bundle discount on earbuds & accessories.', 'خصم على السماعات والإكسسوارات.', 'Bundle', 'Bundle', 'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=900', '#FBCFE8', '#EC4899', NOW(), DATE_ADD(NOW(), INTERVAL 21 DAY), TRUE, 4),
  (3, 300, 'Creator Essentials', 'أساسيات صانعي المحتوى', 'Stabilizers & gear with free shipping.', 'مثبتات ومعدات مع شحن مجاني.', 'Free Shipping', 'Free', 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=900', '#E0E7FF', '#6366F1', NOW(), DATE_ADD(NOW(), INTERVAL 25 DAY), TRUE, 5),
  (4, 301, 'Living Room Refresh', 'تجديد غرفة المعيشة', 'Modern sofas with complimentary cushions.', 'أرائك عصرية مع وسائد مجانية.', 'Gift Included', 'Gift', 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=900', '#FFE4E6', '#F43F5E', NOW(), DATE_ADD(NOW(), INTERVAL 18 DAY), TRUE, 6),
  (5, 302, 'Skincare Glow', 'بشرة متألقة', 'Premium skincare kit limited offer.', 'عرض محدود على مجموعة العناية بالبشرة.', '15% OFF', '15%', 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=900', '#FFE4E6', '#F43F5E', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), TRUE, 7),
  (6, 303, 'Run The Trails', 'انطلق في الممرات', 'Trail shoes bundled with water bottle.', 'أحذية الطرق الوعرة مع زجاجة ماء مجانية.', 'Bundle', 'Bundle', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900', '#DCFCE7', '#22C55E', NOW(), DATE_ADD(NOW(), INTERVAL 12 DAY), TRUE, 8);
