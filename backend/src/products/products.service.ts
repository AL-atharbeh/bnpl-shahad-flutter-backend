import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Product } from './entities/product.entity';
import { Store } from '../stores/entities/store.entity';
import { Category } from '../categories/entities/category.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
  ) { }

  async create(createProductDto: CreateProductDto): Promise<Product> {
    const store = await this.storeRepository.findOne({ where: { id: createProductDto.store_id } });
    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }

    if (createProductDto.category_id) {
      const category = await this.categoryRepository.findOne({ where: { id: createProductDto.category_id } });
      if (!category) {
        throw new NotFoundException('الفئة غير موجودة');
      }
    }

    const product = this.productRepository.create({
      storeId: createProductDto.store_id,
      name: createProductDto.name,
      nameAr: createProductDto.name_ar,
      description: createProductDto.description,
      descriptionAr: createProductDto.description_ar,
      price: createProductDto.price,
      currency: createProductDto.currency ?? 'JOD',
      category: createProductDto.category,
      categoryId: createProductDto.category_id,
      imageUrl: createProductDto.image_url,
      images: createProductDto.images ?? null,
      stockQuantity: createProductDto.stock_quantity ?? 0,
      discountPrice: createProductDto.discount_price ?? null,
      rating: createProductDto.rating ?? 0,
      reviewsCount: createProductDto.reviews_count ?? 0,
      isActive: createProductDto.is_active ?? true,
    });

    const saved = await this.productRepository.save(product);
    await this.updateStoreProductsCount(saved.storeId);
    return saved;
  }

  async getProductsByStore(storeId: number, categoryId?: number): Promise<any[]> {
    const query = this.productRepository.createQueryBuilder('product')
      .leftJoin('bnpl_session_items', 'si', 'si.product_id = product.id')
      .leftJoin('bnpl_sessions', 's', 's.id = si.session_id')
      .select([
        'product.*',
        'COUNT(CASE WHEN s.status = \'APPROVED\' THEN si.id ELSE NULL END) as real_sales_count',
        'SUM(CASE WHEN s.status = \'APPROVED\' THEN IFNULL(si.price * si.quantity, 0) ELSE 0 END) as real_total_revenue'
      ])
      .where('product.store_id = :storeId', { storeId })
      .andWhere('product.is_active = true')
      .groupBy('product.id');

    if (categoryId) {
      query.andWhere('product.category_id = :categoryId', { categoryId });
    }

    const rawProducts = await query.getRawMany();
    
    return rawProducts.map(p => ({
       ...p,
       id: p.id,
       storeId: p.store_id,
       name: p.name,
       nameAr: p.name_ar,
       description: p.description,
       descriptionAr: p.description_ar,
       price: parseFloat(p.price),
       currency: p.currency,
       categoryId: p.category_id,
       imageUrl: p.image_url,
       stockQuantity: p.stock_quantity,
       discountPrice: p.discount_price ? parseFloat(p.discount_price) : null,
       inStock: p.stock_quantity > 0,
       salesCount: parseInt(p.real_sales_count) || 0,
       totalRevenue: parseFloat(p.real_total_revenue) || 0
    }));
  }

  async getProductById(id: number): Promise<Product> {
    const product = await this.productRepository.findOne({
      where: { id, isActive: true },
      relations: ['store', 'categoryRelation'],
    });

    if (!product) {
      throw new NotFoundException('المنتج غير موجود');
    }

    return product;
  }

  async update(id: number, updateProductDto: UpdateProductDto): Promise<Product> {
    const product = await this.productRepository.findOne({ where: { id } });
    if (!product) {
      throw new NotFoundException('المنتج غير موجود');
    }

    const originalStoreId = product.storeId;
    let targetStoreId = originalStoreId;

    if (updateProductDto.store_id && updateProductDto.store_id !== originalStoreId) {
      const newStore = await this.storeRepository.findOne({ where: { id: updateProductDto.store_id } });
      if (!newStore) {
        throw new NotFoundException('المتجر الجديد غير موجود');
      }
      targetStoreId = updateProductDto.store_id;
    }

    if (updateProductDto.category_id) {
      const category = await this.categoryRepository.findOne({ where: { id: updateProductDto.category_id } });
      if (!category) {
        throw new NotFoundException('الفئة غير موجودة');
      }
    }

    // Creating a partial object with mapped keys for merging
    const updates: Partial<Product> = {};
    if (updateProductDto.store_id !== undefined) updates.storeId = updateProductDto.store_id;
    if (updateProductDto.name !== undefined) updates.name = updateProductDto.name;
    if (updateProductDto.name_ar !== undefined) updates.nameAr = updateProductDto.name_ar;
    if (updateProductDto.description !== undefined) updates.description = updateProductDto.description;
    if (updateProductDto.description_ar !== undefined) updates.descriptionAr = updateProductDto.description_ar;
    if (updateProductDto.price !== undefined) updates.price = updateProductDto.price;
    if (updateProductDto.currency !== undefined) updates.currency = updateProductDto.currency;
    if (updateProductDto.category !== undefined) updates.category = updateProductDto.category;
    if (updateProductDto.category_id !== undefined) updates.categoryId = updateProductDto.category_id;
    if (updateProductDto.image_url !== undefined) updates.imageUrl = updateProductDto.image_url;
    if (updateProductDto.images !== undefined) updates.images = updateProductDto.images;
    if (updateProductDto.stock_quantity !== undefined) {
      updates.stockQuantity = updateProductDto.stock_quantity;
      updates.inStock = updateProductDto.stock_quantity > 0;
    }
    if (updateProductDto.discount_price !== undefined) updates.discountPrice = updateProductDto.discount_price;
    if (updateProductDto.in_stock !== undefined) updates.inStock = updateProductDto.in_stock;
    if (updateProductDto.rating !== undefined) updates.rating = updateProductDto.rating;
    if (updateProductDto.reviews_count !== undefined) updates.reviewsCount = updateProductDto.reviews_count;
    if (updateProductDto.is_active !== undefined) updates.isActive = updateProductDto.is_active;

    const merged = this.productRepository.merge(product, updates);

    const saved = await this.productRepository.save(merged);

    await this.updateStoreProductsCount(targetStoreId);
    if (targetStoreId !== originalStoreId) {
      await this.updateStoreProductsCount(originalStoreId);
    }

    return saved;
  }

  async remove(id: number): Promise<void> {
    const product = await this.productRepository.findOne({ where: { id } });
    if (!product) {
      throw new NotFoundException('المنتج غير موجود');
    }

    await this.productRepository.delete(id);
    await this.updateStoreProductsCount(product.storeId);
  }

  async searchProducts(query: string, categoryId?: number): Promise<Product[]> {
    const whereConditions: any[] = [
      { name: Like(`%${query}%`), isActive: true },
      { nameAr: Like(`%${query}%`), isActive: true },
      { description: Like(`%${query}%`), isActive: true },
      { descriptionAr: Like(`%${query}%`), isActive: true },
    ];

    if (categoryId) {
      whereConditions.forEach(condition => {
        condition.categoryId = categoryId;
      });
    }

    return this.productRepository.find({
      where: whereConditions,
      relations: ['store', 'categoryRelation'],
    });
  }

  /**
   * Get products by category
   */
  async getProductsByCategory(categoryId: number): Promise<Product[]> {
    return this.productRepository.find({
      where: { categoryId, isActive: true },
      relations: ['store', 'categoryRelation'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get all products with optional category filter
   */
  async getAllProducts(categoryId?: number): Promise<Product[]> {
    const where: any = { isActive: true };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    return this.productRepository.find({
      where,
      relations: ['store', 'categoryRelation'],
      order: { createdAt: 'DESC' },
    });
  }

  private async updateStoreProductsCount(storeId: number): Promise<void> {
    const count = await this.productRepository.count({ where: { storeId, isActive: true } });
    await this.storeRepository.update(storeId, { productsCount: count });
  }
}

