import { IsString, IsNotEmpty, IsOptional, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SendNotificationDto {
    @ApiProperty({ description: 'User ID to send notification to' })
    @IsNotEmpty()
    @IsString()
    userId: string;

    @ApiProperty({ description: 'Notification title' })
    @IsNotEmpty()
    @IsString()
    title: string;

    @ApiProperty({ description: 'Notification body' })
    @IsNotEmpty()
    @IsString()
    body: string;

    @ApiPropertyOptional({ description: 'Additional data payload' })
    @IsOptional()
    @IsObject()
    data?: Record<string, string>;
}

export class SendBulkNotificationDto {
    @ApiProperty({ description: 'Array of user IDs', type: [String] })
    @IsNotEmpty()
    userIds: string[];

    @ApiProperty({ description: 'Notification title' })
    @IsNotEmpty()
    @IsString()
    title: string;

    @ApiProperty({ description: 'Notification body' })
    @IsNotEmpty()
    @IsString()
    body: string;

    @ApiPropertyOptional({ description: 'Additional data payload' })
    @IsOptional()
    @IsObject()
    data?: Record<string, string>;
}

export class SendTopicNotificationDto {
    @ApiProperty({ description: 'Topic name' })
    @IsNotEmpty()
    @IsString()
    topic: string;

    @ApiProperty({ description: 'Notification title' })
    @IsNotEmpty()
    @IsString()
    title: string;

    @ApiProperty({ description: 'Notification body' })
    @IsNotEmpty()
    @IsString()
    body: string;

    @ApiPropertyOptional({ description: 'Additional data payload' })
    @IsOptional()
    @IsObject()
    data?: Record<string, string>;
}

export class SubscribeToTopicDto {
    @ApiProperty({ description: 'User ID to subscribe' })
    @IsNotEmpty()
    @IsString()
    userId: string;

    @ApiProperty({ description: 'Topic name' })
    @IsNotEmpty()
    @IsString()
    topic: string;
}

export class UpdateFcmTokenDto {
    @ApiProperty({ description: 'FCM device token' })
    @IsNotEmpty()
    @IsString()
    token: string;
}
