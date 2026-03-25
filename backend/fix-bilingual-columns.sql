-- SQL Script to fix missing name_ar and description_ar columns if they don't exist
-- Run this on your database if you see "Column not found" errors in the search logs.

USE bnpl_db;

-- Fix Stores table
ALTER TABLE stores ADD COLUMN IF NOT EXISTS name_ar VARCHAR(255) AFTER name;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS description_ar TEXT AFTER description;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS deal_description_ar TEXT AFTER deal_description;

-- Fix Products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS name_ar VARCHAR(255) AFTER name;
ALTER TABLE products ADD COLUMN IF NOT EXISTS description_ar TEXT AFTER description;

-- Fix Categories table (if needed, though it seems to have it)
ALTER TABLE categories ADD COLUMN IF NOT EXISTS name_ar VARCHAR(255) AFTER name;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS description_ar TEXT AFTER description;

-- Success message
SELECT 'Bilingual columns verified/added successfully' AS message;
