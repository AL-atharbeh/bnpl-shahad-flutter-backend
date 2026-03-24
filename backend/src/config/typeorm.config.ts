import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const typeOrmConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => {
  const isSsl = configService.get('DB_SSL') === 'true';
  return {
    type: 'mysql',
    host: configService.get('DB_HOST', 'localhost'),
    port: configService.get('DB_PORT', 3306),
    username: configService.get('DB_USERNAME', 'root'),
    password: configService.get('DB_PASSWORD', ''),
    database: configService.get('DB_DATABASE', 'bnpl_db'),
    ...(isSsl ? { ssl: { rejectUnauthorized: false } } : {}),
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    synchronize: true, // Always sync for now
    logging: configService.get('NODE_ENV') === 'development',
    timezone: 'Z',
    charset: 'utf8mb4',
  };
};

