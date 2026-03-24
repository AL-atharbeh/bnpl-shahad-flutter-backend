# 🔍 Debug: المدفوعات المعلقة في الصفحة الرئيسية

## ✅ البيانات الصحيحة في قاعدة البيانات

```
ID  | Amount  | Store              | Due Date
----|---------|-------------------|------------------
13  | 150.50  | Test Store 1       | 2025-11-10
15  | 75.25   | Fashion Store      | 2025-11-16
14  | 250.00  | Electronics Store  | 2025-11-18
```

---

## 📊 Backend Logs المتوقعة

عند فتح الصفحة الرئيسية، يجب أن ترى في Backend logs:

```
[HomeService] Found 3 pending payments for user 8
  Payment 1: ID=13, Amount=150.50, Store=Test Store 1, DueDate=2025-11-10T20:13:53.000Z
  Payment 2: ID=15, Amount=75.25, Store=Fashion Store, DueDate=2025-11-16T20:14:05.000Z
  Payment 3: ID=14, Amount=250.00, Store=Electronics Store, DueDate=2025-11-18T20:14:05.000Z

[HomeService] Formatted payment ID=13: amount=150.5, title=Test Store 1, daysUntilDue=...
[HomeService] Formatted payment ID=15: amount=75.25, title=Fashion Store, daysUntilDue=...
[HomeService] Formatted payment ID=14: amount=250, title=Electronics Store, daysUntilDue=...
```

---

## 📱 Flutter Logs المتوقعة

في Flutter Console، يجب أن ترى:

```
🏠 [HomePage] Received 3 pending payments from backend
  Raw Payment 1: ID=13, Amount=150.5 (type: double), Title=Test Store 1, Store=null, daysUntilDue=...
  Raw Payment 2: ID=15, Amount=75.25 (type: double), Title=Fashion Store, Store=null, daysUntilDue=...
  Raw Payment 3: ID=14, Amount=250.0 (type: double), Title=Electronics Store, Store=null, daysUntilDue=...

    Parsed amount: 150.5 from 150.5
    Formatted: ID=13, Title=Test Store 1, Amount=JD 150.50, DaysLeft=...
    Parsed amount: 75.25 from 75.25
    Formatted: ID=15, Title=Fashion Store, Amount=JD 75.25, DaysLeft=...
    Parsed amount: 250.0 from 250.0
    Formatted: ID=14, Title=Electronics Store, Amount=JD 250.00, DaysLeft=...

🏠 [HomePage] Formatted 3 payments for display
  Payment 1: ID=13, Title=Test Store 1, Amount=JD 150.50
  Payment 2: ID=15, Title=Fashion Store, Amount=JD 75.25
  Payment 3: ID=14, Title=Electronics Store, Amount=JD 250.00
```

---

## 🔧 كيفية رؤية Logs

### Backend Logs:
```bash
cd backend
docker-compose logs app --tail=100 -f | grep -E "\[HomeService\]|Found.*pending"
```

### Flutter Logs:
1. افتح Terminal في VS Code
2. شغل التطبيق: `flutter run`
3. افتح الصفحة الرئيسية
4. ستظهر الـ logs في Terminal

---

## ❌ المشاكل المحتملة

### 1. **عدد الدفعات خاطئ**
- إذا ظهر أكثر من 3 دفعات:
  - تحقق من `take: 3` في `home.service.ts`
  - تحقق من قاعدة البيانات - قد تكون هناك دفعات إضافية

### 2. **المبالغ خاطئة**
- إذا ظهرت المبالغ كـ 0 أو خاطئة:
  - تحقق من `amount` في Backend - يجب أن يكون `number`
  - تحقق من parsing في Flutter

### 3. **أسماء المتاجر خاطئة**
- إذا ظهرت "Unknown":
  - تحقق من `store` relation في Backend
  - تحقق من `p['title']` أو `p['store']?['name']` في Flutter

### 4. **الأيام المتبقية خاطئة**
- إذا ظهرت الأيام خاطئة:
  - تحقق من `daysUntilDue` في Backend
  - تحقق من `dueDate` في قاعدة البيانات

---

## 📝 ملاحظات

- **Backend** يرجع `amount` كـ `number` (ليس string)
- **Backend** يرجع `daysUntilDue` كـ `number`
- **Flutter** يستخرج `title` من `p['title']` أو `p['store']?['name']`
- **Flutter** يحسب `amount` من `p['amount']` (number)

---

## ✅ التحقق

1. ✅ عدد الدفعات = 3
2. ✅ المبالغ صحيحة: 150.50, 75.25, 250.00
3. ✅ أسماء المتاجر صحيحة
4. ✅ الأيام المتبقية صحيحة

إذا كانت البيانات لا تزال خاطئة، أرسل الـ logs من Backend و Flutter.

