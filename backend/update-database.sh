#!/bin/bash

# سكريبت تحديث قاعدة البيانات - Database Update Script
# يضيف عمود OTP إلى جدول users

echo "🔧 بدء تحديث قاعدة البيانات..."

# الألوان للأخبار
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# التحقق من وجود Docker
if docker ps | grep -q "bnpl-mysql"; then
    echo -e "${GREEN}✓${NC} MySQL container يعمل"
    
    # تنفيذ Migrations
    echo "📝 تنفيذ Migrations..."
    docker exec -i bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db < add-otp-column.sql
    docker exec -i bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db < add-commission-columns.sql
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} تم تحديث قاعدة البيانات بنجاح!"
        
        # التحقق من النتيجة
        echo "🔍 التحقق من التحديث..."
        docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db -e "DESCRIBE users;" | grep -q "otp"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} تم التحقق: عمود OTP موجود في جدول users"
            echo ""
            echo "📋 معلومات العمود:"
            docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db -e "DESCRIBE users;" | grep otp
        else
            echo -e "${YELLOW}⚠${NC}  لم يتم العثور على عمود OTP - قد تحتاج للتحديث يدوياً"
        fi
    else
        echo -e "${RED}✗${NC} حدث خطأ أثناء تنفيذ Migration"
        echo "💡 جرب التنفيذ يدوياً:"
        echo "   docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db"
        echo "   ALTER TABLE users ADD COLUMN otp VARCHAR(6) NULL AFTER employer;"
    fi
else
    echo -e "${YELLOW}⚠${NC}  MySQL container غير موجود أو لا يعمل"
    echo "💡 تأكد من تشغيل: docker-compose up -d"
    echo ""
    echo "أو قم بتنفيذ SQL يدوياً:"
    echo "  mysql -u bnpl_user -p bnpl_db < add-otp-column.sql"
fi

echo ""
echo "✅ انتهى السكريبت"

