-- Create Contact System Tables
-- Table 1: Contact Settings (Company Contact Information)
-- Table 2: Contact Messages (User Messages)

USE bnpl_db;

-- Contact Settings Table (Company Contact Information)
-- Contains email, phone, and WhatsApp number that can be updated
CREATE TABLE IF NOT EXISTS contact_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  contact_email VARCHAR(255) NOT NULL,
  contact_phone VARCHAR(20) NOT NULL,
  whatsapp_number VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_settings (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default contact settings
INSERT INTO contact_settings (contact_email, contact_phone, whatsapp_number)
VALUES ('info@bnpl.com', '+962791234567', '+962791234567')
ON DUPLICATE KEY UPDATE 
  contact_email = VALUES(contact_email),
  contact_phone = VALUES(contact_phone),
  whatsapp_number = VALUES(whatsapp_number);

-- Contact Messages Table (User Contact Messages)
-- Stores messages sent by users
CREATE TABLE IF NOT EXISTS contact_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  message TEXT NOT NULL,
  status ENUM('new', 'read', 'replied', 'archived') DEFAULT 'new',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Contact system tables created successfully!' AS message;

