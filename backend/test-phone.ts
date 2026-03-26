import { createConnection } from 'typeorm';
import * as dotenv from 'dotenv';
import { User } from './src/users/entities/user.entity';

dotenv.config();

async function test() {
  const connection = await createConnection({
    type: 'mysql',
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    entities: [User],
  });

  const phone = process.argv[2];
  console.log('Testing phone:', phone);

  const cleanPhone = phone.replace(/[^\d+]/g, '');
  const variations = new Set<string>();
  variations.add(cleanPhone);
  if (cleanPhone.startsWith('+')) {
    const sansPlus = cleanPhone.substring(1);
    variations.add(sansPlus);
    if (sansPlus.startsWith('962')) {
      variations.add('0' + sansPlus.substring(3));
    }
  } else {
    variations.add('+' + cleanPhone);
    if (cleanPhone.startsWith('962')) {
      const local = '0' + cleanPhone.substring(3);
      variations.add(local);
      variations.add('+' + local);
    } else if (cleanPhone.startsWith('0')) {
      const intl = '962' + cleanPhone.substring(1);
      variations.add(intl);
      variations.add('+' + intl);
    }
  }

  console.log('Variations to search:', Array.from(variations));

  const repo = connection.getRepository(User);
  const found = await repo.findOne({
    where: Array.from(variations).map(p => ({ phone: p }))
  });

  if (found) {
    console.log('FOUND USER:', found.name, 'Phone in DB:', found.phone);
  } else {
    console.log('NOT FOUND');
  }

  await connection.close();
}

test().catch(console.error);
