import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostponementsController } from './postponements.controller';
import { PostponementsService } from './postponements.service';
import { Postponement } from './entities/postponement.entity';
import { PaymentsModule } from '../payments/payments.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Postponement]),
    forwardRef(() => PaymentsModule), // Use forwardRef to avoid circular dependency
    UsersModule,
  ],
  controllers: [PostponementsController],
  providers: [PostponementsService],
  exports: [PostponementsService],
})
export class PostponementsModule { }

