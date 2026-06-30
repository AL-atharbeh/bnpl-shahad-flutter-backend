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

    console.log('✅ Connected to database for migration');

    // Run the migration SQL to link old settled payments to their respective sessions
    const [result]: any = await connection.query(`
        UPDATE bnpl_sessions s
        JOIN payments p ON p.order_id = CONCAT('order_', s.session_id)
        JOIN settlement_payments sp ON sp.payment_id = p.id
        SET s.settlement_id = sp.settlement_id
    `);

    console.log(`📊 Migration complete! Affected rows: ${result.affectedRows}`);

    await connection.end();
}
bootstrap().catch(console.error);
