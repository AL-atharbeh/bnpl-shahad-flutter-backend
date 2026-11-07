-- Adds the merchant application to stores: business and owner details, bank
-- account for settlements, document files, terms acceptance and the admin's
-- review note. Safe to run more than once.

ALTER TABLE stores
  ADD COLUMN IF NOT EXISTS legal_name varchar(255),
  ADD COLUMN IF NOT EXISTS commercial_registration_no varchar(50),
  ADD COLUMN IF NOT EXISTS trade_license_no varchar(50),
  ADD COLUMN IF NOT EXISTS city varchar(100),
  ADD COLUMN IF NOT EXISTS owner_national_id varchar(20),
  ADD COLUMN IF NOT EXISTS bank_name varchar(100),
  ADD COLUMN IF NOT EXISTS bank_account_holder varchar(255),
  ADD COLUMN IF NOT EXISTS iban varchar(34),
  ADD COLUMN IF NOT EXISTS doc_commercial_registration varchar(255),
  ADD COLUMN IF NOT EXISTS doc_trade_license varchar(255),
  ADD COLUMN IF NOT EXISTS doc_owner_id varchar(255),
  ADD COLUMN IF NOT EXISTS terms_accepted_at timestamp,
  ADD COLUMN IF NOT EXISTS terms_version varchar(20),
  ADD COLUMN IF NOT EXISTS application_submitted_at timestamp,
  ADD COLUMN IF NOT EXISTS review_note text;

SELECT count(*) AS application_columns
  FROM information_schema.columns
 WHERE table_name = 'stores'
   AND column_name IN ('legal_name','commercial_registration_no','trade_license_no','city',
     'owner_national_id','bank_name','bank_account_holder','iban','doc_commercial_registration',
     'doc_trade_license','doc_owner_id','terms_accepted_at','terms_version',
     'application_submitted_at','review_note');
