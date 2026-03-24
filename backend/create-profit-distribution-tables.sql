-- Commission Settings Table
CREATE TABLE IF NOT EXISTS commission_settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  bank_commission DECIMAL(5,4) NOT NULL DEFAULT 0.0300,
  platform_commission DECIMAL(5,4) NOT NULL DEFAULT 0.0200,
  store_discount DECIMAL(5,4) NOT NULL DEFAULT 0.0500,
  effective_from DATETIME NOT NULL,
  created_by VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Settlements Table
CREATE TABLE IF NOT EXISTS settlements (
  id INT PRIMARY KEY AUTO_INCREMENT,
  settlement_date DATETIME NOT NULL,
  total_collected DECIMAL(10,2) NOT NULL,
  bank_share DECIMAL(10,2) NOT NULL,
  platform_share DECIMAL(10,2) NOT NULL,
  status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Settlement Payments Junction Table
CREATE TABLE IF NOT EXISTS settlement_payments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  settlement_id INT NOT NULL,
  payment_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (settlement_id) REFERENCES settlements(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  UNIQUE KEY unique_settlement_payment (settlement_id, payment_id)
);

-- Add indexes
CREATE INDEX idx_settlement_id ON settlement_payments(settlement_id);
CREATE INDEX idx_payment_id_settlement ON settlement_payments(payment_id);
CREATE INDEX idx_effective_from ON commission_settings(effective_from);

-- Insert default commission settings
INSERT INTO commission_settings (bank_commission, platform_commission, store_discount, effective_from, created_by)
VALUES (0.0300, 0.0200, 0.0500, NOW(), 'System')
ON DUPLICATE KEY UPDATE id=id;
