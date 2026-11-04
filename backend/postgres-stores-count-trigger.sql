-- Keeps categories.stores_count right on Postgres.
--
-- add-stores-count-to-categories.sql maintained the column with MySQL
-- triggers, which were not carried over when the database moved to
-- Postgres, so every category showed 0 stores in the admin panel.
--
-- Instead of adding and subtracting one, the trigger recounts the affected
-- categories, so a missed event can never leave a count wrong for good.
-- Safe to run more than once.

CREATE OR REPLACE FUNCTION refresh_category_stores_count() RETURNS trigger AS $$
BEGIN
  UPDATE categories c
     SET stores_count = (
           SELECT count(*) FROM stores s
            WHERE s.category_id = c.id AND s.is_active
         )
   WHERE c.id IN (
           CASE WHEN TG_OP <> 'INSERT' THEN OLD.category_id END,
           CASE WHEN TG_OP <> 'DELETE' THEN NEW.category_id END
         );
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS stores_refresh_category_count ON stores;
CREATE TRIGGER stores_refresh_category_count
AFTER INSERT OR DELETE OR UPDATE OF category_id, is_active ON stores
FOR EACH ROW EXECUTE FUNCTION refresh_category_stores_count();

-- Bring every existing count up to date.
UPDATE categories c
   SET stores_count = (
         SELECT count(*) FROM stores s
          WHERE s.category_id = c.id AND s.is_active
       );

SELECT c.name_ar, c.stores_count FROM categories c WHERE c.stores_count > 0;
