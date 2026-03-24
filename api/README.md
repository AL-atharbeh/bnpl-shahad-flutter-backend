# BNPL API Project

## الفكرة العامة

هذا المشروع يتبع نهج **API-First** حيث:

1. **نحدد الـ endpoints والـ JSON schemas** أولاً
2. **ننشئ Mock Server** يرد بنفس الـ JSON المتفق عليه
3. **تطبيق Flutter يعمل فعلياً** مع الـ Mock Server

## هيكل المشروع

```
api/
├── docs/           # توثيق الـ API specifications
├── mock-server/    # Mock Server implementation
└── README.md       # هذا الملف
```

## الخطوات القادمة

1. تحديد الـ endpoints المطلوبة
2. تصميم JSON schemas
3. إنشاء Mock Server
4. اختبار الـ API مع تطبيق Flutter

## التقنيات المقترحة

- **Mock Server**: JSON Server أو Express.js
- **API Documentation**: OpenAPI/Swagger
- **JSON Schemas**: JSON Schema validation
