import { Body, Controller, Post, Get, Put, Delete, HttpCode, HttpStatus, UseGuards, Request, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { VendorRegisterDto } from './dto/vendor-register.dto';
import { VendorLoginDto } from './dto/vendor-login.dto';
import { ChangeVendorPasswordDto, DeleteVendorAccountDto, UpdateVendorProfileDto } from './dto/vendor-account.dto';
import { VendorNotificationsService } from '../vendors/vendor-notifications.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { Roles } from './decorators/roles.decorator';
import { ShowPrivateStoreFields } from '../common/hide-private-store-fields.interceptor';

@ApiTags('Vendor Auth')
@Controller('auth/vendor')
export class VendorAuthController {
    constructor(
        private readonly authService: AuthService,
        private readonly vendorNotifications: VendorNotificationsService,
    ) { }

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

    @Get('me')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @ShowPrivateStoreFields()
    @Roles('vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: "The signed-in vendor and their store's review status" })
    async me(@Request() req: any) {
        return this.authService.getVendorAccount(req.user.id);
    }

    @Put('me')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: "Update the signed-in vendor's name, email or phone" })
    async updateProfile(@Request() req: any, @Body() dto: UpdateVendorProfileDto) {
        return this.authService.updateVendorProfile(req.user.id, dto);
    }

    @Put('password')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Change the signed-in vendor password' })
    async changePassword(@Request() req: any, @Body() dto: ChangeVendorPasswordDto) {
        return this.authService.changeVendorPassword(req.user.id, dto.currentPassword, dto.newPassword);
    }

    /** Closes the signed-in vendor's account; needs their password. */
    @Delete('me')
    @HttpCode(HttpStatus.OK)
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: "Delete the signed-in vendor's account" })
    async deleteAccount(@Request() req: any, @Body() dto: DeleteVendorAccountDto) {
        return this.authService.deleteVendorAccount(req.user.id, dto.password);
    }

    @Get('notifications')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: "The signed-in vendor's notifications, newest first" })
    async notifications(@Request() req: any, @Query('limit') limit?: string) {
        return { success: true, data: await this.vendorNotifications.list(req.user.id, Number(limit) || 50) };
    }

    /** Marks one notification read, or all of them without an id. */
    @Post('notifications/read')
    @HttpCode(HttpStatus.OK)
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('vendor')
    @ApiBearerAuth()
    async markRead(@Request() req: any, @Body('id') id?: number) {
        await this.vendorNotifications.markRead(req.user.id, Number(id) || undefined);
        return { success: true };
    }
}
