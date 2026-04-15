import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import configuration from './config/configuration';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { StoresModule } from './stores/stores.module';
import { ProductsModule } from './products/products.module';
import { CategoriesModule } from './categories/categories.module';
import { PromoNotificationsModule } from './promo-notifications/promo-notifications.module';
import { HomeModule } from './home/home.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PaymentsModule } from './payments/payments.module';
import { ContactModule } from './contact/contact.module';
import { DealsModule } from './deals/deals.module';
import { BnplSessionsModule } from './bnpl-sessions/bnpl-sessions.module';
import { PostponementsModule } from './postponements/postponements.module';
import { BankTransfersModule } from './bank-transfers/bank-transfers.module';
import { CommissionSettingsModule } from './commission-settings/commission-settings.module';
import { SettlementsModule } from './settlements/settlements.module';
import { ProfitDistributionModule } from './profit-distribution/profit-distribution.module';
import { ReportsModule } from './reports/reports.module';
import { BannersModule } from './banners/banners.module';
import { AppConfigModule } from './app-config/app-config.module';
import { SavedCardsModule } from './saved-cards/saved-cards.module';

@Module({
  imports: [
    ConfigModule.forRoot({ load: [configuration], isGlobal: true }),
    DatabaseModule,
    UsersModule,
    AuthModule,
    StoresModule,
    ProductsModule,
    CategoriesModule,
    PromoNotificationsModule,
    HomeModule,
    NotificationsModule,
    PaymentsModule,
    ContactModule,
    DealsModule,
    BnplSessionsModule,
    PostponementsModule,
    BankTransfersModule,
    CommissionSettingsModule,
    SettlementsModule,
    ProfitDistributionModule,
    ReportsModule,
    BannersModule,
    AppConfigModule,
    SavedCardsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }

