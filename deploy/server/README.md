# شهد على السيرفر

شهد كامل على سيرفر Hostinger (`2.24.54.103`)، مستقل عن أي مشروع ثاني على نفس السيرفر.

## الدخول بـ FileZilla

| | |
|---|---|
| Protocol | SFTP |
| Host | `2.24.54.103` |
| Port | `22` |
| User | `shahed` |

بعد الدخول بتشوف:

```
/home/shahed/
  backend/    الباك إند            api.shahedapp.com
  admin/      لوحة الأدمن          admin.shahedapp.com
  vendor/     موقع التاجر          vendor.shahedapp.com
  site/       الموقع التعريفي      shahedapp.com
  waitlist/   قائمة الانتظار       waitlist.shahedapp.com
  uploads/    صور المنتجات والبانرات
  backups/    نسخة احتياطية لقاعدة البيانات كل ليلة (آخر 14 يوم)
  stack/      ملفات التشغيل والإعدادات السرية (لا تعدّل إلا إذا عارف شو بتعمل)
```

## رفع تحديث

1. ارفع الملفات المعدّلة بـ FileZilla للمجلد الصح (مثلاً `backend/src/...`).
   لا ترفع `node_modules` ولا `.next` ولا `dist`.
2. افتح Terminal من لوحة Hostinger (VPS ← «وحدة تحكم الويب»)، وشغّل:

```bash
/home/shahed/stack/update.sh backend
```

غيّر `backend` لاسم اللي حدّثته: `admin` أو `vendor` أو `site` أو `waitlist`.
بدون اسم بيحدّث الكل. التحديث بياخذ دقيقة أو دقيقتين.

## قاعدة البيانات في المتصفح

`https://db.shahedapp.com` (Adminer، مثل phpMyAdmin)

| | |
|---|---|
| System | PostgreSQL |
| Server | `db` |
| Username | `shahed` |
| Password | قيمة `POSTGRES_PASSWORD` في `stack/.env` |
| Database | `shahed` (كل بيانات شهد، ومنها جدول `waitlist`) |

## أوامر مفيدة (من Terminal)

```bash
cd /home/shahed/stack
docker compose ps                     # حالة كل خدمة
docker compose logs -f backend        # سجل الباك إند مباشرة
docker compose restart backend        # إعادة تشغيل بدون بناء
sh backup.sh                          # نسخة احتياطية الآن (داخل حاوية backups)
```

## الدفع التلقائي اليومي

بيضل **مطفأ** (`AUTO_PAYMENTS_IN_PROCESS=false` في `stack/.env`) لحد ما يتحوّل الدومين
للسيرفر وينطفئ Vercel. لو اشتغل بالمكانين، العميل بينخصم منه مرتين.
بعد التحويل: غيّرها لـ `true` وشغّل `update.sh backend`.
