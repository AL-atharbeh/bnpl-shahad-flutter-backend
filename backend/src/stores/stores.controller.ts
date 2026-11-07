import { Controller, Get, Put, Post, Delete, Body, Param, Query, ParseIntPipe, UseGuards, Req, Res, ForbiddenException, BadRequestException, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { Response } from 'express';
import { documentContentType } from '../common/upload-storage';
import { DOCUMENT_TYPES, DocumentType, LOCKED_AFTER_APPROVAL, hasBeenApproved } from './merchant-application';
import { ApiTags, ApiOperation, ApiQuery, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { StoresService } from './stores.service';
import { ProductsService } from '../products/products.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { assertStoreAccess, publicStore } from '../auth/store-access';
import { ShowPrivateStoreFields } from '../common/hide-private-store-fields.interceptor';

/** Fields only an admin may set: money, approval and placement. */
const ADMIN_ONLY_STORE_FIELDS = [
  'rating',
  'commissionRate',
  'bankCommissionRate',
  'platformCommissionRate',
  'isActive',
  'topStore',
  'vendorId',
  'status',
  'payoutCycle',
] as const;

@ApiTags('stores')
@Controller('stores')
export class StoresController {
  constructor(
    private readonly storesService: StoresService,
    private readonly productsService: ProductsService,
  ) { }

  @Get()
  @ApiOperation({ summary: 'Get all stores' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  @ApiQuery({ name: 'topStore', required: false, type: Boolean, description: 'Filter by top stores (1 or 0)' })
  @ApiQuery({ name: 'genderCategoryId', required: false, type: Number, description: 'Filter by gender category ID (Women, Men, Kids)' })
  async getAllStores(
    @Query('categoryId') categoryId?: number,
    @Query('topStore') topStore?: string,
    @Query('genderCategoryId') genderCategoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const topStoreBool = topStore === 'true' || topStore === '1' ? true : undefined;
    const genderCategoryIdNum = genderCategoryId ? parseInt(genderCategoryId.toString()) : undefined;
    const stores = await this.storesService.getAllStores(categoryIdNum, topStoreBool, genderCategoryIdNum);
    return {
      success: true,
      data: stores,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @ShowPrivateStoreFields()
  @Get('admin/all')
  @ApiOperation({ summary: 'Get all stores for admin (includes pending/inactive)' })
  async getAllAdminStores() {
    const stores = await this.storesService.getAllAdminStores();
    return {
      success: true,
      data: stores,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Put('admin/:id/status')
  @ApiOperation({ summary: 'Update store status (approve/reject)' })
  async updateStoreStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: string,
    @Body('note') note?: string,
  ) {
    const store = await this.storesService.updateStoreStatus(id, status, note);
    return {
      success: true,
      data: store,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Get('admin/vendors')
  @ApiOperation({ summary: 'Get all vendors for admin dropdown' })
  async getAllVendors() {
    const vendors = await this.storesService.getAllVendors();
    return {
      success: true,
      data: vendors,
    };
  }

  /** Suspends or restores a merchant's account: a suspended one cannot sign in. */
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Put('admin/vendors/:id/status')
  @ApiOperation({ summary: 'Suspend or restore a vendor account (admin)' })
  async setVendorActive(
    @Param('id', ParseIntPipe) id: number,
    @Body('isActive') isActive: unknown,
  ) {
    if (typeof isActive !== 'boolean') {
      throw new BadRequestException('isActive must be true or false');
    }
    return { success: true, data: await this.storesService.setVendorActive(id, isActive) };
  }

  /**
   * Gives a merchant a new one-time password, shown to the admin once, for a
   * merchant who is locked out. Their old password stops working.
   */
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Post('admin/vendors/:id/reset-password')
  @ApiOperation({ summary: 'Reset a vendor password (admin)' })
  async resetVendorPassword(@Param('id', ParseIntPipe) id: number) {
    return { success: true, data: await this.storesService.resetVendorPassword(id) };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: 'Create new store' })
  async createStore(@Body() createStoreDto: CreateStoreDto) {
    const store = await this.storesService.createStore(createStoreDto);
    return {
      success: true,
      data: store,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Delete(':id')
  @ApiOperation({ summary: 'Delete store' })
  async deleteStore(@Param('id', ParseIntPipe) id: number) {
    await this.storesService.deleteStore(id);
    return {
      success: true,
      message: 'تم حذف المتجر بنجاح',
    };
  }

  @Get('deals')
  @ApiOperation({ summary: 'Get stores with active deals' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async getStoresWithDeals(@Query('categoryId') categoryId?: number) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const stores = await this.storesService.getStoresWithDeals(categoryIdNum);
    return {
      success: true,
      data: stores,
    };
  }

  @Get('search')
  @ApiOperation({ summary: 'Search stores' })
  @ApiQuery({ name: 'q', required: true, description: 'Search query' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async searchStores(
    @Query('q') query: string,
    @Query('categoryId') categoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const stores = await this.storesService.searchStores(query, categoryIdNum);
    return {
      success: true,
      data: stores,
    };
  }

  @Get('category/:categoryId')
  @ApiOperation({ summary: 'Get stores by category' })
  async getStoresByCategory(@Param('categoryId', ParseIntPipe) categoryId: number) {
    const stores = await this.storesService.getStoresByCategory(categoryId);
    return {
      success: true,
      data: stores,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Put(':id/top-store')
  @ApiOperation({ summary: 'Toggle top store status' })
  async toggleTopStore(@Param('id', ParseIntPipe) id: number) {
    const store = await this.storesService.toggleTopStore(id);
    return {
      success: true,
      data: store,
    };
  }

  /**
   * Public, since the customer app opens store pages. The store's own vendor
   * and admins also get its API keys, for the credentials screen.
   */
  @UseGuards(OptionalJwtAuthGuard)
  @ShowPrivateStoreFields()
  @Get(':id')
  @ApiOperation({ summary: 'Get store by ID' })
  async getStore(@Param('id') id: number, @Req() req: any) {
    const isOwnerOrAdmin =
      req.user?.role === 'admin' ||
      (req.user?.role === 'vendor' && Number(req.user.storeId) === Number(id));
    const store = await this.storesService.getStoreById(id, isOwnerOrAdmin);
    return {
      success: true,
      data: isOwnerOrAdmin ? store : publicStore(store),
    };
  }

  @Get(':id/products')
  @ApiOperation({ summary: 'Get products for store' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async getStoreProducts(
    @Param('id', ParseIntPipe) id: number,
    @Query('categoryId') categoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const products = await this.productsService.getProductsByStore(id, categoryIdNum);
    return {
      success: true,
      data: products,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @ShowPrivateStoreFields()
  @Put(':id')
  @ApiOperation({ summary: 'Update store details' })
  async updateStore(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateStoreDto: UpdateStoreDto,
    @Req() req: any,
  ) {
    assertStoreAccess(req.user, id);

    if (req.user.role === 'vendor') {
      const blocked = ADMIN_ONLY_STORE_FIELDS.filter((f) => updateStoreDto[f] !== undefined);
      if (blocked.length) {
        throw new ForbiddenException(`هذه الحقول يعدّلها المشرف فقط: ${blocked.join(', ')}`);
      }

      // Once approved, the owner and bank details only change through an
      // admin, so a stolen login cannot redirect the store's money.
      const current = await this.storesService.getStoreById(id, true);
      if (hasBeenApproved(current.status)) {
        const locked = LOCKED_AFTER_APPROVAL.filter(
          (f) => updateStoreDto[f] !== undefined && updateStoreDto[f] !== current[f],
        );
        if (locked.length) {
          throw new ForbiddenException(
            `لتغيير بيانات المالك أو الحساب البنكي بعد التفعيل تواصل مع إدارة شهد: ${locked.join(', ')}`,
          );
        }
      }
    }

    const store = await this.storesService.updateStore(id, updateStoreDto);
    return {
      success: true,
      data: store,
    };
  }

  /** New API keys for the store's own merchant or an admin; the old ones stop working. */
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @ShowPrivateStoreFields()
  @Post(':id/api-keys/regenerate')
  @ApiOperation({ summary: 'Regenerate store API keys' })
  async regenerateApiKeys(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    assertStoreAccess(req.user, id);
    return { success: true, data: await this.storesService.regenerateApiKeys(id) };
  }

  /** Uploads a merchant document: commercial-registration, trade-license or owner-id. */
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @ApiConsumes('multipart/form-data')
  @ShowPrivateStoreFields()
  @Post(':id/documents/:type')
  @UseInterceptors(FileInterceptor('file', { storage: memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } }))
  async uploadDocument(
    @Param('id', ParseIntPipe) id: number,
    @Param('type') type: string,
    @UploadedFile() file: Express.Multer.File,
    @Req() req: any,
  ) {
    assertStoreAccess(req.user, id);
    const docType = this.documentType(type);
    if (!file) throw new BadRequestException('File is not provided');

    if (req.user.role === 'vendor') {
      const current = await this.storesService.getStoreById(id, true);
      if (hasBeenApproved(current.status)) {
        throw new ForbiddenException('لتغيير مستندات متجر مفعّل تواصل مع إدارة شهد');
      }
    }

    const store = await this.storesService.saveDocument(id, docType, file);
    return { success: true, data: { type: docType, uploaded: Boolean(store[DOCUMENT_TYPES[docType]]) } };
  }

  /** Streams a merchant document to the store itself or an admin. */
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @Get(':id/documents/:type')
  async getDocument(
    @Param('id', ParseIntPipe) id: number,
    @Param('type') type: string,
    @Req() req: any,
    @Res() res: Response,
  ) {
    assertStoreAccess(req.user, id);
    const path = await this.storesService.getDocumentPath(id, this.documentType(type));
    res.setHeader('Content-Type', documentContentType(path));
    res.setHeader('Cache-Control', 'private, no-store');
    res.sendFile(path);
  }

  /** Sends a complete application, with the terms accepted, for review. */
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @ShowPrivateStoreFields()
  @Post(':id/application/submit')
  async submitApplication(
    @Param('id', ParseIntPipe) id: number,
    @Body('termsAccepted') termsAccepted: boolean,
    @Req() req: any,
  ) {
    assertStoreAccess(req.user, id);
    const store = await this.storesService.submitApplication(id, termsAccepted === true);
    return { success: true, data: store };
  }

  private documentType(type: string): DocumentType {
    if (!(type in DOCUMENT_TYPES)) {
      throw new BadRequestException(`type must be one of: ${Object.keys(DOCUMENT_TYPES).join(', ')}`);
    }
    return type as DocumentType;
  }
}
