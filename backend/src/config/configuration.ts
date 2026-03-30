export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    host: process.env.DB_HOST || process.env.Host || 'localhost',
    port: parseInt(process.env.DB_PORT || process.env.Port, 10) || 3306,
    username: process.env.DB_USERNAME || process.env.User || 'bnpl_user',
    password: process.env.DB_PASSWORD || process.env.Password || 'bnpl_password',
    database: process.env.DB_DATABASE || 'bnpl_db', 
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
});

