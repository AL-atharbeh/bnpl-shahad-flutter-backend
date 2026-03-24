"use client";

import { useEffect, useState } from "react";
import {
  ResponsiveContainer,
  Bar,
  BarChart,
  Tooltip,
  CartesianGrid,
  XAxis,
  YAxis,
  Legend,
} from "recharts";
import {
  getSessionsStats,
  getAllSessions,
  getSessionsChartData,
  getPostponementsStats,
  getAllPostponements,
  getPostponementsChartData,
} from "@/services/api";

export default function TransactionsPage() {
  const [loading, setLoading] = useState(true);
  const [sessionsStats, setSessionsStats] = useState<any>(null);
  const [postponementsStats, setPostponementsStats] = useState<any>(null);
  const [sessions, setSessions] = useState<any[]>([]);
  const [postponements, setPostponements] = useState<any[]>([]);
  const [chartData, setChartData] = useState<any[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState("");
  const itemsPerPage = 10;

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);

      // Fetch statistics
      const [sessionsStatsRes, postponementsStatsRes] = await Promise.all([
        getSessionsStats(),
        getPostponementsStats(),
      ]);

      setSessionsStats(sessionsStatsRes.data.data);
      setPostponementsStats(postponementsStatsRes.data.data);

      // Fetch sessions and postponements
      const [sessionsRes, postponementsRes] = await Promise.all([
        getAllSessions({ page: 1, limit: 100 }),
        getAllPostponements({ page: 1, limit: 100 }),
      ]);

      setSessions(sessionsRes.data.data || []);
      setPostponements(postponementsRes.data.data || []);

      // Fetch chart data
      const [sessionsChartRes, postponementsChartRes] = await Promise.all([
        getSessionsChartData(),
        getPostponementsChartData(),
      ]);

      // Combine chart data
      const sessionsChart = sessionsChartRes.data.data || [];
      const postponementsChart = postponementsChartRes.data.data || [];

      const combined = sessionsChart.map((item: any, index: number) => ({
        day: item.day,
        purchases: item.count || 0,
        postponements: postponementsChart[index]?.count || 0,
      }));

      setChartData(combined);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  // Combine sessions and postponements for table
  const combinedTransactions = [
    ...sessions.map((s: any) => ({
      id: s.sessionId,
      type: "شراء",
      customer: s.user?.name || s.customerName || "غير معروف",
      store: s.store?.nameAr || s.store?.name || "غير معروف",
      amount: Number(s.totalAmount),
      currency: s.currency || "JOD",
      status: s.status === "approved" ? "موافق عليه" : s.status === "pending" ? "معلق" : "مرفوض",
      statusColor: s.status === "approved" ? "emerald" : s.status === "pending" ? "amber" : "red",
      date: new Date(s.createdAt).toLocaleDateString("ar"),
      installments: `${s.installmentsCount} أقساط`,
    })),
    ...postponements.map((p: any) => ({
      id: `P-${p.id}`,
      type: "تأجيل",
      customer: p.payment?.user?.name || "غير معروف",
      store: p.merchantName || p.payment?.store?.nameAr || "غير معروف",
      amount: Number(p.amount),
      currency: "JOD",
      status: p.isFree ? "تأجيل مجاني" : "تأجيل مدفوع",
      statusColor: p.isFree ? "emerald" : "amber",
      date: new Date(p.createdAt).toLocaleDateString("ar"),
      installments: `${p.daysPostponed} يوم`,
    })),
  ];

  const filteredTransactions = combinedTransactions.filter((tx) =>
    tx.customer.includes(searchQuery) ||
    tx.store.includes(searchQuery) ||
    tx.id.includes(searchQuery)
  );

  const totalPages = Math.ceil(filteredTransactions.length / itemsPerPage);
  const paginatedTransactions = filteredTransactions.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const statusStyles = {
    emerald: "bg-emerald-500/15 text-emerald-300 border-emerald-500/40",
    amber: "bg-amber-500/15 text-amber-200 border-amber-500/40",
    red: "bg-red-500/15 text-red-300 border-red-500/40",
  };

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
        <h1 className="text-lg font-semibold text-slate-50">المعاملات</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          متابعة عمليات الشراء والتأجيلات مع مراقبة الحالات.
        </p>
      </div>

      {/* Statistics Cards */}
      <section className="grid gap-4 md:grid-cols-5">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🧾</span>
            <span>إجمالي الجلسات</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {sessionsStats?.totalSessions || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">جميع الجلسات</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🛒</span>
            <span>جلسات جديدة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {sessionsStats?.newSessions || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">آخر 7 أيام</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💳</span>
            <span>التأجيلات</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {postponementsStats?.totalPostponements || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {postponementsStats?.freePostponements || 0} مجاني
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⚠️</span>
            <span>الجلسات المعلقة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {sessionsStats?.pendingSessions || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">بحاجة متابعة</p>
        </div>

        <div className="rounded-xl border border-emerald-500/60 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 shadow-[0_18px_40px_rgba(16,185,129,0.6)]">
          <p className="text-xs text-slate-950 font-medium flex items-center gap-1">
            <span>💰</span>
            <span>إجمالي القيمة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-950">
            {sessionsStats?.totalTransactionValue?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-emerald-900">
            الجلسات الموافق عليها
          </p>
        </div>
      </section>

      {/* Chart */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
        <div className="flex items-center justify-between pb-3">
          <div>
            <h2 className="text-sm font-semibold text-slate-50">
              حجم المعاملات حسب اليوم
            </h2>
            <p className="mt-1 text-[11px] text-slate-400">
              مقارنة بين الشراء والتأجيلات خلال الأسبوع.
            </p>
          </div>
          <span className="rounded-full border border-slate-700 bg-slate-900/70 px-3 py-1 text-[11px] text-slate-300">
            أحدث 7 أيام
          </span>
        </div>
        <div className="mt-4 h-64 rounded-lg border border-slate-800 bg-[#031824] px-3 py-3">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chartData}>
              <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" />
              <XAxis dataKey="day" stroke="#9ca3af" tick={{ fontSize: 11 }} />
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
              <Bar dataKey="purchases" name="شراء" fill="#22c55e" />
              <Bar dataKey="postponements" name="تأجيلات" fill="#38bdf8" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div className="relative flex-1">
            <input
              type="text"
              placeholder="ابحث برقم المعاملة، العميل، أو المتجر..."
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setCurrentPage(1);
              }}
              className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
              🔍
            </span>
          </div>
          <button
            onClick={fetchData}
            className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
          >
            🔄 تحديث
          </button>
        </div>
        <div className="mt-3 text-xs text-slate-400">
          عرض {paginatedTransactions.length} من {filteredTransactions.length} معاملة
        </div>
      </div>

      {/* Table */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800 text-xs">
            <thead className="bg-[#041f2e] text-slate-300">
              <tr>
                <th className="px-3 py-3 text-right">المعاملة</th>
                <th className="px-3 py-3 text-right">النوع</th>
                <th className="px-3 py-3 text-right">العميل</th>
                <th className="px-3 py-3 text-right">المتجر</th>
                <th className="px-3 py-3 text-right">المبلغ</th>
                <th className="px-3 py-3 text-right">التفاصيل</th>
                <th className="px-3 py-3 text-right">الحالة</th>
                <th className="px-3 py-3 text-right">التاريخ</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-200">
              {paginatedTransactions.length === 0 ? (
                <tr>
                  <td
                    colSpan={8}
                    className="px-4 py-8 text-center text-slate-400"
                  >
                    لا توجد معاملات مطابقة للبحث الحالي.
                  </td>
                </tr>
              ) : (
                paginatedTransactions.map((tx) => (
                  <tr
                    key={tx.id}
                    className="hover:bg-slate-900/40 transition-colors"
                  >
                    <td className="px-3 py-3">
                      <div className="font-semibold text-slate-50">{tx.id}</div>
                    </td>
                    <td className="px-3 py-3">
                      <span className="rounded-full border border-slate-700 bg-slate-900/60 px-2 py-0.5 text-[10px]">
                        {tx.type}
                      </span>
                    </td>
                    <td className="px-3 py-3">{tx.customer}</td>
                    <td className="px-3 py-3 text-slate-300">{tx.store}</td>
                    <td className="px-3 py-3">
                      <span className="font-semibold text-slate-50">
                        {tx.amount.toLocaleString()} {tx.currency}
                      </span>
                    </td>
                    <td className="px-3 py-3 text-[11px] text-slate-400">
                      {tx.installments}
                    </td>
                    <td className="px-3 py-3">
                      <span
                        className={`inline-flex rounded-full px-3 py-1 text-[10px] font-medium border ${statusStyles[tx.statusColor as keyof typeof statusStyles]
                          }`}
                      >
                        {tx.status}
                      </span>
                    </td>
                    <td className="px-3 py-3 text-[11px] text-slate-400">
                      {tx.date}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="border-t border-slate-800 bg-[#041f2e] px-4 py-3">
            <div className="flex items-center justify-between text-xs text-slate-400">
              <span>
                الصفحة {currentPage} من {totalPages}
              </span>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-300 hover:bg-slate-900 disabled:opacity-40"
                >
                  السابق
                </button>
                {Array.from({ length: Math.min(totalPages, 5) }, (_, i) => i + 1).map((page) => (
                  <button
                    key={page}
                    onClick={() => setCurrentPage(page)}
                    className={`rounded-lg px-3 py-1.5 ${currentPage === page
                        ? "bg-emerald-500 text-slate-950 font-semibold"
                        : "border border-slate-700 bg-slate-900/60 text-slate-300 hover:bg-slate-900"
                      }`}
                  >
                    {page}
                  </button>
                ))}
                <button
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                  className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-300 hover:bg-slate-900 disabled:opacity-40"
                >
                  التالي
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
