import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: any) {
    // Vendors are stored in their own table with their own id sequence, so the
    // claim decides which table to resolve against. Resolving every token
    // against users would let vendor N inherit whatever user N happens to be.
    if (payload.role === 'vendor') {
      const vendor = await this.authService.validateVendorById(payload.sub);

      return {
        id: vendor.id,
        phone: vendor.phone,
        role: 'vendor',
        storeId: vendor.storeId,
      };
    }

    const user = await this.authService.validateUserById(payload.sub);

    if (!user) {
      throw new UnauthorizedException('المستخدم غير موجود');
    }

    // The role comes from the database, not from the token, so an old token
    // cannot keep privileges that have since been revoked.
    return {
      id: user.id,
      phone: user.phone,
      role: user.role,
    };
  }
}
