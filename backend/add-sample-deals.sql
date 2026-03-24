-- Add sample deals to the deals table
-- These deals are linked to existing stores and products

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
-- Deal 1: Zara Fashion (store_id=1, using product_id=60)
(1, 60, 'Fashion Sale', 'عرض الأزياء', 
 'Up to 20% off on new arrivals', 'خصم حتى 20% على الموديلات الجديدة',
 'خصم', '20%', 
 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
 '#10B981', '#34D399',
 NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 1),

-- Deal 2: TechBox Electronics (store_id=3, using product_id=62)
(3, 62, 'Electronics Discount', 'خصم الإلكترونيات',
 'Free shipping on orders above 150 JOD', 'توصيل مجاني للطلبات فوق 150 دينار',
 'توصيل مجاني', '150+ JOD',
 'https://images.unsplash.com/photo-1512499617640-c2f999098c01?w=400',
 '#3B82F6', '#60A5FA',
 NOW(), DATE_ADD(NOW(), INTERVAL 45 DAY), 1, 2),

-- Deal 3: Glow Beauty (store_id=5, using product_id=64)
(5, 64, 'Beauty Special', 'عرض الجمال',
 'Buy 2 get 1 free on skincare', 'اشترِ 2 واحصل على الثالث مجانًا للعناية بالبشرة',
 '2+1', 'مجانًا',
 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400',
 '#EC4899', '#F472B6',
 NOW(), DATE_ADD(NOW(), INTERVAL 20 DAY), 1, 3),

-- Deal 4: HomePlus (store_id=4, using product_id=63)
(4, 63, 'Home Sale', 'عرض المنزل',
 'Special prices on furniture', 'أسعار خاصة على الأثاث',
 'خصم', '30%',
 'https://images.unsplash.com/photo-1505691723518-36a5ac3be353?w=400',
 '#F59E0B', '#FBBF24',
 NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1, 4),

-- Deal 5: H&M Fashion (store_id=2, using product_id=61)
(2, 61, 'Summer Collection', 'مجموعة الصيف',
 'Up to 40% off on summer items', 'خصم حتى 40% على مستلزمات الصيف',
 'خصم', '40%',
 'https://images.unsplash.com/photo-1520969136020-0fd56e9d7c1c?w=400',
 '#8B5CF6', '#A78BFA',
 NOW(), DATE_ADD(NOW(), INTERVAL 25 DAY), 1, 5),

-- Deal 6: ActiveLife Sports (store_id=6, using product_id=65)
(6, 65, 'Sports Gear Sale', 'عرض المعدات الرياضية',
 'Discount on all sports equipment', 'خصم على جميع المعدات الرياضية',
 'خصم', '25%',
 'https://images.unsplash.com/photo-1526401281623-3596f992e09b?w=400',
 '#EF4444', '#F87171',
 NOW(), DATE_ADD(NOW(), INTERVAL 35 DAY), 1, 6);
