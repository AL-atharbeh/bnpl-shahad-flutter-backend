import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SecurityService } from './security.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('security')
@Controller('security')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SecurityController {
  constructor(private readonly securityService: SecurityService) {}

  @Get('settings')
  @ApiOperation({ summary: 'Get security settings (PIN and Biometric status)' })
  async getSettings(@Request() req) {
    const settings = await this.securityService.getSecuritySettings(req.user.id);
    return {
      success: true,
      data: {
        pinEnabled: settings.pinEnabled,
        biometricEnabled: settings.biometricEnabled,
      },
    };
  }

  @Post('pin')
  @ApiOperation({ summary: 'Set PIN code (4 digits)' })
  async setPin(@Request() req, @Body('pin') pin: string) {
    await this.securityService.setPin(req.user.id, pin);
    return {
      success: true,
      message: 'تم تفعيل رقم التعريف الشخصي بنجاح',
    };
  }

  @Post('pin/verify')
  @ApiOperation({ summary: 'Verify PIN code' })
  async verifyPin(@Request() req, @Body('pin') pin: string) {
    console.log(`[SecurityController] PIN verify request for user ${req.user.id}`);
    console.log(`[SecurityController] Received PIN: "${pin}" (type: ${typeof pin}, length: ${pin?.length})`);
    
    const isValid = await this.securityService.verifyPin(req.user.id, pin);
    
    console.log(`[SecurityController] PIN verification result: ${isValid}`);
    
    return {
      success: true,
      data: { isValid },
      message: isValid ? 'رقم التعريف صحيح' : 'رقم التعريف غير صحيح',
    };
  }

  @Delete('pin')
  @ApiOperation({ summary: 'Disable PIN code' })
  async disablePin(@Request() req) {
    await this.securityService.disablePin(req.user.id);
    return {
      success: true,
      message: 'تم تعطيل رقم التعريف الشخصي',
    };
  }

  @Put('biometric/enable')
  @ApiOperation({ summary: 'Enable biometric authentication' })
  async enableBiometric(@Request() req) {
    await this.securityService.enableBiometric(req.user.id);
    return {
      success: true,
      message: 'تم تفعيل البصمة بنجاح',
    };
  }

  @Put('biometric/disable')
  @ApiOperation({ summary: 'Disable biometric authentication' })
  async disableBiometric(@Request() req) {
    await this.securityService.disableBiometric(req.user.id);
    return {
      success: true,
      message: 'تم تعطيل البصمة',
    };
  }

  @Delete('account')
  @ApiOperation({ summary: 'Delete user account' })
  async deleteAccount(@Request() req) {
    await this.securityService.deleteAccount(req.user.id);
    return {
      success: true,
      message: 'تم حذف الحساب بنجاح',
    };
  }
}

