-- SQL Migration Script to enable Dynamic Commission System
-- This script makes the commission columns nullable so that stores can fallback to global settings.

-- 1. Alter Stores table
ALTER TABLE stores MODIFY bank_commission_rate decimal(5,2) NULL;
ALTER TABLE stores MODIFY platform_commission_rate decimal(5,2) NULL;
ALTER TABLE stores MODIFY commission_rate decimal(5,2) NULL;

-- 2. Alter Payments table (for historical consistency and fallbacks)
ALTER TABLE payments MODIFY bank_commission_rate decimal(5,2) NULL;
ALTER TABLE payments MODIFY platform_commission_rate decimal(5,2) NULL;

-- 3. [Optional] Reset existing stores that have the old default (3.0 and 2.0) to NULL 
-- so they immediately start following your Global Settings.
-- UPDATE stores SET bank_commission_rate = NULL WHERE bank_commission_rate = 3.0;
-- UPDATE stores SET platform_commission_rate = NULL WHERE platform_commission_rate = 2.0;
