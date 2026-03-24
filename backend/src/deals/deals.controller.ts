import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { DealsService } from './deals.service';
import { CreateDealDto } from './dto/create-deal.dto';
import { UpdateDealDto } from './dto/update-deal.dto';

@ApiTags('deals')
@Controller('deals')
export class DealsController {
  constructor(private readonly dealsService: DealsService) {}

  @Get()
  @ApiOperation({ summary: 'Get deals with optional filters' })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean })
  @ApiQuery({ name: 'storeId', required: false, type: Number })
  @ApiQuery({ name: 'productId', required: false, type: Number })
  @ApiQuery({ name: 'includeExpired', required: false, type: Boolean })
  async findAll(
    @Query('isActive') isActive?: string,
    @Query('storeId') storeId?: number,
    @Query('productId') productId?: number,
    @Query('includeExpired') includeExpired?: string,
  ) {
    const deals = await this.dealsService.findAll({
      isActive: typeof isActive !== 'undefined' ? isActive === 'true' : undefined,
      storeId: storeId ? Number(storeId) : undefined,
      productId: productId ? Number(productId) : undefined,
      includeExpired: includeExpired === 'true',
    });
    return { success: true, data: deals };
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active deals for home page' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async findActive(@Query('limit') limit?: number) {
    const deals = await this.dealsService.findActiveForHome(limit ? Number(limit) : undefined);
    return { success: true, data: deals };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get deal by id' })
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const deal = await this.dealsService.findOne(id);
    return { success: true, data: deal };
  }

  @Post()
  @ApiOperation({ summary: 'Create new deal' })
  async create(@Body() createDealDto: CreateDealDto) {
    const deal = await this.dealsService.create(createDealDto);
    return { success: true, data: deal };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update deal' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDealDto: UpdateDealDto,
  ) {
    const deal = await this.dealsService.update(id, updateDealDto);
    return { success: true, data: deal };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete deal' })
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.dealsService.remove(id);
    return { success: true };
  }
}
