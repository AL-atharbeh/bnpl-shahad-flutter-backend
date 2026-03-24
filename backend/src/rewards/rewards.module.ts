import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RewardsController } from './rewards.controller';
import { RewardsService } from './rewards.service';
import { RewardPoint } from './entities/reward-point.entity';

@Module({
  imports: [TypeOrmModule.forFeature([RewardPoint])],
  controllers: [RewardsController],
  providers: [RewardsService],
  exports: [RewardsService],
})
export class RewardsModule {}

