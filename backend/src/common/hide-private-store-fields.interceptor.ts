import { CallHandler, ExecutionContext, Injectable, NestInterceptor, SetMetadata } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable, map } from 'rxjs';

const SHOW_PRIVATE_STORE_FIELDS = 'showPrivateStoreFields';

/**
 * Lets a route return a store's private fields. Only for routes that already
 * check the caller is that store or an admin.
 */
export const ShowPrivateStoreFields = () => SetMetadata(SHOW_PRIVATE_STORE_FIELDS, true);

/** A store's API keys, and the application only it and admins may see. */
const HIDDEN = new Set([
  'apiKey',
  'apiSecret',
  'ownerNationalId',
  'bankName',
  'bankAccountHolder',
  'iban',
  'docCommercialRegistration',
  'docTradeLicense',
  'docOwnerId',
  'reviewNote',
]);

/**
 * Removes those fields from every response unless the route is marked with
 * @ShowPrivateStoreFields(). Stores travel inside many responses (home
 * deals, a customer's payments, products), so one safety net here beats
 * remembering to strip them in each place.
 */
@Injectable()
export class HidePrivateStoreFieldsInterceptor implements NestInterceptor {
  constructor(private readonly reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const show = this.reflector.getAllAndOverride<boolean>(SHOW_PRIVATE_STORE_FIELDS, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (show) return next.handle();
    return next.handle().pipe(map((body) => strip(body, new WeakSet())));
  }
}

function strip(value: unknown, seen: WeakSet<object>): unknown {
  if (!value || typeof value !== 'object' || value instanceof Date || Buffer.isBuffer(value)) {
    return value;
  }
  if (seen.has(value)) return value;
  seen.add(value);

  if (Array.isArray(value)) {
    for (const item of value) strip(item, seen);
    return value;
  }
  for (const key of Object.keys(value)) {
    if (HIDDEN.has(key)) delete (value as Record<string, unknown>)[key];
    else strip((value as Record<string, unknown>)[key], seen);
  }
  return value;
}
