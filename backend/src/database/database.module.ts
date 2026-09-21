import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        url: configService.get<string>('database.url'),
        ssl: { rejectUnauthorized: false },
        autoLoadEntities: true,
        // Set DB_SYNC=true for the very first deploy to create the tables,
        // then switch it back to false so schema changes go through migrations.
        synchronize: configService.get<string>('database.sync') === 'true',
        // Serverless functions are short lived: keep one connection per instance
        // so the database does not run out of slots under load.
        extra: {
          max: 1,
          connectionTimeoutMillis: 10000,
          idleTimeoutMillis: 10000,
        },
        logging: ['error'],
      }),
    }),
  ],
})
export class DatabaseModule {}
