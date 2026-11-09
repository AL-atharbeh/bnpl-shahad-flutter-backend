/**
 * Adds the store categories the app's category picker reads.
 *
 *   cd backend
 *   npx ts-node seed-categories.ts
 *
 * The list is the one in create-categories-table.sql, so these are the
 * categories the system was designed around rather than invented ones. Safe to
 * run twice: a category whose English name already exists is skipped.
 */
import * as readline from 'readline';
import { Client } from 'pg';

type Row = [string, string, string, string, number];

const CATEGORIES: Row[] = [
  ['Fashion & Clothing', 'الأزياء والملابس', 'Fashion and clothing stores', 'متاجر الأزياء والملابس', 1],
  ['Electronics', 'الإلكترونيات', 'Electronics and gadgets', 'الإلكترونيات والأجهزة', 2],
  ['Home & Furniture', 'المنزل والأثاث', 'Home and furniture stores', 'متاجر المنزل والأثاث', 3],
  ['Beauty & Cosmetics', 'الجمال ومستحضرات التجميل', 'Beauty and cosmetics stores', 'متاجر الجمال ومستحضرات التجميل', 4],
  ['Sports & Outdoors', 'الرياضة والهواء الطلق', 'Sports and outdoor equipment', 'معدات الرياضة والهواء الطلق', 5],
  ['Food & Beverages', 'الطعام والمشروبات', 'Food and beverage stores', 'متاجر الطعام والمشروبات', 6],
  ['Health & Wellness', 'الصحة والعافية', 'Health and wellness products', 'منتجات الصحة والعافية', 7],
  ['Books & Education', 'الكتب والتعليم', 'Books and educational materials', 'الكتب والمواد التعليمية', 8],
  ['Toys & Games', 'الألعاب', 'Toys and games', 'الألعاب والدمى', 9],
  ['Automotive', 'السيارات', 'Automotive products and services', 'منتجات وخدمات السيارات', 10],
  ['Pet Supplies', 'مستلزمات الحيوانات الأليفة', 'Pet supplies and accessories', 'مستلزمات وإكسسوارات الحيوانات الأليفة', 11],
  ['Baby & Kids', 'الرضع والأطفال', 'Baby and kids products', 'منتجات الرضع والأطفال', 12],
  ['Office Supplies', 'المستلزمات المكتبية', 'Office supplies and equipment', 'المستلزمات والمعدات المكتبية', 13],
];

function ask(question: string, hidden = false): Promise<string> {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

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
  let conn = process.env.DATABASE_URL || process.env.POSTGRES_URL;
  if (!conn) conn = await ask('الصق POSTGRES_URL: ', true);
  conn = normalize(conn);

  if (!/^postgres(ql)?:\/\//i.test(conn)) {
    console.error('❌ هذه ليست سلسلة اتصال Postgres صالحة.');
    console.error(`   ما وصلني يبدأ بـ: "${conn.slice(0, 24)}..."`);
    process.exit(1);
  }

  const client = new Client({ connectionString: conn, ssl: { rejectUnauthorized: false } });
  await client.connect();

  try {
    let added = 0;
    let skipped = 0;

    for (const [name, nameAr, desc, descAr, order] of CATEGORIES) {
      const { rowCount } = await client.query(
        'SELECT 1 FROM categories WHERE name = $1',
        [name],
      );

      if (rowCount && rowCount > 0) {
        console.log(`  — ${nameAr} (موجود)`);
        skipped++;
        continue;
      }

      await client.query(
        `INSERT INTO categories
           (name, name_ar, description, description_ar, gender_type, sort_order, is_active)
         VALUES ($1, $2, $3, $4, 'All', $5, true)`,
        [name, nameAr, desc, descAr, order],
      );

      console.log(`  ✅ ${nameAr}`);
      added++;
    }

    console.log(`\nأُضيف ${added} · تُخطّي ${skipped}`);
    console.log('افتح التطبيق الآن وجرّب قائمة التصنيف.');
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error('❌ فشل:', err.message);
  process.exit(1);
});
