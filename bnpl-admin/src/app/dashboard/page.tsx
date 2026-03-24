"use client";

import { useState, useEffect } from "react";
import { TransactionsOverview } from "./transactions-overview";
import { dashboardService, DashboardStats, RecentUser, RecentStore } from "@/services/dashboard.service";

export default function DashboardPage() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    activeUsers: 0,
    totalStores: 0,
    activeStores: 0,
    totalSales: 0,
    totalProfits: 0,
    overduePayments: 0,
    blockedUsers: 0,
    verifiedUsers: 0,
    newUsersThisMonth: 0,
    avgCreditScore: 0,
    totalCreditLimit: 0,
    totalCreditUsed: 0,
    totalDelays: 0,
    avgTransactionValue: 0,
  });
  const [recentUsers, setRecentUsers] = useState<RecentUser[]>([]);
  const [recentStores, setRecentStores] = useState<RecentStore[]>([]);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      const [statsData, usersData, storesData] = await Promise.all([
        dashboardService.getStats(),
        dashboardService.getRecentUsers(5),
        dashboardService.getRecentStores(5),
      ]);

      setStats(statsData);
      setRecentUsers(usersData);
      setRecentStores(storesData);
    } catch (error) {
      console.error("Failed to fetch dashboard data", error);
    } finally {
      setLoading(false);
    }
  };

  const formatNumber = (num: number) => {
    return num.toLocaleString('ar-EG');
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('ar-EG', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  return (
    <div className="space-y-6">
      <section className="grid gap-4 md:grid-cols-5">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>👥</span>
            <span>المستخدمون النشطون</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(stats.activeUsers)} مستخدم`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            عدد المستخدمين النشطين في النظام
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🏪</span>
            <span>المتاجر المتعاونة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(stats.totalStores)} متجرًا`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            عدد المتاجر المسجّلة في نظام BNPL
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💳</span>
            <span>إجمالي المبيعات</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(stats.totalSales)} دينار`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            مجموع جميع عمليات الشراء عبر BNPL
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💰</span>
            <span>الأرباح (عمولة شهد)</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(stats.totalProfits)} دينار`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            عمولتك الشهرية أو الإجمالية من عمليات BNPL
          </p>
        </div>

        <div className="rounded-xl border border-emerald-400 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 text-slate-950 shadow-[0_18px_40px_rgba(16,185,129,0.6)]">
          <p className="text-xs font-medium flex items-center gap-1">
            <span>⚠️</span>
            <span>الدفعات المتأخرة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold">
            {loading ? "..." : `${formatNumber(stats.overduePayments)} عملية`}
          </p>
          <p className="mt-1 text-[11px] text-emerald-50">
            عدد الدفعات التي تجاوزت تاريخ الاستحقاق
          </p>
        </div>
      </section>

      {/* إحصائيات المستخدمين التفصيلية */}
      <section className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>👥</span>
            <span>إجمالي المستخدمين</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.totalUsers)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم مسجّل</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>✅</span>
            <span>المستخدمون النشطون</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.activeUsers)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم نشط</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🆕</span>
            <span>جدد هذا الشهر</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.newUsersThisMonth)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم جديد</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🚫</span>
            <span>المحظورون</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.blockedUsers)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم محظور</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>📊</span>
            <span>متوسط الجدارة الائتمانية</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.avgCreditScore)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">نقطة</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💳</span>
            <span>إجمالي حدود الائتمان</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(stats.totalCreditLimit)} دينار`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">إجمالي الحد المتاح</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💰</span>
            <span>إجمالي الائتمان المستخدم</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(stats.totalCreditUsed)} دينار`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">المستخدم فعلياً</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>✅</span>
            <span>المستخدمون المحققون</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.verifiedUsers)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم محقق</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⚠️</span>
            <span>إجمالي التأخيرات</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : formatNumber(stats.totalDelays)}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">دفعة متأخرة</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>📈</span>
            <span>متوسط قيمة المعاملة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {loading ? "..." : `${formatNumber(Math.round(stats.avgTransactionValue))} دينار`}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">متوسط المبلغ</p>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 md:col-span-2 shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
          <div className="flex items-center justify-between pb-3">
            <h2 className="text-sm font-semibold text-slate-50">
              الدفعات القادمة
            </h2>
            <span className="text-[11px] text-slate-400">السبعة أيام القادمة</span>
          </div>

          <div className="overflow-hidden rounded-xl border border-slate-800 bg-[#031824]">
            <table className="min-w-full divide-y divide-slate-800 text-xs">
              <thead className="bg-[#041f2e] text-slate-300">
                <tr>
                  <th className="px-3 py-2 text-left font-medium">العميل</th>
                  <th className="px-3 py-2 text-left font-medium">الخطة</th>
                  <th className="px-3 py-2 text-left font-medium">تاريخ الاستحقاق</th>
                  <th className="px-3 py-2 text-right font-medium">المبلغ</th>
                  <th className="px-3 py-2 text-right font-medium">
                    الحالة
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-100">
                <tr>
                  <td colSpan={5} className="px-3 py-8 text-center text-xs text-slate-400">
                    لا توجد دفعات قادمة
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div className="space-y-4">
          <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
            <h2 className="text-sm font-semibold text-slate-50">
              لمحة عن المخاطر
            </h2>
            <p className="mt-1 text-[11px] text-slate-400">
              توزيع سريع لحالات العملاء حسب المخاطر.
            </p>

            <div className="mt-4 space-y-3 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-slate-300">في الوقت</span>
                <span className="text-emerald-300">0%</span>
              </div>
              <div className="h-1.5 overflow-hidden rounded-full bg-slate-800">
                <div className="h-full w-[0%] rounded-full bg-emerald-500" />
              </div>

              <div className="flex items-center justify-between pt-2">
                <span className="text-slate-300">فترة سماح</span>
                <span className="text-amber-300">0%</span>
              </div>
              <div className="h-1.5 overflow-hidden rounded-full bg-slate-800">
                <div className="h-full w-[0%] rounded-full bg-amber-400" />
              </div>

              <div className="flex items-center justify-between pt-2">
                <span className="text-slate-300">متأخر</span>
                <span className="text-rose-300">0%</span>
              </div>
              <div className="h-1.5 overflow-hidden rounded-full bg-slate-800">
                <div className="h-full w-[0%] rounded-full bg-rose-500" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* نظرة عامة على المعاملات + بطاقة المستخدمين/المتاجر الجدد */}
      <section className="grid gap-4 md:grid-cols-3">
        <div className="md:col-span-2">
          <TransactionsOverview />
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-4">
          <div>
            <h2 className="text-sm font-semibold text-slate-50 flex items-center gap-1">
              <span>🧑‍💼</span>
              <span>المستخدمون الجدد</span>
            </h2>
            <p className="mt-1 text-[11px] text-slate-400">
              آخر 5 مستخدمين انضمّوا للنظام.
            </p>
            {loading ? (
              <div className="mt-3 text-center text-xs text-slate-400">جاري التحميل...</div>
            ) : recentUsers.length === 0 ? (
              <div className="mt-3 text-center text-xs text-slate-400">لا توجد بيانات</div>
            ) : (
              <ul className="mt-3 space-y-2 text-[11px] text-slate-200">
                {recentUsers.map((user) => (
                  <li key={user.id} className="flex items-center justify-between border-b border-slate-800/70 pb-1.5">
                    <span className="truncate">{user.name}</span>
                    <span className="text-slate-400">{user.phone}</span>
                    <span className={`ml-1 rounded-full px-2 py-0.5 text-[10px] border ${
                      user.isActive 
                        ? "bg-emerald-500/15 text-emerald-300 border-emerald-500/40"
                        : "bg-rose-500/15 text-rose-200 border-rose-500/40"
                    }`}>
                      {user.isActive ? "نشط" : "محظور"}
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </div>

          <div className="border-t border-slate-800 pt-3">
            <h2 className="text-sm font-semibold text-slate-50 flex items-center gap-1">
              <span>🏬</span>
              <span>المتاجر الجديدة</span>
            </h2>
            <p className="mt-1 text-[11px] text-slate-400">
              آخر 5 متاجر مسجّلة في النظام.
            </p>
            {loading ? (
              <div className="mt-3 text-center text-xs text-slate-400">جاري التحميل...</div>
            ) : recentStores.length === 0 ? (
              <div className="mt-3 text-center text-xs text-slate-400">لا توجد بيانات</div>
            ) : (
              <ul className="mt-3 space-y-2 text-[11px] text-slate-200">
                {recentStores.map((store) => (
                  <li key={store.id} className="flex items-center justify-between border-b border-slate-800/70 pb-1.5">
                    <span className="truncate">{store.name}</span>
                    <span className="text-slate-400">{store.category || "—"}</span>
                    <span className="ml-1 text-slate-500">{formatDate(store.createdAt)}</span>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </section>

      {/* جدول صغير لآخر 10 عمليات شراء */}
      <section className="mt-2">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <div className="flex items-center justify-between pb-2">
            <h2 className="text-sm font-semibold text-slate-50">
              آخر 10 عمليات شراء
            </h2>
            <span className="text-[11px] text-slate-400">
              متابعة سريعة لأحدث معاملات الشراء
            </span>
          </div>
          <div className="overflow-x-auto rounded-lg border border-slate-800 bg-[#031824]">
            <table className="min-w-full divide-y divide-slate-800 text-[11px]">
              <thead className="bg-[#041f2e] text-slate-300">
                <tr>
                  <th className="px-3 py-2 text-left font-medium">العميل</th>
                  <th className="px-3 py-2 text-left font-medium">المتجر</th>
                  <th className="px-3 py-2 text-right font-medium">المبلغ</th>
                  <th className="px-3 py-2 text-right font-medium">الحالة</th>
                  <th className="px-3 py-2 text-right font-medium">
                    تاريخ العملية
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 text-slate-100">
                <tr>
                  <td colSpan={5} className="px-3 py-8 text-center text-xs text-slate-400">
                    لا توجد عمليات شراء
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* قسم المعاملات المتأخرة */}
      <section className="mt-2 grid gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <h2 className="text-sm font-semibold text-slate-50 flex items-center gap-1">
            <span>🟪</span>
            <span>المعاملات المتأخرة</span>
          </h2>
          <p className="mt-1 text-[11px] text-slate-400">
            أهم العملاء الذين لديهم دفعات متأخرة تحتاج متابعة.
          </p>

          <div className="mt-3 overflow-x-auto rounded-lg border border-slate-800 bg-[#031824]">
            <table className="min-w-full divide-y divide-slate-800 text-[11px]">
              <thead className="bg-[#041f2e] text-slate-300">
                <tr>
                  <th className="px-3 py-2 text-left font-medium">العميل</th>
                  <th className="px-3 py-2 text-right font-medium">
                    المبلغ المستحق
                  </th>
                  <th className="px-3 py-2 text-right font-medium">
                    تاريخ الاستحقاق
                  </th>
                  <th className="px-3 py-2 text-right font-medium">
                    عدد الأيام المتأخرة
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 text-slate-100">
                <tr>
                  <td colSpan={4} className="px-3 py-8 text-center text-xs text-slate-400">
                    لا توجد معاملات متأخرة
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>
    </div>
  );
}

