ALTER TABLE stores MODIFY bank_commission_rate decimal(5,2) NULL;
ALTER TABLE stores MODIFY platform_commission_rate decimal(5,2) NULL;
ALTER TABLE stores MODIFY commission_rate decimal(5,2) NULL;
ALTER TABLE payments MODIFY bank_commission_rate decimal(5,2) NULL;
ALTER TABLE payments MODIFY platform_commission_rate decimal(5,2) NULL;
