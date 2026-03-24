-- تحديث العروض بروابط المتاجر
-- استخدام store_url من المتجر إذا كان موجوداً، وإلا استخدام website_url

UPDATE deals d
INNER JOIN stores s ON d.store_id = s.id
SET d.store_url = COALESCE(s.store_url, s.website_url, 'https://www.example.com')
WHERE d.store_url IS NULL OR d.store_url = '';

-- أمثلة على روابط المتاجر (يمكن تحديثها حسب الحاجة)
UPDATE deals SET store_url = 'https://www.zara.com' WHERE store_id = 1;
UPDATE deals SET store_url = 'https://www.hm.com' WHERE store_id = 2;
UPDATE deals SET store_url = 'https://www.techbox.com' WHERE store_id = 3;
UPDATE deals SET store_url = 'https://www.homeplus.com' WHERE store_id = 4;
UPDATE deals SET store_url = 'https://www.glowbeauty.com' WHERE store_id = 5;
UPDATE deals SET store_url = 'https://www.activelife.com' WHERE store_id = 6;

