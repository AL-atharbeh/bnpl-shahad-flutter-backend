import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Vendor } from './entities/vendor.entity';
import { VendorNotification } from './entities/vendor-notification.entity';
import { VendorNotificationsService } from './vendor-notifications.service';

@Module({
  imports: [TypeOrmModule.forFeature([Vendor, VendorNotification])],
  providers: [VendorNotificationsService],
  exports: [VendorNotificationsService],
})
export class VendorsModule {}
