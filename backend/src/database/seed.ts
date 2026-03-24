import { DataSource } from 'typeorm';
import { Store } from '../stores/entities/store.entity';
import { Product } from '../products/entities/product.entity';
import { Payment } from '../payments/entities/payment.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { RewardPoint } from '../rewards/entities/reward-point.entity';
import { User } from '../users/entities/user.entity';
import * as bcrypt from 'bcrypt';

/**
 * Seed script to populate database with sample data
 * Run: npm run seed
 */

// TypeORM configuration for seed script
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

const storesData = [
  {
    name: 'Zara',
    nameAr: 'زارا',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Zara-Logo.png',
    description: 'Spanish clothing retailer',
    descriptionAr: 'متجر ملابس إسباني',
    category: 'Fashion',
    rating: 4.8,
    hasDeal: true,
    dealDescription: '10% OFF on selected items',
    dealDescriptionAr: 'خصم 10% على أصناف مختارة',
    commissionRate: 2.5,
    minOrderAmount: 50,
    maxOrderAmount: 5000,
  },
  {
    name: 'H&M',
    nameAr: 'إتش أند إم',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/HM-Logo.png',
    description: 'Swedish clothing retailer',
    descriptionAr: 'متجر ملابس سويدي',
    category: 'Fashion',
    rating: 4.6,
    hasDeal: true,
    dealDescription: '15% OFF on new collection',
    dealDescriptionAr: 'خصم 15% على المجموعة الجديدة',
    commissionRate: 2.5,
    minOrderAmount: 50,
    maxOrderAmount: 3000,
  },
  {
    name: 'Nike',
    nameAr: 'نايك',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Nike-Logo.png',
    description: 'American sportswear company',
    descriptionAr: 'شركة أمريكية للملابس الرياضية',
    category: 'Sports',
    rating: 4.9,
    hasDeal: true,
    dealDescription: '20% OFF on sports shoes',
    dealDescriptionAr: 'خصم 20% على الأحذية الرياضية',
    commissionRate: 3.0,
    minOrderAmount: 75,
    maxOrderAmount: 5000,
  },
  {
    name: 'Adidas',
    nameAr: 'أديداس',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Adidas-Logo.png',
    description: 'German sportswear company',
    descriptionAr: 'شركة ألمانية للملابس الرياضية',
    category: 'Sports',
    rating: 4.7,
    hasDeal: false,
    commissionRate: 3.0,
    minOrderAmount: 75,
    maxOrderAmount: 5000,
  },
  {
    name: 'Apple Store',
    nameAr: 'متجر أبل',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Apple-Logo.png',
    description: 'Premium electronics and devices',
    descriptionAr: 'إلكترونيات وأجهزة راقية',
    category: 'Electronics',
    rating: 4.9,
    hasDeal: true,
    dealDescription: '5% OFF on iPhone 15',
    dealDescriptionAr: 'خصم 5% على iPhone 15',
    commissionRate: 1.5,
    minOrderAmount: 100,
    maxOrderAmount: 10000,
  },
  {
    name: 'Samsung',
    nameAr: 'سامسونج',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/06/Samsung-Logo.png',
    description: 'Korean electronics company',
    descriptionAr: 'شركة إلكترونيات كورية',
    category: 'Electronics',
    rating: 4.5,
    hasDeal: true,
    dealDescription: '12% OFF on Galaxy series',
    dealDescriptionAr: 'خصم 12% على سلسلة Galaxy',
    commissionRate: 2.0,
    minOrderAmount: 100,
    maxOrderAmount: 8000,
  },
  {
    name: 'Amazon',
    nameAr: 'أمازون',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Amazon-Logo.png',
    description: 'Online marketplace',
    descriptionAr: 'سوق إلكتروني',
    category: 'Shopping',
    rating: 4.8,
    hasDeal: true,
    dealDescription: 'Free shipping on orders above 50 JD',
    dealDescriptionAr: 'شحن مجاني على الطلبات فوق 50 دينار',
    commissionRate: 2.5,
    minOrderAmount: 25,
    maxOrderAmount: 10000,
  },
  {
    name: 'IKEA',
    nameAr: 'إيكيا',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/IKEA-Logo.png',
    description: 'Swedish furniture retailer',
    descriptionAr: 'متجر أثاث سويدي',
    category: 'Furniture',
    rating: 4.6,
    hasDeal: false,
    commissionRate: 2.0,
    minOrderAmount: 100,
    maxOrderAmount: 15000,
  },
  {
    name: 'Virgin Megastore',
    nameAr: 'فيرجن ميغاستور',
    logoUrl: 'https://via.placeholder.com/200x100?text=Virgin',
    description: 'Books, music, and entertainment',
    descriptionAr: 'كتب وموسيقى وترفيه',
    category: 'Books',
    rating: 4.4,
    hasDeal: true,
    dealDescription: '25% OFF on books',
    dealDescriptionAr: 'خصم 25% على الكتب',
    commissionRate: 3.5,
    minOrderAmount: 20,
    maxOrderAmount: 2000,
  },
  {
    name: 'Jarir Bookstore',
    nameAr: 'جرير',
    logoUrl: 'https://via.placeholder.com/200x100?text=Jarir',
    description: 'Books and office supplies',
    descriptionAr: 'كتب ومستلزمات مكتبية',
    category: 'Books',
    rating: 4.5,
    hasDeal: true,
    dealDescription: '15% OFF on stationery',
    dealDescriptionAr: 'خصم 15% على القرطاسية',
    commissionRate: 3.0,
    minOrderAmount: 15,
    maxOrderAmount: 1500,
  },
  {
    name: 'Carrefour',
    nameAr: 'كارفور',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Carrefour-Logo.png',
    description: 'Hypermarket chain',
    descriptionAr: 'سلسلة هايبرماركت',
    category: 'Groceries',
    rating: 4.3,
    hasDeal: true,
    dealDescription: 'Buy 2 Get 1 Free on selected items',
    dealDescriptionAr: 'اشتري 2 واحصل على 1 مجاناً على أصناف مختارة',
    commissionRate: 1.5,
    minOrderAmount: 30,
    maxOrderAmount: 5000,
  },
  {
    name: 'Nike Outlet',
    nameAr: 'نايك أوتليت',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Nike-Logo.png',
    description: 'Nike outlet store with discounts',
    descriptionAr: 'متجر نايك للمنتجات المخفضة',
    category: 'Sports',
    rating: 4.7,
    hasDeal: true,
    dealDescription: 'Up to 40% OFF',
    dealDescriptionAr: 'خصم يصل إلى 40%',
    commissionRate: 2.5,
    minOrderAmount: 50,
    maxOrderAmount: 3000,
  },
  {
    name: 'Sephora',
    nameAr: 'سيفورا',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Sephora-Logo.png',
    description: 'Beauty and cosmetics',
    descriptionAr: 'مستحضرات تجميل',
    category: 'Beauty',
    rating: 4.6,
    hasDeal: true,
    dealDescription: '20% OFF on beauty products',
    dealDescriptionAr: 'خصم 20% على منتجات التجميل',
    commissionRate: 3.0,
    minOrderAmount: 40,
    maxOrderAmount: 4000,
  },
  {
    name: 'Home Center',
    nameAr: 'هوم سنتر',
    logoUrl: 'https://via.placeholder.com/200x100?text=HomeCenter',
    description: 'Home improvement and decoration',
    descriptionAr: 'تحسين وتزيين المنزل',
    category: 'Home & Garden',
    rating: 4.5,
    hasDeal: false,
    commissionRate: 2.0,
    minOrderAmount: 60,
    maxOrderAmount: 6000,
  },
  {
    name: 'Toys R Us',
    nameAr: 'تويز آر أص',
    logoUrl: 'https://logos-world.net/wp-content/uploads/2020/04/Toys-R-Us-Logo.png',
    description: 'Toys and games',
    descriptionAr: 'ألعاب وألعاب أطفال',
    category: 'Toys',
    rating: 4.4,
    hasDeal: true,
    dealDescription: '30% OFF on toys',
    dealDescriptionAr: 'خصم 30% على الألعاب',
    commissionRate: 3.5,
    minOrderAmount: 25,
    maxOrderAmount: 2000,
  },
];

const productsByCategory = {
  Fashion: [
    { name: 'Cotton T-Shirt', nameAr: 'قميص قطني', price: 25.99, category: 'T-Shirts' },
    { name: 'Jeans', nameAr: 'بنطلون جينز', price: 79.99, category: 'Pants' },
    { name: 'Sneakers', nameAr: 'أحذية رياضية', price: 120.00, category: 'Shoes' },
    { name: 'Winter Jacket', nameAr: 'جاكيت شتوي', price: 199.99, category: 'Outerwear' },
    { name: 'Summer Dress', nameAr: 'فستان صيفي', price: 65.99, category: 'Dresses' },
    { name: 'Handbag', nameAr: 'حقيبة يد', price: 89.99, category: 'Accessories' },
  ],
  Sports: [
    { name: 'Running Shoes', nameAr: 'أحذية جري', price: 150.00, category: 'Footwear' },
    { name: 'Basketball', nameAr: 'كرة سلة', price: 45.00, category: 'Equipment' },
    { name: 'Yoga Mat', nameAr: 'سجادة يوغا', price: 35.99, category: 'Accessories' },
    { name: 'Gym Bag', nameAr: 'حقيبة نادي رياضي', price: 55.00, category: 'Accessories' },
    { name: 'Tennis Racket', nameAr: 'مضرب تنس', price: 120.00, category: 'Equipment' },
  ],
  Electronics: [
    { name: 'iPhone 15 Pro', nameAr: 'آيفون 15 برو', price: 1200.00, category: 'Smartphones' },
    { name: 'Samsung Galaxy S24', nameAr: 'سامسونج جالاكسي إس 24', price: 900.00, category: 'Smartphones' },
    { name: 'AirPods Pro', nameAr: 'إيربودز برو', price: 250.00, category: 'Audio' },
    { name: 'MacBook Pro', nameAr: 'ماك بوك برو', price: 2500.00, category: 'Laptops' },
    { name: 'iPad Air', nameAr: 'آيباد إير', price: 650.00, category: 'Tablets' },
  ],
  Books: [
    { name: 'Programming Book', nameAr: 'كتاب برمجة', price: 45.00, category: 'Technology' },
    { name: 'Novel', nameAr: 'رواية', price: 25.00, category: 'Fiction' },
    { name: 'Cookbook', nameAr: 'كتاب طبخ', price: 35.00, category: 'Cooking' },
    { name: 'Children Book', nameAr: 'كتاب أطفال', price: 15.00, category: 'Children' },
  ],
  Furniture: [
    { name: 'Office Chair', nameAr: 'كرسي مكتب', price: 200.00, category: 'Seating' },
    { name: 'Desk', nameAr: 'مكتب', price: 350.00, category: 'Furniture' },
    { name: 'Bookshelf', nameAr: 'رف كتب', price: 150.00, category: 'Storage' },
  ],
  Beauty: [
    { name: 'Lipstick', nameAr: 'أحمر شفاه', price: 25.00, category: 'Makeup' },
    { name: 'Perfume', nameAr: 'عطر', price: 80.00, category: 'Fragrance' },
    { name: 'Skincare Set', nameAr: 'مجموعة عناية بالبشرة', price: 120.00, category: 'Skincare' },
  ],
  Groceries: [
    { name: 'Organic Milk', nameAr: 'حليب عضوي', price: 8.50, category: 'Dairy' },
    { name: 'Bread', nameAr: 'خبز', price: 2.00, category: 'Bakery' },
    { name: 'Chicken', nameAr: 'دجاج', price: 12.00, category: 'Meat' },
  ],
  Toys: [
    { name: 'LEGO Set', nameAr: 'مجموعة ليغو', price: 85.00, category: 'Building' },
    { name: 'Action Figure', nameAr: 'شخصية حركية', price: 35.00, category: 'Action' },
    { name: 'Puzzle', nameAr: 'بازل', price: 25.00, category: 'Games' },
  ],
  'Home & Garden': [
    { name: 'Plant Pot', nameAr: 'أصيص نبات', price: 15.00, category: 'Garden' },
    { name: 'Wall Clock', nameAr: 'ساعة حائط', price: 45.00, category: 'Decor' },
  ],
};

async function seedDatabase() {
  console.log('🌱 Starting database seeding...');

  // Create DataSource
  const dataSource = new DataSource(typeOrmConfigDirect);
  await dataSource.initialize();

  const userRepository = dataSource.getRepository(User);
  const storeRepository = dataSource.getRepository(Store);
  const productRepository = dataSource.getRepository(Product);
  const paymentRepository = dataSource.getRepository(Payment);
  const notificationRepository = dataSource.getRepository(Notification);
  const rewardPointRepository = dataSource.getRepository(RewardPoint);

  try {
    // Clear existing data (optional - comment out if you want to keep existing data)
    console.log('🗑️  Clearing existing data...');
    // Use query builder for safe deletion
    await rewardPointRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    await paymentRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    await notificationRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    await productRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    await storeRepository
      .createQueryBuilder()
      .delete()
      .where('1 = 1')
      .execute();
    // Delete test user if exists
    await userRepository
      .createQueryBuilder()
      .delete()
      .where('phone = :phone', { phone: '+962799999999' })
      .execute();
    console.log('✅ Existing data cleared');

    // Seed Stores
    console.log('📦 Seeding stores...');
    const stores = [];
    for (const storeData of storesData) {
      const store = storeRepository.create({
        ...storeData,
        supportedCountries: ['JO'],
        supportedCurrencies: ['JOD'],
      });
      const savedStore = await storeRepository.save(store);
      stores.push(savedStore);
      console.log(`  ✅ Created store: ${storeData.name}`);
    }
    console.log(`✅ Created ${stores.length} stores`);

    // Seed Products
    console.log('🛍️  Seeding products...');
    let productCount = 0;
    for (const store of stores) {
      const categoryProducts = productsByCategory[store.category as keyof typeof productsByCategory] || [];
      const productsToAdd = categoryProducts.slice(0, Math.min(6, categoryProducts.length));

      for (const productData of productsToAdd) {
        const product = productRepository.create({
          storeId: store.id,
          name: productData.name,
          nameAr: productData.nameAr,
          description: `Quality ${productData.name}`,
          descriptionAr: `${productData.nameAr} عالي الجودة`,
          price: productData.price,
          currency: 'JOD',
          category: productData.category,
          imageUrl: `https://via.placeholder.com/400x400?text=${encodeURIComponent(productData.name)}`,
          images: [
            `https://via.placeholder.com/400x400?text=${encodeURIComponent(productData.name)}`,
          ],
          inStock: true,
          rating: 4.0 + Math.random() * 1.0, // Random rating between 4.0 and 5.0
          reviewsCount: Math.floor(Math.random() * 100),
          isActive: true,
        });
        await productRepository.save(product);
        productCount++;
      }
      console.log(`  ✅ Added ${productsToAdd.length} products to ${store.name}`);
    }
    console.log(`✅ Created ${productCount} products`);

    // Create a test user for sample payments and notifications
    console.log('👤 Creating test user...');
    const testPassword = await bcrypt.hash('password123', 10);
    const testUser = userRepository.create({
      name: 'Test User',
      phone: '+962799999999',
      email: 'test@example.com',
      passwordHash: testPassword,
      isPhoneVerified: true,
      country: 'JO',
      currency: 'JOD',
      role: 'user',
      isActive: true,
    });
    const savedUser = await userRepository.save(testUser);
    console.log(`  ✅ Created test user: ${testUser.name} (ID: ${savedUser.id})`);

    // Seed Sample Payments (for test user) with installments
    console.log('💳 Seeding sample payments...');
    const samplePayments = [
      // ============ Zara Order: 4 installments (orderId: ZARA-ORD-001) ============
      // Payment 1: Zara - Installment 1/4
      {
        userId: savedUser.id,
        storeId: stores[0].id, // Zara
        orderId: 'ZARA-ORD-001', // Same orderId for all 4 installments
        amount: 37.50, // 150 / 4 = 37.50
        totalAmount: 150.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 1,
        dueDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000), // 3 days from now
      },
      // Payment 2: Zara - Installment 2/4
      {
        userId: savedUser.id,
        storeId: stores[0].id, // Zara
        orderId: 'ZARA-ORD-001',
        amount: 37.50,
        totalAmount: 150.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 2,
        dueDate: new Date(Date.now() + 33 * 24 * 60 * 60 * 1000), // 30 days after first
      },
      // Payment 3: Zara - Installment 3/4
      {
        userId: savedUser.id,
        storeId: stores[0].id, // Zara
        orderId: 'ZARA-ORD-001',
        amount: 37.50,
        totalAmount: 150.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 3,
        dueDate: new Date(Date.now() + 63 * 24 * 60 * 60 * 1000), // 60 days after first
      },
      // Payment 4: Zara - Installment 4/4
      {
        userId: savedUser.id,
        storeId: stores[0].id, // Zara
        orderId: 'ZARA-ORD-001',
        amount: 37.50,
        totalAmount: 150.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 4,
        dueDate: new Date(Date.now() + 93 * 24 * 60 * 60 * 1000), // 90 days after first
      },
      
      // ============ Nike Order: 4 installments (orderId: NIKE-ORD-001) ============
      // Payment 5: Nike - Installment 1/4
      {
        userId: savedUser.id,
        storeId: stores[2].id, // Nike
        orderId: 'NIKE-ORD-001',
        amount: 62.50, // 250 / 4 = 62.50
        totalAmount: 250.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 1,
        dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
      },
      // Payment 6: Nike - Installment 2/4
      {
        userId: savedUser.id,
        storeId: stores[2].id, // Nike
        orderId: 'NIKE-ORD-001',
        amount: 62.50,
        totalAmount: 250.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 2,
        dueDate: new Date(Date.now() + 37 * 24 * 60 * 60 * 1000), // 30 days after first
      },
      // Payment 7: Nike - Installment 3/4
      {
        userId: savedUser.id,
        storeId: stores[2].id, // Nike
        orderId: 'NIKE-ORD-001',
        amount: 62.50,
        totalAmount: 250.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 3,
        dueDate: new Date(Date.now() + 67 * 24 * 60 * 60 * 1000), // 60 days after first
      },
      // Payment 8: Nike - Installment 4/4
      {
        userId: savedUser.id,
        storeId: stores[2].id, // Nike
        orderId: 'NIKE-ORD-001',
        amount: 62.50,
        totalAmount: 250.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 4,
        dueDate: new Date(Date.now() + 97 * 24 * 60 * 60 * 1000), // 90 days after first
      },
      
      // ============ Apple Store Order: 4 installments (orderId: APPLE-ORD-001) ============
      // Payment 9: Apple Store - Installment 1/4
      {
        userId: savedUser.id,
        storeId: stores[4].id, // Apple Store
        orderId: 'APPLE-ORD-001',
        amount: 300.00, // 1200 / 4 = 300
        totalAmount: 1200.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 1,
        dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 14 days from now
      },
      // Payment 10: Apple Store - Installment 2/4
      {
        userId: savedUser.id,
        storeId: stores[4].id, // Apple Store
        orderId: 'APPLE-ORD-001',
        amount: 300.00,
        totalAmount: 1200.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 2,
        dueDate: new Date(Date.now() + 44 * 24 * 60 * 60 * 1000), // 30 days after first
      },
      // Payment 11: Apple Store - Installment 3/4
      {
        userId: savedUser.id,
        storeId: stores[4].id, // Apple Store
        orderId: 'APPLE-ORD-001',
        amount: 300.00,
        totalAmount: 1200.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 3,
        dueDate: new Date(Date.now() + 74 * 24 * 60 * 60 * 1000), // 60 days after first
      },
      // Payment 12: Apple Store - Installment 4/4
      {
        userId: savedUser.id,
        storeId: stores[4].id, // Apple Store
        orderId: 'APPLE-ORD-001',
        amount: 300.00,
        totalAmount: 1200.00,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'pending',
        installmentsCount: 4,
        installmentNumber: 4,
        dueDate: new Date(Date.now() + 104 * 24 * 60 * 60 * 1000), // 90 days after first
      },
      
      // ============ H&M Order: Single payment (completed) ============
      // Payment 13: H&M - Single payment (completed)
      {
        userId: savedUser.id,
        storeId: stores[1].id, // H&M
        orderId: 'HM-ORD-001',
        amount: 89.99,
        totalAmount: 89.99,
        currency: 'JOD',
        paymentMethod: 'bnpl',
        status: 'completed',
        installmentsCount: 1,
        installmentNumber: 1,
        dueDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 days ago
        paidAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      },
    ];

    const savedPayments = [];
    for (const paymentData of samplePayments) {
      const payment = paymentRepository.create(paymentData);
      const savedPayment = await paymentRepository.save(payment);
      savedPayments.push(savedPayment);
      console.log(`  ✅ Created payment: ${paymentData.amount} ${paymentData.currency} (${paymentData.status})`);
    }
    console.log(`✅ Created ${samplePayments.length} sample payments`);

    // Seed Sample Notifications (for test user)
    console.log('🔔 Seeding sample notifications...');
    const sampleNotifications = [
      {
        userId: savedUser.id,
        title: 'Payment Due Soon',
        titleAr: 'قسط مستحق قريباً',
        message: 'Your payment of 150 JOD is due in 3 days',
        messageAr: 'قسطك البالغ 150 دينار مستحق خلال 3 أيام',
        type: 'payment',
        isRead: false,
      },
      {
        userId: savedUser.id,
        title: 'New Offer Available',
        titleAr: 'عرض جديد متاح',
        message: 'Check out our new offers from Zara',
        messageAr: 'اطلع على عروضنا الجديدة من زارا',
        type: 'offer',
        isRead: false,
      },
      {
        userId: savedUser.id,
        title: 'Payment Completed',
        titleAr: 'تم الدفع',
        message: 'Your payment of 89.99 JOD has been completed',
        messageAr: 'تم إتمام دفعتك البالغة 89.99 دينار',
        type: 'payment',
        isRead: true,
      },
      {
        userId: savedUser.id,
        title: 'Reward Points Earned',
        titleAr: 'نقاط مكتسبة',
        message: 'You earned 89 points from your last payment',
        messageAr: 'لقد ربحت 89 نقطة من آخر دفعة',
        type: 'system',
        isRead: false,
      },
      {
        userId: savedUser.id,
        title: 'Welcome to BNPL',
        titleAr: 'مرحباً بك في BNPL',
        message: 'Start shopping and pay later with flexible installments',
        messageAr: 'ابدأ التسوق وادفع لاحقاً بأقساط مرنة',
        type: 'system',
        isRead: true,
      },
    ];

    for (const notificationData of sampleNotifications) {
      const notification = notificationRepository.create(notificationData);
      await notificationRepository.save(notification);
      console.log(`  ✅ Created notification: ${notificationData.title}`);
    }
    console.log(`✅ Created ${sampleNotifications.length} sample notifications`);

    // Seed Reward Points (for test user)
    console.log('🎁 Seeding reward points...');
    const rewardPoints = [
      {
        userId: savedUser.id,
        points: 89, // From the completed payment
        transactionType: 'earned',
        amount: 89.99,
        description: 'نقاط من عملية دفع بمبلغ 89.99 دينار',
        paymentId: savedPayments[3].id, // Reference to completed payment
      },
      {
        userId: savedUser.id,
        points: 150, // From pending payment (would be awarded when paid)
        transactionType: 'earned',
        amount: 150.00,
        description: 'نقاط من عملية دفع بمبلغ 150 دينار',
        paymentId: savedPayments[0].id, // Reference to first pending payment
      },
    ];

    for (const rewardData of rewardPoints) {
      const reward = rewardPointRepository.create(rewardData);
      await rewardPointRepository.save(reward);
    }
    console.log(`✅ Created ${rewardPoints.length} reward point transactions`);

    console.log('\n✅ Database seeding completed successfully!');
    console.log(`📊 Summary:`);
    console.log(`   - Stores: ${stores.length}`);
    console.log(`   - Products: ${productCount}`);
    console.log(`   - Test User: 1 (${savedUser.name})`);
    console.log(`   - Payments: ${samplePayments.length}`);
    console.log(`   - Notifications: ${sampleNotifications.length}`);
    console.log(`   - Reward Points: ${rewardPoints.length} transactions`);
    console.log('\n📱 Test User Credentials:');
    console.log(`   Phone: +962799999999`);
    console.log(`   (Use this to login and see the sample data)`);

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  } finally {
    await dataSource.destroy();
  }
}

// Run the seed script
seedDatabase()
  .then(() => {
    console.log('\n🎉 Seed script completed!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seed script failed:', error);
    process.exit(1);
  });

