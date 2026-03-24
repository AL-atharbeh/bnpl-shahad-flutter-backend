import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StoresController } from './stores.controller';
import { StoresService } from './stores.service';
import { Store } from './entities/store.entity';
import { ProductsModule } from '../products/products.module';
import { Deal } from '../deals/entities/deal.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Store, Deal]), ProductsModule],
  controllers: [StoresController],
  providers: [StoresService],
  exports: [StoresService],
})
export class StoresModule {}

