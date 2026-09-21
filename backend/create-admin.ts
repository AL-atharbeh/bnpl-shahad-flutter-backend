/**
 * Creates (or promotes) an admin account for the dashboard.
 *
 *   cd backend
 *   DATABASE_URL="postgres://..." npx ts-node create-admin.ts
 *
 * Email and password are typed at the prompt, so neither ends up in the shell
 * history nor in any file.
 */
import * as readline from 'readline';
import { Client } from 'pg';
import * as bcrypt from 'bcrypt';

function ask(question: string, hidden = false): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  if (hidden) {
    // Suppress echo so the password is not shown while typing.
    const output = rl as any;
    output._writeToOutput = function (chunk: string) {
      if (chunk.includes(question)) {
        output.output.write(chunk);
      }
    };
  }

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      if (hidden) process.stdout.write('\n');
      rl.close();
      resolve(answer.trim());
    });
  });
}

async function main() {
  const connectionString = process.env.DATABASE_URL || process.env.POSTGRES_URL;

  if (!connectionString) {
    console.error('❌ DATABASE_URL is not set.');
    console.error('   Copy it from Vercel > Storage > your Neon database.');
    process.exit(1);
  }

  const name = await ask('الاسم: ');
  const email = await ask('البريد الإلكتروني: ');
  const phone = await ask('رقم الهاتف (مثال +962790000000): ');
  const password = await ask('كلمة المرور: ', true);

  if (!email || !password) {
    console.error('❌ البريد وكلمة المرور مطلوبان');
    process.exit(1);
  }

  if (password.length < 8) {
    console.error('❌ كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    process.exit(1);
  }

  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false },
  });

  await client.connect();

  try {
    const passwordHash = await bcrypt.hash(password, 10);
    const existing = await client.query(
      'SELECT id FROM users WHERE email = $1',
      [email],
    );

    if (existing.rowCount > 0) {
      await client.query(
        `UPDATE users
            SET password_hash = $1, role = 'admin', is_active = true
          WHERE email = $2`,
        [passwordHash, email],
      );
      console.log(`✅ تمت ترقية ${email} إلى مشرف وتحديث كلمة المرور`);
    } else {
      const inserted = await client.query(
        `INSERT INTO users (name, email, phone, password_hash, role,
                            is_active, is_phone_verified, is_email_verified)
         VALUES ($1, $2, $3, $4, 'admin', true, true, true)
         RETURNING id`,
        [name || 'Admin', email, phone || null, passwordHash],
      );
      console.log(`✅ أُنشئ حساب المشرف (id=${inserted.rows[0].id}) لـ ${email}`);
    }

    console.log('   سجّل الدخول الآن من https://admin.shahedapp.com');
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error('❌ فشل:', err.message);
  process.exit(1);
});
