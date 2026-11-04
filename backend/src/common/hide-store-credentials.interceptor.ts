import { CallHandler, ExecutionContext, Injectable, NestInterceptor, SetMetadata } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable, map } from 'rxjs';

const SHOW_STORE_CREDENTIALS = 'showStoreCredentials';

/**
 * Lets a route return store API keys. Only for routes that already check the
 * caller is that store or an admin.
 */
export const ShowStoreCredentials = () => SetMetadata(SHOW_STORE_CREDENTIALS, true);

const HIDDEN = new Set(['apiKey', 'apiSecret']);

/**
 * Removes store API keys from every response unless the route is marked
 * with @ShowStoreCredentials(). Stores travel inside many responses (home
 * deals, a customer's payments, products), so one safety net here beats
 * remembering to strip them in each place.
 */
@Injectable()
export class HideStoreCredentialsInterceptor implements NestInterceptor {
  constructor(private readonly reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const show = this.reflector.getAllAndOverride<boolean>(SHOW_STORE_CREDENTIALS, [
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
