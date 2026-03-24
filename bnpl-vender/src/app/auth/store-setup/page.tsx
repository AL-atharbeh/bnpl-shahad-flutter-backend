"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getCategories, updateStoreSettings } from "@/services/api";
import {
    Store,
    Image as ImageIcon,
    Globe,
    Tags,
    FileText,
    CheckCircle2,
    Languages,
    Loader2,
    ArrowRight,
    Upload,
    X
} from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";

export default function StoreSetupPage() {
    const [formData, setFormData] = useState({
        name: "",
        nameAr: "",
        description: "",
        descriptionAr: "",
        logoUrl: "",
        websiteUrl: "",
        categoryId: "",
    });
    const [categories, setCategories] = useState<any[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState(false);
    const router = useRouter();
    const { t, language, setLanguage } = useLanguage();

    useEffect(() => {
        const userStr = localStorage.getItem("vendor_user");
        if (!userStr) {
            router.push("/auth/login");
            return;
        }

        const user = JSON.parse(userStr);
        setFormData(prev => ({ ...prev, name: user.storeName || "" }));

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

        // Validation
        if (file.size > 5 * 1024 * 1024) {
            setError(language === "ar" ? "حجم الصورة يجب أن يكون أقل من 5 ميجابايت" : "Image size must be less than 5MB");
            return;
        }

        // Compress image using canvas before converting to base64
        const img = new Image();
        const reader = new FileReader();
        reader.onloadend = () => {
            img.onload = () => {
                const canvas = document.createElement("canvas");
                const MAX_SIZE = 200;
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

            const res = await updateStoreSettings(user.storeId, {
                ...formData,
                categoryId: formData.categoryId ? parseInt(formData.categoryId) : undefined,
            });

            if (res.data.success) {
                setSuccess(true);
                setTimeout(() => {
                    router.push("/");
                }, 2000);
            }
        } catch (err: any) {
            setError(err.response?.data?.message || "Failed to update store settings.");
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const toggleLanguage = () => {
        setLanguage(language === "ar" ? "en" : "ar");
    };

    if (success) {
        return (
            <div className="flex min-h-screen items-center justify-center bg-[#01160e] p-6 text-center">
                <div className="space-y-6">
                    <div className="inline-flex h-24 w-24 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-500 animate-bounce">
                        <CheckCircle2 className="h-12 w-12" />
                    </div>
                    <h1 className="text-3xl font-black text-white">{t("setupSuccess")}</h1>
                    <p className="text-slate-400">Redirecting to your dashboard...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="flex min-h-screen items-center justify-center bg-[#01160e] p-6 py-12 relative" dir={language === "ar" ? "rtl" : "ltr"}>
            {/* Floating Language Switcher */}
            <button
                onClick={toggleLanguage}
                className={`absolute top-8 ${language === "ar" ? "left-8" : "right-8"} flex items-center gap-2 rounded-xl border border-emerald-500/20 bg-[#011f18]/80 px-4 py-2 text-xs font-bold text-emerald-400 hover:bg-emerald-500/10 transition-all backdrop-blur-sm z-50`}
            >
                <Languages className="h-4 w-4" />
                {language === "ar" ? "English" : "العربية"}
            </button>

            <div className="w-full max-w-2xl space-y-8">
                <div className="text-center">
                    <div className="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-emerald-500/10 border border-emerald-500/20 mb-6">
                        <Store className="h-8 w-8 text-emerald-500" />
                    </div>
                    <h1 className="text-3xl font-black text-white tracking-tight">{t("storeSetupTitle")}</h1>
                    <p className="mt-2 text-sm text-slate-400">{t("storeSetupSubtitle")}</p>
                </div>

                <div className="glass rounded-3xl p-8 shadow-2xl border-emerald-900/20">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {error && (
                            <div className="rounded-xl bg-red-500/10 border border-red-500/20 p-4 text-xs text-red-400 text-center">
                                {error}
                            </div>
                        )}

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Store Name EN */}
                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("storeNameEn")}</label>
                                <div className="relative">
                                    <Store className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                    <input
                                        name="name"
                                        required
                                        value={formData.name}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                        placeholder="Zara Official"
                                    />
                                </div>
                            </div>

                            {/* Store Name AR */}
                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("storeNameAr")}</label>
                                <div className="relative">
                                    <Store className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                    <input
                                        name="nameAr"
                                        required
                                        value={formData.nameAr}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                        placeholder="زارا"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Description EN */}
                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("descriptionEn")}</label>
                            <div className="relative">
                                <FileText className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-3 h-4 w-4 text-slate-600`} />
                                <textarea
                                    name="description"
                                    rows={2}
                                    value={formData.description}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="International fashion brand..."
                                />
                            </div>
                        </div>

                        {/* Description AR */}
                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("descriptionAr")}</label>
                            <div className="relative">
                                <FileText className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-3 h-4 w-4 text-slate-600`} />
                                <textarea
                                    name="descriptionAr"
                                    rows={2}
                                    value={formData.descriptionAr}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="علامة أزياء عالمية..."
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Logo Upload */}
                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("logo")}</label>
                                <div className="relative group">
                                    {formData.logoUrl ? (
                                        <div className="relative h-32 w-full rounded-2xl border-2 border-emerald-500/20 bg-emerald-500/5 flex items-center justify-center overflow-hidden">
                                            <img src={formData.logoUrl} alt="Preview" className="h-full w-full object-contain p-2" />
                                            <button
                                                type="button"
                                                onClick={removeLogo}
                                                className="absolute top-2 right-2 h-8 w-8 rounded-full bg-red-500/20 text-red-500 flex items-center justify-center hover:bg-red-500 transition-all opacity-0 group-hover:opacity-100"
                                            >
                                                <X className="h-4 w-4" />
                                            </button>
                                        </div>
                                    ) : (
                                        <label className="flex h-32 w-full cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed border-emerald-900/30 bg-[#011f18] transition-all hover:border-emerald-500/50 hover:bg-emerald-500/5">
                                            <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                                <Upload className="mb-3 h-8 w-8 text-emerald-500" />
                                                <p className="mb-2 text-sm text-slate-300 font-bold">{t("clickToUpload")}</p>
                                                <p className="text-xs text-slate-500">PNG, JPG (MAX. 5MB)</p>
                                            </div>
                                            <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} />
                                        </label>
                                    )}
                                </div>
                            </div>

                            {/* Website URL */}
                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("websiteUrl")}</label>
                                <div className="relative">
                                    <Globe className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                    <input
                                        name="websiteUrl"
                                        value={formData.websiteUrl}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                        placeholder="https://www.zara.com"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Category */}
                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("category")}</label>
                            <div className="relative">
                                <Tags className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-emerald-500/50`} />
                                <select
                                    name="categoryId"
                                    value={formData.categoryId}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-slate-800 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 appearance-none`}
                                >
                                    <option value="">Select Category</option>
                                    {categories.map((cat: any) => (
                                        <option key={cat.id} value={cat.id}>
                                            {language === "ar" ? cat.nameAr || cat.name : cat.name}
                                        </option>
                                    ))}
                                </select>
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
                                    {t("finishSetup")}
                                    <ArrowRight className={`${language === "ar" ? "rotate-180" : ""} h-4 w-4`} />
                                </>
                            )}
                        </button>
                    </form>
                </div>

                <div className="text-center text-[10px] text-slate-600 font-medium uppercase tracking-widest">
                    BNPL Partners Portal &bull; Professional Merchant Onboarding
                </div>
            </div>
        </div>
    );
}
