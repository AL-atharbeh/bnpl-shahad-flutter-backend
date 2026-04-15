import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SavedCard } from './entities/saved-card.entity';
import { StripeService } from '../payments/stripe.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class SavedCardsService {
  constructor(
    @InjectRepository(SavedCard)
    private savedCardRepository: Repository<SavedCard>,
    private stripeService: StripeService,
    private usersService: UsersService,
  ) { }

  async createSetupIntent(userId: number) {
    const user = await this.usersService.findById(userId);
    let stripeCustomerId = user.stripeCustomerId;

    if (!stripeCustomerId) {
      const customer = await this.stripeService.createCustomer(user.email, user.name, user.phone);
      stripeCustomerId = customer.id;
      await this.usersService.updateProfile(userId, { stripeCustomerId });
    }

    const setupIntent = await this.stripeService.createSetupIntent(stripeCustomerId);
    return {
      clientSecret: setupIntent.client_secret,
    };
  }

  async confirmCard(userId: number, paymentMethodId: string) {
    const user = await this.usersService.findById(userId);
    if (!user.stripeCustomerId) {
      throw new BadRequestException('User does not have a Stripe customer ID');
    }

    // Attach payment method to customer
    await this.stripeService.attachPaymentMethod(user.stripeCustomerId, paymentMethodId);

    // Set as default payment method on Stripe (optional but recommended)
    // For now we just retrieve card details to save locally
    const paymentMethod = await this.stripeService.getPaymentMethod(paymentMethodId);
    const card = paymentMethod.card;

    if (!card) {
      throw new BadRequestException('Invalid payment method: no card details found');
    }

    // Check if card is already saved
    const existing = await this.savedCardRepository.findOne({
      where: { stripePaymentMethodId: paymentMethodId },
    });

    if (existing) {
      return existing;
    }

    // If this is the first card, make it default
    const cardsCount = await this.savedCardRepository.count({ where: { userId } });

    const savedCard = this.savedCardRepository.create({
      userId,
      stripeCustomerId: user.stripeCustomerId,
      stripePaymentMethodId: paymentMethodId,
      brand: card.brand,
      last4: card.last4,
      expMonth: card.exp_month,
      expYear: card.exp_year,
      isDefault: cardsCount === 0,
      isActive: true,
    });

    return this.savedCardRepository.save(savedCard);
  }

  async listCards(userId: number) {
    return this.savedCardRepository.find({
      where: { userId, isActive: true },
      order: { isDefault: 'DESC', createdAt: 'DESC' },
    });
  }

  async deleteCard(userId: number, cardId: number) {
    const card = await this.savedCardRepository.findOne({
      where: { id: cardId, userId },
    });

    if (!card) {
      throw new NotFoundException('Card not found');
    }

    // Detach from Stripe
    await this.stripeService.detachPaymentMethod(card.stripePaymentMethodId);

    // Delete from DB or mark as inactive
    await this.savedCardRepository.remove(card);

    // If it was default, set another card as default if available
    if (card.isDefault) {
      const nextCard = await this.savedCardRepository.findOne({
        where: { userId, isActive: true },
      });
      if (nextCard) {
        nextCard.isDefault = true;
        await this.savedCardRepository.save(nextCard);
      }
    }

    return { success: true };
  }

  async setDefaultCard(userId: number, cardId: number) {
    const card = await this.savedCardRepository.findOne({
      where: { id: cardId, userId },
    });

    if (!card) {
      throw new NotFoundException('Card not found');
    }

    // Reset current default
    await this.savedCardRepository.update({ userId, isDefault: true }, { isDefault: false });

    // Set new default
    card.isDefault = true;
    return this.savedCardRepository.save(card);
  }

  async getDefaultCard(userId: number) {
    return this.savedCardRepository.findOne({
      where: { userId, isDefault: true, isActive: true },
    });
  }
}
