"use client";

import { useEffect, useState } from "react";
import {
  getAllPayments,
  getCurrentCommissionSettings,
  getAdminStores,
} from "@/services/api";

// ─── Helper: safe number ────────────────────────────────────────────
const n = (v: any): number => {
  const x = Number(v);
  return isNaN(x) ? 0 : x;
};
const fmt = (v: number) =>
  v.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

// ─── Types ──────────────────────────────────────────────────────────
interface OrderRow {
  orderId: string;
  customer: string;
  store: string;
  storeId: number;
  productValue: number;
  installmentsCount: number;
  bankRate: number;
  platformRate: number;
  bankShare: number;
  platformShare: number;
  vendorNet: number;
  paidInstallments: number;
  totalInstallments: number;
  paidAmount: number;
  status: string;
  date: string;
}

export default function FinalProfitsPage() {
  const [mounted, setMounted] = useState(false);
  const [loading, setLoading] = useState(true);
  const [orders, setOrders] = useState<OrderRow[]>([]);
  const [bankRate, setBankRate] = useState(3);
  const [platformRate, setPlatformRate] = useState(2);
  const [stores, setStores] = useState<any[]>([]);
  const [filterStore, setFilterStore] = useState("الكل");
  const [filterStatus, setFilterStatus] = useState("الكل");

  useEffect(() => {
    setMounted(true);
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);

      // 1) Commission settings (works ✅)
      const settingsRes = await getCurrentCommissionSettings().catch(() => null);
      const bRate = n(settingsRes?.data?.data?.bankCommission || 0.03) * 100;
      const pRate = n(settingsRes?.data?.data?.platformCommission || 0.02) * 100;
      setBankRate(bRate);
      setPlatformRate(pRate);

      // 2) All payments (works ✅)
      const paymentsRes = await getAllPayments({ page: 1, limit: 500 }).catch(() => null);
      const list: any[] = paymentsRes?.data?.data || paymentsRes?.data || [];

      // 3) Stores
      const storesRes = await getAdminStores().catch(() => null);
      setStores(storesRes?.data || []);

      // Group payments by orderId
      const ordersMap = new Map<string, any>();

      if (Array.isArray(list)) {
        list.forEach((p: any) => {
          if (!p || !p.orderId) return;

          if (!ordersMap.has(p.orderId)) {
            const amount = n(p.amount);
            const installments = n(p.installmentsCount) || 1;
            const productValue = amount * installments;

            // Priority Linkage: 1. Current Store Rate -> 2. Historical Payment Rate -> 3. Global Fallback
            // This ensures that when the user updates a store's rates, it reflects on the reports immediately.
            const br = (p.store?.bankCommissionRate !== null && p.store?.bankCommissionRate !== undefined)
              ? n(p.store.bankCommissionRate)
              : (p.bankCommissionRate !== null && p.bankCommissionRate !== undefined)
                ? n(p.bankCommissionRate)
                : bRate;

            const pr = (p.store?.platformCommissionRate !== null && p.store?.platformCommissionRate !== undefined)
              ? n(p.store.platformCommissionRate)
              : (p.platformCommissionRate !== null && p.platformCommissionRate !== undefined)
                ? n(p.platformCommissionRate)
                : pRate;

            ordersMap.set(p.orderId, {
              orderId: p.orderId,
              customer: p.user?.name || "عميل",
              store: p.store?.name || "متجر",
              storeId: n(p.storeId),
              productValue,
              installmentsCount: installments,
              bankRate: br,
              platformRate: pr,
              bankShare: productValue * (br / 100),
              platformShare: productValue * (pr / 100),
              vendorNet: productValue * (1 - (br + pr) / 100),
              paidInstallments: p.status === "completed" ? 1 : 0,
              totalInstallments: installments,
              paidAmount: p.status === "completed" ? amount : 0,
              status: p.status,
              date: p.createdAt
                ? new Date(p.createdAt).toLocaleDateString("ar-JO")
                : "-",
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

      setOrders(Array.from(ordersMap.values()));
    } catch (err) {
      console.error("Error loading data:", err);
    } finally {
      setLoading(false);
    }
  }

  if (!mounted) return null;

  // ─── Computed Statistics ──────────────────────────────────────────
  const filtered = orders.filter((o) => {
    const storeMatch = filterStore === "الكل" || o.store === filterStore;
    const statusMatch =
      filterStatus === "الكل" ||
      (filterStatus === "مكتمل" && o.status === "completed") ||
      (filterStatus === "معلق" && o.status === "pending");
    return storeMatch && statusMatch;
  });

  const totalProductValue = filtered.reduce((s, o) => s + o.productValue, 0);
  const totalBankShare = filtered.reduce((s, o) => s + o.bankShare, 0);
  const totalPlatformShare = filtered.reduce((s, o) => s + o.platformShare, 0);
  const totalVendorNet = filtered.reduce((s, o) => s + o.vendorNet, 0);
  const totalPaid = filtered.reduce((s, o) => s + o.paidAmount, 0);
  const totalCommission = totalBankShare + totalPlatformShare;
  const orderCount = filtered.length;

  // Calculate effective rates for display (Dynamic based on filter)
  const effectiveBankRate = orderCount > 0 
    ? (totalBankShare / (totalProductValue || 1)) * 100 
    : bankRate;
  const effectivePlatformRate = orderCount > 0 
    ? (totalPlatformShare / (totalProductValue || 1)) * 100 
    : platformRate;

  // Per-store breakdown
  const storeMap = new Map<string, { name: string; value: number; bank: number; platform: number; vendor: number; orders: number }>();
  filtered.forEach((o) => {
    if (!storeMap.has(o.store)) {
      storeMap.set(o.store, { name: o.store, value: 0, bank: 0, platform: 0, vendor: 0, orders: 0 });
    }
    const s = storeMap.get(o.store)!;
    s.value += o.productValue;
    s.bank += o.bankShare;
    s.platform += o.platformShare;
    s.vendor += o.vendorNet;
    s.orders += 1;
  });
  const storeBreakdown = Array.from(storeMap.values()).sort((a, b) => b.value - a.value);

  // Unique store names for filter
  const storeNames = [...new Set(orders.map((o) => o.store))];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 rounded-full border-2 border-emerald-500 border-t-transparent animate-spin" />
          <p className="text-slate-400 text-sm">جاري تحميل البيانات المالية...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6" dir="rtl">
      {/* ─── Header ──────────────────────────────────────────── */}
      <div>
        <h1 className="text-xl font-bold text-slate-50">الأرباح النهائية</h1>
        <p className="mt-1 text-xs text-slate-400">
          تقرير تفصيلي شامل لجميع الأرباح والعمولات — يُحسب مباشرة من سجل الدفعات الفعلي
        </p>
      </div>

      {/* ─── Top Stats Grid ──────────────────────────────────── */}
      <div className="grid gap-4 grid-cols-2 lg:grid-cols-4 xl:grid-cols-6">
        {/* إجمالي قيمة المنتجات */}
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-lg">
          <p className="text-[10px] text-slate-400 uppercase tracking-wider mb-1">إجمالي قيمة المنتجات</p>
          <p className="text-lg font-bold text-white">{fmt(totalProductValue)}</p>
          <p className="text-[10px] text-slate-500 mt-1">{orderCount} عملية</p>
        </div>

        {/* إجمالي العمولات */}
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-lg">
          <p className="text-[10px] text-slate-400 uppercase tracking-wider mb-1">إجمالي العمولات</p>
          <p className="text-lg font-bold text-amber-400">{fmt(totalCommission)}</p>
          <p className="text-[10px] text-slate-500 mt-1">{((totalCommission / (totalProductValue || 1)) * 100).toFixed(1)}% من القيمة</p>
        </div>

        {/* حصة البنك */}
        <div className="rounded-xl border border-sky-900/40 bg-gradient-to-br from-[#021f2a] to-sky-950/30 p-4 shadow-lg">
          <p className="text-[10px] text-sky-300 uppercase tracking-wider mb-1">🏦 حصة البنك</p>
          <p className="text-lg font-bold text-sky-200">{fmt(totalBankShare)}</p>
          <p className="text-[10px] text-sky-400/60 mt-1">نسبة {effectiveBankRate.toFixed(1)}%</p>
        </div>

        {/* حصة المنصة */}
        <div className="rounded-xl border border-emerald-900/40 bg-gradient-to-br from-[#021f2a] to-emerald-950/30 p-4 shadow-lg">
          <p className="text-[10px] text-emerald-300 uppercase tracking-wider mb-1">🧾 حصة المنصة</p>
          <p className="text-lg font-bold text-emerald-200">{fmt(totalPlatformShare)}</p>
          <p className="text-[10px] text-emerald-400/60 mt-1">نسبة {effectivePlatformRate.toFixed(1)}%</p>
        </div>

        {/* صافي الفيندر */}
        <div className="rounded-xl border border-purple-900/40 bg-gradient-to-br from-[#021f2a] to-purple-950/30 p-4 shadow-lg">
          <p className="text-[10px] text-purple-300 uppercase tracking-wider mb-1">🏪 صافي المتاجر</p>
          <p className="text-lg font-bold text-purple-200">{fmt(totalVendorNet)}</p>
          <p className="text-[10px] text-purple-400/60 mt-1">{((totalVendorNet / (totalProductValue || 1)) * 100).toFixed(1)}% من القيمة</p>
        </div>

        {/* المبالغ المحصّلة */}
        <div className="rounded-xl border border-amber-600/40 bg-gradient-to-br from-amber-600 to-amber-500 p-4 shadow-lg text-amber-950">
          <p className="text-[10px] font-semibold uppercase tracking-wider mb-1">💰 المحصّل فعلياً</p>
          <p className="text-lg font-bold">{fmt(totalPaid)}</p>
          <p className="text-[10px] mt-1">{((totalPaid / (totalProductValue || 1)) * 100).toFixed(1)}% تحصيل</p>
        </div>
      </div>

      {/* ─── Breakdown by Store ──────────────────────────────── */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-5 shadow-lg">
        <h2 className="text-sm font-bold text-slate-50 mb-4 flex items-center gap-2">
          <span>📊</span> توزيع الأرباح حسب المتجر
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full text-xs">
            <thead>
              <tr className="border-b border-slate-800 text-slate-400">
                <th className="px-3 py-2.5 text-right font-medium">المتجر</th>
                <th className="px-3 py-2.5 text-right font-medium">عدد العمليات</th>
                <th className="px-3 py-2.5 text-right font-medium">قيمة المنتجات</th>
                <th className="px-3 py-2.5 text-right font-medium">حصة البنك</th>
                <th className="px-3 py-2.5 text-right font-medium">حصة المنصة</th>
                <th className="px-3 py-2.5 text-right font-medium">صافي المتجر</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {storeBreakdown.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-slate-500">لا توجد بيانات</td>
                </tr>
              ) : (
                storeBreakdown.map((s) => (
                  <tr key={s.name} className="hover:bg-slate-900/40 transition-colors">
                    <td className="px-3 py-2.5 font-semibold text-slate-100">{s.name}</td>
                    <td className="px-3 py-2.5 text-slate-300">{s.orders}</td>
                    <td className="px-3 py-2.5 text-slate-200">{fmt(s.value)} د.أ</td>
                    <td className="px-3 py-2.5 text-sky-300">{fmt(s.bank)} د.أ</td>
                    <td className="px-3 py-2.5 text-emerald-300">{fmt(s.platform)} د.أ</td>
                    <td className="px-3 py-2.5 text-purple-300 font-semibold">{fmt(s.vendor)} د.أ</td>
                  </tr>
                ))
              )}
            </tbody>
            {storeBreakdown.length > 0 && (
              <tfoot>
                <tr className="border-t-2 border-slate-700 bg-slate-900/30 font-bold text-slate-100">
                  <td className="px-3 py-2.5">الإجمالي</td>
                  <td className="px-3 py-2.5">{orderCount}</td>
                  <td className="px-3 py-2.5">{fmt(totalProductValue)} د.أ</td>
                  <td className="px-3 py-2.5 text-sky-200">{fmt(totalBankShare)} د.أ</td>
                  <td className="px-3 py-2.5 text-emerald-200">{fmt(totalPlatformShare)} د.أ</td>
                  <td className="px-3 py-2.5 text-purple-200">{fmt(totalVendorNet)} د.أ</td>
                </tr>
              </tfoot>
            )}
          </table>
        </div>
      </div>

      {/* ─── Filters + Detailed Table ────────────────────────── */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-5 shadow-lg">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between mb-4">
          <h2 className="text-sm font-bold text-slate-50 flex items-center gap-2">
            <span>📋</span> الدفعات المفصّلة
          </h2>
          <div className="flex gap-2 flex-wrap">
            <select
              value={filterStore}
              onChange={(e) => setFilterStore(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-50 focus:border-emerald-500/60 focus:outline-none"
            >
              <option value="الكل">كل المتاجر</option>
              {storeNames.map((name) => (
                <option key={name} value={name}>{name}</option>
              ))}
            </select>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-50 focus:border-emerald-500/60 focus:outline-none"
            >
              <option value="الكل">كل الحالات</option>
              <option value="مكتمل">مكتمل</option>
              <option value="معلق">معلق</option>
            </select>
          </div>
        </div>

        <p className="text-[11px] text-slate-500 mb-3">
          عرض {filtered.length} من {orders.length} عملية
        </p>

        <div className="overflow-x-auto">
          <table className="w-full text-xs">
            <thead>
              <tr className="border-b border-slate-800 text-slate-400">
                <th className="px-3 py-2.5 text-right font-medium">رقم العملية</th>
                <th className="px-3 py-2.5 text-right font-medium">العميل</th>
                <th className="px-3 py-2.5 text-right font-medium">المتجر</th>
                <th className="px-3 py-2.5 text-right font-medium">قيمة المنتج</th>
                <th className="px-3 py-2.5 text-right font-medium">الأقساط</th>
                <th className="px-3 py-2.5 text-right font-medium">نسبة البنك</th>
                <th className="px-3 py-2.5 text-right font-medium">نسبة المنصة</th>
                <th className="px-3 py-2.5 text-right font-medium">حصة البنك</th>
                <th className="px-3 py-2.5 text-right font-medium">حصة المنصة</th>
                <th className="px-3 py-2.5 text-right font-medium">صافي المتجر</th>
                <th className="px-3 py-2.5 text-right font-medium">المحصّل</th>
                <th className="px-3 py-2.5 text-right font-medium">التاريخ</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={12} className="py-10 text-center text-slate-500">
                    لا توجد عمليات مطابقة
                  </td>
                </tr>
              ) : (
                filtered.map((o) => (
                  <tr key={o.orderId} className="hover:bg-slate-900/40 transition-colors">
                    <td className="px-3 py-2.5 font-mono text-[10px] text-slate-300 max-w-[120px] truncate" title={o.orderId}>
                      {o.orderId.length > 20 ? "..." + o.orderId.slice(-16) : o.orderId}
                    </td>
                    <td className="px-3 py-2.5 text-slate-200">{o.customer}</td>
                    <td className="px-3 py-2.5 text-slate-300">{o.store}</td>
                    <td className="px-3 py-2.5 text-white font-semibold">{fmt(o.productValue)} د.أ</td>
                    <td className="px-3 py-2.5">
                      <span className="inline-flex items-center rounded-full bg-slate-800 px-2 py-0.5 text-[10px] text-slate-300">
                        {o.paidInstallments}/{o.totalInstallments}
                      </span>
                    </td>
                    <td className="px-3 py-2.5 text-sky-400/80">{n(o.bankRate).toFixed(1)}%</td>
                    <td className="px-3 py-2.5 text-emerald-400/80">{n(o.platformRate).toFixed(1)}%</td>
                    <td className="px-3 py-2.5 text-sky-200">{fmt(o.bankShare)} د.أ</td>
                    <td className="px-3 py-2.5 text-emerald-200">{fmt(o.platformShare)} د.أ</td>
                    <td className="px-3 py-2.5 text-purple-200 font-semibold">{fmt(o.vendorNet)} د.أ</td>
                    <td className="px-3 py-2.5">
                      <span className={`font-semibold ${o.paidAmount > 0 ? "text-amber-400" : "text-slate-500"}`}>
                        {fmt(o.paidAmount)} د.أ
                      </span>
                    </td>
                    <td className="px-3 py-2.5 text-slate-400">{o.date}</td>
                  </tr>
                ))
              )}
            </tbody>
            {filtered.length > 0 && (
              <tfoot>
                <tr className="border-t-2 border-slate-700 bg-slate-900/30 font-bold text-xs">
                  <td className="px-3 py-2.5 text-slate-100" colSpan={3}>الإجمالي</td>
                  <td className="px-3 py-2.5 text-white">{fmt(totalProductValue)} د.أ</td>
                  <td className="px-3 py-2.5" />
                  <td className="px-3 py-2.5" />
                  <td className="px-3 py-2.5" />
                  <td className="px-3 py-2.5 text-sky-200">{fmt(totalBankShare)} د.أ</td>
                  <td className="px-3 py-2.5 text-emerald-200">{fmt(totalPlatformShare)} د.أ</td>
                  <td className="px-3 py-2.5 text-purple-200">{fmt(totalVendorNet)} د.أ</td>
                  <td className="px-3 py-2.5 text-amber-300">{fmt(totalPaid)} د.أ</td>
                  <td className="px-3 py-2.5" />
                </tr>
              </tfoot>
            )}
          </table>
        </div>
      </div>

      {/* ─── Commission Info Card ────────────────────────────── */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-5 shadow-lg">
        <h2 className="text-sm font-bold text-slate-50 mb-3 flex items-center gap-2">
          <span>⚙️</span> نسب العمولات المُطبّقة
        </h2>
        <div className="grid gap-4 md:grid-cols-3">
          <div className="rounded-lg bg-sky-950/30 border border-sky-900/30 p-4">
            <p className="text-[10px] text-sky-400 uppercase tracking-wider">نسبة البنك</p>
            <p className="text-2xl font-black text-sky-200 mt-1">{effectiveBankRate.toFixed(1)}%</p>
            <p className="text-[10px] text-sky-500 mt-1">تُقتطع لصالح البنك الممول</p>
          </div>
          <div className="rounded-lg bg-emerald-950/30 border border-emerald-900/30 p-4">
            <p className="text-[10px] text-emerald-400 uppercase tracking-wider">نسبة المنصة</p>
            <p className="text-2xl font-black text-emerald-200 mt-1">{effectivePlatformRate.toFixed(1)}%</p>
            <p className="text-[10px] text-emerald-500 mt-1">أرباح منصة BNPL</p>
          </div>
          <div className="rounded-lg bg-purple-950/30 border border-purple-900/30 p-4">
            <p className="text-[10px] text-purple-400 uppercase tracking-wider">صافي المتجر</p>
            <p className="text-2xl font-black text-purple-200 mt-1">{(100 - effectiveBankRate - effectivePlatformRate).toFixed(1)}%</p>
            <p className="text-[10px] text-purple-500 mt-1">ما يحصل عليه الفيندر من كل عملية</p>
          </div>
        </div>
        <div className="mt-4 rounded-lg bg-slate-900/40 border border-slate-800 p-3">
          <p className="text-[11px] text-slate-300 leading-relaxed">
            <strong className="text-slate-100">آلية التدفق:</strong> العميل يسدد أقساطه إلى المنصة ←
            تُقتطع عمولة البنك ({effectiveBankRate.toFixed(1)}%) + عمولة المنصة ({effectivePlatformRate.toFixed(1)}%) ←
            المتبقي ({(100 - effectiveBankRate - effectivePlatformRate).toFixed(1)}%) يُحوّل لحساب المتجر.
          </p>
        </div>
      </div>
    </div>
  );
}
