"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    LayoutDashboard,
    Receipt,
    CreditCard,
    Settings,
    Store,
    LogOut,
    Package,
    TrendingUp,
    ShoppingCart
} from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";

export default function Sidebar({ onLogout }: { onLogout?: () => void }) {
    const pathname = usePathname();
    const { t, language } = useLanguage();

    const navigation = [
        { name: t("dashboard"), href: "/", icon: LayoutDashboard },
        { name: t("pos"), href: "/pos", icon: ShoppingCart },
        { name: t("products"), href: "/products", icon: Package },
        { name: t("salesOps"), href: "/sales", icon: TrendingUp },
        { name: t("transactions"), href: "/transactions", icon: Receipt },
        { name: t("finance"), href: "/finance", icon: CreditCard },
        { name: t("settings"), href: "/settings", icon: Settings },
    ];

    return (
        <div className={`flex h-full w-64 flex-col bg-[#011f18] shadow-xl ${language === "ar" ? "border-l" : "border-r"} border-emerald-900/30`}>
            <div className="flex h-20 items-center justify-center border-b border-emerald-900/30 px-6">
                <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-emerald-500 flex items-center justify-center">
                        <Store className="h-5 w-5 text-[#01160e]" />
                    </div>
                    <span className="text-xl font-bold text-white tracking-tight">{t("partnersPortal")}</span>
                </div>
            </div>

            <nav className="flex-1 space-y-1 px-4 py-6">
                {navigation.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={`group flex items-center rounded-xl px-4 py-3 text-sm font-medium transition-all duration-200 ${isActive
                                ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"
                                : "text-slate-400 hover:bg-slate-800/50 hover:text-slate-200"
                                }`}
                        >
                            <item.icon
                                className={`${language === "ar" ? "ml-3" : "mr-3"} h-5 w-5 flex-shrink-0 transition-colors ${isActive ? "text-emerald-400" : "text-slate-500 group-hover:text-slate-300"
                                    }`}
                            />
                            {item.name}
                        </Link>
                    );
                })}
            </nav>

            <div className="border-t border-emerald-900/30 p-4">
                <button
                    onClick={onLogout}
                    className="flex w-full items-center rounded-xl px-4 py-3 text-sm font-medium text-slate-400 transition-all hover:bg-red-500/10 hover:text-red-400"
                >
                    <LogOut className={`${language === "ar" ? "ml-3" : "mr-3"} h-5 w-5`} />
                    {t("logout")}
                </button>
            </div>
        </div>
    );
}
