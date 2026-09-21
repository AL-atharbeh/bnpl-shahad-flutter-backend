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
  let connectionString = process.env.DATABASE_URL || process.env.POSTGRES_URL;

  if (!connectionString) {
    // Asking here avoids any shell quoting or clipboard surprises.
    connectionString = await ask('الصق DATABASE_URL: ', true);
  }

  connectionString = connectionString.trim().replace(/^["']|["']$/g, '');

  // Vercel rows are often copied as KEY=value, and Neon's snippets as a psql
  // command. Accept both rather than failing on a confusing DNS error.
  connectionString = connectionString
    .replace(/^(DATABASE_URL|POSTGRES_URL|POSTGRES_PRISMA_URL)\s*=\s*/i, '')
    .replace(/^psql\s+/i, '')
    .replace(/^["']|["']$/g, '');

  if (!/^postgres(ql)?:\/\//i.test(connectionString)) {
    console.error('❌ هذه ليست سلسلة اتصال Postgres صالحة.');
    console.error('   يجب أن تبدأ بـ postgres:// أو postgresql://');
    console.error(`   ما وصلني يبدأ بـ: "${connectionString.slice(0, 24)}..."`);
    process.exit(1);
  }

  try {
    const parsed = new URL(connectionString);
    console.log(`🔗 الاتصال بـ ${parsed.hostname} (قاعدة: ${parsed.pathname.slice(1)})`);
  } catch {
    console.error('❌ تعذّر تحليل سلسلة الاتصال.');
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
