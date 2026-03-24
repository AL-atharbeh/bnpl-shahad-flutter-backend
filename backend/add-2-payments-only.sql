-- Clear all existing payments for user ID 4
DELETE FROM payments WHERE user_id = 4;

-- Add only 2 payments from 2 different stores
-- Each payment has 4 installments
-- User ID 4 (phone: +962792380449)

-- ===============================
-- Payment 1: Zara (Store ID: 1)
-- Total: 100 JOD (4 installments of 25 JOD each)
-- ===============================
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency, 
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1 (Due in 7 days)
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 1, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 7 DAY), NOW(), NOW()),
-- Installment 2 (Due in 37 days)
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 2, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 37 DAY), NOW(), NOW()),
-- Installment 3 (Due in 67 days)
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 3, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 67 DAY), NOW(), NOW()),
-- Installment 4 (Due in 97 days)
(4, 1, 'ORD-2025-001', 25.00, 'JOD', 4, 4, 100.00, 'bnpl', 'pending', 2.50, 22.50, DATE_ADD(NOW(), INTERVAL 97 DAY), NOW(), NOW());

-- ===============================
-- Payment 2: H&M (Store ID: 2)
-- Total: 120 JOD (4 installments of 30 JOD each)
-- ===============================
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES 
-- Installment 1 (Due in 5 days)
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 1, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 5 DAY), NOW(), NOW()),
-- Installment 2 (Due in 35 days)
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 2, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 35 DAY), NOW(), NOW()),
-- Installment 3 (Due in 65 days)
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 3, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 65 DAY), NOW(), NOW()),
-- Installment 4 (Due in 95 days)
(4, 2, 'ORD-2025-002', 30.00, 'JOD', 4, 4, 120.00, 'bnpl', 'pending', 3.00, 27.00, DATE_ADD(NOW(), INTERVAL 95 DAY), NOW(), NOW());

-- Summary:
-- Total payments: 2 orders
-- Total installments: 8 (4 per order)
-- Stores: Zara (ID: 1) and H&M (ID: 2)
-- User: ID 4 (phone: +962792380449)

