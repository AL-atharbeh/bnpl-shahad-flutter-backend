import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';

export interface InitiatePaymentDto {
    amount: number;
    currency: string;
    customerName: string;
    customerEmail: string;
    customerPhone: string;
    customerReference: string;
}

export interface PaymentResponse {
    IsSuccess: boolean;
    Message: string;
    Data: {
        InvoiceId: number;
        IsDirectPayment: boolean;
        PaymentURL: string;
        CustomerReference: string;
    };
}

export interface PaymentStatusResponse {
    IsSuccess: boolean;
    Message: string;
    Data: {
        InvoiceId: number;
        InvoiceStatus: string;
        InvoiceValue: number;
        CustomerReference: string;
        InvoiceTransactions: Array<{
            TransactionId: string;
            PaymentId: string;
            TransactionStatus: string;
            TransactionValue: string;
        }>;
    };
}

@Injectable()
export class MyFatoorahService {
    private readonly logger = new Logger(MyFatoorahService.name);
    private readonly baseUrl: string;
    private readonly apiToken: string;
    private readonly ngrokUrl: string;

    constructor(
        private readonly configService: ConfigService,
        private readonly httpService: HttpService,
    ) {
        this.baseUrl = this.configService.get<string>(
            'MYFATOORAH_API_URL',
            'https://apitest.myfatoorah.com',
        );
        this.apiToken = this.configService.get<string>(
            'MYFATOORAH_API_TOKEN',
            'rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL',
        );
        this.ngrokUrl =
            this.configService.get<string>('APP_URL') ||
            this.configService.get<string>('NGROK_URL') ||
            'https://api.shahedapp.com';

        this.logger.log('✅ MyFatoorah Service initialized');
        this.logger.log(`📍 Base URL: ${this.baseUrl}`);
        this.logger.log(`🌐 Callback URL: ${this.ngrokUrl}`);
    }

    /**
     * Execute payment and get payment URL
     */
    async executePayment(data: InitiatePaymentDto): Promise<PaymentResponse> {
        try {
            this.logger.log(`💳 Executing payment for ${data.customerReference}`);

            const url = `${this.baseUrl}/v2/ExecutePayment`;
            const headers = {
                Authorization: `Bearer ${this.apiToken}`,
                'Content-Type': 'application/json',
            };

            const payload = {
                CustomerName: data.customerName,
                NotificationOption: 'LNK',
                InvoiceValue: data.amount,
                CustomerEmail: data.customerEmail,
                CustomerMobile: data.customerPhone,
                DisplayCurrencyIso: data.currency,
                CallBackUrl: `${this.ngrokUrl}/api/v1/payments/callback/success`,
                ErrorUrl: `${this.ngrokUrl}/api/v1/payments/callback/error`,
                Language: 'ar',
                CustomerReference: data.customerReference,
                UserDefinedField: data.customerReference,
            };

            this.logger.debug(`Payment payload: ${JSON.stringify(payload)}`);

            const response = await firstValueFrom(
                this.httpService.post<PaymentResponse>(url, payload, { headers }),
            );

            if (!response.data.IsSuccess) {
                throw new Error(response.data.Message);
            }

            this.logger.log(
                `✅ Payment URL generated: ${response.data.Data.PaymentURL}`,
            );
            return response.data;
        } catch (error) {
            this.logger.error(
                '❌ Failed to execute payment',
                error.response?.data || error.message,
            );
            throw new Error(`MyFatoorah payment failed: ${error.message}`);
        }
    }

    /**
     * Get payment status
     */
    async getPaymentStatus(paymentId: string): Promise<PaymentStatusResponse> {
        try {
            this.logger.log(`🔍 Getting payment status for: ${paymentId}`);

            const url = `${this.baseUrl}/v2/GetPaymentStatus`;
            const headers = {
                Authorization: `Bearer ${this.apiToken}`,
                'Content-Type': 'application/json',
            };

            const payload = {
                Key: paymentId,
                KeyType: 'PaymentId',
            };

            const response = await firstValueFrom(
                this.httpService.post<PaymentStatusResponse>(url, payload, { headers }),
            );

            if (!response.data.IsSuccess) {
                throw new Error(response.data.Message);
            }

            this.logger.log(`📊 Payment status: ${response.data.Data.InvoiceStatus}`);
            return response.data;
        } catch (error) {
            this.logger.error(
                '❌ Failed to get payment status',
                error.response?.data || error.message,
            );
            throw new Error(`MyFatoorah status check failed: ${error.message}`);
        }
    }

    /**
     * Verify payment from webhook
     */
    async verifyPayment(paymentId: string): Promise<boolean> {
        try {
            const status = await this.getPaymentStatus(paymentId);

            // Check if payment is successful
            const isPaid = status.Data.InvoiceStatus === 'Paid';

            if (isPaid) {
                this.logger.log(`✅ Payment verified successfully: ${paymentId}`);
            } else {
                this.logger.warn(
                    `⚠️ Payment not completed: ${status.Data.InvoiceStatus}`,
                );
            }

            return isPaid;
        } catch (error) {
            this.logger.error('❌ Payment verification error', error);
            return false;
        }
    }

    /**
     * Get customer reference from payment
     */
    async getCustomerReference(paymentId: string): Promise<string | null> {
        try {
            const status = await this.getPaymentStatus(paymentId);
            return status.Data.CustomerReference || null;
        } catch (error) {
            this.logger.error('Failed to get customer reference', error);
            return null;
        }
    }
}

