import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommissionSettingsController } from './commission-settings.controller';
import { CommissionSettingsService } from './commission-settings.service';
import { CommissionSetting } from './entities/commission-setting.entity';

@Module({
    imports: [TypeOrmModule.forFeature([CommissionSetting])],
    controllers: [CommissionSettingsController],
    providers: [CommissionSettingsService],
    exports: [CommissionSettingsService],
})
export class CommissionSettingsModule { }
