"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { href: "/dashboard", label: "الرئيسية" },
  { href: "/dashboard/users", label: "المستخدمون" },
  { href: "/dashboard/stores", label: "المتاجر" },
  { href: "/dashboard/categories", label: "التصنيفات" },
  { href: "/dashboard/offers", label: "العروض" },
  { href: "/dashboard/banners", label: "البانرات" },
  { href: "/dashboard/settings/splash", label: "شاشة الافتتاح" },
  { href: "/dashboard/transactions", label: "المعاملات" },
  { href: "/dashboard/payments", label: "الدفعات" },
  { href: "/dashboard/profits", label: "الأرباح النهائية" },
  { href: "/dashboard/rewards", label: "النقاط والمكافآت 🏆" },
  { href: "/dashboard/notifications", label: "الإشعارات" },
  { href: "/dashboard/reports", label: "التقارير" },
  { href: "/dashboard/settings", label: "الإعدادات العامة" },
  { href: "/dashboard/extension-options", label: "خيارات التمديد" },
  { href: "/dashboard/reviews", label: "التقييمات والتعليقات" },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="flex h-screen w-64 flex-col border-r border-slate-800 bg-[#021f2a] px-4 py-4">
      <div className="flex items-center gap-2 px-2 pb-6">
        <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-500 text-slate-950 font-semibold shadow-sm shadow-emerald-700/40">
          BN
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-50">لوحة تحكم BNPL</p>
          <p className="text-[11px] text-slate-400">لوحة إدارة العمليات</p>
        </div>
      </div>

      <nav className="flex-1 space-y-1">
        {navItems.map((item) => {
          const isActive =
            pathname === item.href || pathname.startsWith(item.href + "/");

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center justify-between rounded-lg px-3 py-2 text-sm transition-colors ${isActive
                ? "bg-emerald-500/20 text-emerald-100 border border-emerald-500/60"
                : "text-slate-300 hover:bg-slate-900/60 hover:text-slate-50"
                }`}
            >
              <span>{item.label}</span>
              {isActive && (
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
              )}
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto space-y-2 border-t border-slate-800 pt-4 text-xs text-slate-400">
        <p className="flex items-center justify-between">
          <span>البيئة</span>
          <span className="rounded-full bg-emerald-500/15 px-2 py-0.5 text-[10px] text-emerald-200 border border-emerald-500/40">
            Sandbox التجريبية
          </span>
        </p>
        <button className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-left text-[11px] text-slate-200 hover:bg-slate-900">
          تسجيل الخروج
        </button>
      </div>
    </aside>
  );
}


