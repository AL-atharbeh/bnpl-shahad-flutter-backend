import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor(private configService: ConfigService) {
    const secretKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    this.stripe = new Stripe(secretKey || 'sk_test_mock', {
      apiVersion: '2023-10-16' as any,
    });
  }

  async createCheckoutSession(params: {
    amount: number;
    currency: string;
    customerName: string;
    customerEmail: string;
    customerReference: string; // This is the sessionId
    successUrl: string;
    cancelUrl: string;
  }) {
    const { amount, currency, customerEmail, customerReference, successUrl, cancelUrl } = params;

    // Convert amount to cents/fils (Stripe expects integers)
    // JOD has 3 decimal places technically, but Stripe JOD is zero-decimal or 2?
    // Actually, Stripe JOD follows standard 2-decimal format for API, or sometimes 3.
    // Most currencies are amount * 100.
    const unitAmount = Math.round(amount * 100);

    const session = await this.stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: currency.toLowerCase(),
            product_data: {
              name: 'First Installment - BNPL',
            },
            unit_amount: unitAmount,
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      customer_email: customerEmail,
      client_reference_id: customerReference,
      success_url: successUrl,
      cancel_url: cancelUrl,
    });

    return {
      id: session.id,
      url: session.url,
    };
  }

  async verifySession(sessionId: string) {
    const session = await this.stripe.checkout.sessions.retrieve(sessionId);
    return session.payment_status === 'paid';
  }
}
