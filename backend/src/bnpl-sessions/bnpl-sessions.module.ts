import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BnplSessionsController } from './bnpl-sessions.controller';
import { BnplSessionsService } from './bnpl-sessions.service';
import { BnplSession } from './entities/bnpl-session.entity';
import { BnplSessionItem } from './entities/bnpl-session-item.entity';
import { Store } from '../stores/entities/store.entity';
import { PaymentsModule } from '../payments/payments.module';
import { UsersModule } from '../users/users.module';
import { RewardsModule } from '../rewards/rewards.module';
import { NotificationsModule } from '../notifications/notifications.module';

import { Product } from '../products/entities/product.entity';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
    imports: [
        TypeOrmModule.forFeature([BnplSession, BnplSessionItem, Store, Product]),
        forwardRef(() => PaymentsModule),
        UsersModule,
        RewardsModule,
        NotificationsModule,
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: (configService: ConfigService) => ({
                secret: configService.get('JWT_SECRET', 'your-secret-key'),
            }),
            inject: [ConfigService],
        }),
    ],
    controllers: [BnplSessionsController],
    providers: [BnplSessionsService],
    exports: [BnplSessionsService],
})
export class BnplSessionsModule { }
