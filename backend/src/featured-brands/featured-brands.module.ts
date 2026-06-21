import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FeaturedBrand } from './entities/featured-brand.entity';
import { FeaturedBrandsService } from './featured-brands.service';
import { FeaturedBrandsController } from './featured-brands.controller';

@Module({
  imports: [TypeOrmModule.forFeature([FeaturedBrand])],
  controllers: [FeaturedBrandsController],
  providers: [FeaturedBrandsService],
  exports: [FeaturedBrandsService],
})
export class FeaturedBrandsModule {}
