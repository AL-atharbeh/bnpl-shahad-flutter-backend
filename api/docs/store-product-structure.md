# هيكل المتاجر والمنتجات في BNPL

## نظرة عامة

هذا الملف يوضح كيفية عمل المتاجر والمنتجات في تطبيق BNPL.

## الفكرة الأساسية

### 1. المتاجر (Stores)
- **معلومات ثابتة** محفوظة في التطبيق
- **صفحة تفاصيل** تعرض معلومات المتجر فقط
- **زر "زيارة المتجر"** ينقل إلى الموقع الرسمي
- **لا تحتوي على منتجات**

### 2. المنتجات (Products)
- **مربوطة تلقائياً** مع المتاجر
- **يتم جلبها** من المتاجر الرسمية
- **زر "شراء من المتجر"** ينقل إلى صفحة المنتج في المتجر
- **لا يتم حفظها محلياً**

## هيكل البيانات

### Store Object
```json
{
  "id": 1,
  "name": "شي إن",
  "logo": "https://example.com/shein-logo.jpg",
  "banner": "https://example.com/shein-banner.jpg",
  "description": "متجر أزياء عالمي يقدم أحدث صيحات الموضة",
  "rating": 4.5,
  "reviewsCount": 1250,
  "category": "fashion",
  "location": "عمان، الأردن",
  "phone": "+962791234567",
  "email": "contact@shein.jo",
  "website": "https://www.shein.com",
  "socialMedia": {
    "instagram": "@shein_jo",
    "facebook": "shein.jordan",
    "twitter": "@shein_jo"
  },
  "features": {
    "hasDeal": true,
    "onlineOnly": true,
    "supportsBNPL": true,
    "freeShipping": true
  },
  "businessHours": {
    "sunday": "24/7",
    "monday": "24/7",
    "tuesday": "24/7",
    "wednesday": "24/7",
    "thursday": "24/7",
    "friday": "24/7",
    "saturday": "24/7"
  }
}
```

### Product Object
```json
{
  "id": "shein_product_123",
  "storeId": 1,
  "storeName": "شي إن",
  "name": "فستان أسود أنيق",
  "description": "فستان أنيق مناسب للمناسبات الرسمية",
  "price": 89.99,
  "originalPrice": 120.00,
  "currency": "JOD",
  "images": [
    "https://shein.com/images/dress1.jpg",
    "https://shein.com/images/dress2.jpg"
  ],
  "category": "dresses",
  "subcategory": "evening-dresses",
  "attributes": {
    "material": "قطن 100%",
    "color": "أسود",
    "sizes": ["XS", "S", "M", "L", "XL"],
    "availableSizes": ["S", "M", "L"],
    "brand": "SHEIN"
  },
  "availability": {
    "inStock": true,
    "stockQuantity": 50,
    "estimatedDelivery": "3-5 أيام عمل"
  },
  "externalLinks": {
    "productUrl": "https://www.shein.com/dress-black-elegant-p-123",
    "storeUrl": "https://www.shein.com"
  },
  "metadata": {
    "lastUpdated": "2024-01-20T10:30:00Z",
    "source": "shein_api"
  }
}
```

## الـ API Endpoints المحدثة

### Stores Endpoints

#### GET /stores
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "شي إن",
      "logo": "https://example.com/shein-logo.jpg",
      "banner": "https://example.com/shein-banner.jpg",
      "description": "متجر أزياء عالمي",
      "rating": 4.5,
      "reviewsCount": 1250,
      "category": "fashion",
      "website": "https://www.shein.com",
      "features": {
        "hasDeal": true,
        "supportsBNPL": true
      }
    }
  ]
}
```

#### GET /stores/{id}
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "شي إن",
    "logo": "https://example.com/shein-logo.jpg",
    "banner": "https://example.com/shein-banner.jpg",
    "description": "متجر أزياء عالمي يقدم أحدث صيحات الموضة بأسعار منافسة",
    "rating": 4.5,
    "reviewsCount": 1250,
    "category": "fashion",
    "location": "عمان، الأردن",
    "phone": "+962791234567",
    "email": "contact@shein.jo",
    "website": "https://www.shein.com",
    "socialMedia": {
      "instagram": "@shein_jo",
      "facebook": "shein.jordan"
    },
    "features": {
      "hasDeal": true,
      "onlineOnly": true,
      "supportsBNPL": true,
      "freeShipping": true
    },
    "businessHours": {
      "sunday": "24/7",
      "monday": "24/7"
    }
  }
}
```

### Products Endpoints

#### GET /products
```json
{
  "success": true,
  "data": [
    {
      "id": "shein_product_123",
      "storeId": 1,
      "storeName": "شي إن",
      "name": "فستان أسود أنيق",
      "price": 89.99,
      "originalPrice": 120.00,
      "currency": "JOD",
      "images": ["https://shein.com/images/dress1.jpg"],
      "category": "dresses",
      "attributes": {
        "material": "قطن 100%",
        "color": "أسود",
        "sizes": ["S", "M", "L"]
      },
      "availability": {
        "inStock": true,
        "estimatedDelivery": "3-5 أيام عمل"
      },
      "externalLinks": {
        "productUrl": "https://www.shein.com/dress-black-elegant-p-123",
        "storeUrl": "https://www.shein.com"
      }
    }
  ]
}
```

#### GET /products/{id}
```json
{
  "success": true,
  "data": {
    "id": "shein_product_123",
    "storeId": 1,
    "storeName": "شي إن",
    "name": "فستان أسود أنيق",
    "description": "فستان أنيق مناسب للمناسبات الرسمية",
    "price": 89.99,
    "originalPrice": 120.00,
    "currency": "JOD",
    "images": [
      "https://shein.com/images/dress1.jpg",
      "https://shein.com/images/dress2.jpg"
    ],
    "category": "dresses",
    "subcategory": "evening-dresses",
    "attributes": {
      "material": "قطن 100%",
      "color": "أسود",
      "sizes": ["XS", "S", "M", "L", "XL"],
      "availableSizes": ["S", "M", "L"],
      "brand": "SHEIN"
    },
    "availability": {
      "inStock": true,
      "stockQuantity": 50,
      "estimatedDelivery": "3-5 أيام عمل"
    },
    "externalLinks": {
      "productUrl": "https://www.shein.com/dress-black-elegant-p-123",
      "storeUrl": "https://www.shein.com"
    },
    "metadata": {
      "lastUpdated": "2024-01-20T10:30:00Z",
      "source": "shein_api"
    }
  }
}
```

## تدفق المستخدم

### 1. تصفح المتاجر
```
الصفحة الرئيسية → قائمة المتاجر → تفاصيل المتجر → زر "زيارة المتجر"
```

### 2. تصفح المنتجات
```
الصفحة الرئيسية → قائمة المنتجات → تفاصيل المنتج → زر "شراء من المتجر"
```

### 3. البحث
```
البحث → نتائج المنتجات → تفاصيل المنتج → زر "شراء من المتجر"
```

## ملاحظات مهمة

### للمتاجر:
- **معلومات ثابتة** يتم تحديثها يدوياً
- **لا تحتوي على منتجات**
- **زر "زيارة المتجر"** ينقل إلى الموقع الرسمي

### للمنتجات:
- **مربوطة مع المتاجر** تلقائياً
- **يتم جلبها** من APIs المتاجر
- **زر "شراء من المتجر"** ينقل إلى صفحة المنتج
- **لا يتم حفظها** محلياً بشكل دائم

### للـ BNPL:
- **يتم التعامل** مع المتجر مباشرة
- **التطبيق** يعمل كوسيط فقط
- **المدفوعات** تتم في المتجر الأصلي
