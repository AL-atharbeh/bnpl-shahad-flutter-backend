"use client";

import { useEffect, useState } from "react";
import {
  getProfitDistributionStats,
  getProfitDistributionChart,
  getCurrentCommissionSettings,
  updateCommissionSettings,
  getAllSettlements,
  getAllPayments,
  getAdminStores,
  updateStore,
} from "@/services/api";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

const settlementStatusStyles = {
  "تم التحويل":
    "bg-emerald-500/15 text-emerald-200 border border-emerald-500/40",
  "بنتظار":
    "bg-amber-500/15 text-amber-200 border border-amber-500/40",
};

export default function ProfitsPage() {
  const [mounted, setMounted] = useState(false);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<any>(null);
  const [chartData, setChartData] = useState<any[]>([]);
  const [settings, setSettings] = useState<any>(null);
  const [settlements, setSettlements] = useState<any[]>([]);
  const [payments, setPayments] = useState<any[]>([]);
  const [editMode, setEditMode] = useState(false);
  const [allStores, setAllStores] = useState<any[]>([]);
  const [selectedStoreId, setSelectedStoreId] = useState<string>("global");
  const [bankRate, setBankRate] = useState("");
  const [platformRate, setPlatformRate] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("الكل");

  useEffect(() => {
    setMounted(true);
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      // Fetch core data first
      const statsRes = await getProfitDistributionStats().catch(() => ({ data: { data: null } }));
      const settingsRes = await getCurrentCommissionSettings().catch(() => ({ data: { data: { bankCommission: 0.03, platformCommission: 0.02 } } }));
      
      if (statsRes?.data?.data) setStats(statsRes.data.data);
      if (settingsRes?.data?.data) {
        setSettings(settingsRes.data.data);
        setBankRate(((settingsRes.data.data.bankCommission || 0.03) * 100).toString());
        setPlatformRate(((settingsRes.data.data.platformCommission || 0.02) * 100).toString());
      }

      // Fetch supplementary data
      const [chartRes, settlementsRes, paymentsRes, storesRes] = await Promise.all([
        getProfitDistributionChart(7).catch(() => ({ data: { data: [] } })),
        getAllSettlements({ page: 1, limit: 10 }).catch(() => ({ data: { data: { settlements: [] } } })),
        getAllPayments({ page: 1, limit: 100 }).catch(() => ({ data: { data: [] } })),
        getAdminStores().catch(() => ({ data: [] })),
      ]);

      if (chartRes?.data?.data) setChartData(chartRes.data.data);
      if (settlementsRes?.data?.data?.settlements) setSettlements(settlementsRes.data.data.settlements);
      if (storesRes?.data) setAllStores(storesRes.data);

      // Process payments
      const uniqueOrders = new Map();
      const paymentsList = paymentsRes?.data?.data || paymentsRes?.data || [];
      
      if (Array.isArray(paymentsList)) {
        paymentsList.forEach((p: any) => {
          if (p && p.orderId && !uniqueOrders.has(p.orderId)) {
            const amount = Number(p.amount) || 0;
            const installments = p.installmentsCount || 1;
            const prodVal = amount * installments;
            
            const bR = p.bankCommissionRate ? Number(p.bankCommissionRate) / 100 : (settingsRes?.data?.data?.bankCommission || 0.03);
            const pR = p.platformCommissionRate ? Number(p.platformCommissionRate) / 100 : (settingsRes?.data?.data?.platformCommission || 0.02);

            uniqueOrders.set(p.orderId, {
              id: p.orderId,
              customer: p.user?.name || "عميل غير معروف",
              store: p.store?.name || "متجر غير معروف",
              productValue: prodVal,
              bankRate: (bR * 100).toFixed(1),
              platformRate: (pR * 100).toFixed(1),
              bankShare: prodVal * bR,
              platformShare: prodVal * pR,
              netToMerchant: prodVal * (1 - bR - pR),
              settlementStatus: p.status === 'completed' ? 'تم التحويل' : 'بنتظار',
              settlementDate: p.paidAt ? new Date(p.paidAt).toLocaleDateString("ar") : "-",
            });
          }
        });
      }
      setPayments(Array.from(uniqueOrders.values()));

    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  if (!mounted) return null;

  const handleSaveSettings = async () => {
    try {
      if (selectedStoreId === "global") {
        await updateCommissionSettings({
          bankCommission: parseFloat(bankRate) / 100,
          platformCommission: parseFloat(platformRate) / 100,
          storeDiscount: settings?.storeDiscount || 0.05,
          createdBy: "Admin",
        });
      } else {
        // Update specific store ratios
        const storeId = parseInt(selectedStoreId);
        await updateStore(storeId, {
          bankCommissionRate: parseFloat(bankRate),
          platformCommissionRate: parseFloat(platformRate),
        });
      }
      alert("تم حفظ التغييرات بنجاح!");
      setEditMode(false);
      fetchData();
    } catch (error) {
      alert("فشل الحفظ!");
    }
  };

  const onStoreSelect = (value: string) => {
    setSelectedStoreId(value);
    if (value === "global") {
      setBankRate((settings?.bankCommission * 100 || 3).toString());
      setPlatformRate((settings?.platformCommission * 100 || 2).toString());
    } else {
      const store = allStores.find(s => s.id.toString() === value);
      if (store) {
        setBankRate(store.bankCommissionRate?.toString() || "1.5");
        setPlatformRate(store.platformCommissionRate?.toString() || "1.0");
      }
    }
  };

  const filteredEntries = payments.filter((entry) => {
    const matchesSearch =
      entry.customer.includes(searchQuery) ||
      entry.store.includes(searchQuery) ||
      entry.id.includes(searchQuery);

    const matchesStatus =
      statusFilter === "الكل" || entry.settlementStatus === statusFilter;

    return matchesSearch && matchesStatus;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-slate-400">جاري التحميل...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-lg font-semibold text-slate-50">توزيع الأرباح</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          العميل يسدد عبرنا، فنقتطع عمولتنا من الدفعات ثم نحوّل المتبقي للبنك كي يغطي تمويله للمتجر.
        </p>
      </div>

      {/* Statistics Cards */}
      <section className="grid gap-4 md:grid-cols-4">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💼</span>
            <span>حجم العمليات</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalFinanced?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">تم تمويلها عبر البنك</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🏦</span>
            <span>حصة البنك</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.bankTotalShare?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">نقتطعها من كل دفعة عميل ونحوّلها للبنك</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🧾</span>
            <span>عمولة المنصة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.platformTotalShare?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">إجمالي أرباحك من العمليات</p>
        </div>

        <div className="rounded-xl border border-amber-500/60 bg-gradient-to-br from-amber-500 to-amber-400 p-4 text-amber-950 shadow-[0_18px_40px_rgba(245,158,11,0.5)]">
          <p className="text-xs font-medium flex items-center gap-1">
            <span>⏳</span>
            <span>أرباح بانتظار التحويل</span>
          </p>
          <p className="mt-2 text-2xl font-semibold">
            {(stats?.pendingProfits || 0).toFixed(2)} دينار
          </p>
          <p className="mt-1 text-[11px]">تُحوّل في التسوية الأسبوعية القادمة</p>
        </div>
      </section>

      <div className="grid gap-4 xl:grid-cols-2">
        {/* Chart */}
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
          <h2 className="text-sm font-semibold text-slate-50 mb-1">تدفق التسويات</h2>
          <p className="text-[11px] text-slate-400 mb-4">مقارنة بين ما يتم تحصيله من العملاء وما يوزّع بين البنك والمنصة.</p>
          <div className="h-64 rounded-lg border border-slate-800 bg-[#031824] px-3 py-3">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData}>
                <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" />
                <XAxis dataKey="day" stroke="#9ca3af" tick={{ fontSize: 11 }} />
                <YAxis stroke="#9ca3af" tick={{ fontSize: 11 }} />
                <Tooltip
                  contentStyle={{ backgroundColor: "#020617", borderColor: "#1f2937", borderRadius: 8, fontSize: 11 }}
                />
                <Legend wrapperStyle={{ fontSize: 11 }} />
                <Bar dataKey="bankShare" name="حصة البنك" stackId="shares" fill="#38bdf8" />
                <Bar dataKey="platformShare" name="حصة المنصة" stackId="shares" fill="#22c55e" />
                <Bar dataKey="totalCollected" name="التحصيل الكلي" fill="#6366f1" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Commission Settings */}
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-3">
          <h2 className="text-sm font-semibold text-slate-50">نسب المشاركة في الأرباح</h2>

          <div className="rounded-lg border border-slate-800 bg-[#031824] p-4 text-xs text-slate-200">
            <div className="flex items-center justify-between">
              <span>نسبة البنك</span>
              <span className="text-slate-50 text-sm font-semibold">{(settings?.bankCommission * 100 || 3).toFixed(1)}%</span>
            </div>
            <div className="mt-2 h-2 rounded-full bg-slate-800 overflow-hidden">
              <div className="h-full bg-sky-400 transition-all duration-500" style={{ width: `${(settings?.bankCommission * 100) || 0}%` }} />
            </div>
          </div>

          <div className="rounded-lg border border-slate-800 bg-[#031824] p-4 text-xs text-slate-200">
            <div className="flex items-center justify-between">
              <span>نسبة المنصة</span>
              <span className="text-slate-50 text-sm font-semibold">{(settings?.platformCommission * 100 || 2).toFixed(1)}%</span>
            </div>
            <div className="mt-2 h-2 rounded-full bg-slate-800 overflow-hidden">
              <div className="h-full bg-emerald-400 transition-all duration-500" style={{ width: `${(settings?.platformCommission * 100) || 0}%` }} />
            </div>
          </div>

          <div className="rounded-lg border border-slate-800 bg-[#031824] p-4 text-xs text-slate-300">
            <p className="text-slate-200 font-medium font-bold">طريقة تدفق الأموال</p>
            <ul className="mt-2 space-y-1">
              <li>• العميل يسدد أقساطه إلى المنصة.</li>
              <li>• تُقتطع عمولتنا من الدفعة نفسها وتُسجَّل كأرباح.</li>
              <li>• المبلغ المتبقي يُحوَّل للبنك بعد خصم حصته، ثم يرسل البنك صافي المتجر.</li>
            </ul>
          </div>

          {/* Edit Ratios */}
          <div className="rounded-lg border border-slate-800 bg-[#031824] p-4 text-xs text-slate-200 space-y-3">
            <p className="text-slate-200 font-medium">تخصيص النسب</p>
            
            <div className="flex flex-col gap-2">
              <label className="text-[11px] text-slate-400">اختر المتجر لتعديل نسبته:</label>
              <select 
                value={selectedStoreId}
                onChange={(e) => onStoreSelect(e.target.value)}
                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-slate-50 focus:border-emerald-500/60 focus:outline-none"
              >
                <option value="global">الإعدادات العامة (الكل)</option>
                {allStores.map(store => (
                  <option key={store.id} value={store.id.toString()}>
                    {store.nameAr || store.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="flex items-center gap-3">
              <label className="flex flex-col text-[11px] text-slate-400">
                نسبة البنك
                <input
                  type="number"
                  value={bankRate}
                  onChange={(e) => setBankRate(e.target.value)}
                  className="mt-1 rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                />
              </label>
              <label className="flex flex-col text-[11px] text-slate-400">
                نسبة المنصة
                <input
                  type="number"
                  value={platformRate}
                  onChange={(e) => setPlatformRate(e.target.value)}
                  className="mt-1 rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                />
              </label>
            </div>

            {selectedStoreId !== "global" && (
               <div className="rounded-lg bg-emerald-500/10 border border-emerald-500/20 p-2 text-[11px] text-emerald-200">
                  إجمالي عمولة المتجر ستصبح: <span className="font-bold">{(parseFloat(bankRate || "0") + parseFloat(platformRate || "0")).toFixed(1)}%</span>
               </div>
            )}

            <button
              onClick={handleSaveSettings}
              className="w-full rounded-lg bg-emerald-500 px-4 py-2 text-xs font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
            >
              حفظ التغييرات
            </button>
          </div>
        </div>
      </div>

      {/* Filter and Table */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div className="flex flex-1 flex-col gap-3 md:flex-row md:items-center">
            <div className="relative flex-1">
              <input
                type="text"
                placeholder="ابحث برقم العملية، العميل، أو المتجر..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none"
              />
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">🔍</span>
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
            >
              <option value="الكل">كل حالات التسوية</option>
              <option value="تم التحويل">تم التحويل</option>
              <option value="بنتظار">بانتظار التحويل</option>
            </select>
          </div>
          <div className="flex items-center gap-2">
            <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 transition-colors">
              📥 تصدير تقرير
            </button>
            <button className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors">
              + إضافة تسوية
            </button>
          </div>
        </div>
        <div className="mt-3 text-xs text-slate-400">
          عرض {filteredEntries.length} من {payments.length} عملية تمويل
        </div>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800 text-xs">
            <thead className="bg-[#041f2e] text-slate-300">
              <tr>
                <th className="px-4 py-3 text-right">رقم العملية</th>
                <th className="px-4 py-3 text-right">العميل</th>
                <th className="px-4 py-3 text-right">المتجر</th>
                <th className="px-4 py-3 text-right">قيمة المنتج</th>
                <th className="px-4 py-3 text-right">نسبة البنك</th>
                <th className="px-4 py-3 text-right">نسبة المنصة</th>
                <th className="px-4 py-3 text-right">حصة البنك</th>
                <th className="px-4 py-3 text-right">حصة المنصة</th>
                <th className="px-4 py-3 text-right">صافي المتجر</th>
                <th className="px-4 py-3 text-right">حالة التسوية</th>
                <th className="px-4 py-3 text-right">تاريخ التسوية</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-200">
              {filteredEntries.length === 0 ? (
                <tr>
                  <td colSpan={11} className="px-4 py-8 text-center text-slate-400">
                    لا توجد عمليات مطابقة للاستعلام الحالي.
                  </td>
                </tr>
              ) : (
                filteredEntries.map((entry: any) => (
                  <tr key={entry.id} className="hover:bg-slate-900/40 transition-colors">
                    <td className="px-4 py-3 font-semibold text-slate-50">{entry.id}</td>
                    <td className="px-4 py-3">{entry.customer}</td>
                    <td className="px-4 py-3 text-slate-300">{entry.store}</td>
                    <td className="px-4 py-3 text-slate-200">{(entry.productValue || 0).toFixed(2)} دينار</td>
                    <td className="px-4 py-3 text-sky-300/80">{(entry.bankRate || 0).toFixed(1)}%</td>
                    <td className="px-4 py-3 text-emerald-300/80">{(entry.platformRate || 0).toFixed(1)}%</td>
                    <td className="px-4 py-3 text-sky-200">{(entry.bankShare || 0).toFixed(2)} دينار</td>
                    <td className="px-4 py-3 text-emerald-200">{(entry.platformShare || 0).toFixed(2)} دينار</td>
                    <td className="px-4 py-3 text-slate-100">{(entry.netToMerchant || 0).toFixed(2)} دينار</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex rounded-full px-3 py-1 text-[10px] font-medium ${settlementStatusStyles[entry.settlementStatus as keyof typeof settlementStatusStyles] || ""
                        }`}>
                        {entry.settlementStatus}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-400">{entry.settlementDate}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Settlements Summary */}
        <div className="mt-8 rounded-xl border border-slate-800 bg-[#02121b] p-6 shadow-[0_20px_50px_rgba(0,0,0,0.7)]">
          <h3 className="mb-6 text-lg font-bold text-slate-50 flex items-center gap-2">
            <span>📅</span>
            أحدث التسويات المالية
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full text-right text-sm">
              <thead>
                <tr className="border-b border-slate-800 text-slate-400">
                  <th className="px-4 py-3 font-medium">رقم العملية</th>
                  <th className="px-4 py-3 font-medium">التاريخ</th>
                  <th className="px-4 py-3 font-medium">إجمالي المبلغ</th>
                  <th className="px-4 py-3 font-medium">حصة البنك</th>
                  <th className="px-4 py-3 font-medium">حصة المنصة</th>
                  <th className="px-4 py-3 font-medium">الحالة</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 text-slate-200">
                {settlements.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-4 py-8 text-center text-slate-400">
                      لا توجد تسويات مالية مسجلة حالياً.
                    </td>
                  </tr>
                ) : (
                  settlements.map((s) => (
                    <tr key={s.id} className="hover:bg-slate-900/40 transition-colors">
                      <td className="px-4 py-3 font-semibold text-slate-50">{s.id}</td>
                      <td className="px-4 py-3">{s.createdAt ? new Date(s.createdAt).toLocaleDateString("ar") : "-"}</td>
                      <td className="px-4 py-3">{(s.totalAmount || 0).toFixed(2)} د.أ</td>
                      <td className="px-4 py-3 text-emerald-300/80">{(s.bankShare || 0).toFixed(2)} د.أ</td>
                      <td className="px-4 py-3 text-emerald-100">{(s.platformShare || 0).toFixed(2)} د.أ</td>
                      <td className="px-4 py-3">
                        <span className="inline-flex rounded-full bg-emerald-500/10 px-3 py-1 text-[10px] font-medium text-emerald-400 border border-emerald-500/20">
                          {s.status === 'completed' ? 'تمت التسوية' : 'بانتظار التحويل'}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
