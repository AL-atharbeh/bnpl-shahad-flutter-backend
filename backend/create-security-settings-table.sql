-- Security Settings Table for User PIN and Biometric
USE bnpl_db;

-- Drop table if exists
DROP TABLE IF EXISTS user_security_settings;

-- Create user_security_settings table
CREATE TABLE user_security_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  pin_hash VARCHAR(255) NULL COMMENT 'Hashed PIN (4 digits)',
  pin_enabled BOOLEAN DEFAULT FALSE,
  biometric_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings for existing users (optional)
-- INSERT INTO user_security_settings (user_id, pin_enabled, biometric_enabled)
-- SELECT id, FALSE, FALSE FROM users
-- ON DUPLICATE KEY UPDATE user_id = user_id;

SELECT 'Security settings table created successfully!' AS message;

