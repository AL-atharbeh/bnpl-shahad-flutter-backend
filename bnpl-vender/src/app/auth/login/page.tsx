"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { vendorLogin } from "@/services/api";
import { Store, Mail, Lock, Loader2, ArrowRight, Languages } from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";

export default function LoginPage() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const router = useRouter();
    const { t, language, setLanguage } = useLanguage();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            const res = await vendorLogin({ email, password });
            if (res.data.success) {
                localStorage.setItem("vendor_token", res.data.data.token);
                localStorage.setItem("vendor_user", JSON.stringify(res.data.data.user));
                router.push("/");
            }
        } catch (err: any) {
            setError(err.response?.data?.message || t("loginError"));
        } finally {
            setLoading(false);
        }
    };

    const toggleLanguage = () => {
        setLanguage(language === "ar" ? "en" : "ar");
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-[#01160e] p-6 relative" dir={language === "ar" ? "rtl" : "ltr"}>
            {/* Floating Language Switcher */}
            <button
                onClick={toggleLanguage}
                className={`absolute top-8 ${language === "ar" ? "left-8" : "right-8"} flex items-center gap-2 rounded-xl border border-emerald-500/20 bg-[#011f18]/80 px-4 py-2 text-xs font-bold text-emerald-400 hover:bg-emerald-500/10 transition-all backdrop-blur-sm z-50`}
            >
                <Languages className="h-4 w-4" />
                {language === "ar" ? "English" : "العربية"}
            </button>
            <div className="w-full max-w-md space-y-8">
                <div className="text-center">
                    <div className="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-emerald-500/10 border border-emerald-500/20 mb-6">
                        <Store className="h-8 w-8 text-emerald-500" />
                    </div>
                    <h1 className="text-3xl font-black text-white tracking-tight">{t("loginTitle")}</h1>
                    <p className="mt-2 text-sm text-slate-400">{t("loginWelcome")}</p>
                </div>

                <div className="glass rounded-3xl p-8 shadow-2xl">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {error && (
                            <div className="rounded-xl bg-red-500/10 border border-red-500/20 p-4 text-xs text-red-400 text-center">
                                {error}
                            </div>
                        )}

                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("email")}</label>
                            <div className="relative">
                                <Mail className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                <input
                                    type="email"
                                    required
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="example@store.com"
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className={`text-xs font-bold text-slate-500 ${language === "ar" ? "pr-1" : "pl-1"}`}>{t("password")}</label>
                            <div className="relative">
                                <Lock className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                <input
                                    type="password"
                                    required
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className={`w-full rounded-xl border border-slate-800 bg-slate-900/50 py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                    placeholder="••••••••"
                                />
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="btn-financial w-full rounded-xl py-4 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-bold"
                        >
                            {loading ? (
                                <Loader2 className="h-5 w-5 animate-spin" />
                            ) : (
                                <>
                                    {t("loginButton")}
                                    <ArrowRight className={`${language === "ar" ? "rotate-180" : ""} h-4 w-4`} />
                                </>
                            )}
                        </button>
                    </form>

                    <p className="mt-8 text-center text-sm text-slate-500">
                        {t("noAccount")}{" "}
                        <Link href="/auth/signup" className="text-emerald-500 font-bold hover:text-emerald-400">
                            {t("signupLinkText")}
                        </Link>
                    </p>
                </div>

                <div className="text-center text-[10px] text-slate-600 font-medium">
                    {t("techTeamCredit")} &copy; 2026
                </div>
            </div>
        </div>
    );
}
