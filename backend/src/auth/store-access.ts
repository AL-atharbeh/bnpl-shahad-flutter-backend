import { ForbiddenException } from '@nestjs/common';

/**
 * Who may act on which store. An admin acts on any store; a vendor only on
 * the store their account belongs to, whatever id the request names. The
 * vendor's store comes from JwtStrategy, which reads it from the database.
 */
export interface StoreActor {
  role?: string;
  storeId?: number;
}

/** Throws unless the actor may act on this store. */
export function assertStoreAccess(actor: StoreActor | undefined, storeId: number | string | undefined): void {
  if (actor?.role === 'admin') return;
  if (actor?.role === 'vendor' && actor.storeId && Number(storeId) === Number(actor.storeId)) return;
  throw new ForbiddenException('لا تملك صلاحية على هذا المتجر');
}

/**
 * The store a listing should cover: always the vendor's own; for an admin,
 * whichever store was asked for, or every store when none was.
 */
export function scopedStoreId(actor: StoreActor | undefined, storeId?: number | string): number | undefined {
  if (actor?.role === 'vendor') {
    if (!actor.storeId) throw new ForbiddenException('حساب التاجر غير مرتبط بمتجر');
    return Number(actor.storeId);
  }
  if (actor?.role !== 'admin') throw new ForbiddenException('لا تملك صلاحية على هذا المتجر');
  const parsed = storeId === undefined || storeId === '' ? NaN : Number(storeId);
  return Number.isFinite(parsed) ? parsed : undefined;
}

/** Store fields only the store itself and admins may see. */
export const PRIVATE_STORE_FIELDS = ['apiKey', 'apiSecret'] as const;

/** Copies a store without the fields the public must not see. */
export function publicStore<T extends Record<string, any>>(store: T): T {
  if (!store) return store;
  const copy: any = { ...store };
  for (const field of PRIVATE_STORE_FIELDS) delete copy[field];
  return copy;
}
