# دليل النشر على Vercel

يحل هذا الدليل محل النشر القديم على سيرفر Hetzner.

## البنية الجديدة

| المشروع | المنصة | الدومين |
|---|---|---|
| `backend` (NestJS) | Vercel Functions | `api.shahedapp.com` |
| `bnpl-admin` (Next.js) | Vercel | `admin.shahedapp.com` |
| `bnpl-vender` (Next.js) | Vercel | `vendor.shahedapp.com` |
| قاعدة البيانات | Vercel Postgres (Neon) | — |
| الصور | Vercel Blob | — |
| DNS + البريد | Cloudflare (كما هو) | — |

> الـ Nameservers تبقى على Cloudflare. تغييرها إلى Vercel **يُعطّل البريد**
> لأن Email Routing خدمة من Cloudflare.

---

## 1. رفع الكود

```bash
git push -u origin migrate-to-vercel
```

## 2. إنشاء مشاريع Vercel الثلاثة

من [vercel.com/new](https://vercel.com/new) استورد المستودع **ثلاث مرات**،
وفي كل مرة غيّر **Root Directory** فقط:

| اسم المشروع | Root Directory |
|---|---|
| `bnpl-backend` | `backend` |
| `bnpl-admin` | `bnpl-admin` |
| `bnpl-vendor` | `bnpl-vender` |

## 3. تجهيز التخزين (في مشروع الباكند)

من تبويب **Storage** في مشروع `bnpl-backend`:

1. **Create Database → Postgres** — يضيف `DATABASE_URL` تلقائياً
2. **Create → Blob** — يضيف `BLOB_READ_WRITE_TOKEN` تلقائياً

## 4. متغيرات البيئة للباكند

في **Settings → Environment Variables**:

| المتغير | القيمة |
|---|---|
| `DATABASE_URL` | يُضاف تلقائياً مع Postgres |
| `BLOB_READ_WRITE_TOKEN` | يُضاف تلقائياً مع Blob |
| `DB_SYNC` | `true` **لأول نشر فقط**، ثم `false` |
| `JWT_SECRET` | سر جديد عشوائي — **لا تستخدم القديم** |
| `JWT_EXPIRES_IN` | `7d` |
| `API_PREFIX` | `api/v1` |
| `CRON_SECRET` | سر جديد عشوائي |
| `CORS_ORIGINS` | `https://shahedapp.com,https://admin.shahedapp.com,https://vendor.shahedapp.com` |
| `APP_URL` | `https://api.shahedapp.com` |
| `STRIPE_SECRET_KEY` | مفتاح **جديد** من Stripe |
| `STRIPE_PUBLISHABLE_KEY` | مفتاح **جديد** من Stripe |
| `FIREBASE_PROJECT_ID` | `shahedapp` |
| `FIREBASE_CLIENT_EMAIL` | من ملف خدمة Firebase |
| `FIREBASE_PRIVATE_KEY` | من ملف خدمة Firebase |

لتوليد الأسرار:

```bash
openssl rand -hex 32
```

## 5. متغيرات البيئة للواجهتين

في كل من `bnpl-admin` و `bnpl-vendor`:

| المتغير | القيمة |
|---|---|
| `NEXT_PUBLIC_API_URL` | `https://api.shahedapp.com/api/v1` |

## 6. أول نشر وإنشاء الجداول

1. تأكد أن `DB_SYNC=true`
2. **Deploy**
3. افتح `https://<اسم-المشروع>.vercel.app/` — يجب أن ترى رسالة الترحيب
4. ارجع وغيّر `DB_SYNC` إلى `false` ثم أعد النشر

> `DB_SYNC=true` ينشئ الـ 29 جدولاً تلقائياً. إبقاؤه مفعّلاً في الإنتاج خطر
> لأنه قد يغيّر المخطط ويحذف أعمدة عند أي تعديل على الكيانات.

## 7. ربط الدومينات

لكل مشروع: **Settings → Domains → Add**، ثم في Cloudflare عدّل السجل
الموجود من `A` إلى `CNAME` يشير إلى ما تعطيه Vercel:

| السجل | النوع | القيمة | Proxy |
|---|---|---|---|
| `api` | CNAME | `cname.vercel-dns.com` | DNS only |
| `admin` | CNAME | `cname.vercel-dns.com` | DNS only |
| `vendor` | CNAME | `cname.vercel-dns.com` | DNS only |

> اجعلها **DNS only** (سحابة رمادية) حتى تتمكن Vercel من إصدار شهادة SSL.
> **لا تلمس سجلات `MX` ولا `TXT`** — فهي بريدك.

## 8. تطبيق Flutter

لا يحتاج أي تعديل. الرابط في `lib/config/env/env_dev.dart` هو
`https://api.shahedapp.com/api/v1`، وسيعمل فور توجيه الدومين.

---

## المهمة المجدولة (الدفع التلقائي)

الدوال على Vercel لا تبقى قيد التشغيل، لذا لا يعمل `@Cron` داخل التطبيق.
تستدعي **Vercel Cron** بدلاً منه المسار `/api/v1/cron/auto-payments` يومياً
الساعة 9 صباحاً (معرّف في `backend/vercel.json`)، وهو محمي بـ `CRON_SECRET`.

للاختبار اليدوي:

```bash
curl -H "Authorization: Bearer $CRON_SECRET" \
  https://api.shahedapp.com/api/v1/cron/auto-payments
```

## قيود يجب معرفتها

- **حد 4.5 ميغابايت** على حجم الطلب في Vercel. رفع صورة أكبر سيفشل رغم أن
  الكود يسمح بـ 10 ميغابايت. الحل عند الحاجة: الرفع المباشر من المتصفح إلى Blob.
- **حد 60 ثانية** لتنفيذ الدالة في الخطة المجانية. إذا كثرت الأقساط المستحقة
  في يوم واحد قد تتجاوز المهمة المجدولة هذا الحد وتُقطع.
- **Vercel Cron في الخطة المجانية** يسمح بمهمة يومية واحدة فقط.
