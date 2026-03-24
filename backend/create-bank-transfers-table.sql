CREATE TABLE IF NOT EXISTS bank_transfers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  transfer_date DATETIME NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  transferred_by VARCHAR(255),
  status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
