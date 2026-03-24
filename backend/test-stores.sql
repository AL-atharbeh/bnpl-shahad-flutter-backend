-- إضافة متاجر تجريبية لاختبار صفحة المتاجر

INSERT INTO stores (name, description, logo_url, category_id, top_store, is_active, created_at, updated_at) VALUES
('متاجر الربيع', 'متجر متخصص في الأزياء النسائية والإكسسوارات', 'https://via.placeholder.com/150', 1, true, true, NOW(), NOW()),
('إلكترونيات ميزو', 'أحدث الأجهزة الإلكترونية والهواتف الذكية', 'https://via.placeholder.com/150', 2, true, true, NOW(), NOW()),
('أثاث الفخامة', 'أثاث منزلي عصري وكلاسيكي', 'https://via.placeholder.com/150', 3, false, true, NOW(), NOW()),
('مكتبة المعرفة', 'كتب ومستلزمات مكتبية', 'https://via.placeholder.com/150', 4, false, true, NOW(), NOW()),
('رياضة برو', 'ملابس ومعدات رياضية', 'https://via.placeholder.com/150', 5, true, true, NOW(), NOW());
