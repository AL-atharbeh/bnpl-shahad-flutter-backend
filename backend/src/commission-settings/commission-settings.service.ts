import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommissionSetting } from './entities/commission-setting.entity';

@Injectable()
export class CommissionSettingsService {
    constructor(
        @InjectRepository(CommissionSetting)
        private commissionSettingRepository: Repository<CommissionSetting>,
    ) { }

    async getCurrentSettings() {
        const settings = await this.commissionSettingRepository.findOne({
            where: {},
            order: { effectiveFrom: 'DESC' },
        });

        return {
            success: true,
            data: settings || {
                bankCommission: 0.03,
                platformCommission: 0.02,
                storeDiscount: 0.05,
            },
        };
    }

    async updateSettings(data: {
        bankCommission: number;
        platformCommission: number;
        storeDiscount?: number;
        createdBy?: string;
    }) {
        const newSettings = this.commissionSettingRepository.create({
            ...data,
            effectiveFrom: new Date(),
        });

        await this.commissionSettingRepository.save(newSettings);

        return {
            success: true,
            message: 'Commission settings updated successfully',
            data: newSettings,
        };
    }

    async getSettingsHistory() {
        const history = await this.commissionSettingRepository.find({
            order: { effectiveFrom: 'DESC' },
            take: 10,
        });

        return {
            success: true,
            data: history,
        };
    }
}
