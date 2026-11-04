export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    // Vercel Postgres / Neon expose the connection string under these names.
    url:
      process.env.DATABASE_URL ||
      process.env.POSTGRES_URL ||
      process.env.POSTGRES_PRISMA_URL,
    sync: process.env.DB_SYNC || 'false',
    // Neon needs TLS; a database on the same Docker network does not offer it.
    ssl: process.env.DB_SSL !== 'false',
    // One connection suits a serverless instance; a long-running server can
    // hold a small pool.
    poolMax: parseInt(process.env.DB_POOL_MAX, 10) || 1,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  stripe: {
    publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
    secretKey: process.env.STRIPE_SECRET_KEY,
  },
});
