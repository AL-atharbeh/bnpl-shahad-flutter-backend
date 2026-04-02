"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { useRouter } from "next/navigation";
import {
  TrendingUp,
  Users,
  Package,
  AlertCircle,
  ArrowUpRight
} from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';
import { getVendorDashboardStats, getVendorPerformance, requestSettlement } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

export default function Home() {
  const [stats, setStats] = useState<any>(null);
  const [performanceData, setPerformanceData] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [vendor, setVendor] = useState<any>(null);
  const { t, language } = useLanguage();
  const router = useRouter();
  const [settlementLoading, setSettlementLoading] = useState(false);

  useEffect(() => {
    async function loadData() {
      const userStr = localStorage.getItem("vendor_user");
      if (!userStr) return;

      try {
        const user = JSON.parse(userStr);
        setVendor(user);
        const storeId = user.storeId;

        const [statsRes, perfRes] = await Promise.all([
          getVendorDashboardStats(storeId),
          getVendorPerformance(storeId)
        ]);
        setStats(statsRes.data.data);
        setPerformanceData(perfRes.data.data);
      } catch (error) {
        console.error("Failed to load dashboard data", error);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  const kpis = [
    { name: t("totalSales"), value: (stats?.totalFinancedQuarter || 0).toLocaleString() + " " + t("currency"), icon: TrendingUp, detail: t("basedOnInstallments"), color: "text-emerald-400" },
    { name: t("totalCollections"), value: (stats?.totalCollected || 0).toLocaleString() + " " + t("currency"), icon: Package, detail: t("completedPayments"), color: "text-emerald-300" },
    { name: t("riskLevel"), value: (stats?.riskIndicator || 0).toFixed(1) + " %", icon: AlertCircle, detail: t("riskRatio"), color: "text-amber-400" },
    { name: t("platformCommission"), value: (stats?.totalCommission || 0).toLocaleString() + " " + t("currency"), icon: Users, detail: t("serviceFees"), color: "text-emerald-500" },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-8">
        {/* Header Section */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-extrabold text-white tracking-tight">{t("welcome")}، {vendor?.name}</h1>
            <p className="mt-2 text-slate-400 text-sm">{t("performanceSummary")}</p>
          </div>
          <button className="btn-financial flex items-center gap-2 rounded-xl px-6 py-3 text-sm">
            {t("downloadReport")}
            <ArrowUpRight className={`${language === "ar" ? "mr-2" : "ml-2"} h-4 w-4`} />
          </button>
        </div>

        {/* Info Cards */}
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
          {kpis.map((kpi) => (
            <div key={kpi.name} className="glass rounded-2xl p-6 relative overflow-hidden group">
              <div className="relative z-10">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-medium text-slate-400">{kpi.name}</p>
                  <kpi.icon className={`h-5 w-5 ${kpi.color}`} />
                </div>
                <div className="mt-4">
                  <h3 className="text-2xl font-bold text-white">{loading ? "..." : kpi.value}</h3>
                  <p className="mt-1 text-[11px] text-slate-500">{kpi.detail}</p>
                </div>
              </div>
              <div className={`absolute -bottom-6 -right-6 h-24 w-24 rounded-full opacity-5 blur-2xl transition-all group-hover:opacity-10 ${kpi.color.replace('text', 'bg')}`} />
            </div>
          ))}
        </div>

        {/* Charts & Main Content */}
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
          <div className="glass lg:col-span-2 rounded-2xl p-8">
            <div className="mb-8">
              <h3 className="text-lg font-bold text-white">{t("salesGrowth")}</h3>
              <p className="text-xs text-slate-400">{t("last6Months")}</p>
            </div>
            <div className="h-80 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={performanceData}>
                  <defs>
                    <linearGradient id="colorPurchases" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10b981" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" vertical={false} />
                  <XAxis dataKey="month" stroke="#64748b" fontSize={11} tickMargin={10} axisLine={false} tickLine={false} reversed={language === "ar"} />
                  <YAxis stroke="#64748b" fontSize={11} axisLine={false} tickLine={false} orientation={language === "ar" ? "right" : "left"} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#021f2a', border: '1px solid #1e293b', borderRadius: '12px', fontSize: '11px' }}
                    itemStyle={{ color: '#fff' }}
                  />
                  <Area type="monotone" dataKey="purchases" stroke="#10b981" fillOpacity={1} fill="url(#colorPurchases)" name={t("totalSales")} strokeWidth={2} />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="glass rounded-2xl p-8 flex flex-col">
            <h3 className="text-lg font-bold text-white mb-6">{t("quickActions")}</h3>
            <div className="space-y-4 flex-1">
              <div 
                onClick={() => router.push('/products')}
                className="rounded-xl border border-slate-800 bg-slate-900/40 p-4 hover:bg-slate-900/60 transition-colors cursor-pointer group"
              >
                <h4 className="text-sm font-semibold text-slate-200 group-hover:text-emerald-400">{t("updatePrices")}</h4>
                <p className="text-[11px] text-slate-500 mt-1">{t("updatePricesDetail")}</p>
              </div>
{/* <div 
                onClick={() => router.push('/stores/new')}
                className="rounded-xl border border-slate-800 bg-slate-900/40 p-4 hover:bg-slate-900/60 transition-colors cursor-pointer group"
              >
                <h4 className="text-sm font-semibold text-slate-200 group-hover:text-blue-400">{t("addBranch")}</h4>
                <p className="text-[11px] text-slate-500 mt-1">{t("addBranchDetail")}</p>
              </div> */}
              <div 
                onClick={async () => {
                  if (settlementLoading) return;
                  setSettlementLoading(true);
                  try {
                    await requestSettlement(vendor.storeId, vendor.name);
                    alert(t("paymentSent")); // Using an existing translation or I can add a new one
                  } catch (error) {
                    console.error("Failed to request settlement", error);
                    alert("Failed to request settlement");
                  } finally {
                    setSettlementLoading(false);
                  }
                }}
                className={`rounded-xl border border-slate-800 bg-slate-900/40 p-4 hover:bg-slate-900/60 transition-colors cursor-pointer group ${settlementLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <h4 className="text-sm font-semibold text-slate-200 group-hover:text-amber-400">{t("requestSettlement")}</h4>
                <p className="text-[11px] text-slate-500 mt-1">{t("requestSettlementDetail")}</p>
              </div>
            </div>
            <div className="mt-8 rounded-2xl glass-emerald p-6 text-center">
              <p className="text-xs text-emerald-400/80 font-medium">{t("accountActiveMsg")}</p>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
