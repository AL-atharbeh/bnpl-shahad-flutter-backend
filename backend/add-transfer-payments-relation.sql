-- Create junction table for many-to-many relationship
CREATE TABLE IF NOT EXISTS bank_transfer_payments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  bank_transfer_id INT NOT NULL,
  payment_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (bank_transfer_id) REFERENCES bank_transfers(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  UNIQUE KEY unique_transfer_payment (bank_transfer_id, payment_id)
);

-- Add index for better query performance
CREATE INDEX idx_bank_transfer_id ON bank_transfer_payments(bank_transfer_id);
CREATE INDEX idx_payment_id ON bank_transfer_payments(payment_id);
