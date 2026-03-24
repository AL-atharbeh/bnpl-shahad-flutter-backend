import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { Notification } from './entities/notification.entity';
import { InAppNotification } from './entities/in-app-notification.entity';
import { InAppNotificationsController } from './in-app-notifications.controller';
import { InAppNotificationsService } from './in-app-notifications.service';
import { FirebaseModule } from '../firebase/firebase.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification, InAppNotification]),
    FirebaseModule,
    UsersModule,
  ],
  controllers: [NotificationsController, InAppNotificationsController],
  providers: [
    NotificationsService,
    InAppNotificationsService,
  ],
  exports: [NotificationsService, InAppNotificationsService],
})
export class NotificationsModule { }

