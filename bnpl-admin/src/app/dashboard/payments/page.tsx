"use client";

import { useEffect, useState } from "react";
import {
  getPaymentsStats,
  getAllPayments,
  getUpcomingPayments,
  manualCollectPayment,
  sendPaymentReminder,
  getAllBankTransfers,
  createBankTransfer,
} from "@/services/api";

const BANK_COMMISSION = 0.03; // 3%
const PLATFORM_COMMISSION = 0.02; // 2%

export default function PaymentsPage() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<any>(null);
  const [upcoming, setUpcoming] = useState<any>(null);
  const [payments, setPayments] = useState<any[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [storeFilter, setStoreFilter] = useState("");
  const [transfers, setTransfers] = useState<any[]>([]);
  const [showTransferForm, setShowTransferForm] = useState(false);
  const [transferAmount, setTransferAmount] = useState("");
  const [transferNotes, setTransferNotes] = useState("");
  const itemsPerPage = 10;

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);

      const [statsRes, upcomingRes, paymentsRes] = await Promise.all([
        getPaymentsStats(),
        getUpcomingPayments(),
        getAllPayments({ page: 1, limit: 100 }),
      ]);

      setStats(statsRes.data.data);
      setUpcoming(upcomingRes.data.data);
      setPayments(paymentsRes.data.data || []);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  const filteredPayments = payments.filter((p) => {
    // Search filter
    const matchesSearch =
      !searchQuery ||
      p.user?.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.store?.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.id?.toString().includes(searchQuery);

    // Status filter
    const matchesStatus = !statusFilter || p.status === statusFilter;

    // Store filter
    const matchesStore = !storeFilter || p.store?.id?.toString() === storeFilter;

    return matchesSearch && matchesStatus && matchesStore;
  });

  // Group payments by order to create order summary
  const orderSummary = payments.reduce((acc: any[], payment) => {
    const existingOrder = acc.find(o => o.orderId === payment.orderId);

    if (!existingOrder) {
      const totalOrderValue = Number(payment.amount) * payment.installmentsCount;
      const paidToStore = totalOrderValue * 0.95; // Bank pays 95% to store
      const bankCommission = totalOrderValue * BANK_COMMISSION; // 3%
      const remainingForBank = paidToStore + bankCommission; // What bank needs to collect
      const platformCommission = totalOrderValue * PLATFORM_COMMISSION; // 2%

      // Count completed installments
      const completedCount = payments.filter(
        p => p.orderId === payment.orderId && p.status === 'completed'
      ).length;

      const collectedAmount = completedCount * Number(payment.amount);

      acc.push({
        orderId: payment.orderId,
        storeName: payment.store?.nameAr || payment.store?.name || "غير معروف",
        customerName: payment.user?.name || "غير معروف",
        totalPrice: totalOrderValue,
        installmentsCount: payment.installmentsCount,
        paidToStore,
        remainingForBank,
        platformCommission,
        completedInstallments: completedCount,
        collectedAmount,
        currency: payment.currency || "JOD",
      });
    }

    return acc;
  }, []);

  const totalPages = Math.ceil(filteredPayments.length / itemsPerPage);
  const paginatedPayments = filteredPayments.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

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
        <h1 className="text-lg font-semibold text-slate-50">إدارة الدفعات</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          نحصّل أقساط العملاء، نقتطع عمولتنا، ثم نحول المتبقي للبنك ليتولى تسوية المتجر.
        </p>
      </div>

      {/* Overdue Alert */}
      {stats?.overdueOver7DaysCount > 0 && (
        <div className="rounded-xl border border-red-500/60 bg-gradient-to-r from-red-500/20 to-orange-500/20 p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <span className="text-2xl">⚠️</span>
              <div>
                <h3 className="text-sm font-semibold text-red-300">
                  تنبيه: دفعات متأخرة أكثر من 7 أيام!
                </h3>
                <p className="mt-1 text-xs text-slate-300">
                  {stats.overdueOver7DaysCount} دفعة متأخرة بإجمالي{" "}
                  {stats.overdueOver7DaysAmount?.toFixed(2)} دينار تحتاج متابعة عاجلة
                </p>
              </div>
            </div>
            <button
              onClick={() => setStatusFilter("pending")}
              className="rounded-lg bg-red-500 px-4 py-2 text-sm font-medium text-white hover:bg-red-600 transition-colors"
            >
              عرض المتأخرة
            </button>
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4">
        <div className="grid gap-4 md:grid-cols-3">
          <div>
            <label className="block text-xs text-slate-400 mb-2">الحالة</label>
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setCurrentPage(1);
              }}
              className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value="">الكل</option>
              <option value="pending">معلقة</option>
              <option value="completed">مكتملة</option>
              <option value="cancelled">ملغاة</option>
            </select>
          </div>

          <div>
            <label className="block text-xs text-slate-400 mb-2">المتجر</label>
            <select
              value={storeFilter}
              onChange={(e) => {
                setStoreFilter(e.target.value);
                setCurrentPage(1);
              }}
              className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value="">كل المتاجر</option>
              {Array.from(new Set(payments.map((p) => p.store?.id))).map(
                (storeId) => {
                  const store = payments.find((p) => p.store?.id === storeId)?.store;
                  return store ? (
                    <option key={storeId} value={storeId}>
                      {store.nameAr || store.name}
                    </option>
                  ) : null;
                }
              )}
            </select>
          </div>

          <div>
            <label className="block text-xs text-slate-400 mb-2">بحث</label>
            <input
              type="text"
              placeholder="ابحث بالعميل أو المتجر..."
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setCurrentPage(1);
              }}
              className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </div>
        </div>
      </div>

      {/* Statistics Cards */}
      <section className="grid gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>📅</span>
            <span>إجمالي الدفعات المستحقة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalDue?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {stats?.pendingCount || 0} دفعة معلقة
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>✅</span>
            <span>تم تحصيلها</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalCollected?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {stats?.collectedCount || 0} دفعة (آخر 48 ساعة)
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⚠️</span>
            <span>دفعات متأخرة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalOverdue?.toLocaleString() || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            {stats?.overdueCount || 0} دفعة تحتاج متابعة
          </p>
        </div>
      </section>

      {/* Detailed Financial Statistics */}
      <section className="grid gap-4 md:grid-cols-5">
        <div className="rounded-xl border border-blue-500/60 bg-gradient-to-br from-blue-500 to-blue-400 p-4 shadow-[0_18px_40px_rgba(59,130,246,0.6)]">
          <p className="text-xs text-slate-950 font-medium flex items-center gap-1">
            <span>🏦</span>
            <span>إجمالي ما دفعه البنك</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-950">
            {stats?.bankTotalPaid?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-blue-900">للمتاجر (95%)</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>💰</span>
            <span>إجمالي ما حصّله البنك</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.bankTotalCollected?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">من المستخدمين</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>📊</span>
            <span>الباقي للبنك</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.bankTotalRemaining?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">سيتم تحصيله</p>
        </div>

        <div className="rounded-xl border border-emerald-500/60 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 shadow-[0_18px_40px_rgba(16,185,129,0.6)]">
          <p className="text-xs text-slate-950 font-medium flex items-center gap-1">
            <span>✅</span>
            <span>حصّلته المنصة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-950">
            {stats?.platformTotalCollected?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-emerald-900">لحد الآن (2%)</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⏳</span>
            <span>ستحصّله المنصة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.platformTotalRemaining?.toFixed(2) || 0} دينار
          </p>
          <p className="mt-1 text-[11px] text-slate-300">من المعلق (2%)</p>
        </div>
      </section >

      {/* Timeline */}
      < div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]" >
        <h2 className="text-sm font-semibold text-slate-50">
          خط زمني للدفعات القادمة
        </h2>
        <p className="mt-1 text-[11px] text-slate-400">
          يوضح عدد الأقساط المستحقة خلال الأيام القادمة ونسبة المدفوع منها.
        </p>

        <div className="mt-4 grid gap-3 md:grid-cols-3">
          <div className="rounded-lg border border-slate-800 bg-[#031824] p-3">
            <p className="text-xs text-slate-400">اليوم</p>
            <p className="mt-1 text-lg font-semibold text-slate-50">
              {upcoming?.today?.count || 0} دفعات مستحقة
            </p>
            <p className="mt-1 text-[11px] text-emerald-400">
              مدفوعة: {upcoming?.today?.paid || 0}
            </p>
          </div>

          <div className="rounded-lg border border-slate-800 bg-[#031824] p-3">
            <p className="text-xs text-slate-400">غدًا</p>
            <p className="mt-1 text-lg font-semibold text-slate-50">
              {upcoming?.tomorrow?.count || 0} دفعات مستحقة
            </p>
            <p className="mt-1 text-[11px] text-emerald-400">
              مدفوعة: {upcoming?.tomorrow?.paid || 0}
            </p>
          </div>

          <div className="rounded-lg border border-slate-800 bg-[#031824] p-3">
            <p className="text-xs text-slate-400">بعد غد</p>
            <p className="mt-1 text-lg font-semibold text-slate-50">
              {upcoming?.dayAfter?.count || 0} دفعات مستحقة
            </p>
            <p className="mt-1 text-[11px] text-emerald-400">
              مدفوعة: {upcoming?.dayAfter?.paid || 0}
            </p>
          </div>
        </div>

        {/* Upcoming Payments List */}
        {
          upcoming?.upcomingPayments && upcoming.upcomingPayments.length > 0 && (
            <div className="mt-4 border-t border-slate-800 pt-4">
              <h3 className="text-xs font-semibold text-slate-300 mb-3">
                أقرب الدفعات القادمة
              </h3>
              <div className="space-y-2">
                {upcoming.upcomingPayments.map((payment: any) => (
                  <div
                    key={payment.id}
                    className="flex items-center justify-between rounded-lg border border-slate-800 bg-[#031824] p-3"
                  >
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className="font-semibold text-slate-50 text-xs">
                          {payment.customer}
                        </span>
                        <span className="text-[10px] text-slate-500">•</span>
                        <span className="text-[11px] text-slate-400">
                          {payment.store}
                        </span>
                      </div>
                      <div className="mt-1 text-[11px] text-slate-500">
                        القسط {payment.installmentNumber}/{payment.installmentsCount}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="font-semibold text-emerald-400 text-xs">
                        {payment.amount} JOD
                      </div>
                      <div className="mt-1 text-[10px] text-slate-400">
                        {new Date(payment.dueDate).toLocaleDateString("ar", {
                          month: "short",
                          day: "numeric",
                        })}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )
        }
      </div >

      {/* Settings */}
      < div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]" >
        <h2 className="text-sm font-semibold text-slate-50">
          إعدادات التحصيل والتحويل
        </h2>
        <p className="mt-1 text-[11px] text-slate-400">
          نضبط هذه النسب بحيث نقتطع عمولتنا من الدفعات ونحوّل المتبقي للبنك تلقائيًا.
        </p>

        <div className="mt-4 grid gap-3 md:grid-cols-2">
          <div className="rounded-lg border border-slate-800 bg-[#031824] p-3">
            <p className="text-xs text-slate-400">خصم عمولة المنصة</p>
            <p className="mt-1 text-2xl font-semibold text-emerald-400">
              {PLATFORM_COMMISSION * 100}%
            </p>
            <p className="mt-1 text-[11px] text-slate-500">
              تُقتطع قبل تحويل المبلغ للبنك
            </p>
          </div>

          <div className="rounded-lg border border-slate-800 bg-[#031824] p-3">
            <p className="text-xs text-slate-400">تحويل حصة البنك</p>
            <p className="mt-1 text-2xl font-semibold text-blue-400">
              {BANK_COMMISSION * 100}%
            </p>
            <p className="mt-1 text-[11px] text-slate-500">
              تُحوّل بعد خصم عمولتنا وبشكل يومي
            </p>
          </div>
        </div>
      </div >

      {/* Actions */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]" >
        <div className="flex items-center justify-between">
          <p className="text-sm text-slate-400">
            عرض {paginatedPayments.length} من {filteredPayments.length} دفعة
          </p>
          <div className="flex items-center gap-2">
            <button
              onClick={fetchData}
              className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
            >
              🔄 تحديث
            </button>
            <button
              onClick={() => {
                // Simple CSV export
                const headers = ["الدفعة", "العميل", "المتجر", "القسط", "المبلغ", "الحالة", "تاريخ الاستحقاق"];
                const rows = filteredPayments.map(p => [
                  p.id,
                  p.user?.name || "",
                  p.store?.nameAr || p.store?.name || "",
                  `${p.installmentNumber}/${p.installmentsCount}`,
                  p.amount,
                  p.status === "completed" ? "مكتملة" : p.status === "pending" ? "معلقة" : "ملغاة",
                  new Date(p.dueDate).toLocaleDateString("ar")
                ]);
                const csv = [headers, ...rows].map(row => row.join(",")).join("\n");
                const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
                const link = document.createElement("a");
                link.href = URL.createObjectURL(blob);
                link.download = `payments_${new Date().toISOString().split("T")[0]}.csv`;
                link.click();
              }}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 transition-colors"
            >
              📥 تصدير Excel
            </button>
          </div>
        </div>
      </div >

      {/* Table */}
      < div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden" >
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800 text-xs">
            <thead className="bg-[#041f2e] text-slate-300">
              <tr>
                <th className="px-3 py-3 text-right">الدفعة</th>
                <th className="px-3 py-3 text-right">العميل</th>
                <th className="px-3 py-3 text-right">المتجر</th>
                <th className="px-3 py-3 text-right">القسط</th>
                <th className="px-3 py-3 text-right">تاريخ الاستحقاق</th>
                <th className="px-3 py-3 text-right">مبلغ القسط</th>
                <th className="px-3 py-3 text-right">إجمالي الطلب</th>
                <th className="px-3 py-3 text-right">توزيع الإجمالي</th>
                <th className="px-3 py-3 text-right">الحالة</th>
                <th className="px-3 py-3 text-right">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-200">
              {paginatedPayments.length === 0 ? (
                <tr>
                  <td
                    colSpan={9}
                    className="px-4 py-8 text-center text-slate-400"
                  >
                    لا توجد دفعات مطابقة للاستعلام الحالي.
                  </td>
                </tr>
              ) : (
                paginatedPayments.map((payment) => {
                  const installmentAmount = Number(payment.amount);
                  const totalOrderValue = installmentAmount * payment.installmentsCount;

                  // Commission calculations based on TOTAL order value
                  const bankPrincipal = totalOrderValue * 0.95; // Bank pays 95% to store
                  const bankCommission = totalOrderValue * BANK_COMMISSION; // 3%
                  const bankTotal = bankPrincipal + bankCommission;
                  const platformCommission = totalOrderValue * PLATFORM_COMMISSION; // 2%

                  const dueDate = payment.isPostponed && payment.postponedDueDate
                    ? payment.postponedDueDate
                    : payment.dueDate;

                  return (
                    <tr
                      key={payment.id}
                      className="hover:bg-slate-900/40 transition-colors"
                    >
                      <td className="px-3 py-3">
                        <div className="font-semibold text-slate-50">
                          #{payment.id}
                        </div>
                        <div className="text-[11px] text-slate-400">
                          {payment.orderId}
                        </div>
                      </td>
                      <td className="px-3 py-3">
                        {payment.user?.name || "غير معروف"}
                      </td>
                      <td className="px-3 py-3 text-slate-300">
                        {payment.store?.nameAr || payment.store?.name || "غير معروف"}
                      </td>
                      <td className="px-3 py-3">
                        <span className="text-slate-50">
                          {payment.installmentNumber}/{payment.installmentsCount}
                        </span>
                      </td>
                      <td className="px-3 py-3 text-[11px] text-slate-400">
                        {dueDate
                          ? new Date(dueDate).toLocaleDateString("ar")
                          : "-"}
                      </td>
                      <td className="px-3 py-3">
                        <span className="font-semibold text-slate-50">
                          {installmentAmount.toLocaleString()} {payment.currency || "JOD"}
                        </span>
                      </td>
                      <td className="px-3 py-3">
                        <span className="font-semibold text-emerald-400">
                          {totalOrderValue.toLocaleString()} {payment.currency || "JOD"}
                        </span>
                        <div className="text-[11px] text-slate-400 mt-1">
                          {payment.installmentsCount} أقساط
                        </div>
                      </td>
                      <td className="px-3 py-3 text-[11px] text-slate-300">
                        <p className="mb-1">
                          💰 الإجمالي:{" "}
                          <span className="text-emerald-400 font-semibold">
                            {totalOrderValue.toFixed(2)}
                          </span>
                        </p>
                        <p className="mb-1">
                          🏦 البنك:{" "}
                          <span className="text-blue-400 font-semibold">
                            {bankTotal.toFixed(2)}
                          </span>
                          <span className="text-slate-500 text-[10px]"> ({bankPrincipal.toFixed(0)} + {bankCommission.toFixed(0)})</span>
                        </p>
                        <p>
                          🧾 المنصة:{" "}
                          <span className="text-slate-100 font-semibold">
                            {platformCommission.toFixed(2)}
                          </span>
                        </p>
                      </td>
                      <td className="px-3 py-3">
                        <span
                          className={`inline-flex rounded-full px-3 py-1 text-[10px] font-medium border ${payment.status === "completed"
                            ? "bg-emerald-500/15 text-emerald-300 border-emerald-500/40"
                            : payment.status === "pending"
                              ? "bg-amber-500/15 text-amber-200 border-amber-500/40"
                              : "bg-red-500/15 text-red-300 border-red-500/40"
                            }`}
                        >
                          {payment.status === "completed"
                            ? "مكتملة"
                            : payment.status === "pending"
                              ? "معلقة"
                              : "ملغاة"}
                        </span>
                      </td>
                      <td className="px-3 py-3">
                        {payment.status === "pending" && (
                          <div className="flex items-center gap-1">
                            <button
                              onClick={async () => {
                                if (confirm("تحصيل هذه الدفعة للبنك؟")) {
                                  try {
                                    await manualCollectPayment(payment.id);
                                    alert("تم التحصيل!");
                                    fetchData();
                                  } catch (e) {
                                    alert("فشل!");
                                  }
                                }
                              }}
                              className="rounded bg-emerald-500 px-2 py-1 text-[10px] text-white hover:bg-emerald-600"
                              title="تحصيل"
                            >
                              💰
                            </button>
                            <button
                              onClick={async () => {
                                if (confirm("إرسال تذكير؟")) {
                                  try {
                                    await sendPaymentReminder(payment.id);
                                    alert("تم الإرسال!");
                                  } catch (e) {
                                    alert("فشل!");
                                  }
                                }
                              }}
                              className="rounded bg-blue-500 px-2 py-1 text-[10px] text-white hover:bg-blue-600"
                              title="تذكير"
                            >
                              🔔
                            </button>
                          </div>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {
          totalPages > 1 && (
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
                  {Array.from({ length: Math.min(totalPages, 5) }, (_, i) => i + 1).map(
                    (page) => (
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
                    )
                  )}
                  <button
                    onClick={() =>
                      setCurrentPage((p) => Math.min(totalPages, p + 1))
                    }
                    disabled={currentPage === totalPages}
                    className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-300 hover:bg-slate-900 disabled:opacity-40"
                  >
                    التالي
                  </button>
                </div>
              </div>
            </div>
          )
        }
      </div >

      {/* Order Summary Table */}
      < div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]" >
        <h2 className="text-sm font-semibold text-slate-50 mb-4">
          ملخص الطلبات - التفصيل المالي الكامل
        </h2>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800 text-xs">
            <thead className="bg-[#041f2e] text-slate-300">
              <tr>
                <th className="px-3 py-3 text-right">رقم الطلب</th>
                <th className="px-3 py-3 text-right">المتجر</th>
                <th className="px-3 py-3 text-right">العميل</th>
                <th className="px-3 py-3 text-right">سعر المنتج</th>
                <th className="px-3 py-3 text-right">عدد الأقساط</th>
                <th className="px-3 py-3 text-right">المدفوع للمتجر</th>
                <th className="px-3 py-3 text-right">الباقي للبنك</th>
                <th className="px-3 py-3 text-right">حصة المنصة</th>
                <th className="px-3 py-3 text-right">التقدم</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-200">
              {orderSummary.length === 0 ? (
                <tr>
                  <td
                    colSpan={9}
                    className="px-4 py-8 text-center text-slate-400"
                  >
                    لا توجد طلبات
                  </td>
                </tr>
              ) : (
                orderSummary.map((order) => (
                  <tr
                    key={order.orderId}
                    className="hover:bg-slate-900/40 transition-colors"
                  >
                    <td className="px-3 py-3">
                      <div className="text-[11px] text-slate-400 font-mono">
                        {order.orderId}
                      </div>
                    </td>
                    <td className="px-3 py-3">
                      <span className="font-semibold text-slate-50">
                        {order.storeName}
                      </span>
                    </td>
                    <td className="px-3 py-3 text-slate-300">
                      {order.customerName}
                    </td>
                    <td className="px-3 py-3">
                      <span className="font-semibold text-emerald-400">
                        {order.totalPrice.toLocaleString()} {order.currency}
                      </span>
                    </td>
                    <td className="px-3 py-3 text-center">
                      <span className="rounded-full bg-slate-800 px-2 py-1 text-[10px] font-semibold">
                        {order.installmentsCount} أقساط
                      </span>
                    </td>
                    <td className="px-3 py-3">
                      <div className="text-slate-50 font-semibold">
                        {order.paidToStore.toFixed(2)} {order.currency}
                      </div>
                      <div className="text-[10px] text-slate-500">
                        (95% من الإجمالي)
                      </div>
                    </td>
                    <td className="px-3 py-3">
                      <div className="text-blue-400 font-semibold">
                        {order.remainingForBank.toFixed(2)} {order.currency}
                      </div>
                      <div className="text-[10px] text-slate-500">
                        محصّل: {order.collectedAmount.toFixed(0)}
                      </div>
                    </td>
                    <td className="px-3 py-3">
                      <div className="text-emerald-400 font-semibold">
                        {order.platformCommission.toFixed(2)} {order.currency}
                      </div>
                      <div className="text-[10px] text-slate-500">
                        (2% من الإجمالي)
                      </div>
                    </td>
                    <td className="px-3 py-3">
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-2 rounded-full bg-slate-800 overflow-hidden">
                          <div
                            className="h-full bg-emerald-500 transition-all"
                            style={{
                              width: `${(order.completedInstallments / order.installmentsCount) * 100}%`,
                            }}
                          />
                        </div>
                        <span className="text-[10px] text-slate-400 whitespace-nowrap">
                          {order.completedInstallments}/{order.installmentsCount}
                        </span>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div >

      {/* Per-Installment Commission Breakdown */}
      < div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]" >
        <h2 className="text-sm font-semibold text-slate-50 mb-4">
          توزيع العمولات لكل دفعة
        </h2>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800 text-xs">
            <thead className="bg-[#041f2e] text-slate-300">
              <tr>
                <th className="px-3 py-3 text-right">رقم الدفعة</th>
                <th className="px-3 py-3 text-right">الطلب</th>
                <th className="px-3 py-3 text-right">القسط</th>
                <th className="px-3 py-3 text-right">المبلغ</th>
                <th className="px-3 py-3 text-right">حصة البنك</th>
                <th className="px-3 py-3 text-right">حصة المنصة</th>
                <th className="px-3 py-3 text-right">الحالة</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-200">
              {paginatedPayments.length === 0 ? (
                <tr>
                  <td
                    colSpan={8}
                    className="px-4 py-8 text-center text-slate-400"
                  >
                    لا توجد دفعات
                  </td>
                </tr>
              ) : (
                paginatedPayments.map((payment) => {
                  const installmentAmount = Number(payment.amount);
                  const totalOrderValue = installmentAmount * payment.installmentsCount;

                  // Per-installment share calculation
                  const bankSharePerInstallment = (totalOrderValue * (0.95 + BANK_COMMISSION)) / payment.installmentsCount;
                  const platformSharePerInstallment = (totalOrderValue * PLATFORM_COMMISSION) / payment.installmentsCount;

                  return (
                    <tr
                      key={payment.id}
                      className="hover:bg-slate-900/40 transition-colors"
                    >
                      <td className="px-3 py-3">
                        <span className="font-semibold text-slate-50">
                          #{payment.id}
                        </span>
                      </td>
                      <td className="px-3 py-3">
                        <div className="text-[11px] text-slate-400 font-mono">
                          {payment.orderId}
                        </div>
                      </td>
                      <td className="px-3 py-3">
                        <span className="rounded-full bg-slate-800 px-2 py-1 text-[10px]">
                          {payment.installmentNumber}/{payment.installmentsCount}
                        </span>
                      </td>
                      <td className="px-3 py-3">
                        <span className="font-semibold text-emerald-400">
                          {installmentAmount.toLocaleString()} {payment.currency || "JOD"}
                        </span>
                      </td>
                      <td className="px-3 py-3">
                        <div className="text-blue-400 font-semibold">
                          {bankSharePerInstallment.toFixed(2)} {payment.currency || "JOD"}
                        </div>
                        <div className="text-[10px] text-slate-500">
                          من إجمالي {totalOrderValue} JOD
                        </div>
                      </td>
                      <td className="px-3 py-3">
                        <div className="text-emerald-400 font-semibold">
                          {platformSharePerInstallment.toFixed(2)} {payment.currency || "JOD"}
                        </div>
                        <div className="text-[10px] text-slate-500">
                          من إجمالي {totalOrderValue} JOD
                        </div>
                      </td>
                      <td className="px-3 py-3">
                        <span
                          className={`inline-flex rounded-full px-3 py-1 text-[10px] font-medium border ${payment.status === "completed"
                            ? "bg-emerald-500/15 text-emerald-300 border-emerald-500/40"
                            : payment.status === "pending"
                              ? "bg-amber-500/15 text-amber-200 border-amber-500/40"
                              : "bg-red-500/15 text-red-300 border-red-500/40"
                            }`}
                        >
                          {payment.status === "completed"
                            ? "مكتملة"
                            : payment.status === "pending"
                              ? "معلقة"
                              : "ملغاة"}
                        </span>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div >
    </div >
  );
}
