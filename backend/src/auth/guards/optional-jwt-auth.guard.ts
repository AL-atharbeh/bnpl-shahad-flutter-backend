import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * For public routes that show more to a signed-in caller: lets every request
 * through, and sets req.user only when a valid token came with it.
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(_err: unknown, user: any) {
    return user || null;
  }
}
