import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getApiInfo(): any {
    return {
      message: 'Welcome to BNPL API',
      version: '1.0',
      documentation: '/api/docs',
      apiPrefix: '/api/v1',
    };
  }
}

