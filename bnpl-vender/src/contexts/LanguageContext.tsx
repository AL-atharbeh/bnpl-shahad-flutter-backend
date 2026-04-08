"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

type Language = "ar" | "en";

interface LanguageContextType {
    language: Language;
    setLanguage: (lang: Language) => void;
    t: (key: string) => string;
    dir: "rtl" | "ltr";
}

const translations: Record<Language, Record<string, string>> = {
    ar: {
        // Sidebar & Navigation
        dashboard: "لوحة التحكم",
        transactions: "العمليات المالية",
        finance: "التسويات المالية",
        settings: "إعدادات المتجر",
        logout: "تسجيل الخروج",
        partnersPortal: "بوابة الشركاء",
        products: "إدارة المنتجات",
        pos: "نقطة البيع (بيع داخلي)",
        posDescription: "قم بإنشاء طلب دفع فوري للعملاء المتواجدين في المتجر.",
        salesOps: "العمليات البيعية",
        salesOpsDescription: "متابعة تفصيلية لحجم المبيعات وحركة القطع المباعة والتحصيلات.",
        piecesSold: "القطع المباعة",
        totalVolume: "إجمالي قيمة المبيعات",
        collectedPerTotal: "المحصل من الإجمالي",
        orderDate: "تاريخ الطلب",
        itemsCount: "عدد القطع",
        paymentProgress: "تقدم التحصيل",
        totalOrders: "إجمالي الطلبات",
        activeCustomers: "العملاء النشطون",
        customerPhone: "رقم هاتف العميل",
        totalAmount: "المبلغ الإجمالي",
        installmentsCount: "عدد الأقساط",
        createSession: "إرسال طلب الدفع",
        paymentSent: "تم إرسال طلب الدفع بنجاح",
        scanToPay: "ار المسح بالكود للدفع",
        searchProduct: "ابحث عن منتج بالاسم...",
        addToCart: "إضافة للسلة",
        clearCart: "إفراغ السلة",
        cartTitle: "ملخص الطلب",
        total: "المجموع",
        customerInfo: "بيانات العميل",
        paymentMethod: "طريقة إرسال الطلب",
        sendToPhone: "إرسال إلى رقم هاتف العميل",
        scanQR: "مسح الكود عبر تطبيق شهد",
        enterPhone: "أدخل رقم الهاتف المسجل",
        showQR: "أظهر كود الدفع للعميل",
        sessionActive: "جلسة الدفع نشطة حالياً",
        waitingCustomerApproval: "بانتظار موافقة العميل...",
        backToPOS: "العودة لنقطة البيع",

        // Dashboard
        welcome: "أهلاً بك",
        performanceSummary: "إليك ملخص أداء متجرك خلال الفترة الحالية.",
        downloadReport: "تنزيل التقرير",
        totalSales: "مبيعات الربع الحالي",
        totalCollections: "إجمالي التحصيلات",
        riskLevel: "معدل المخاطر",
        platformCommission: "عمولة المنصة",
        basedOnInstallments: "بناءً على طلبات التقسيط",
        completedPayments: "دفعات مكتملة",
        riskRatio: "نسبة التعثر الحالية",
        serviceFees: "مستقطعات الخدمة",
        salesGrowth: "تطور المبيعات والأقساط",
        last6Months: "آخر 6 أشهر من العمليات",
        quickActions: "إجراءات سريعة",
        updatePrices: "تحديث أسعار المنتجات",
        updatePricesDetail: "تعديل الأسعار والعروض الخاصة.",
        addBranch: "إضافة متجر جديد",
        addBranchDetail: "توسيع نطاق العمل وإضافة متاجر.",
        requestSettlement: "طلب تسوية فورية",
        requestSettlementDetail: "المطالبة بالمبالغ المستحقة.",
        accountActiveMsg: "حسابك مفعل وجاهز للعمل",
        activeNow: "نشط الآن",
        currency: "د.أ",

        // Transactions
        orderId: "رقم الطلب",
        customer: "العميل",
        amount: "المبلغ",
        status: "الحالة",
        date: "التاريخ",
        actions: "الإجراءات",
        transactionsDescription: "تابع كافة عمليات التقسيط التي تمت في متجرك.",
        productValue: "قيمة العملة",
        unknownCustomer: "عميل غير معروف",
        paid: "مدفوع",
        noTransactions: "لا توجد عمليات حالياً.",
        filter: "تصفية",
        export: "تصدير CSV",
        completed: "مكتمل",
        processing: "قيد المعالجة",

        // Products
        productList: "قائمة المنتجات",
        addProduct: "إضافة منتج",
        editProduct: "تعديل منتج",
        productName: "اسم المنتج",
        productNameAr: "اسم المنتج (عربي)",
        productPrice: "السعر",
        stockStatus: "حالة المخزون",
        inStock: "متوفر",
        outOfStock: "غير متوفر",
        category: "التصنيف",
        deleteProduct: "حذف المنتج",
        deleteConfirm: "هل أنت متأكد من حذف هذا المنتج؟",
        image: "صورة",
        uploadImage: "رفع صورة",

        // Finance
        financialSettlements: "التسويات المالية",
        manageProfits: "إدارة الأرباح والتحويلات البنكية الخاصة بمتجرك.",
        pendingBalance: "الرصيد المعلق",
        lastTransfer: "آخر تحويل",
        nextSettlementDate: "موعد التسوية القادم",
        nextSettlementDateDetail: "سيتم تحويلها في موعد التسوية القادم",
        transferredOn: "تم التحويل بتاريخ",
        settlementHistory: "سجل التسويات",
        noSettlements: "لا توجد تسويات سابقة.",
        reference: "المرجع",
        monthlySettlement: "تسوية شهرية",
        transferSuccess: "تم التحويل بنجاح",
        loadingSettlements: "جاري تحميل سجل التسويات...",

        // Settings
        storeSettings: "إعدادات المتجر",
        manageProfile: "إدارة الملف التعريفي للمتجر ومعلومات التواصل.",
        basicInfo: "المعلومات الأساسية",
        storeName: "اسم المتجر",
        contactPhone: "رقم هاتف التواصل",
        officialEmail: "البريد الإلكتروني الرسمي",
        mainAddress: "العنوان الرئيسي",
        saveChanges: "حفظ التغييرات",
        accountActive: "الحساب مفعل",
        quickInfo: "معلومات سريعة",
        workingHours: "ساعات العمل",
        workingHoursDetail: "ساعات العمل: 9 ص - 10 م",
        verifiedPartner: "شريك معتمد",
        verifiedPartnerStatus: "الحالة: شريك معتمد",
        loading: "جاري التحميل...",
        genderCategory: "فئة المتجر (رجال/نساء)",
        women: "نساء",
        men: "رجال",
        kids: "أطفال",
        unisex: "الكل / للجنسين",
        mainCategory: "التصنيف الرئيسي للمتجر",

        // Auth
        loginTitle: "تسجيل الدخول",
        loginWelcome: "مرحباً بك مجدداً في بوابة الموردين",
        email: "البريد الإلكتروني",
        password: "كلمة المرور",
        loginButton: "دخول للنظام",
        noAccount: "ليس لديك حساب؟",
        signupLinkText: "أنشئ حسابك الآن",
        techTeamCredit: "بواسطة فريق BNPL التقني",
        signupTitle: "إنشاء حساب جديد",
        signupWelcome: "انضم لشبكة تجارنا وابدأ البيع بالتقسيط",
        fullName: "الاسم الكامل",
        vendorName: "اسم المورد",
        phoneNumber: "رقم الهاتف",
        getStarted: "البدء الآن",
        haveAccount: "لديك حساب بالفعل؟",
        loginLinkText: "سجل دخولك",
        loginError: "خطأ في تسجيل الدخول. يرجى التأكد من البيانات.",
        joinAsPartner: "انضم إلينا كشريك",
        signupSubtitle: "ابدأ بقبول مدفوعات BNPL في متجرك اليوم",
        createAccountAndStart: "إنشاء الحساب والبدء",

        // Store Setup
        storeSetupTitle: "إعداد المتجر",
        storeSetupSubtitle: "أكمل بيانات متجرك ليتمكن العملاء من التعرف عليك",
        storeNameAr: "اسم المتجر (بالعربية)",
        storeNameEn: "اسم المتجر (بالإنجليزية)",
        descriptionAr: "وصف المتجر (بالعربية)",
        descriptionEn: "وصف المتجر (بالإنجليزية)",
        logo: "شعار المتجر",
        clickToUpload: "انقر للرفع أو اسحب الصورة هنا",
        websiteUrl: "رابط الموقع الإلكتروني الرسمي",
        storeUrl: "رابط المتجر المخصص",
        productsCount: "عدد المنتجات",

        finishSetup: "إكمال الإعداد والبدء",
        setupSuccess: "تم حفظ الإعدادات بنجاح",
        apiCredentials: "بيانات الربط البرمجي (API)",
        apiKeyLabel: "المفتاح العام (Public API Key)",
        apiSecretLabel: "المفتاح السري (Secret API Key)",
        copy: "نسخ",
        show: "إظهار",
        hide: "إخفاء",
    },
    en: {
        // Sidebar & Navigation
        dashboard: "Dashboard",
        transactions: "Transactions",
        finance: "Financial Settlements",
        settings: "Store Settings",
        logout: "Logout",
        partnersPortal: "Partners Portal",
        products: "Products",
        pos: "Point of Sale (POS)",
        posDescription: "Create instant payment requests for in-store customers.",
        salesOps: "Sales Operations",
        salesOpsDescription: "Detailed tracking of sales volume, pieces sold, and collections.",
        piecesSold: "Pieces Sold",
        totalVolume: "Total Sales Volume",
        collectedPerTotal: "Collected vs Total",
        orderDate: "Order Date",
        itemsCount: "Items Count",
        paymentProgress: "Payment Progress",
        totalOrders: "Total Orders",
        activeCustomers: "Active Customers",
        customerPhone: "Customer Phone Number",
        totalAmount: "Total Amount",
        installmentsCount: "Installments Count",
        createSession: "Send Payment Request",
        paymentSent: "Payment Request Sent Successfully",
        scanToPay: "Scan QR to Pay",
        searchProduct: "Search product by name...",
        addToCart: "Add to Cart",
        clearCart: "Clear Cart",
        cartTitle: "Order Summary",
        total: "Total",
        customerInfo: "Customer Info",
        paymentMethod: "Payment Method",
        sendToPhone: "Send to customer phone",
        scanQR: "Scan QR with Shahd App",
        enterPhone: "Enter registered phone number",
        showQR: "Show payment QR to customer",
        sessionActive: "Payment session is active",
        waitingCustomerApproval: "Waiting for customer approval...",
        backToPOS: "Back to POS",

        // Dashboard
        welcome: "Welcome",
        performanceSummary: "Here is your store performance summary for the current period.",
        downloadReport: "Download Report",
        totalSales: "Current Quarter Sales",
        totalCollections: "Total Collections",
        riskLevel: "Risk Level",
        platformCommission: "Platform Commission",
        basedOnInstallments: "Based on installment orders",
        completedPayments: "Completed payments",
        riskRatio: "Current default rate",
        serviceFees: "Service deductions",
        salesGrowth: "Sales & Installments Growth",
        last6Months: "Last 6 months of operations",
        quickActions: "Quick Actions",
        updatePrices: "Update Product Prices",
        updatePricesDetail: "Edit prices and special offers.",
        addBranch: "Add New Store",
        addBranchDetail: "Expand scope and add stores.",
        requestSettlement: "Request Instant Settlement",
        requestSettlementDetail: "Claim outstanding amounts.",
        accountActiveMsg: "Your account is active and ready",
        activeNow: "Active Now",
        currency: "JOD",

        // Transactions
        orderId: "Order ID",
        customer: "Customer",
        amount: "Amount",
        status: "Status",
        date: "Date",
        actions: "Actions",
        searchPlaceholder: "Search by order ID or customer name...",
        transactionsDescription: "Track all installment operations that took place in your store.",
        productValue: "Product Value",
        unknownCustomer: "Unknown Customer",
        paid: "Paid",
        noTransactions: "No transactions currently.",
        filter: "Filter",
        export: "Export CSV",
        processing: "Processing",

        // Products
        productList: "Products List",
        addProduct: "Add Product",
        editProduct: "Edit Product",
        productName: "Product Name",
        productNameAr: "Product Name (Arabic)",
        productPrice: "Price",
        stockStatus: "Stock Status",
        inStock: "In Stock",
        outOfStock: "Out of Stock",
        deleteProduct: "Delete Product",
        deleteConfirm: "Are you sure you want to delete this product?",
        image: "Image",
        uploadImage: "Upload Image",

        // Finance
        financialSettlements: "Financial Settlements",
        manageProfits: "Manage profits and bank transfers for your store.",
        pendingBalance: "Pending Balance",
        lastTransfer: "Last Transfer",
        nextSettlementDate: "Next Settlement Date",
        nextSettlementDateDetail: "Will be transferred on the next settlement date",
        transferredOn: "Transferred on",
        settlementHistory: "Settlement History",
        noSettlements: "No past settlements.",
        reference: "Ref",
        monthlySettlement: "Monthly Settlement",
        transferSuccess: "Transferred Successfully",
        loadingSettlements: "Loading settlement history...",

        // Settings
        storeSettings: "Store Settings",
        manageProfile: "Manage store profile and contact information.",
        basicInfo: "Basic Information",
        storeName: "Store Name",
        contactPhone: "Contact Phone",
        officialEmail: "Official Email",
        mainAddress: "Main Address",
        saveChanges: "Save Changes",
        accountActive: "Account Active",
        quickInfo: "Quick Info",
        workingHours: "Working Hours",
        workingHoursDetail: "Working Hours: 9 AM - 10 PM",
        verifiedPartner: "Verified Partner",
        verifiedPartnerStatus: "Status: Verified Partner",
        loading: "Loading...",
        genderCategory: "Store Category (Gender)",
        women: "Women",
        men: "Men",
        kids: "Kids",
        unisex: "All / Unisex",
        mainCategory: "Main Store Category",

        // Auth
        loginTitle: "Login",
        loginWelcome: "Welcome back to the Partners Portal",
        email: "Email Address",
        password: "Password",
        loginButton: "Enter System",
        noAccount: "Don't have an account?",
        signupLinkText: "Create your account now",
        techTeamCredit: "By BNPL Technical Team",
        signupTitle: "Create New Account",
        signupWelcome: "Join our merchant network and start selling with installments",
        fullName: "Full Name",
        vendorName: "Vendor Name",
        phoneNumber: "Phone Number",
        getStarted: "Get Started Now",
        haveAccount: "Already have an account?",
        loginLinkText: "Login here",
        loginError: "Login failed. Please check your credentials.",
        joinAsPartner: "Join as a Partner",
        signupSubtitle: "Start accepting BNPL payments in your store today",
        createAccountAndStart: "Create Account and Start",

        // Store Setup
        storeSetupTitle: "Store Setup",
        storeSetupSubtitle: "Complete your store details so customers can recognize you",
        storeNameAr: "Store Name (Arabic)",
        storeNameEn: "Store Name (English)",
        descriptionAr: "Store Description (Arabic)",
        descriptionEn: "Store Description (English)",
        logo: "Store Logo",
        clickToUpload: "Click to upload or drag & drop",
        websiteUrl: "Official Website URL",
        storeUrl: "Custom Store URL",
        productsCount: "Products Count",
        category: "Category",
        finishSetup: "Finish Setup & Start",
        setupSuccess: "Settings saved successfully",
        apiCredentials: "API Credentials",
        apiKeyLabel: "Public API Key",
        apiSecretLabel: "Secret API Key",
        copy: "Copy",
        show: "Show",
        hide: "Hide",
    },
};

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
    const [language, setLanguage] = useState<Language>("ar");

    useEffect(() => {
        const savedLang = localStorage.getItem("vendor_lang") as Language;
        if (savedLang) {
            setLanguage(savedLang);
        }
    }, []);

    const handleSetLanguage = (lang: Language) => {
        setLanguage(lang);
        localStorage.setItem("vendor_lang", lang);
        document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
        document.documentElement.lang = lang;
    };

    useEffect(() => {
        document.documentElement.dir = language === "ar" ? "rtl" : "ltr";
        document.documentElement.lang = language;
    }, [language]);

    const t = (key: string) => {
        return translations[language][key] || key;
    };

    const dir = language === "ar" ? "rtl" : "ltr";

    return (
        <LanguageContext.Provider value={{ language, setLanguage: handleSetLanguage, t, dir }}>
            {children}
        </LanguageContext.Provider>
    );
}

export function useLanguage() {
    const context = useContext(LanguageContext);
    if (context === undefined) {
        throw new Error("useLanguage must be used within a LanguageProvider");
    }
    return context;
}
