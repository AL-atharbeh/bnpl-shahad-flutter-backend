import { NextResponse } from 'next/server';
import fs from 'fs';
import path from 'path';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { phone, store, city } = body;

    // Validate phone format (Jordanian 07XXXXXXXX)
    // 077, 078, 079 are the main prefixes in Jordan
    const phoneRegex = /^07[7-9][0-9]{7}$/;
    if (!phoneRegex.test(phone)) {
      return NextResponse.json(
        { success: false, message: 'رقم الهاتف غير صحيح (مثال: 07XXXXXXXX)' },
        { status: 400 }
      );
    }

    if (!store || !city) {
       return NextResponse.json(
        { success: false, message: 'يرجى ملء جميع الحقول' },
        { status: 400 }
      );
    }

    const dataPath = path.join(process.cwd(), 'data', 'waitlist.json');
    
    // Ensure the data directory exists (just in case)
    if (!fs.existsSync(path.dirname(dataPath))) {
      fs.mkdirSync(path.dirname(dataPath), { recursive: true });
    }

    let waitlist = [];
    if (fs.existsSync(dataPath)) {
      const fileData = fs.readFileSync(dataPath, 'utf8');
      try {
        waitlist = JSON.parse(fileData);
      } catch (e) {
        waitlist = [];
      }
    }

    const newEntry = {
      phone,
      store,
      city,
      timestamp: new Date().toISOString(),
    };

    waitlist.push(newEntry);
    fs.writeFileSync(dataPath, JSON.stringify(waitlist, null, 2));

    return NextResponse.json({ success: true, message: "تم التسجيل" });
  } catch (error) {
    console.error('Waitlist API Error:', error);
    return NextResponse.json(
      { success: false, message: 'حدث خطأ ما، يرجى المحاولة لاحقاً' },
      { status: 500 }
    );
  }
}
