-- Add Price Compare promo notification
INSERT INTO promo_notifications (
  title,
  title_ar,
  subtitle,
  subtitle_ar,
  background_color,
  text_color,
  category_id,
  link_type,
  link_id,
  link_url,
  is_active,
  sort_order,
  click_count,
  created_at,
  updated_at
) VALUES (
  'Price Compare',
  'مقارنة الأسعار',
  'Compare prices across different stores and find the best deals',
  'قارن الأسعار بين المتاجر المختلفة واعثر على أفضل العروض',
  '#10B981',
  '#FFFFFF',
  NULL, -- Global notification (not tied to a specific category)
  'none', -- No link (or change to 'external' with link_url if needed)
  NULL,
  NULL, -- Can add URL here if link_type is 'external'
  1, -- Active
  0, -- Sort order
  0, -- Initial click count
  NOW(),
  NOW()
);

