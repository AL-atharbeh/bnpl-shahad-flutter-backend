USE bnpl_db;

ALTER TABLE stores
  ADD COLUMN products_count INT NOT NULL DEFAULT 0 AFTER is_active;

UPDATE stores s
LEFT JOIN (
  SELECT store_id, COUNT(*) AS cnt
  FROM products
  WHERE is_active = 1
  GROUP BY store_id
) p ON p.store_id = s.id
SET s.products_count = COALESCE(p.cnt, 0);
