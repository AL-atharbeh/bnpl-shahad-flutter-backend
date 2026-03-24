import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { SecurityController } from './security.controller';
import { SecurityService } from './security.service';
import { User } from './entities/user.entity';
import { UserSecuritySetting } from './entities/user-security-setting.entity';
import { Payment } from '../payments/entities/payment.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, UserSecuritySetting, Payment])],
  controllers: [UsersController, SecurityController],
  providers: [UsersService, SecurityService],
  exports: [UsersService, SecurityService, TypeOrmModule],
})
export class UsersModule {}

