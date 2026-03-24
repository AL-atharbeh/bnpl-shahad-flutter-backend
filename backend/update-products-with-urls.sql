-- تحديث المنتجات بروابط المنتجات
-- استخدام روابط المتاجر كأساس وإضافة مسار المنتج

UPDATE products p
INNER JOIN stores s ON p.store_id = s.id
SET p.product_url = CONCAT(
  COALESCE(s.store_url, s.website_url, 'https://www.example.com'),
  '/product/',
  p.id
)
WHERE p.product_url IS NULL OR p.product_url = '';

-- أمثلة على روابط المنتجات (يمكن تحديثها حسب الحاجة)
-- Zara products
UPDATE products SET product_url = CONCAT('https://www.zara.com/jp/en/product/', id) WHERE store_id = 1;
-- H&M products
UPDATE products SET product_url = CONCAT('https://www2.hm.com/en_us/productpage.', id, '.html') WHERE store_id = 2;
-- TechBox products
UPDATE products SET product_url = CONCAT('https://www.techbox.example/products/', id) WHERE store_id = 3;
-- HomePlus products
UPDATE products SET product_url = CONCAT('https://www.homeplus.example/product/', id) WHERE store_id = 4;
-- Glow Beauty products
UPDATE products SET product_url = CONCAT('https://www.glowbeauty.example/products/', id) WHERE store_id = 5;
-- ActiveLife products
UPDATE products SET product_url = CONCAT('https://www.activelife.example/products/', id) WHERE store_id = 6;

