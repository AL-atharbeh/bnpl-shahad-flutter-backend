"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Sidebar from "./Sidebar";
import { useLanguage } from "@/contexts/LanguageContext";
import { Languages } from "lucide-react";

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const [vendor, setVendor] = useState<any>(null);
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

    const handleLogout = () => {
        localStorage.removeItem("vendor_token");
        localStorage.removeItem("vendor_user");
        router.push("/auth/login");
    };

    const toggleLanguage = () => {
        setLanguage(language === "ar" ? "en" : "ar");
    };

    if (!vendor) return null;

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
