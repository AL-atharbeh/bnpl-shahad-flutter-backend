import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';

/**
 * Restricts a route to the given roles. Use together with JwtAuthGuard and
 * RolesGuard: @UseGuards(JwtAuthGuard, RolesGuard) @Roles('admin')
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
