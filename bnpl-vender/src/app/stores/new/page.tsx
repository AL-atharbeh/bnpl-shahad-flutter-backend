"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { getCategories, createStore } from "@/services/api";
import {
    Store,
    Globe,
    Tags,
    FileText,
    CheckCircle2,
    Loader2,
    ArrowRight,
    Upload,
    X,
    PlusCircle
} from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";

export default function NewStorePage() {
    const [formData, setFormData] = useState({
        name: "",
        nameAr: "",
        description: "",
        descriptionAr: "",
        logoUrl: "",
        websiteUrl: "",
        categoryId: "",
        genderCategoryId: "",
        storeUrl: "",
    });
    const [categories, setCategories] = useState<any[]>([]);
    const genderCategories = [
        { id: 1, name: "Women", nameAr: "نسائي" },
        { id: 2, name: "Men", nameAr: "رجالي" },
        { id: 3, name: "Kids", nameAr: "أطفال" },
        { id: 4, name: "Unisex/All", nameAr: "للجميع / للجنسين" },
    ];
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState(false);
    const router = useRouter();
    const { t, language } = useLanguage();

    useEffect(() => {
        const userStr = localStorage.getItem("vendor_user");
        if (!userStr) {
            router.push("/auth/login");
            return;
        }

        async function fetchCategories() {
            try {
                const res = await getCategories();
                setCategories(res.data.data);
            } catch (err) {
                console.error("Failed to fetch categories", err);
            }
        }
        fetchCategories();
    }, [router]);

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (file.size > 5 * 1024 * 1024) {
            setError(language === "ar" ? "حجم الصورة يجب أن يكون أقل من 5 ميجابايت" : "Image size must be less than 5MB");
            return;
        }

        const img = new Image();
        const reader = new FileReader();
        reader.onloadend = () => {
            img.onload = () => {
                const canvas = document.createElement("canvas");
                const MAX_SIZE = 400;
                let width = img.width;
                let height = img.height;

                if (width > height) {
                    if (width > MAX_SIZE) { height = (height * MAX_SIZE) / width; width = MAX_SIZE; }
                } else {
                    if (height > MAX_SIZE) { width = (width * MAX_SIZE) / height; height = MAX_SIZE; }
                }

                canvas.width = width;
                canvas.height = height;
                const ctx = canvas.getContext("2d");
                ctx?.drawImage(img, 0, 0, width, height);
                const compressedBase64 = canvas.toDataURL("image/jpeg", 0.7);
                setFormData(prev => ({ ...prev, logoUrl: compressedBase64 }));
            };
            img.src = reader.result as string;
        };
        reader.readAsDataURL(file);
    };

    const removeLogo = () => {
        setFormData(prev => ({ ...prev, logoUrl: "" }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            const userStr = localStorage.getItem("vendor_user");
            if (!userStr) return;
            const user = JSON.parse(userStr);

            const res = await createStore({
                ...formData,
                vendorId: user.id,
                categoryId: formData.categoryId ? parseInt(formData.categoryId) : undefined,
                genderCategoryId: formData.genderCategoryId ? parseInt(formData.genderCategoryId) : undefined,
                isActive: false,
                status: 'pending'
            });

            if (res.data.success) {
                setSuccess(true);
                setTimeout(() => {
                    router.push("/");
                }, 3000);
            }
        } catch (err: any) {
            setError(err.response?.data?.message || "Failed to create store request.");
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    if (success) {
        return (
            <DashboardLayout>
                <div className="flex flex-col items-center justify-center min-h-[60vh] text-center space-y-6">
                    <div className="inline-flex h-24 w-24 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-500 animate-pulse border-2 border-emerald-500/50">
                        <CheckCircle2 className="h-12 w-12" />
                    </div>
                    <h1 className="text-3xl font-black text-white">{language === 'ar' ? 'تم تقديم الطلب بنجاح' : 'Request Submitted Successfully'}</h1>
                    <p className="text-slate-400 max-w-md">
                        {language === 'ar' 
                            ? 'تم إرسال طلب إضافة المتجر للمراجعة من قبل الإدارة. ستصلك رسالة حال الموافقة عليه.' 
                            : 'The request to add a new store has been sent for review by the administration. You will receive a notification once approved.'}
                    </p>
                    <button onClick={() => router.push('/')} className="text-emerald-400 hover:underline text-sm font-bold">
                        {language === 'ar' ? 'العودة للرئيسية' : 'Back to Home'}
                    </button>
                </div>
            </DashboardLayout>
        );
    }

    return (
        <DashboardLayout>
            <div className="max-w-3xl mx-auto space-y-8 py-6">
                <div className="flex items-center gap-4">
                    <div className="h-12 w-12 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center">
                        <PlusCircle className="h-6 w-6 text-emerald-500" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-black text-white tracking-tight">{language === 'ar' ? 'إضافة متجر جديد' : 'Add New Store'}</h1>
                        <p className="text-sm text-slate-400">{language === 'ar' ? 'أكمل البيانات أدناه لإرسال طلب إضافة متجر جديد للمراجعة.' : 'Complete the details below to submit a new store request for review.'}</p>
                    </div>
                </div>

                <div className="glass rounded-3xl p-8 border-emerald-900/20 shadow-2xl">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {error && (
                            <div className="rounded-xl bg-red-500/10 border border-red-500/20 p-4 text-xs text-red-400 text-center">
                                {error}
                            </div>
                        )}

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div className="space-y-2">
                                <label className="text-xs font-bold text-slate-500 px-1">{language === 'ar' ? 'اسم المتجر (EN)' : 'Store Name (EN)'}</label>
                                <div className="relative">
                                    <Store className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-600" />
                                    <input
                                        name="name"
                                        required
                                        value={formData.name}
                                        onChange={handleChange}
                                        className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 pl-10 pr-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all"
                                        placeholder="Store name in English"
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-xs font-bold text-slate-500 px-1">{language === 'ar' ? 'اسم المتجر (AR)' : 'Store Name (AR)'}</label>
                                <div className="relative">
                                    <Store className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-600" />
                                    <input
                                        name="nameAr"
                                        required
                                        value={formData.nameAr}
                                        onChange={handleChange}
                                        className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 pr-10 pl-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all"
                                        placeholder="اسم المتجر بالعربي"
                                        dir="rtl"
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div className="space-y-2">
                                <label className="text-xs font-bold text-slate-500 px-1">{language === 'ar' ? 'رابط المتجر الفريد (Slug)' : 'Unique Store URL (Slug)'}</label>
                                <div className="relative">
                                    <Globe className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-600" />
                                    <input
                                        name="storeUrl"
                                        required
                                        value={formData.storeUrl}
                                        onChange={handleChange}
                                        className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 pl-10 pr-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all"
                                        placeholder="e.g. zara-jordan"
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-xs font-bold text-slate-500 px-1">{language === 'ar' ? 'تصنيف الجنس' : 'Gender Category'}</label>
                                <div className="relative">
                                    <Tags className={`absolute ${language === 'ar' ? 'right-3' : 'left-3'} top-1/2 -translate-y-1/2 h-4 w-4 text-emerald-500/50`} />
                                    <select
                                        name="genderCategoryId"
                                        required
                                        value={formData.genderCategoryId}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-slate-800 bg-[#011f18] py-3 ${language === 'ar' ? 'pr-10 pl-4' : 'pl-10 pr-4'} text-sm text-slate-200 outline-none focus:border-emerald-500/50 appearance-none`}
                                    >
                                        <option value="">{language === 'ar' ? 'اختر النوع' : 'Select Gender'}</option>
                                        {genderCategories.map((cat) => (
                                            <option key={cat.id} value={cat.id}>
                                                {language === "ar" ? cat.nameAr : cat.name}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-xs font-bold text-slate-500 px-1">{language === 'ar' ? 'وصف المتجر (EN)' : 'Store Description (EN)'}</label>
                            <div className="relative">
                                <FileText className="absolute left-3 top-3 h-4 w-4 text-slate-600" />
                                <textarea
                                    name="description"
                                    rows={2}
                                    value={formData.description}
                                    onChange={handleChange}
                                    className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 pl-10 pr-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all"
                                    placeholder="Brief description in English"
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-xs font-bold text-slate-500 px-1">{language === 'ar' ? 'وصف المتجر (AR)' : 'Store Description (AR)'}</label>
                            <div className="relative">
                                <FileText className="absolute right-3 top-3 h-4 w-4 text-slate-600" />
                                <textarea
                                    name="descriptionAr"
                                    rows={2}
                                    value={formData.descriptionAr}
                                    onChange={handleChange}
                                    className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 pr-10 pl-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all"
                                    placeholder="وصف المتجر بالعربي"
                                    dir="rtl"
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div className="space-y-2">
                                <label className="text-xs font-bold text-slate-500 px-1">{t("logo")}</label>
                                <div className="relative group">
                                    {formData.logoUrl ? (
                                        <div className="relative h-40 w-full rounded-2xl border-2 border-emerald-500/20 bg-emerald-500/5 flex items-center justify-center overflow-hidden group">
                                            <img src={formData.logoUrl} alt="Preview" className="h-full w-full object-contain p-4" />
                                            <button
                                                type="button"
                                                onClick={removeLogo}
                                                className="absolute top-2 right-2 h-8 w-8 rounded-full bg-red-500/80 text-white flex items-center justify-center hover:bg-red-600 transition-all opacity-0 group-hover:opacity-100"
                                            >
                                                <X className="h-4 w-4" />
                                            </button>
                                        </div>
                                    ) : (
                                        <label className="flex h-40 w-full cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed border-emerald-900/30 bg-[#011f18] transition-all hover:border-emerald-500/50 hover:bg-emerald-500/5">
                                            <Upload className="mb-3 h-8 w-8 text-emerald-500" />
                                            <p className="mb-2 text-sm text-slate-300 font-bold">{t("clickToUpload")}</p>
                                            <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} />
                                        </label>
                                    )}
                                </div>
                            </div>

                            <div className="space-y-2 flex flex-col">
                                <div className="flex-1 space-y-2">
                                    <label className="text-xs font-bold text-slate-500 px-1">{t("websiteUrl")}</label>
                                    <div className="relative">
                                        <Globe className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-600" />
                                        <input
                                            name="websiteUrl"
                                            value={formData.websiteUrl}
                                            onChange={handleChange}
                                            className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 pl-10 pr-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all"
                                            placeholder="https://example.com"
                                        />
                                    </div>
                                </div>
                                
                                <div className="flex-1 space-y-2">
                                    <label className="text-xs font-bold text-slate-500 px-1">{t("category")}</label>
                                    <div className="relative">
                                        <Tags className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-emerald-500/50" />
                                        <select
                                            name="categoryId"
                                            value={formData.categoryId}
                                            onChange={handleChange}
                                            className="w-full rounded-xl border border-slate-800 bg-[#011f18] py-3 pl-10 pr-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 appearance-none transition-all"
                                        >
                                            <option value="">{language === 'ar' ? 'اختر التصنيف' : 'Select Category'}</option>
                                            {categories.map((cat: any) => (
                                                <option key={cat.id} value={cat.id}>
                                                    {language === "ar" ? cat.nameAr || cat.name : cat.name}
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="btn-financial w-full rounded-xl py-4 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-bold shadow-xl shadow-emerald-500/10 transition-all active:scale-[0.98]"
                        >
                            {loading ? (
                                <Loader2 className="h-5 w-5 animate-spin" />
                            ) : (
                                <>
                                    {language === 'ar' ? 'إرسال طلب الإضافة' : 'Submit Request'}
                                    <ArrowRight className={`${language === "ar" ? "rotate-180" : ""} h-4 w-4`} />
                                </>
                            )}
                        </button>
                    </form>
                </div>
            </div>
        </DashboardLayout>
    );
}
