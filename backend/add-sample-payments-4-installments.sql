-- Add sample payments for users from different stores
-- All payments must have 4 installments minimum
-- User ID 4 (phone: +962792380449)

-- Payment 1: Zara - 4 installments (100 JOD total)
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency, 
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 1, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 7 DAY), NOW(), NOW()),
-- Installment 2
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 2, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 37 DAY), NOW(), NOW()),
-- Installment 3
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 3, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 67 DAY), NOW(), NOW()),
-- Installment 4
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 4, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 97 DAY), NOW(), NOW());

-- Payment 2: H&M - 4 installments (120 JOD total)
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 1, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 5 DAY), NOW(), NOW()),
-- Installment 2
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 2, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 35 DAY), NOW(), NOW()),
-- Installment 3
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 3, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 65 DAY), NOW(), NOW()),
-- Installment 4
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 4, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 95 DAY), NOW(), NOW());

-- Payment 3: TechBox - 4 installments (182 JOD total)
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1
(4, 3, 'ORD-2025-003', 45.50, 'JOD', 4, 1, 182.00, 'bnpl', 'pending', 4.55, 40.95, DATE_ADD(NOW(), INTERVAL 10 DAY), NOW(), NOW()),
-- Installment 2
(4, 3, 'ORD-2025-003', 45.50, 'JOD', 4, 2, 182.00, 'bnpl', 'pending', 4.55, 40.95, DATE_ADD(NOW(), INTERVAL 40 DAY), NOW(), NOW()),
-- Installment 3
(4, 3, 'ORD-2025-003', 45.50, 'JOD', 4, 3, 182.00, 'bnpl', 'pending', 4.55, 40.95, DATE_ADD(NOW(), INTERVAL 70 DAY), NOW(), NOW()),
-- Installment 4
(4, 3, 'ORD-2025-003', 45.50, 'JOD', 4, 4, 182.00, 'bnpl', 'pending', 4.55, 40.95, DATE_ADD(NOW(), INTERVAL 100 DAY), NOW(), NOW());

-- Payment 4: HomePlus - 4 installments (160 JOD total)
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1
(4, 4, 'ORD-2025-004', 40.00, 'JOD', 4, 1, 160.00, 'bnpl', 'pending', 4.00, 36.00, DATE_ADD(NOW(), INTERVAL 3 DAY), NOW(), NOW()),
-- Installment 2
(4, 4, 'ORD-2025-004', 40.00, 'JOD', 4, 2, 160.00, 'bnpl', 'pending', 4.00, 36.00, DATE_ADD(NOW(), INTERVAL 33 DAY), NOW(), NOW()),
-- Installment 3
(4, 4, 'ORD-2025-004', 40.00, 'JOD', 4, 3, 160.00, 'bnpl', 'pending', 4.00, 36.00, DATE_ADD(NOW(), INTERVAL 63 DAY), NOW(), NOW()),
-- Installment 4
(4, 4, 'ORD-2025-004', 40.00, 'JOD', 4, 4, 160.00, 'bnpl', 'pending', 4.00, 36.00, DATE_ADD(NOW(), INTERVAL 93 DAY), NOW(), NOW());

-- Payment 5: Glow Beauty - 4 installments (63 JOD total)
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1
(4, 5, 'ORD-2025-005', 15.75, 'JOD', 4, 1, 63.00, 'bnpl', 'pending', 1.58, 14.17, DATE_ADD(NOW(), INTERVAL 1 DAY), NOW(), NOW()),
-- Installment 2
(4, 5, 'ORD-2025-005', 15.75, 'JOD', 4, 2, 63.00, 'bnpl', 'pending', 1.58, 14.17, DATE_ADD(NOW(), INTERVAL 31 DAY), NOW(), NOW()),
-- Installment 3
(4, 5, 'ORD-2025-005', 15.75, 'JOD', 4, 3, 63.00, 'bnpl', 'pending', 1.58, 14.17, DATE_ADD(NOW(), INTERVAL 61 DAY), NOW(), NOW()),
-- Installment 4
(4, 5, 'ORD-2025-005', 15.75, 'JOD', 4, 4, 63.00, 'bnpl', 'pending', 1.58, 14.17, DATE_ADD(NOW(), INTERVAL 91 DAY), NOW(), NOW());

