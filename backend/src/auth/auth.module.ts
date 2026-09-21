import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuthController } from './auth.controller';
import { VendorAuthController } from './vendor-auth.controller';
import { AdminAuthController } from './admin-auth.controller';
import { AuthService } from './auth.service';
import { OtpService } from './otp.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { LocalStrategy } from './strategies/local.strategy';
import { RolesGuard } from './guards/roles.guard';

import { User } from '../users/entities/user.entity';
import { OtpCode } from '../users/entities/otp-code.entity';
import { Store } from '../stores/entities/store.entity';
import { Vendor } from '../vendors/entities/vendor.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, OtpCode, Store, Vendor]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => {
        const expiresIn = configService.get<string>('JWT_EXPIRES_IN') || 
                          configService.get<string>('JWT_EXPIRATION_TIME') || 
                          '3650d';
        const secret = configService.get<string>('JWT_SECRET');
        if (!secret) {
          // Signing with a hardcoded fallback would let anyone mint valid
          // tokens, so refuse to start instead.
          throw new Error('JWT_SECRET is not set');
        }

        return {
          secret,
          signOptions: {
            expiresIn,
          },
        };
      },
      inject: [ConfigService],
    }),
    UsersModule,
  ],
  controllers: [AuthController, VendorAuthController, AdminAuthController],
  providers: [AuthService, OtpService, JwtStrategy, LocalStrategy, RolesGuard],
  exports: [AuthService, OtpService, JwtStrategy, RolesGuard, PassportModule],
})
export class AuthModule { }

