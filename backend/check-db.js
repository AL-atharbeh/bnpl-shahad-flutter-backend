const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function checkStore() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10),
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    ssl: { rejectUnauthorized: false }
  });

  try {
    const [rows] = await connection.execute('SELECT id, name, store_url, website_url FROM stores WHERE id = 3');
    console.log('📊 Current Store 3 Data:', JSON.stringify(rows, null, 2));
  } catch (err) {
    console.error('❌ Error fetching store:', err);
  } finally {
    await connection.end();
  }
}

checkStore();
