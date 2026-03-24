-- إضافة عمود show_in_home إلى جدول deals
-- إذا كان 1، يتم عرض العرض في الصفحة الرئيسية
-- إذا كان 0، لا يتم عرضه في الصفحة الرئيسية

ALTER TABLE deals ADD COLUMN show_in_home TINYINT(1) DEFAULT 1 AFTER is_active;

-- تحديث العروض الموجودة: أول 6 عروض فقط تظهر في الصفحة الرئيسية
UPDATE deals SET show_in_home = 1 WHERE id IN (19, 20, 21, 22, 23, 24);
UPDATE deals SET show_in_home = 0 WHERE id IN (25, 26, 27, 28);

