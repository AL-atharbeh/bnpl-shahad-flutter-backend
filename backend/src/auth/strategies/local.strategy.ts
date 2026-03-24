import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-local';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      usernameField: 'phone',
      passwordField: 'code',
    });
  }

  async validate(phone: string, code: string): Promise<any> {
    // This strategy is not used in the current flow
    // OTP verification is handled by AuthService.verifyOtp
    throw new UnauthorizedException('Use OTP verification endpoint');
  }
}

