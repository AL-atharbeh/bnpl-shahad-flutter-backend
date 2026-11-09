/**
 * Browse the production database from the terminal.
 *
 *   cd backend
 *   npx ts-node db-view.ts              # every table, with its row count
 *   npx ts-node db-view.ts users        # the 20 newest rows of one table
 *   npx ts-node db-view.ts users 50     # ...50 of them
 *
 * The connection string is typed at the prompt, so it stays out of the shell
 * history. Read only: this script never writes.
 */
import * as readline from 'readline';
import { Client } from 'pg';

function ask(question: string, hidden = false): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  if (hidden) {
    const out = rl as any;
    out._writeToOutput = function (chunk: string) {
      if (chunk.includes(question)) out.output.write(chunk);
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

function normalize(raw: string): string {
  return raw
    .trim()
    .replace(/^["']|["']$/g, '')
    .replace(/^(DATABASE_URL|POSTGRES_URL|POSTGRES_PRISMA_URL)\s*=\s*/i, '')
    .replace(/^psql\s+/i, '')
    .replace(/^["']|["']$/g, '');
}

async function main() {
  const table = process.argv[2];
  const limit = Math.min(parseInt(process.argv[3] ?? '20', 10) || 20, 200);

  let conn = process.env.DATABASE_URL || process.env.POSTGRES_URL;
  if (!conn) {
    conn = await ask('الصق POSTGRES_URL: ', true);
  }
  conn = normalize(conn);

  if (!/^postgres(ql)?:\/\//i.test(conn)) {
    console.error('❌ هذه ليست سلسلة اتصال Postgres صالحة.');
    console.error(`   ما وصلني يبدأ بـ: "${conn.slice(0, 24)}..."`);
    process.exit(1);
  }

  const client = new Client({ connectionString: conn, ssl: { rejectUnauthorized: false } });
  await client.connect();

  try {
    if (!table) {
      const { rows: tables } = await client.query(
        `SELECT table_name FROM information_schema.tables
          WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
          ORDER BY table_name`,
      );

      console.log(`\n📊 ${tables.length} جدولاً\n`);
      console.log('  الجدول'.padEnd(36) + 'الصفوف');
      console.log('  ' + '-'.repeat(44));

      let total = 0;
      for (const { table_name } of tables) {
        const { rows } = await client.query(
          `SELECT COUNT(*)::int AS n FROM "${table_name}"`,
        );
        total += rows[0].n;
        const mark = rows[0].n > 0 ? '●' : '○';
        console.log(`  ${mark} ${table_name}`.padEnd(38) + String(rows[0].n).padStart(6));
      }

      console.log('  ' + '-'.repeat(44));
      console.log('  الإجمالي'.padEnd(38) + String(total).padStart(6));
      console.log('\n  لعرض جدول:  npx ts-node db-view.ts <اسم الجدول>\n');
      return;
    }

    const { rows: exists } = await client.query(
      `SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = $1`,
      [table],
    );

    if (exists.length === 0) {
      console.error(`❌ لا يوجد جدول باسم "${table}"`);
      process.exit(1);
    }

    // created_at is not on every table, so order by it only when present.
    const { rows: hasCreatedAt } = await client.query(
      `SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = $1 AND column_name = 'created_at'`,
      [table],
    );
    const order = hasCreatedAt.length ? 'ORDER BY created_at DESC' : '';

    const { rows } = await client.query(
      `SELECT * FROM "${table}" ${order} LIMIT ${limit}`,
    );

    console.log(`\n📋 ${table} — أحدث ${rows.length} صف\n`);
    if (rows.length === 0) {
      console.log('  (فارغ)\n');
      return;
    }

    // Hide password hashes and tokens rather than printing them.
    const secret = /password|token|secret|otp/i;
    console.table(
      rows.map((row) =>
        Object.fromEntries(
          Object.entries(row).map(([k, v]) => [
            k,
            secret.test(k) && v ? '***' : v,
          ]),
        ),
      ),
    );
    console.log();
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error('❌ فشل:', err.message);
  process.exit(1);
});
