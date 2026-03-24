-- Clear BNPL sessions and payments tables for testing

-- Delete all BNPL-related payments (order_id starts with 'order_sess_')
DELETE FROM payments WHERE order_id LIKE 'order_sess_%';

-- Delete all BNPL sessions
DELETE FROM bnpl_sessions;

-- Reset auto-increment (optional)
ALTER TABLE bnpl_sessions AUTO_INCREMENT = 1;

-- Verify deletion
SELECT COUNT(*) as sessions_count FROM bnpl_sessions;
SELECT COUNT(*) as bnpl_payments_count FROM payments WHERE order_id LIKE 'order_sess_%';
