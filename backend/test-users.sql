-- إضافة مستخدمين تجريبيين لاختبار صفحة المستخدمين

INSERT INTO users (name, phone, email, password_hash, is_phone_verified, is_active, role, created_at, updated_at) VALUES
('أحمد العتيبي', '+96550001234', 'ahmed@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', true, true, 'user', NOW(), NOW()),
('سارة المطيري', '+96551112233', 'sara@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', true, true, 'user', NOW(), NOW()),
('محمد النجار', '+96552223344', 'mohammed@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', false, false, 'user', NOW(), NOW()),
('ليلى خليل', '+96553334455', 'layla@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', true, true, 'user', NOW(), NOW()),
('خالد المطيري', '+96554445566', 'khalid@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', true, true, 'user', NOW(), NOW());
