-- BNPL Database Tables Creation Script
-- This script creates all necessary tables for the BNPL application

USE bnpl_db;

-- Drop existing tables (in correct order due to foreign keys)
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS contact_messages;
DROP TABLE IF EXISTS contact_settings;
DROP TABLE IF EXISTS user_security_settings;
DROP TABLE IF EXISTS postponements;
DROP TABLE IF EXISTS rewards_points;
DROP TABLE IF EXISTS payment_installments;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS otp_codes;
DROP TABLE IF EXISTS users;

-- Users Table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(255) NULL UNIQUE,
  password_hash VARCHAR(255) NULL,
  civil_id_number VARCHAR(50) NULL UNIQUE,
  civil_id_front VARCHAR(500) NULL,
  civil_id_back VARCHAR(500) NULL,
  date_of_birth DATE NULL,
  address TEXT NULL,
  monthly_income DECIMAL(10,2) NULL,
  employer VARCHAR(255) NULL,
  avatar_url LONGTEXT NULL,
  free_postponement_count INT DEFAULT 0,
  days_since_last_postponement INT DEFAULT 0,
  otp VARCHAR(6) NULL,
  is_phone_verified BOOLEAN DEFAULT FALSE,
  country VARCHAR(2) DEFAULT 'JO',
  currency VARCHAR(3) DEFAULT 'JOD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_phone (phone),
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- OTP Codes Table
CREATE TABLE otp_codes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  phone VARCHAR(20) NOT NULL,
  code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_phone (phone),
  INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores Table
CREATE TABLE stores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  logo_url VARCHAR(500) NULL,
  description TEXT NULL,
  category VARCHAR(100) NULL,
  rating DECIMAL(3,2) DEFAULT 0.00,
  has_deal BOOLEAN DEFAULT FALSE,
  deal_description TEXT NULL,
  commission_rate DECIMAL(5,2) DEFAULT 0.00,
  min_order_amount DECIMAL(10,2) DEFAULT 0.00,
  max_order_amount DECIMAL(10,2) NULL,
  website_url VARCHAR(500) NULL,
  supported_countries JSON NULL,
  supported_currencies JSON NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_category (category),
  INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products Table
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  store_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url VARCHAR(500) NULL,
  category VARCHAR(100) NULL,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
  INDEX idx_store_id (store_id),
  INDEX idx_category (category),
  INDEX idx_is_available (is_available)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payments Table
CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  store_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  installments_count INT NOT NULL,
  installment_amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending', 'active', 'completed', 'cancelled', 'defaulted') DEFAULT 'active',
  currency VARCHAR(3) DEFAULT 'JOD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_store_id (store_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment Installments Table
CREATE TABLE payment_installments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payment_id INT NOT NULL,
  installment_number INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  due_date DATE NOT NULL,
  paid_date DATE NULL,
  status ENUM('pending', 'paid', 'overdue', 'postponed') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  INDEX idx_payment_id (payment_id),
  INDEX idx_due_date (due_date),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rewards Points Table
CREATE TABLE rewards_points (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  payment_id INT NULL,
  points INT NOT NULL,
  type ENUM('earned', 'redeemed', 'expired') DEFAULT 'earned',
  description TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Postponements Table
CREATE TABLE postponements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  installment_id INT NOT NULL,
  original_due_date DATE NOT NULL,
  new_due_date DATE NOT NULL,
  is_free BOOLEAN DEFAULT FALSE,
  reason TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (installment_id) REFERENCES payment_installments(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_installment_id (installment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contact Settings Table (Company Contact Information)
CREATE TABLE contact_settings (
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
CREATE TABLE contact_messages (
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

-- Notifications Table
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  type ENUM('payment_reminder', 'payment_success', 'reward_earned', 'system') DEFAULT 'system',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Security Settings Table
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

-- Success message
SELECT 'All tables created successfully!' AS message;

