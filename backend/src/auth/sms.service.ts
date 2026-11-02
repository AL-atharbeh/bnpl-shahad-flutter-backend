import { Injectable, Logger } from '@nestjs/common';
import { Twilio } from 'twilio';

/**
 * Sends the OTP by SMS.
 *
 * When Twilio is not configured the code is logged instead, so local
 * development keeps working without spending credit. In production a missing
 * configuration is reported rather than hidden, because the previous behaviour
 * was to answer "code sent" while sending nothing at all.
 */
@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);
  private client: Twilio | null = null;
  private readonly from = process.env.TWILIO_PHONE_NUMBER;

  constructor() {
    const sid = process.env.TWILIO_ACCOUNT_SID;
    const token = process.env.TWILIO_AUTH_TOKEN;

    if (sid && token && this.from) {
      this.client = new Twilio(sid, token);
      this.logger.log('Twilio is configured; OTPs will be sent by SMS.');
    } else {
      this.logger.warn(
        'Twilio is not configured (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, ' +
          'TWILIO_PHONE_NUMBER) - OTPs will only be written to the log.',
      );
    }
  }

  get isConfigured(): boolean {
    return this.client !== null;
  }

  /**
   * Returns true when the message was handed to Twilio, false when it was only
   * logged. Throws when Twilio is configured but rejected the message, so the
   * caller can tell the user the code did not go out.
   */
  async sendOtp(phone: string, code: string): Promise<boolean> {
    const body = `رمز التحقق الخاص بك في شِهد هو: ${code}`;

    if (!this.client) {
      this.logger.warn(`📱 OTP for ${phone}: ${code} (not sent - no SMS provider)`);
      return false;
    }

    const message = await this.client.messages.create({
      to: phone,
      from: this.from,
      body,
    });

    this.logger.log(`OTP sent to ${phone} (sid: ${message.sid})`);
    return true;
  }
}
