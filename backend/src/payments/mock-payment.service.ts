import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface MockPaymentDto {
    amount: number;
    currency: string;
    customerName: string;
    customerEmail: string;
    customerPhone: string;
    customerReference: string;
}

export interface MockPaymentResponse {
    IsSuccess: boolean;
    Message: string;
    Data: {
        InvoiceId: number;
        IsDirectPayment: boolean;
        PaymentURL: string;
        CustomerReference: string;
    };
}

@Injectable()
export class MockPaymentService {
    private readonly logger = new Logger(MockPaymentService.name);
    private readonly ngrokUrl: string;

    constructor(private readonly configService: ConfigService) {
        this.ngrokUrl = this.configService.get<string>('APP_URL') || 
            this.configService.get<string>('NGROK_URL') || 
            'https://pantropical-apolonia-unproportionably.ngrok-free.dev';
        this.logger.log(`✅ Mock Payment Service initialized using URL: ${this.ngrokUrl}`);
    }

    /**
     * Generate mock payment URL
     */
    async executePayment(data: MockPaymentDto): Promise<MockPaymentResponse> {
        this.logger.log(`💳 Mock Payment for ${data.customerReference}`);
        this.logger.log(`   Amount: ${data.amount} ${data.currency}`);
        this.logger.log(`   Customer: ${data.customerName}`);

        // Generate fake invoice ID
        const invoiceId = Math.floor(Math.random() * 1000000);

        // Create mock payment URL that will redirect to success
        const paymentUrl = `${this.ngrokUrl}/api/v1/payments/mock-payment?` +
            `invoiceId=${invoiceId}&` +
            `amount=${data.amount}&` +
            `currency=${data.currency}&` +
            `customerRef=${data.customerReference}`;

        this.logger.log(`✅ Mock Payment URL: ${paymentUrl}`);

        return {
            IsSuccess: true,
            Message: 'Mock payment initiated',
            Data: {
                InvoiceId: invoiceId,
                IsDirectPayment: false,
                PaymentURL: paymentUrl,
                CustomerReference: data.customerReference,
            },
        };
    }

    /**
     * Verify mock payment (always returns true for testing)
     */
    async verifyPayment(paymentId: string): Promise<boolean> {
        this.logger.log(`✅ Mock Payment verified: ${paymentId}`);
        return true;
    }

    /**
     * Get customer reference
     */
    async getCustomerReference(paymentId: string): Promise<string | null> {
        this.logger.log(`📋 Getting customer reference for: ${paymentId}`);
        return paymentId; // Return payment ID as reference for mock
    }
}
