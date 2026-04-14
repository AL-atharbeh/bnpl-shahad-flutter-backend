import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AppConfig } from './entities/app-config.entity';

@Injectable()
export class AppConfigService {
  constructor(
    @InjectRepository(AppConfig)
    private appConfigRepository: Repository<AppConfig>,
  ) {}

  async getSplashConfig() {
    let config = await this.appConfigRepository.findOne({ where: {} });
    if (!config) {
      // Create default if not exists
      config = this.appConfigRepository.create({
        splashImageUrl: null,
        maintenanceMode: false,
      });
      await this.appConfigRepository.save(config);
    }
    return {
      success: true,
      data: {
        splashImageUrl: config.splashImageUrl,
        updatedAt: config.updatedAt,
      },
    };
  }

  async updateSplashImage(imageUrl: string) {
    let config = await this.appConfigRepository.findOne({ where: {} });
    if (!config) {
      config = this.appConfigRepository.create({ splashImageUrl: imageUrl });
    } else {
      config.splashImageUrl = imageUrl;
    }
    await this.appConfigRepository.save(config);
    return {
      success: true,
      message: 'Splash screen updated successfully',
      data: config,
    };
  }

  async getConfig() {
    const config = await this.appConfigRepository.findOne({ where: {} });
    return {
      success: true,
      data: config,
    };
  }
}
