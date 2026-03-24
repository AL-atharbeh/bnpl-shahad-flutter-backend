import { DataSource } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { Store } from '../stores/entities/store.entity';
import { Product } from '../products/entities/product.entity';
import { Payment } from '../payments/entities/payment.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { RewardPoint } from '../rewards/entities/reward-point.entity';
import { Postponement } from '../postponements/entities/postponement.entity';
import { OtpCode } from '../users/entities/otp-code.entity';
import { Category } from '../categories/entities/category.entity';
import { Deal } from '../deals/entities/deal.entity';
import { Banner } from '../banners/entities/banner.entity';
import { PromoNotification } from '../promo-notifications/entities/promo-notification.entity';
import { UserSecuritySetting } from '../users/entities/user-security-setting.entity';
import { ContactMessage } from '../contact/entities/contact-message.entity';
import { ContactSetting } from '../contact/entities/contact-setting.entity';

// TypeORM configuration for clear script (same as seed script)
const typeOrmConfigDirect = {
  type: 'mysql' as const,
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  username: process.env.DB_USERNAME || 'bnpl_user',
  password: process.env.DB_PASSWORD || 'bnpl_password',
  database: process.env.DB_DATABASE || 'bnpl_db',
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  synchronize: false, // Don't sync, tables should exist
  logging: false,
  timezone: 'Z',
  charset: 'utf8mb4',
};

async function clearAllData() {
  console.log('🗑️  Starting data cleanup...');

  // Create DataSource
  const dataSource = new DataSource(typeOrmConfigDirect);
  await dataSource.initialize();

  const userRepository = dataSource.getRepository(User);
  const storeRepository = dataSource.getRepository(Store);
  const productRepository = dataSource.getRepository(Product);
  const paymentRepository = dataSource.getRepository(Payment);
  const notificationRepository = dataSource.getRepository(Notification);
  const rewardPointRepository = dataSource.getRepository(RewardPoint);
  const postponementRepository = dataSource.getRepository(Postponement);
  const otpCodeRepository = dataSource.getRepository(OtpCode);
  const categoryRepository = dataSource.getRepository(Category);
  const dealRepository = dataSource.getRepository(Deal);
  const bannerRepository = dataSource.getRepository(Banner);
  const promoNotificationRepository = dataSource.getRepository(PromoNotification);
  const userSecuritySettingRepository = dataSource.getRepository(UserSecuritySetting);
  const contactMessageRepository = dataSource.getRepository(ContactMessage);
  const contactSettingRepository = dataSource.getRepository(ContactSetting);

  try {
    console.log('🗑️  Clearing all data...');

    // Delete in correct order (respecting foreign key constraints)
    // Start with dependent tables first
    
    await rewardPointRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared reward points');

    await postponementRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared postponements');

    await paymentRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared payments');

    await notificationRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared notifications');

    await userSecuritySettingRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared user security settings');

    await otpCodeRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared OTP codes');

    await dealRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared deals');

    await productRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared products');

    await bannerRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared banners');

    await promoNotificationRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared promo notifications');

    await storeRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared stores');

    await contactMessageRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared contact messages');

    await contactSettingRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared contact settings');

    await categoryRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared categories');

    await userRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    console.log('✅ Cleared users');

    console.log('');
    console.log('✅ All data cleared successfully!');
    console.log('📊 Database is now empty and ready for real data.');
    console.log('');
    console.log('💡 Next steps:');
    console.log('   - Users will be created through registration');
    console.log('   - Stores and Products should be added through admin panel');
    console.log('   - Payments will be created through actual transactions');
    console.log('');

  } catch (error) {
    console.error('❌ Error clearing data:', error);
    process.exit(1);
  } finally {
    await dataSource.destroy();
  }
}

// Run the script
clearAllData()
  .then(() => {
    console.log('✅ Cleanup completed!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Cleanup failed:', error);
    process.exit(1);
  });

