"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Sidebar from "./Sidebar";
import NotificationBell from "./NotificationBell";
import { useLanguage } from "@/contexts/LanguageContext";
import { Languages, Clock, XCircle, RefreshCw, LogOut, Store } from "lucide-react";
import { getVendorAccount } from "@/services/api";

type Review = "checking" | "live" | "pending" | "rejected" | "suspended";

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const [vendor, setVendor] = useState<any>(null);
    const [review, setReview] = useState<Review>("checking");
    const [application, setApplication] = useState<{ submittedAt?: string; missing?: string[]; reviewNote?: string }>({});
    const [refreshing, setRefreshing] = useState(false);
    const router = useRouter();
    const { language, setLanguage, t } = useLanguage();

    useEffect(() => {
        const token = localStorage.getItem("vendor_token");
        const userStr = localStorage.getItem("vendor_user");

        if (!token || !userStr) {
            router.push("/auth/login");
            return;
        }

        try {
            const user = JSON.parse(userStr);
            setVendor(user);
        } catch (e) {
            router.push("/auth/login");
        }
    }, [router]);

    // A new store waits for an admin before it can sell. Ask the server rather
    // than trusting what was saved at sign-in, so approval shows up on its own.
    const checkReview = useCallback(async () => {
        try {
            const res = await getVendorAccount();
            const store = res.data?.data?.store;
            setApplication(res.data?.data?.application || {});
            if (store?.status === "approved" && store?.isActive) setReview("live");
            else if (store?.status === "rejected") setReview("rejected");
            else if (store?.status === "suspended") setReview("suspended");
            else setReview("pending");
        } catch {
            // The server still refuses an unapproved store's sales, so a failed
            // check should not lock an approved merchant out of the dashboard.
            setReview("live");
        }
    }, []);

    useEffect(() => {
        if (!vendor) return;
        checkReview();
    }, [vendor, checkReview]);

    useEffect(() => {
        if (review !== "pending" && review !== "suspended") return;
        const timer = setInterval(checkReview, 30000);
        return () => clearInterval(timer);
    }, [review, checkReview]);

    const handleLogout = () => {
        localStorage.removeItem("vendor_token");
        localStorage.removeItem("vendor_user");
        router.push("/auth/login");
    };

    const toggleLanguage = () => {
        setLanguage(language === "ar" ? "en" : "ar");
    };

    const refresh = async () => {
        setRefreshing(true);
        await checkReview();
        setRefreshing(false);
    };

    if (!vendor || review === "checking") return null;

    if (review !== "live") {
        const ar = language === "ar";
        const pending = review === "pending";
        const suspended = review === "suspended";
        const submitted = Boolean(application.submittedAt);
        return (
            <div className="flex min-h-screen items-center justify-center bg-[#01160e] p-6 relative" dir={ar ? "rtl" : "ltr"}>
                <button
                    onClick={toggleLanguage}
                    className={`absolute top-8 ${ar ? "left-8" : "right-8"} flex items-center gap-2 rounded-xl border border-emerald-500/20 bg-[#011f18]/80 px-4 py-2 text-xs font-bold text-emerald-400 hover:bg-emerald-500/10 transition-all`}
                >
                    <Languages className="h-4 w-4" />
                    {ar ? "English" : "العربية"}
                </button>

                <div className="w-full max-w-lg glass rounded-3xl p-10 text-center space-y-6">
                    <div className="flex justify-center">
                        <div className={`h-20 w-20 rounded-full flex items-center justify-center ${pending ? "bg-amber-500/10 border border-amber-500/30" : "bg-red-500/10 border border-red-500/30"}`}>
                            {pending ? <Clock className="h-10 w-10 text-amber-400" /> : <XCircle className="h-10 w-10 text-red-400" />}
                        </div>
                    </div>

                    <div className="space-y-2">
                        <h1 className="text-2xl font-black text-white">
                            {suspended
                                ? (ar ? "تم إيقاف متجرك" : "Your store is suspended")
                                : !pending
                                ? (ar ? "لم تتم الموافقة على متجرك" : "Your store was not approved")
                                : submitted
                                    ? (ar ? "طلبك قيد المراجعة" : "Your application is under review")
                                    : (ar ? "أكمل طلب الانضمام" : "Complete your application")}
                        </h1>
                        <p className="text-sm leading-7 text-slate-400">
                            {suspended
                                ? (ar
                                    ? "أوقفت إدارة شهد متجرك مؤقتاً، فلا يمكنه البيع الآن. تواصل مع إدارة شهد لإعادة تفعيله. تُحدَّث هذه الصفحة تلقائياً."
                                    : "Shahed has suspended your store, so it cannot sell for now. Contact Shahed to restore it. This page updates on its own.")
                                : !pending
                                ? (ar
                                    ? "راجعت الإدارة طلبك ولم توافق عليه بعد. صحّح ما يلزم وأعد إرسال الطلب."
                                    : "Shahed reviewed your application and did not approve it yet. Fix what is needed and submit again.")
                                : submitted
                                    ? (ar
                                        ? "استلمنا طلبك ومستنداتك. ستراجعه إدارة شهد، وتُفتح لك لوحة التحكم ونقطة البيع فور الموافقة. تُحدَّث هذه الصفحة تلقائياً."
                                        : "We have your application and documents. Shahed will review them and open your dashboard and point of sale once approved. This page updates on its own.")
                                    : (ar
                                        ? "قبل أن تبدأ البيع، أرسل بيانات منشأتك وحسابك البنكي والمستندات لتراجعها إدارة شهد."
                                        : "Before you can sell, send your business details, bank account and documents for Shahed to review.")}
                        </p>
                    </div>

                    {!pending && application.reviewNote && (
                        <div className="rounded-2xl border border-red-500/30 bg-red-500/10 p-4 text-start text-sm text-red-300">
                            <div className="font-black mb-1">{ar ? (suspended ? "سبب الإيقاف" : "سبب الرفض") : "Reason"}</div>
                            {application.reviewNote}
                        </div>
                    )}

                    <div className="rounded-2xl border border-slate-800 bg-slate-900/40 p-4 text-start text-sm text-slate-300 flex items-center gap-3">
                        <Store className="h-5 w-5 text-emerald-400 flex-shrink-0" />
                        <span>{vendor.name}</span>
                    </div>

                    {!suspended && (!submitted || !pending) && (
                        <Link
                            href="/application"
                            className="btn-financial block w-full rounded-xl py-3 text-sm font-bold"
                        >
                            {!pending
                                ? (ar ? "تعديل الطلب وإعادة الإرسال" : "Fix and resubmit")
                                : (ar ? "إكمال طلب الانضمام" : "Complete application")}
                            {pending && (application.missing?.length || 0) > 0 && (
                                <span className="opacity-70"> · {ar ? `${application.missing!.length} متبقٍ` : `${application.missing!.length} left`}</span>
                            )}
                        </Link>
                    )}
                    {submitted && pending && (
                        <Link href="/application" className="block text-xs text-slate-500 hover:text-slate-300">
                            {ar ? "عرض طلبك" : "View your application"}
                        </Link>
                    )}

                    <div className="flex gap-3">
                        <button
                            onClick={refresh}
                            disabled={refreshing}
                            className="btn-financial flex-1 rounded-xl py-3 text-sm font-bold flex items-center justify-center gap-2 disabled:opacity-50"
                        >
                            <RefreshCw className={`h-4 w-4 ${refreshing ? "animate-spin" : ""}`} />
                            {ar ? "تحديث الحالة" : "Check again"}
                        </button>
                        <button
                            onClick={handleLogout}
                            className="flex-1 rounded-xl border border-slate-800 py-3 text-sm font-bold text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-all flex items-center justify-center gap-2"
                        >
                            <LogOut className="h-4 w-4" />
                            {t("logout")}
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="flex min-h-screen bg-[#01160e] text-slate-50 overflow-hidden" dir={language === "ar" ? "rtl" : "ltr"}>
            {/* Sidebar */}
            <Sidebar onLogout={handleLogout} />

            {/* Main Content */}
            <main className="flex-1 overflow-y-auto bg-gradient-to-tr from-[#01160e] via-[#011a14] to-[#042d1f]">
                <header className="sticky top-0 z-10 flex h-16 items-center justify-between border-b border-emerald-900/30 bg-[#011f18]/80 px-8 backdrop-blur-md">
                    <div className="flex items-center gap-4">
                        <h2 className="text-sm font-medium text-slate-400">
                            {t("partnersPortal")} | {vendor.name}
                        </h2>
                    </div>
                    <div className="flex items-center gap-6">
                        <NotificationBell />
                        <button
                            onClick={toggleLanguage}
                            className="flex items-center gap-2 rounded-lg border border-emerald-500/30 bg-emerald-500/10 px-3 py-1.5 text-xs font-bold text-emerald-400 hover:bg-emerald-500/20 transition-all"
                        >
                            <Languages className="h-4 w-4" />
                            {language === "ar" ? "English" : "العربية"}
                        </button>

                        <div className="flex items-center gap-2">
                            <span className="text-xs text-slate-400 italic">{t("activeNow")}</span>
                            <div className="h-8 w-8 rounded-full bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center text-[10px] font-bold text-emerald-400">
                                {vendor.name.substring(0, 2).toUpperCase()}
                            </div>
                        </div>
                    </div>
                </header>

                <div className="p-8">
                    {children}
                </div>
            </main>
        </div>
    );
}
