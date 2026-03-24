"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
    Store,
    MapPin,
    Phone,
    Mail,
    Save,
    Clock,
    Upload,
    X,
    Loader2,
    Package
} from "lucide-react";
import { getStoreSettings, updateStoreSettings } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

export default function SettingsPage() {
    const [store, setStore] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const { t, language } = useLanguage();

    const [updating, setUpdating] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState(false);

    useEffect(() => {
        loadStore();
    }, []);

    async function loadStore() {
        const userStr = localStorage.getItem("vendor_user");
        if (!userStr) return;

        try {
            const user = JSON.parse(userStr);
            const res = await getStoreSettings(user.storeId);
            setStore(res.data.data);
        } catch (error) {
            console.error("Failed to load store settings", error);
        } finally {
            setLoading(false);
        }
    }

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        setStore({ ...store, [e.target.name]: e.target.value });
    };

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (file.size > 5 * 1024 * 1024) {
            setError(language === "ar" ? "حجم الصورة يجب أن يكون أقل من 5 ميجابايت" : "Image size must be less than 5MB");
            return;
        }

        const reader = new FileReader();
        reader.onloadend = () => {
            setStore((prev: any) => ({ ...prev, logoUrl: reader.result as string }));
        };
        reader.readAsDataURL(file);
    };

    const handleSave = async () => {
        setUpdating(true);
        setError("");
        setSuccess(false);

        try {
            const userStr = localStorage.getItem("vendor_user");
            if (!userStr) return;
            const user = JSON.parse(userStr);

            await updateStoreSettings(user.storeId, {
                name: store.name,
                nameAr: store.nameAr,
                description: store.description,
                descriptionAr: store.descriptionAr,
                logoUrl: store.logoUrl,
                websiteUrl: store.websiteUrl,
                storeUrl: store.storeUrl,
                categoryId: store.categoryId,
            });
            setSuccess(true);
            setTimeout(() => setSuccess(false), 3000);
        } catch (err: any) {
            setError(err.response?.data?.message || "Failed to update settings");
        } finally {
            setUpdating(false);
        }
    };

    return (
        <DashboardLayout>
            <div className="max-w-4xl space-y-8">
                <div>
                    <h1 className="text-2xl font-bold text-white tracking-tight">{t("storeSettings")}</h1>
                    <p className="text-sm text-slate-400">{t("manageProfile")}</p>
                </div>

                <div className="grid gap-8 lg:grid-cols-3">
                    <div className="lg:col-span-1 space-y-6">
                        <div className="glass rounded-2xl p-8 flex flex-col items-center text-center border-emerald-900/20">
                            <div className="relative group">
                                <div className="h-24 w-24 rounded-2xl bg-emerald-500/10 border-2 border-dashed border-emerald-500/30 flex items-center justify-center overflow-hidden">
                                    {store?.logoUrl ? (
                                        <img src={store.logoUrl} alt="Store Logo" className="h-full w-full object-cover" />
                                    ) : (
                                        <Store className="h-10 w-10 text-emerald-500/30" />
                                    )}
                                </div>
                                <label className="absolute -bottom-2 -right-2 h-8 w-8 rounded-lg bg-emerald-500 flex items-center justify-center shadow-lg hover:bg-emerald-400 transition-colors cursor-pointer">
                                    <Upload className="h-4 w-4 text-[#01160e]" />
                                    <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} />
                                </label>
                                {store?.logoUrl && (
                                    <button
                                        onClick={() => setStore({ ...store, logoUrl: "" })}
                                        className="absolute -top-2 -right-2 h-6 w-6 rounded-full bg-red-500 text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity shadow-lg"
                                    >
                                        <X className="h-3 w-3" />
                                    </button>
                                )}
                            </div>
                            <h3 className="mt-4 text-lg font-bold text-white tracking-tight">{store?.nameAr || store?.name || t("loading")}</h3>
                            <p className="text-[11px] text-slate-500 mt-1 uppercase tracking-wider font-bold">{t("accountActive")}</p>
                        </div>

                        <div className="glass rounded-2xl p-6 space-y-4 border-emerald-900/20">
                            <h4 className="text-xs font-bold text-emerald-500/60 uppercase tracking-widest border-b border-emerald-900/30 pb-2">{t("quickInfo")}</h4>
                            <div className="flex items-center gap-3 text-sm text-slate-300">
                                <Clock className="h-4 w-4 text-emerald-500" />
                                <span>{t("workingHoursDetail")}</span>
                            </div>
                            <div className="flex items-center gap-3 text-sm text-slate-300">
                                <Package className="h-4 w-4 text-blue-400" />
                                <span>{t("productsCount")}: <span className="font-bold text-white">{store?.productsCount || 0}</span></span>
                            </div>
                            <div className="flex items-center gap-3 text-sm text-slate-300">
                                <Store className="h-4 w-4 text-emerald-400" />
                                <span>{t("verifiedPartnerStatus")}</span>
                            </div>
                        </div>
                    </div>

                    <div className="lg:col-span-2 space-y-6">
                        <div className="glass rounded-2xl p-8 space-y-6 border-emerald-900/20 shadow-2xl shadow-emerald-900/10">
                            <h3 className="text-lg font-bold text-white border-b border-emerald-900/30 pb-4 tracking-tight">{t("basicInfo")}</h3>

                            <div className="grid gap-6 md:grid-cols-2">
                                <div className="space-y-2">
                                    <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("storeNameEn")}</label>
                                    <div className="relative">
                                        <Store className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                        <input
                                            type="text"
                                            name="name"
                                            value={store?.name || ""}
                                            onChange={handleChange}
                                            className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                        />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("storeNameAr")}</label>
                                    <div className="relative">
                                        <Store className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                        <input
                                            type="text"
                                            name="nameAr"
                                            value={store?.nameAr || ""}
                                            onChange={handleChange}
                                            className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                        />
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("descriptionEn")}</label>
                                <textarea
                                    name="description"
                                    rows={2}
                                    value={store?.description || ""}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 px-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                />
                            </div>

                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("descriptionAr")}</label>
                                <textarea
                                    name="descriptionAr"
                                    rows={2}
                                    value={store?.descriptionAr || ""}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 px-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                />
                            </div>

                            <div className="grid gap-6 md:grid-cols-2">
                                <div className="space-y-2">
                                    <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("websiteUrl")}</label>
                                    <div className="relative">
                                        <Mail className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                        <input
                                            type="text"
                                            name="websiteUrl"
                                            value={store?.websiteUrl || ""}
                                            onChange={handleChange}
                                            className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                            placeholder="https://example.com"
                                        />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("storeUrl")}</label>
                                    <div className="relative">
                                        <Store className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                        <input
                                            type="text"
                                            name="storeUrl"
                                            value={store?.storeUrl || ""}
                                            onChange={handleChange}
                                            className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                            placeholder="store-slug"
                                        />
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("mainAddress")}</label>
                                <div className="relative">
                                    <MapPin className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-3 h-4 w-4 text-slate-600`} />
                                    <textarea
                                        rows={3}
                                        name="address"
                                        value={store?.address || "عمان، الأردن"}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                    />
                                </div>
                            </div>

                            <div className="pt-4 flex flex-col gap-4">
                                {error && <p className="text-xs text-red-500 text-center">{error}</p>}
                                {success && <p className="text-xs text-emerald-500 text-center">{t("setupSuccess")}</p>}
                                <div className="flex justify-end">
                                    <button
                                        onClick={handleSave}
                                        disabled={updating}
                                        className="btn-financial flex items-center gap-2 rounded-xl px-10 py-3 text-sm font-bold shadow-xl disabled:opacity-50"
                                    >
                                        {updating ? <Loader2 className="h-4 w-4 animate-spin" /> : (
                                            <>
                                                {t("saveChanges")}
                                                <Save className="h-4 w-4" />
                                            </>
                                        )}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
}
