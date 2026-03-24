-- إضافة عروض جديدة إلى جدول deals
-- هذه العروض مرتبطة بالمتاجر والمنتجات الموجودة

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
  sort_order,
  store_url
) VALUES
-- عرض 1: Zara - خصم على الأزياء
(1, 66, 'Fashion Sale', 'عرض الأزياء', 
 'Up to 20% off on new arrivals', 'خصم حتى 20% على الموديلات الجديدة',
 'خصم', '20%', 
 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
 '#10B981', '#34D399',
 NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 1,
 (SELECT store_url FROM stores WHERE id = 1)),

-- عرض 2: H&M - مجموعة الصيف
(2, 67, 'Summer Collection', 'مجموعة الصيف',
 'Up to 40% off on summer items', 'خصم حتى 40% على مستلزمات الصيف',
 'خصم', '40%',
 'https://images.unsplash.com/photo-1520969136020-0fd56e9d7c1c?w=800',
 '#8B5CF6', '#A78BFA',
 NOW(), DATE_ADD(NOW(), INTERVAL 25 DAY), 1, 2,
 (SELECT store_url FROM stores WHERE id = 2)),

-- عرض 3: TechBox - خصم الإلكترونيات
(3, 68, 'Electronics Discount', 'خصم الإلكترونيات',
 'Free shipping on orders above 150 JOD', 'توصيل مجاني للطلبات فوق 150 دينار',
 'توصيل مجاني', '150+ JOD',
 'https://images.unsplash.com/photo-1512499617640-c2f999098c01?w=800',
 '#3B82F6', '#60A5FA',
 NOW(), DATE_ADD(NOW(), INTERVAL 45 DAY), 1, 3,
 (SELECT store_url FROM stores WHERE id = 3)),

-- عرض 4: HomePlus - عرض المنزل
(4, 69, 'Home Sale', 'عرض المنزل',
 'Special prices on furniture', 'أسعار خاصة على الأثاث',
 'خصم', '30%',
 'https://images.unsplash.com/photo-1505691723518-36a5ac3be353?w=800',
 '#F59E0B', '#FBBF24',
 NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1, 4,
 (SELECT store_url FROM stores WHERE id = 4)),

-- عرض 5: Glow Beauty - عرض الجمال
(5, 70, 'Beauty Special', 'عرض الجمال',
 'Buy 2 get 1 free on skincare', 'اشترِ 2 واحصل على الثالث مجانًا للعناية بالبشرة',
 '2+1', 'مجانًا',
 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800',
 '#EC4899', '#F472B6',
 NOW(), DATE_ADD(NOW(), INTERVAL 20 DAY), 1, 5,
 (SELECT store_url FROM stores WHERE id = 5)),

-- عرض 6: ActiveLife - عرض المعدات الرياضية
(6, 71, 'Sports Gear Sale', 'عرض المعدات الرياضية',
 'Discount on all sports equipment', 'خصم على جميع المعدات الرياضية',
 'خصم', '25%',
 'https://images.unsplash.com/photo-1526401281623-3596f992e09b?w=800',
 '#EF4444', '#F87171',
 NOW(), DATE_ADD(NOW(), INTERVAL 35 DAY), 1, 6,
 (SELECT store_url FROM stores WHERE id = 6)),

-- عرض 7: Zara - عرض خاص على الإكسسوارات
(1, 72, 'Accessories Sale', 'عرض الإكسسوارات',
 'Up to 35% off on accessories', 'خصم حتى 35% على الإكسسوارات',
 'خصم', '35%',
 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800',
 '#10B981', '#6EE7B7',
 NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 1, 7,
 (SELECT store_url FROM stores WHERE id = 1)),

-- عرض 8: TechBox - عرض الهواتف
(3, 73, 'Phone Discount', 'خصم الهواتف',
 'Special prices on smartphones', 'أسعار خاصة على الهواتف الذكية',
 'خصم', '15%',
 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800',
 '#3B82F6', '#93C5FD',
 NOW(), DATE_ADD(NOW(), INTERVAL 40 DAY), 1, 8,
 (SELECT store_url FROM stores WHERE id = 3)),

-- عرض 9: Glow Beauty - عرض العطور
(5, 74, 'Perfume Sale', 'عرض العطور',
 'Buy any perfume and get 20% off', 'اشترِ أي عطر واحصل على خصم 20%',
 'خصم', '20%',
 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800',
 '#EC4899', '#F9A8D4',
 NOW(), DATE_ADD(NOW(), INTERVAL 18 DAY), 1, 9,
 (SELECT store_url FROM stores WHERE id = 5)),

-- عرض 10: ActiveLife - عرض الملابس الرياضية
(6, 75, 'Sportswear Sale', 'عرض الملابس الرياضية',
 'Up to 30% off on sportswear', 'خصم حتى 30% على الملابس الرياضية',
 'خصم', '30%',
 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
 '#EF4444', '#FCA5A5',
 NOW(), DATE_ADD(NOW(), INTERVAL 28 DAY), 1, 10,
 (SELECT store_url FROM stores WHERE id = 6));

