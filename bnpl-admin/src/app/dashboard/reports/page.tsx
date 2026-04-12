"use client";

import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import {
  getReportsStats,
  getReportsPerformance,
  getReportsRisks,
  getReportsTopStores,
} from "@/services/api";

// Dynamically import Recharts to prevent hydration errors
const ResponsiveContainer = dynamic(() => import("recharts").then((mod) => mod.ResponsiveContainer), { ssr: false });
const AreaChart = dynamic(() => import("recharts").then((mod) => mod.AreaChart), { ssr: false });
const Area = dynamic(() => import("recharts").then((mod) => mod.Area), { ssr: false });
const XAxis = dynamic(() => import("recharts").then((mod) => mod.XAxis), { ssr: false });
const YAxis = dynamic(() => import("recharts").then((mod) => mod.YAxis), { ssr: false });
const CartesianGrid = dynamic(() => import("recharts").then((mod) => mod.CartesianGrid), { ssr: false });
const Tooltip = dynamic(() => import("recharts").then((mod) => mod.Tooltip), { ssr: false });
const Legend = dynamic(() => import("recharts").then((mod) => mod.Legend), { ssr: false });

export default function ReportsPage() {
  const [period, setPeriod] = useState<"ربع سنوي" | "شهري" | "سنوي">("ربع سنوي");
  const [reportFilter, setReportFilter] = useState("الكل");
  const [loading, setLoading] = useState(true);

  const [stats, setStats] = useState<any>(null);
  const [performanceData, setPerformanceData] = useState<any[]>([]);
  const [riskDistribution, setRiskDistribution] = useState<any[]>([]);
  const [storesPerformance, setStoresPerformance] = useState<any[]>([]);

  useEffect(() => {
    fetchData();
  }, [period]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [statsRes, perfRes, riskRes, storesRes] = await Promise.all([
        getReportsStats(),
        getReportsPerformance(),
        getReportsRisks(),
        getReportsTopStores(),
      ]);

      setStats(statsRes.data.data);
      setPerformanceData(perfRes.data.data);
      setRiskDistribution(riskRes.data.data);
      setStoresPerformance(storesRes.data.data);
    } catch (error) {
      console.error("Error fetching reports data:", error);
    } finally {
      setLoading(false);
    }
  };

  const reports = [
    { title: "تقرير الأداء الشهري", description: "حجم العمليات وتحليل الأقساط والايرادات.", category: "الأداء" },
    { title: "تقرير المخاطر", description: "توزيع العملاء حسب مستوى المخاطر والتنبيهات الحرجة.", category: "المخاطر" },
    { title: "تقرير المتاجر", description: "أفضل المتاجر أداءً والمتاجر المتأخرة في التسوية.", category: "المتاجر" },
    { title: "تقرير البنك", description: "ملخص التحويلات للبنك مقابل عمولة المنصة.", category: "البنك" },
  ];

  const filteredReports = reportFilter === "الكل"
    ? reports
    : reports.filter(r => r.category === reportFilter);

  if (loading && !stats) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-slate-400">جاري تحميل التقارير...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-lg font-semibold text-slate-50">لوحة التقارير</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          تحليلات الأداء، المخاطر، المتاجر والبنك في مكان واحد.
        </p>
      </div>

      <section className="grid gap-4 md:grid-cols-4">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>📈</span> حجم العمليات الربع الحالي
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalFinancedQuarter?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {stats?.totalFinancedQuarter > 0 ? "بناءً على العمليات الحالية" : "لا توجد بيانات"}
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💳</span> الأقساط المحصّلة
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalCollected?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {stats?.totalCollected > 0 ? "إجمالي التحصيل الكلي" : "لا توجد بيانات"}
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⚠️</span> مؤشر المخاطر
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.riskIndicator?.toFixed(1) || 0}%
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {stats?.riskIndicator > 15 ? "مرتفع" : stats?.riskIndicator > 5 ? "متوسط" : "منخفض"}
          </p>
        </div>
        <div className="rounded-xl border border-emerald-500/70 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 text-slate-950">
          <p className="text-xs font-medium flex items-center gap-1">
            <span>🏦</span> صافي عمولة المنصة
          </p>
          <p className="mt-2 text-2xl font-semibold">
            {stats?.totalCommission?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px]">أرباح من العمليات المكتملة</p>
        </div>
      </section>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 className="text-sm font-semibold text-slate-50">
              أداء العمليات
            </h2>
            <p className="text-[11px] text-slate-400">
              حجم الشراء، الأقساط، والتأخيرات خلال الفترة المحددة.
            </p>
          </div>
          <select
            value={period}
            onChange={(e) => setPeriod(e.target.value as typeof period)}
            className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs text-slate-200 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
          >
            <option value="ربع سنوي">ربع سنوي</option>
            <option value="شهري">شهري</option>
            <option value="سنوي">سنوي</option>
          </select>
        </div>

        <div className="mt-4 h-64 rounded-lg border border-slate-800 bg-[#031824] px-3 py-3">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={performanceData}>
              <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" />
              <XAxis dataKey="month" stroke="#9ca3af" tick={{ fontSize: 11 }} />
              <YAxis stroke="#9ca3af" tick={{ fontSize: 11 }} />
              <Tooltip
                contentStyle={{
                  backgroundColor: "#020617",
                  borderColor: "#1f2937",
                  borderRadius: 8,
                  fontSize: 11,
                }}
              />
              <Legend wrapperStyle={{ fontSize: 11 }} />
              <Area type="monotone" dataKey="purchases" name="الشراء" stroke="#22c55e" fill="#22c55e55" />
              <Area type="monotone" dataKey="installments" name="الأقساط" stroke="#38bdf8" fill="#38bdf855" />
              <Area type="monotone" dataKey="overdue" name="التأخير" stroke="#f97316" fill="#f9731655" />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-slate-50">توزيع المخاطر</h2>
            <span className="text-[11px] text-slate-400">حسب تقييم العملاء</span>
          </div>
          <div className="space-y-4 text-xs text-slate-300">
            {riskDistribution.map((risk) => (
              <div key={risk.label} className="flex flex-col gap-1.5">
                <div className="flex items-center justify-between">
                  <span className={risk.color}>{risk.label}</span>
                  <span className="text-slate-100 font-semibold">{risk.value}%</span>
                </div>
                <div className="h-2 w-full rounded-full bg-slate-800 overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all duration-700 ${risk.color.replace("text", "bg")}`}
                    style={{ width: `${risk.value}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-slate-50">أفضل المتاجر</h2>
            <span className="text-[11px] text-slate-400">آخر 30 يوم</span>
          </div>
          <div className="space-y-3 text-xs text-slate-300">
            {storesPerformance.length === 0 ? (
              <div className="rounded-lg border border-slate-800 bg-[#031824] p-4 text-center text-slate-400">
                لا توجد بيانات مبيعات حالية
              </div>
            ) : (
              storesPerformance.map((store) => (
                <div
                  key={store.store}
                  className="rounded-lg border border-slate-800 bg-[#031824] p-3 hover:bg-[#042436] transition-colors"
                >
                  <div className="flex items-center justify-between text-sm text-slate-100 font-medium">
                    <span>{store.store}</span>
                    <span className="text-emerald-400 font-bold">{store.growth}</span>
                  </div>
                  <p className="mt-1 text-[11px] text-slate-400">
                    مبيعات: {store.sales.toLocaleString()} دينار
                  </p>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 className="text-sm font-semibold text-slate-50">التقارير المتاحة</h2>
            <p className="text-[11px] text-slate-400">
              اختر نوع التقرير لتصديره ومشاركته مع البنك أو الشركاء.
            </p>
          </div>
          <select
            value={reportFilter}
            onChange={(e) => setReportFilter(e.target.value)}
            className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs text-slate-200 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
          >
            <option value="الكل">كل التقارير</option>
            <option value="الأداء">تقارير الأداء</option>
            <option value="المخاطر">تقارير المخاطر</option>
            <option value="المتاجر">تقارير المتاجر</option>
            <option value="البنك">تقارير البنك</option>
          </select>
        </div>

        <div className="mt-4 grid gap-3 md:grid-cols-2 text-xs text-slate-200">
          {filteredReports.map((report) => (
            <div
              key={report.title}
              className="rounded-lg border border-slate-800 bg-[#031824] p-4 hover:border-slate-700 transition-colors"
            >
              <h3 className="text-sm font-semibold text-slate-50">{report.title}</h3>
              <p className="mt-1 text-[11px] text-slate-400">{report.description}</p>
              <div className="mt-3 flex items-center gap-2">
                <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-[11px] text-slate-200 hover:bg-slate-900 transition-colors">
                  معاينة
                </button>
                <button className="rounded-lg bg-emerald-500 px-3 py-1.5 text-[11px] font-medium text-slate-950 hover:bg-emerald-400 transition-colors">
                  تنزيل PDF
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
