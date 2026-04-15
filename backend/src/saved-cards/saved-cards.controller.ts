import {
  Controller,
  Get,
  Post,
  Delete,
  Put,
  Param,
  Body,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { SavedCardsService } from './saved-cards.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Saved Cards')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('saved-cards')
export class SavedCardsController {
  constructor(private readonly savedCardsService: SavedCardsService) {}

  @Post('setup-intent')
  @ApiOperation({ summary: 'Create a Stripe SetupIntent' })
  async createSetupIntent(@Request() req) {
    return this.savedCardsService.createSetupIntent(req.user.id);
  }

  @Post('confirm')
  @ApiOperation({ summary: 'Confirm and save a payment method' })
  async confirmCard(@Request() req, @Body('paymentMethodId') paymentMethodId: string) {
    return this.savedCardsService.confirmCard(req.user.id, paymentMethodId);
  }

  @Get()
  @ApiOperation({ summary: 'List user saved cards' })
  async listCards(@Request() req) {
    return this.savedCardsService.listCards(req.user.id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a saved card' })
  async deleteCard(@Request() req, @Param('id', ParseIntPipe) cardId: number) {
    return this.savedCardsService.deleteCard(req.user.id, cardId);
  }

  @Put(':id/default')
  @ApiOperation({ summary: 'Set a card as default' })
  async setDefaultCard(@Request() req, @Param('id', ParseIntPipe) cardId: number) {
    return this.savedCardsService.setDefaultCard(req.user.id, cardId);
  }
}
