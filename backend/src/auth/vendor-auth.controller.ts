import { Body, Controller, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { VendorRegisterDto } from './dto/vendor-register.dto';
import { VendorLoginDto } from './dto/vendor-login.dto';

@ApiTags('Vendor Auth')
@Controller('auth/vendor')
export class VendorAuthController {
    constructor(private readonly authService: AuthService) { }

    @Post('register')
    @ApiOperation({ summary: 'Register a new vendor and store' })
    @ApiResponse({ status: 201, description: 'Vendor registered successfully' })
    async register(@Body() vendorRegisterDto: VendorRegisterDto) {
        return this.authService.vendorRegister(vendorRegisterDto);
    }

    @Post('login')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Login as a vendor' })
    @ApiResponse({ status: 200, description: 'Login successful' })
    async login(@Body() vendorLoginDto: VendorLoginDto) {
        return this.authService.vendorLogin(vendorLoginDto);
    }
}
