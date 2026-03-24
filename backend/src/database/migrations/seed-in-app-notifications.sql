-- Seed In-App Notifications with Sample Data
-- إضافة بيانات تجريبية في جدول in_app_notifications

-- أولاً: إضافة إشعارات في جدول notifications (إذا لم تكن موجودة)
-- نحتاج معرف المستخدم الأول (user_id = 4) - يمكنك تغييره حسب المستخدم المطلوب

-- إضافة إشعارات تجريبية في جدول notifications
INSERT IGNORE INTO `notifications` (
  `user_id`,
  `title`,
  `title_ar`,
  `message`,
  `message_ar`,
  `type`,
  `is_read`,
  `read_at`,
  `metadata`,
  `created_at`
) VALUES
-- إشعار 1: قسط مستحق
(4, 'Payment Due Soon', 'قسط مستحق قريباً', 
 'Your payment of 150 JOD is due in 3 days', 
 'قسطك البالغ 150 دينار مستحق خلال 3 أيام',
 'payment', 0, NULL, NULL, NOW() - INTERVAL 2 HOUR),

-- إشعار 2: عرض جديد
(4, 'New Offer Available', 'عرض جديد متاح',
 'Check out our new offers from Zara',
 'اطلع على عروضنا الجديدة من زارا',
 'offer', 0, NULL, NULL, NOW() - INTERVAL 4 HOUR),

-- إشعار 3: تم الدفع
(4, 'Payment Completed', 'تم الدفع',
 'Your payment of 89.99 JOD has been completed',
 'تم إتمام دفعتك البالغة 89.99 دينار',
 'payment', 1, NOW() - INTERVAL 1 DAY, NULL, NOW() - INTERVAL 1 DAY),

-- إشعار 4: نقاط مكتسبة
(4, 'Reward Points Earned', 'نقاط مكتسبة',
 'You earned 89 points from your last payment',
 'لقد ربحت 89 نقطة من آخر دفعة',
 'system', 0, NULL, '{"points": 89}', NOW() - INTERVAL 2 DAY),

-- إشعار 5: ترحيب
(4, 'Welcome to BNPL', 'مرحباً بك في BNPL',
 'Start shopping and pay later with flexible installments',
 'ابدأ التسوق وادفع لاحقاً بأقساط مرنة',
 'system', 1, NOW() - INTERVAL 5 DAY, NULL, NOW() - INTERVAL 5 DAY),

-- إشعار 6: تحديث أمني
(4, 'Security Update', 'تحديث أمني',
 'Your security settings have been updated',
 'تم تحديث إعدادات الأمان الخاصة بك',
 'security', 0, NULL, NULL, NOW() - INTERVAL 3 DAY),

-- إشعار 7: عروض خاصة
(4, 'Special Offer', 'عروض خاصة',
 'Get 20% off on all clothing items',
 'احصل على خصم 20% على جميع الألبسة',
 'offer', 1, NOW() - INTERVAL 5 DAY, NULL, NOW() - INTERVAL 5 DAY),

-- إشعار 8: تنبيه عام
(4, 'General Alert', 'تنبيه عام',
 'New features have been released',
 'تم إطلاق ميزات جديدة',
 'system', 0, NULL, NULL, NOW() - INTERVAL 10 DAY);

-- ثانياً: إضافة إشعارات في جدول in_app_notifications مرتبطة بالإشعارات أعلاه
-- نحتاج معرفات الإشعارات التي أضفناها للتو

INSERT IGNORE INTO `in_app_notifications` (
  `notification_id`,
  `user_id`,
  `is_displayed`,
  `displayed_at`,
  `is_clicked`,
  `clicked_at`,
  `priority`,
  `category`,
  `action_button_text`,
  `action_url`,
  `expires_at`,
  `metadata`,
  `created_at`,
  `updated_at`
)
SELECT 
  n.id AS notification_id,
  n.user_id,
  CASE WHEN n.is_read = 1 THEN 1 ELSE 0 END AS is_displayed,
  CASE WHEN n.is_read = 1 THEN n.read_at ELSE NULL END AS displayed_at,
  0 AS is_clicked,
  NULL AS clicked_at,
  CASE 
    WHEN n.type = 'payment' THEN 'high'
    WHEN n.type = 'security' THEN 'urgent'
    WHEN n.type = 'offer' THEN 'medium'
    ELSE 'low'
  END AS priority,
  n.type AS category,
  CASE 
    WHEN n.type = 'payment' THEN 'عرض التفاصيل'
    WHEN n.type = 'offer' THEN 'عرض العروض'
    ELSE NULL
  END AS action_button_text,
  CASE 
    WHEN n.type = 'payment' THEN '/payments'
    WHEN n.type = 'offer' THEN '/offers'
    ELSE NULL
  END AS action_url,
  CASE 
    WHEN n.type = 'offer' THEN DATE_ADD(NOW(), INTERVAL 7 DAY)
    ELSE NULL
  END AS expires_at,
  n.metadata,
  n.created_at,
  NOW() AS updated_at
FROM `notifications` n
WHERE n.user_id = 4
  AND n.id NOT IN (SELECT notification_id FROM `in_app_notifications`)
ORDER BY n.created_at DESC
LIMIT 8;

SELECT '✅ Sample in-app notifications added successfully!' AS message;
SELECT CONCAT('📊 Total in-app notifications: ', COUNT(*)) AS stats FROM `in_app_notifications`;

