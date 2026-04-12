"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
  CreditCard,
  TrendingUp,
  History,
  Info,
  ChevronDown,
  Filter
} from "lucide-react";
import { getVendorTransactions, getCurrentCommissionSettings, getStoreSettings } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

// ─── Helper: safe number ────────────────────────────────────────────
const n = (v: any): number => {
  const x = Number(v);
  return isNaN(x) ? 0 : x;
};

const fmt = (v: number, lang: string) =>
  v.toLocaleString(lang === "ar" ? "ar-JO" : "en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

export default function FinancePage() {
  const [mounted, setMounted] = useState(false);
  const [loading, setLoading] = useState(true);
  const [orders, setOrders] = useState<any[]>([]);
  const [globalBankRate, setGlobalBankRate] = useState(3);
  const [globalPlatformRate, setGlobalPlatformRate] = useState(2);
  const [vendorRates, setVendorRates] = useState<{ bank: number; platform: number } | null>(null);
  const { t, language } = useLanguage();

  useEffect(() => {
    setMounted(true);
    loadVendorFinance();
  }, []);

  async function loadVendorFinance() {
    const userStr = typeof window !== "undefined" ? localStorage.getItem("vendor_user") : null;
    if (!userStr) return;

    try {
      setLoading(true);
      const user = JSON.parse(userStr);
      const storeId = user.storeId;

      // 1) Fetch Settings
      const [settingsRes, storeRes] = await Promise.all([
        getCurrentCommissionSettings().catch(() => null),
        getStoreSettings(storeId).catch(() => null)
      ]);

      const bRate = n(settingsRes?.data?.data?.bankCommission || 0.03) * 100;
      const pRate = n(settingsRes?.data?.data?.platformCommission || 0.02) * 100;
      setGlobalBankRate(bRate);
      setGlobalPlatformRate(pRate);

      if (storeRes?.data) {
        setVendorRates({
          bank: n(storeRes.data.bankCommissionRate) || bRate,
          platform: n(storeRes.data.platformCommissionRate) || pRate
        });
      }

      // 2) Fetch All Vendor Payments
      const paymentsRes = await getVendorTransactions({ page: 1, limit: 1000 }, storeId).catch(() => null);
      const list: any[] = paymentsRes?.data?.data || [];

      // Group payments by orderId (just like Admin side for Final Profits)
      const ordersMap = new Map<string, any>();

      if (Array.isArray(list)) {
        list.forEach((p: any) => {
          if (!p || !p.orderId) return;

          if (!ordersMap.has(p.orderId)) {
            const amount = n(p.amount);
            const installments = n(p.installmentsCount) || 1;
            const productValue = amount * installments;

            const br = p.bankCommissionRate ? n(p.bankCommissionRate) : (vendorRates?.bank || bRate);
            const pr = p.platformCommissionRate ? n(p.platformCommissionRate) : (vendorRates?.platform || pRate);

            ordersMap.set(p.orderId, {
              orderId: p.orderId,
              customer: p.user?.name || "Customer",
              productValue,
              installmentsCount: installments,
              bankRate: br,
              platformRate: pr,
              bankShare: productValue * (br / 100),
              platformShare: productValue * (pr / 100),
              vendorNet: productValue * (1 - (br + pr) / 100),
              paidInstallments: p.status === "completed" ? 1 : 0,
              paidAmount: p.status === "completed" ? amount : 0,
              date: p.createdAt ? new Date(p.createdAt) : null,
            });
          } else {
            const existing = ordersMap.get(p.orderId)!;
            if (p.status === "completed") {
              existing.paidInstallments += 1;
              existing.paidAmount += n(p.amount);
            }
          }
        });
      }

      setOrders(Array.from(ordersMap.values()).sort((a, b) => (b.date?.getTime() || 0) - (a.date?.getTime() || 0)));
    } catch (error) {
      console.error("Failed to load finance data", error);
    } finally {
      setLoading(false);
    }
  }

  if (!mounted) return null;

  // ─── Computed Totals ───────────────────────────────────────────────
  const totalSales = orders.reduce((s, o) => s + o.productValue, 0);
  const totalVendorNet = orders.reduce((s, o) => s + o.vendorNet, 0);
  const totalCollected = orders.reduce((s, o) => s + o.paidAmount, 0);
  const totalPending = totalSales - totalCollected;
  const totalBankShare = orders.reduce((s, o) => s + o.bankShare, 0);
  const totalPlatformShare = orders.reduce((s, o) => s + o.platformShare, 0);

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex flex-col items-center justify-center h-96 gap-4">
          <div className="h-10 w-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-slate-400 text-sm">{language === "ar" ? "جاري تجهيز بيانات الأرباح النهائية..." : "Preparing final profits data..."}</p>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-8" dir={language === "ar" ? "rtl" : "ltr"}>
        {/* Header */}
        <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
          <div>
            <h1 className="text-2xl font-black text-white tracking-tight">
              {language === "ar" ? "الأرباح النهائية" : "Final Profits"}
            </h1>
            <p className="text-sm text-slate-400">
              {language === "ar" ? "تقرير مالي مفصل لجميع المبيعات والعمولات" : "Detailed financial report for all sales and commissions"}
            </p>
          </div>
          <div className="flex items-center gap-2 rounded-xl bg-[#01281e] px-4 py-2 border border-emerald-900/30">
            <TrendingUp className="h-4 w-4 text-emerald-500" />
            <span className="text-xs font-bold text-emerald-100 uppercase tracking-widest">
              Live Data
            </span>
          </div>
        </div>

        {/* ─── Top Level Stats cards ──────────────────────────────── */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {/* Total Sales (Gross) */}
          <div className="relative group overflow-hidden rounded-3xl bg-[#011f18] p-6 border border-emerald-900/20">
            <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:scale-110 transition-transform">
              <TrendingUp className="h-16 w-16 text-emerald-500" />
            </div>
            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-1">
              {language === "ar" ? "إجمالي قيمة المبيعات" : "GROSS SALES"}
            </p>
            <h3 className="text-3xl font-black text-white">{fmt(totalSales, language)}</h3>
            <p className="text-[10px] text-slate-400 mt-2 font-medium">
              {orders.length} {language === "ar" ? "عملية بيع مسجلة" : "registered sales"}
            </p>
          </div>

          {/* Actual Vendor Net (What you earn) */}
          <div className="rounded-3xl bg-gradient-to-br from-emerald-600 to-emerald-800 p-6 shadow-xl shadow-emerald-500/10">
            <p className="text-[10px] font-bold text-emerald-100/60 uppercase tracking-widest mb-1">
              {language === "ar" ? "صافي أرباح المتجر" : "NET REVENUE"}
            </p>
            <h3 className="text-3xl font-black text-white">{fmt(totalVendorNet, language)}</h3>
            <div className="mt-2 flex items-center gap-2">
              <span className="rounded-full bg-white/20 px-2 py-0.5 text-[10px] font-bold text-white">
                {((totalVendorNet / (totalSales || 1)) * 100).toFixed(1)}%
              </span>
              <span className="text-[10px] text-emerald-100/60 font-medium">بعد خصم العمولات</span>
            </div>
          </div>

          {/* Collected so far */}
          <div className="rounded-3xl bg-[#011f18] p-6 border border-emerald-900/20">
            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-1">
              {language === "ar" ? "ما تم تحصيله فعلياً" : "COLLECTED AMOUNT"}
            </p>
            <h3 className="text-3xl font-black text-emerald-400">{fmt(totalCollected, language)}</h3>
            <p className="text-[10px] text-slate-400 mt-2 font-medium">
              {((totalCollected / (totalSales || 1)) * 100).toFixed(1)}% {language === "ar" ? "من القيمة الإجمالية" : "of gross"}
            </p>
          </div>

          {/* Pending installments */}
          <div className="rounded-3xl bg-[#011f18] p-6 border border-emerald-900/20">
            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-1">
              {language === "ar" ? "أقساط بانتظار التحصيل" : "PENDING INSTALLMENTS"}
            </p>
            <h3 className="text-3xl font-black text-amber-500">{fmt(totalPending, language)}</h3>
            <p className="text-[10px] text-slate-400 mt-2 font-medium">
              {language === "ar" ? "تدفقات نقدية مستقبلية" : "future cash flows"}
            </p>
          </div>
        </div>

        {/* ─── Breakdown Details ──────────────────────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Table Container */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center justify-between px-2">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <History className="h-5 w-5 text-emerald-500" />
                {language === "ar" ? "تفاصيل العمليات المالية" : "Financial Transactions Breakdown"}
              </h2>
              <button className="flex items-center gap-2 rounded-lg bg-emerald-500/10 px-3 py-1.5 text-xs font-bold text-emerald-400 border border-emerald-500/20 hover:bg-emerald-500/20 transition-all">
                <Filter className="h-3.5 w-3.5" />
                {language === "ar" ? "تصفية" : "Filter"}
              </button>
            </div>

            <div className="rounded-3xl border border-emerald-900/30 bg-[#011f18] overflow-hidden shadow-2xl">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-emerald-900/20 bg-emerald-500/5 text-slate-400">
                      <th className="px-6 py-4 text-start font-bold uppercase tracking-wider text-[10px]">{language === "ar" ? "الطلب / التاريخ" : "ORDER / DATE"}</th>
                      <th className="px-6 py-4 text-start font-bold uppercase tracking-wider text-[10px]">{language === "ar" ? "قيمة المنتج" : "GROSS"}</th>
                      <th className="px-6 py-4 text-start font-bold uppercase tracking-wider text-[10px]">{language === "ar" ? "الأقساط" : "INST."}</th>
                      <th className="px-6 py-4 text-start font-bold uppercase tracking-wider text-[10px]">{language === "ar" ? "صافي المتجر" : "NET"}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-emerald-900/10">
                    {orders.length === 0 ? (
                      <tr>
                        <td colSpan={4} className="p-12 text-center text-slate-500 italic">
                          {language === "ar" ? "لا توجد عمليات مسجلة حالياً" : "No transactions recorded yet"}
                        </td>
                      </tr>
                    ) : (
                      orders.map((o) => (
                        <tr key={o.orderId} className="group hover:bg-emerald-500/[0.03] transition-colors">
                          <td className="px-6 py-5">
                            <div className="flex flex-col">
                              <span className="font-bold text-slate-200 group-hover:text-white transition-colors">#{o.orderId.slice(-8).toUpperCase()}</span>
                              <span className="text-[10px] text-slate-500 mt-1 uppercase font-mono">{o.date?.toLocaleDateString(language === "ar" ? "ar-JO" : "en-US", { day: 'numeric', month: 'short' })}</span>
                            </div>
                          </td>
                          <td className="px-6 py-5">
                            <span className="font-bold text-slate-300">{fmt(o.productValue, language)}</span>
                          </td>
                          <td className="px-6 py-5">
                            <div className="flex items-center gap-2">
                              <div className="flex h-1.5 w-12 overflow-hidden rounded-full bg-emerald-950/50">
                                <div
                                  className="bg-emerald-500 transition-all duration-500"
                                  style={{ width: `${(o.paidInstallments / o.totalInstallments) * 100}%` }}
                                />
                              </div>
                              <span className="text-[10px] font-black text-emerald-500/80">
                                {o.paidInstallments}/{o.totalInstallments}
                              </span>
                            </div>
                          </td>
                          <td className="px-6 py-5">
                            <div className="flex flex-col items-start gap-1">
                              <span className="font-black text-emerald-400">{fmt(o.vendorNet, language)}</span>
                              <span className="text-[9px] font-bold text-slate-500 uppercase tracking-tighter">
                                {language === "ar" ? "بعد خصم" : "AFTER"} {((1 - o.vendorNet / o.productValue) * 100).toFixed(1)}%
                              </span>
                            </div>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          {/* Side Info Cards */}
          <div className="space-y-6">
            <h2 className="text-lg font-bold text-white px-2 flex items-center gap-2">
              <Info className="h-5 w-5 text-emerald-500" />
              {language === "ar" ? "آلية الخصم" : "Deduction Model"}
            </h2>
            
            <div className="rounded-3xl border border-emerald-900/30 bg-[#011f18] p-6 space-y-6 shadow-xl">
              <div className="space-y-4">
                <div className="flex items-center justify-between pb-4 border-b border-emerald-900/10">
                  <span className="text-xs text-slate-400">{language === "ar" ? "حصة البنك" : "Bank Share"}</span>
                  <span className="text-xs font-black text-sky-400">{vendorRates?.bank.toFixed(1) || globalBankRate.toFixed(1)}%</span>
                </div>
                <div className="flex items-center justify-between pb-4 border-b border-emerald-900/10">
                  <span className="text-xs text-slate-400">{language === "ar" ? "عمولة المنصة" : "Platform Fee"}</span>
                  <span className="text-xs font-black text-emerald-500">{vendorRates?.platform.toFixed(1) || globalPlatformRate.toFixed(1)}%</span>
                </div>
                <div className="flex items-center justify-between pt-2">
                  <span className="text-sm font-bold text-white">{language === "ar" ? "صافي المتجر" : "Vendor Net"}</span>
                  <span className="text-sm font-black text-emerald-400">
                    {(100 - (vendorRates?.bank || globalBankRate) - (vendorRates?.platform || globalPlatformRate)).toFixed(1)}%
                  </span>
                </div>
              </div>

              <div className="rounded-2xl bg-emerald-500/5 border border-emerald-500/10 p-4">
                <p className="text-[10px] text-slate-400 leading-relaxed font-medium">
                  {language === "ar" 
                    ? "يتم احتساب العمولات من إجمالي قيمة المنتج عند إجراء الطلب، وتُوزع الأرباح تلقائياً عند تحصيل كل قسط."
                    : "Commissions are calculated from the gross product value at checkout, and profits are distributed automatically as each installment is collected."
                  }
                </p>
              </div>

              <div className="space-y-2">
                <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">{language === "ar" ? "ملخص العمولات الإجمالية" : "TOTAL COMMISSION SUMMARY"}</p>
                <div className="flex items-end justify-between">
                   <div className="flex flex-col">
                      <span className="text-[10px] text-slate-500">{language === "ar" ? "للبنك" : "Bank"}</span>
                      <span className="text-sm font-bold text-sky-400">{fmt(totalBankShare, language)}</span>
                   </div>
                   <div className="flex flex-col items-end">
                      <span className="text-[10px] text-slate-500 text-end">{language === "ar" ? "للمنصة" : "Platform"}</span>
                      <span className="text-sm font-bold text-emerald-500">{fmt(totalPlatformShare, language)}</span>
                   </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
