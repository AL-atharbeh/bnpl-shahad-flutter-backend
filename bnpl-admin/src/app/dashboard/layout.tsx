import type { ReactNode } from "react";
import { Sidebar } from "./sidebar";

type DashboardLayoutProps = {
  children: ReactNode;
};

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  return (
    <div className="flex min-h-screen bg-[#021820] text-slate-50">
      <Sidebar />

      <div className="flex flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-3">
          <div>
            <h1 className="text-sm font-semibold text-slate-50">لوحة التحكم</h1>
            <p className="text-xs text-slate-400">
              نظرة عامة سريعة على محفظة BNPL الخاصة بك.
            </p>
          </div>
          <div className="flex items-center gap-3 text-xs text-slate-300">
            <button
              type="button"
              className="relative flex h-9 w-9 items-center justify-center rounded-full border border-slate-700 bg-slate-900/40 text-slate-200 hover:bg-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/60"
              aria-label="الإشعارات"
            >
              <span className="text-base leading-none">🔔</span>
              <span className="absolute -top-1 -right-0.5 flex h-3.5 min-w-[14px] items-center justify-center rounded-full bg-emerald-500 px-[5px] text-[10px] font-semibold text-emerald-950 border border-emerald-300">
                3
              </span>
            </button>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto bg-gradient-to-b from-[#021820] via-[#031f2b] to-[#021820] px-6 py-4">
          {children}
        </main>
      </div>
    </div>
  );
}


