"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { vendorRegister } from "@/services/api";
import { Store, Mail, Lock, Loader2, ArrowRight, User, Phone, Briefcase, Languages } from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";

export default function SignupPage() {
    const [formData, setFormData] = useState({
        name: "",
        storeName: "",
        email: "",
        phone: "",
        password: "",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const router = useRouter();
    const { t, language, setLanguage } = useLanguage();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            const res = await vendorRegister(formData);
            if (res.data.success) {
                localStorage.setItem("vendor_token", res.data.data.token);
                localStorage.setItem("vendor_user", JSON.stringify(res.data.data.user));
                router.push("/auth/store-setup");
            }
        } catch (err: any) {
            console.error("Registration error:", err.response?.data || err.message);
            const msg = err.response?.data?.message;
            if (Array.isArray(msg)) {
                setError(msg.join(", "));
            } else if (typeof msg === "string") {
                setError(msg);
            } else {
                setError(err.response?.data?.error || t("loginError"));
            }
        } finally {
            setLoading(false);
        }
    };

    const toggleLanguage = () => {
        setLanguage(language === "ar" ? "en" : "ar");
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

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
            <div className="w-full max-w-lg space-y-8">
                <div className="text-center">
                    <div className="inline-flex h-24 w-24 items-center justify-center rounded-3xl bg-emerald-500/10 border border-emerald-500/20 mb-6 overflow-hidden">
                        <img src="/images/shahd-character.png" alt="Shahd Character" className="h-full w-full object-cover p-1" />
                    </div>
                    <h1 className="text-3xl font-black text-white tracking-tight">{t("joinAsPartner")}</h1>
                    <p className="mt-2 text-sm text-slate-400">{t("signupSubtitle")}</p>
                </div>

                <div className="glass rounded-3xl p-8 shadow-2xl">
                    <form onSubmit={handleSubmit} className="space-y-5">
                        {error && (
                            <div className="rounded-xl bg-red-500/10 border border-red-500/20 p-4 text-xs text-red-400 text-center">
                                {error}
                            </div>
                        )}

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("fullName")}</label>
                                <div className="relative">
                                    <User className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                    <input
                                        name="name"
                                        required
                                        value={formData.name}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                        placeholder={language === "ar" ? "احمد علي" : "John Doe"}
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("storeName")}</label>
                                <div className="relative">
                                    <Briefcase className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                    <input
                                        name="storeName"
                                        required
                                        value={formData.storeName}
                                        onChange={handleChange}
                                        className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                        placeholder={language === "ar" ? "زارا - عمان" : "Zara - Amman"}
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("phoneNumber")}</label>
                            <div className="relative">
                                <Phone className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                <input
                                    name="phone"
                                    required
                                    value={formData.phone}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="+962 7XXXXXXXX"
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("email")}</label>
                            <div className="relative">
                                <Mail className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                <input
                                    name="email"
                                    type="email"
                                    required
                                    value={formData.email}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="vendor@example.com"
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("password")}</label>
                            <div className="relative">
                                <Lock className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                <input
                                    name="password"
                                    type="password"
                                    required
                                    value={formData.password}
                                    onChange={handleChange}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="••••••••"
                                />
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="btn-financial mt-4 w-full rounded-xl py-4 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-bold"
                        >
                            {loading ? (
                                <Loader2 className="h-5 w-5 animate-spin" />
                            ) : (
                                <>
                                    {t("createAccountAndStart")}
                                    <ArrowRight className={`${language === "ar" ? "rotate-180" : ""} h-4 w-4`} />
                                </>
                            )}
                        </button>
                    </form>

                    <p className="mt-8 text-center text-sm text-slate-500">
                        {t("haveAccount")}{" "}
                        <Link href="/auth/login" className="text-emerald-500 font-bold hover:text-emerald-400">
                            {t("loginLinkText")}
                        </Link>
                    </p>
                </div>

                <div className="text-center text-[10px] text-slate-600 font-medium pb-8 uppercase tracking-widest">
                    {t("techTeamCredit")} &bull; Secure Financial Environment
                </div>
            </div>
        </div>
    );
}
