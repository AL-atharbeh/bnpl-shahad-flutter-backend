import { Store } from './entities/store.entity';

/** The terms a merchant accepts when submitting; bump when they change. */
export const TERMS_VERSION = '2026-11';

/** Documents a merchant can upload, and the store column each fills. */
export const DOCUMENT_TYPES = {
  'commercial-registration': 'docCommercialRegistration',
  'trade-license': 'docTradeLicense',
  'owner-id': 'docOwnerId',
} as const;
export type DocumentType = keyof typeof DOCUMENT_TYPES;

/**
 * Fields a vendor fixes once approved: who they are and where their money
 * goes. Changing them afterwards goes through an admin, so a stolen login
 * cannot redirect settlements.
 */
/**
 * A store an admin has approved at least once: live now, or suspended. Its
 * merchant can no longer change the vetted details or reapply their way out.
 */
export const hasBeenApproved = (status?: string) =>
  status === 'approved' || status === 'suspended';

export const LOCKED_AFTER_APPROVAL = [
  'legalName',
  'commercialRegistrationNo',
  'ownerNationalId',
  'bankName',
  'bankAccountHolder',
  'iban',
] as const;

/** Spaces and dashes out, letters upper-cased: how IBANs are written down. */
export function normalizeIban(raw: string): string {
  return (raw || '').replace(/[\s-]/g, '').toUpperCase();
}

/**
 * A Jordanian IBAN is JO, two check digits, a four-letter bank code and 22
 * account characters (30 in all), and must pass the ISO 13616 mod-97 check.
 */
export function isValidJordanIban(raw: string): boolean {
  const iban = normalizeIban(raw);
  if (!/^JO\d{2}[A-Z]{4}[A-Z0-9]{22}$/.test(iban)) return false;
  const rearranged = iban.slice(4) + iban.slice(0, 4);
  const digits = rearranged.replace(/[A-Z]/g, (c) => String(c.charCodeAt(0) - 55));
  let remainder = 0;
  for (const d of digits) remainder = (remainder * 10 + Number(d)) % 97;
  return remainder === 1;
}

/** Jordanian national numbers are ten digits. */
export function isValidNationalId(raw: string): boolean {
  return /^\d{10}$/.test((raw || '').trim());
}

/**
 * What still stops the application from being submitted, as field names the
 * apps can point at. Empty means it is complete.
 */
export function applicationMissing(store: Store): string[] {
  const missing: string[] = [];
  const need = (field: keyof Store, ok = Boolean(store[field] && String(store[field]).trim())) => {
    if (!ok) missing.push(field as string);
  };
  need('legalName');
  need('commercialRegistrationNo');
  need('city');
  need('ownerNationalId', isValidNationalId(store.ownerNationalId));
  need('bankName');
  need('bankAccountHolder');
  need('iban', isValidJordanIban(store.iban));
  need('docCommercialRegistration');
  need('docOwnerId');
  return missing;
}
