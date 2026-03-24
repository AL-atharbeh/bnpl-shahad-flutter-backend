import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Category } from './entities/category.entity';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
  ) { }

  /**
   * Get all active categories
   * @param genderType - Filter by gender type: 'Women', 'Men', 'Kids', or 'All'
   */
  async getAllCategories(genderType?: 'Women' | 'Men' | 'Kids' | 'All'): Promise<Category[]> {
    const where: any = { isActive: true };

    // Filter by gender type
    if (genderType && genderType !== 'All') {
      // Include categories with matching gender_type OR 'All'
      where.genderType = In([genderType, 'All']);
    }

    return this.categoryRepository.find({
      where,
      order: { sortOrder: 'ASC', name: 'ASC' },
      select: ['id', 'name', 'nameAr', 'imageUrl', 'description', 'descriptionAr', 'isActive', 'sortOrder', 'storesCount', 'genderType', 'createdAt', 'updatedAt'],
    });
  }

  /**
   * Get all categories (including inactive) - for admin
   */
  async getAllCategoriesAdmin(): Promise<Category[]> {
    return this.categoryRepository.find({
      order: { sortOrder: 'ASC', name: 'ASC' },
    });
  }

  /**
   * Get category by ID
   */
  async getCategoryById(id: number): Promise<Category> {
    const category = await this.categoryRepository.findOne({
      where: { id },
      relations: ['stores', 'products'],
    });

    if (!category) {
      throw new NotFoundException('الفئة غير موجودة');
    }

    return category;
  }

  /**
   * Create a new category
   */
  async createCategory(categoryData: Partial<Category>): Promise<Category> {
    // Validate required fields
    if (!categoryData.name || !categoryData.nameAr) {
      throw new BadRequestException('اسم الفئة بالإنجليزية والعربية مطلوب');
    }

    // Check if category with same name exists
    const existing = await this.categoryRepository.findOne({
      where: [
        { name: categoryData.name },
        { nameAr: categoryData.nameAr },
      ],
    });

    if (existing) {
      throw new BadRequestException('فئة بهذا الاسم موجودة بالفعل');
    }

    const category = this.categoryRepository.create(categoryData);
    return this.categoryRepository.save(category);
  }

  /**
   * Update category
   */
  async updateCategory(id: number, categoryData: Partial<Category>): Promise<Category> {
    const category = await this.getCategoryById(id);

    // Check if name is being changed and if it conflicts
    if (categoryData.name || categoryData.nameAr) {
      const existing = await this.categoryRepository.findOne({
        where: [
          { name: categoryData.name || category.name },
          { nameAr: categoryData.nameAr || category.nameAr },
        ],
      });

      if (existing && existing.id !== id) {
        throw new BadRequestException('فئة بهذا الاسم موجودة بالفعل');
      }
    }

    Object.assign(category, categoryData);
    return this.categoryRepository.save(category);
  }

  /**
   * Delete category (soft delete - set isActive to false)
   */
  async deleteCategory(id: number): Promise<void> {
    const category = await this.getCategoryById(id);

    // Check if category has stores or products
    const categoryWithRelations = await this.categoryRepository.findOne({
      where: { id },
      relations: ['stores', 'products'],
    });

    if (!categoryWithRelations) {
      throw new NotFoundException('الفئة غير موجودة');
    }

    const storesCount = categoryWithRelations.stores?.filter(s => s.isActive).length || 0;
    const productsCount = categoryWithRelations.products?.filter(p => p.isActive).length || 0;

    if (storesCount > 0 || productsCount > 0) {
      // Soft delete - just set isActive to false
      category.isActive = false;
      await this.categoryRepository.save(category);
    } else {
      // Hard delete if no relations
      await this.categoryRepository.remove(category);
    }
  }

  /**
   * Get categories with store count
   * Uses stores_count column from database (updated by triggers)
   */
  async getCategoriesWithCounts(): Promise<any[]> {
    const categories = await this.categoryRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC' },
      select: ['id', 'name', 'nameAr', 'imageUrl', 'description', 'descriptionAr', 'isActive', 'sortOrder', 'storesCount', 'createdAt', 'updatedAt'],
    });

    return categories.map(category => ({
      id: category.id,
      name: category.name,
      nameAr: category.nameAr,
      imageUrl: category.imageUrl,
      description: category.description,
      descriptionAr: category.descriptionAr,
      isActive: category.isActive,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      storesCount: category.storesCount || 0,
    }));
  }
}

