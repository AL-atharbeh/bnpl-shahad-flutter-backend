-- Add sample payments for users from different stores
-- User ID 4 (phone: +962792380449)

-- Payment 1: Zara - 4 installments
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency, 
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES (
  4, 1, 'ORD-2025-001', 25.00, 'JOD',
  4, 1, 100.00,
  'bnpl', 'pending', 2.50, 22.50,
  DATE_ADD(NOW(), INTERVAL 7 DAY), NOW(), NOW()
),
(
  4, 1, 'ORD-2025-001', 25.00, 'JOD',
  4, 2, 100.00,
  'bnpl', 'pending', 2.50, 22.50,
  DATE_ADD(NOW(), INTERVAL 37 DAY), NOW(), NOW()
),
(
  4, 1, 'ORD-2025-001', 25.00, 'JOD',
  4, 3, 100.00,
  'bnpl', 'pending', 2.50, 22.50,
  DATE_ADD(NOW(), INTERVAL 67 DAY), NOW(), NOW()
),
(
  4, 1, 'ORD-2025-001', 25.00, 'JOD',
  4, 4, 100.00,
  'bnpl', 'pending', 2.50, 22.50,
  DATE_ADD(NOW(), INTERVAL 97 DAY), NOW(), NOW()
);

-- Payment 2: H&M - 3 installments
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES (
  4, 2, 'ORD-2025-002', 30.00, 'JOD',
  3, 1, 90.00,
  'bnpl', 'pending', 3.00, 27.00,
  DATE_ADD(NOW(), INTERVAL 5 DAY), NOW(), NOW()
),
(
  4, 2, 'ORD-2025-002', 30.00, 'JOD',
  3, 2, 90.00,
  'bnpl', 'pending', 3.00, 27.00,
  DATE_ADD(NOW(), INTERVAL 35 DAY), NOW(), NOW()
),
(
  4, 2, 'ORD-2025-002', 30.00, 'JOD',
  3, 3, 90.00,
  'bnpl', 'pending', 3.00, 27.00,
  DATE_ADD(NOW(), INTERVAL 65 DAY), NOW(), NOW()
);

-- Payment 3: TechBox - Single payment
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES (
  4, 3, 'ORD-2025-003', 45.50, 'JOD',
  1, 1, 45.50,
  'bnpl', 'pending', 4.55, 40.95,
  DATE_ADD(NOW(), INTERVAL 10 DAY), NOW(), NOW()
);

-- Payment 4: HomePlus - 2 installments
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES (
  4, 4, 'ORD-2025-004', 40.00, 'JOD',
  2, 1, 80.00,
  'bnpl', 'pending', 4.00, 36.00,
  DATE_ADD(NOW(), INTERVAL 3 DAY), NOW(), NOW()
),
(
  4, 4, 'ORD-2025-004', 40.00, 'JOD',
  2, 2, 80.00,
  'bnpl', 'pending', 4.00, 36.00,
  DATE_ADD(NOW(), INTERVAL 33 DAY), NOW(), NOW()
);

-- Payment 5: Glow Beauty - Single payment (due soon)
INSERT INTO payments (
  user_id, store_id, order_id, amount, currency,
  installments_count, installment_number, total_amount,
  payment_method, status, commission, store_amount,
  due_date, created_at, updated_at
) VALUES (
  4, 5, 'ORD-2025-005', 15.75, 'JOD',
  1, 1, 15.75,
  'bnpl', 'pending', 1.58, 14.17,
  DATE_ADD(NOW(), INTERVAL 1 DAY), NOW(), NOW()
);

