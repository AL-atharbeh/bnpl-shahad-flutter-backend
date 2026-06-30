import * as mysql from 'mysql2/promise';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.join(__dirname, '.env') });

async function bootstrap() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || '127.0.0.1',
        port: parseInt(process.env.DB_PORT || '3306'),
        user: process.env.DB_USERNAME || 'root',
        password: process.env.DB_PASSWORD,
        database: process.env.DB_DATABASE || 'shahedapp',
    });

    console.log('✅ Connected directly via mysql2');

    const [payments]: any = await connection.query(`
        SELECT p.*, s.name as storeName
        FROM payments p
        LEFT JOIN stores s ON p.store_id = s.id
        WHERE p.status = 'completed'
    `);

    console.log(`📊 Completed payments count: ${payments.length}`);
    for (const p of payments) {
        const [inSettlement]: any = await connection.query(`
            SELECT * FROM settlement_payments WHERE payment_id = ${p.id}
        `);
        console.log(`💳 Payment #${p.id} | Store: ${p.storeName} (ID: ${p.store_id}) | Amount: ${p.amount} | In Settlement: ${inSettlement.length > 0 ? 'YES' : 'NO'}`);
    }

    await connection.end();
}
bootstrap().catch(console.error);
