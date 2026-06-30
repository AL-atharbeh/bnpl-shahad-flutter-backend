"use client";

import { useEffect, useState } from "react";
import { getAllSettlements, updateSettlementStatus, getStoresBalances, createSettlement, getStoreOutstandingOrders } from "@/services/api";

export default function SettlementsPage() {
  const [loading, setLoading] = useState(true);
  const [settlements, setSettlements] = useState<any[]>([]);
  const [balances, setBalances] = useState<any[]>([]);
  const [loadingBalances, setLoadingBalances] = useState(true);
  const [activeTab, setActiveTab] = useState<"balances" | "pending" | "completed">("balances");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [submitting, setSubmitting] = useState<number | null>(null);
  
  // Payout Approval modal state (for pending requests)
  const [selectedSettlement, setSelectedSettlement] = useState<any | null>(null);
  const [payoutNotes, setPayoutNotes] = useState("");

  // Store Transactions Details modal state (for selective transaction settlement)
  const [activeStoreForDetails, setActiveStoreForDetails] = useState<any | null>(null);
  const [storeOrders, setStoreOrders] = useState<any[]>([]);
  const [loadingOrders, setLoadingOrders] = useState(false);
  const [selectedOrderIds, setSelectedOrderIds] = useState<number[]>([]);
  const [settlementNotes, setSettlementNotes] = useState("");
  const [submittingManual, setSubmittingManual] = useState(false);

  useEffect(() => {
    if (activeTab === "balances") {
      fetchStoreBalances();
    } else {
      fetchSettlements();
    }
  }, [activeTab, page]);

  const fetchStoreBalances = async () => {
    try {
      setLoadingBalances(true);
      const res = await getStoresBalances();
      if (res.data?.success) {
        setBalances(res.data.data || []);
      }
    } catch (err) {
      console.error("Failed to fetch store balances:", err);
    } finally {
      setLoadingBalances(false);
    }
  };

  const fetchSettlements = async () => {
    try {
      setLoading(true);
      const res = await getAllSettlements({
        page,
        limit: 20,
        status: activeTab === "balances" ? undefined : activeTab,
      });
      if (res.data?.success) {
        setSettlements(res.data.data.settlements || []);
        setTotalPages(res.data.data.totalPages || 1);
      }
    } catch (err) {
      console.error("Failed to fetch settlements:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleApproveClick = (settlement: any) => {
    setSelectedSettlement(settlement);
    setPayoutNotes(`تم تحويل المستحقات للمزود بنجاح عبر الحساب البنكي. مرجع التحويل: `);
  };

  const handleConfirmPayout = async () => {
    if (!selectedSettlement) return;
    try {
      setSubmitting(selectedSettlement.id);
      const res = await updateSettlementStatus(selectedSettlement.id, "completed", payoutNotes);
      if (res.data?.success) {
        setSelectedSettlement(null);
        setPayoutNotes("");
        fetchSettlements();
      }
    } catch (err: any) {
      alert("فشل في تأكيد التسوية: " + (err.response?.data?.message || err.message));
    } finally {
      setSubmitting(null);
    }
  };

  // Fetch outstanding orders for details view
  const handleViewDetailsClick = async (store: any) => {
    setActiveStoreForDetails(store);
    setStoreOrders([]);
    setSelectedOrderIds([]);
    setSettlementNotes(`تسوية دفعات مالية لمتجر ${store.storeName}`);
    
    try {
      setLoadingOrders(true);
      const res = await getStoreOutstandingOrders(store.storeId);
      if (res.data?.success) {
        const orders = res.data.data || [];
        setStoreOrders(orders);
        // Select all by default
        setSelectedOrderIds(orders.map((o: any) => o.id));
      }
    } catch (err) {
      console.error("Failed to fetch store outstanding orders:", err);
    } finally {
      setLoadingOrders(false);
    }
  };

  const handleToggleOrderSelection = (orderId: number) => {
    setSelectedOrderIds(prev => 
      prev.includes(orderId) ? prev.filter(id => id !== orderId) : [...prev, orderId]
    );
  };

  const handleToggleSelectAll = () => {
    if (selectedOrderIds.length === storeOrders.length) {
      setSelectedOrderIds([]);
    } else {
      setSelectedOrderIds(storeOrders.map(o => o.id));
    }
  };

  const handleConfirmManualSettlement = async () => {
    if (!activeStoreForDetails || selectedOrderIds.length === 0) return;
    try {
      setSubmittingManual(true);
      const res = await createSettlement({
        storeId: activeStoreForDetails.storeId,
        sessionIds: selectedOrderIds,
        notes: settlementNotes,
      });
      
      if (res.data?.success) {
        setActiveStoreForDetails(null);
        setSelectedOrderIds([]);
        setSettlementNotes("");
        fetchStoreBalances();
      }
    } catch (err: any) {
      alert("فشل في إجراء التسوية: " + (err.response?.data?.message || err.message));
    } finally {
      setSubmittingManual(false);
    }
  };

  // Quick stats calculations
  const pendingCount = activeTab === "pending" ? settlements.length : 0;
  const pendingTotal = activeTab === "pending" ? settlements.reduce((sum, s) => sum + Number(s.totalCollected || 0), 0) : 0;
  
  // Calculate total outstanding balance across all stores
  const totalOutstandingAllStores = balances.reduce((sum, b) => sum + Number(b.outstandingBalance || 0), 0);

  // Selected total calculations for manual payout modal
  const selectedGrossTotal = storeOrders
    .filter(o => selectedOrderIds.includes(o.id))
    .reduce((sum, o) => sum + Number(o.totalAmount || 0), 0);

  const selectedNetTotal = storeOrders
    .filter(o => selectedOrderIds.includes(o.id))
    .reduce((sum, o) => sum + Number(o.netAmount || 0), 0);

  const selectedPlatformCommission = storeOrders
    .filter(o => selectedOrderIds.includes(o.id))
    .reduce((sum, o) => sum + Number(o.platformShare || 0), 0);

  return (
    <div className="space-y-6 text-right" dir="rtl">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-lg font-semibold text-slate-50">التسويات والنظام المحاسبي للمزودين 🏦</h1>
          <p className="mt-1 text-[12px] text-slate-400">
            متابعة أرصدة المتاجر، مبيعاتهم، إجراء تسويات لكل عملية بيعية على حدة، ومطالعة أرشيف الحوالات المالية.
          </p>
        </div>
      </div>

      {/* Quick Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="rounded-xl border border-slate-800 bg-[#032a39]/40 p-4">
          <p className="text-xs text-slate-400">إجمالي مستحقات المتاجر المعلقة</p>
          <p className="mt-2 text-2xl font-bold text-amber-400">
            {totalOutstandingAllStores.toFixed(2)} <span className="text-xs font-normal">د.أ</span>
          </p>
          <p className="mt-1 text-[11px] text-slate-400">
            مجموع ما يجب تحويله للمزودين عن المبيعات النشطة
          </p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#032a39]/40 p-4">
          <p className="text-xs text-slate-400">طلبات سحب فورية معلقة</p>
          <p className="mt-2 text-2xl font-bold text-slate-50">
            {activeTab === "pending" ? pendingCount : "---"} <span className="text-xs font-normal">طلب</span>
          </p>
          <p className="mt-1 text-[11px] text-slate-400">بانتظار موافقة الإدارة والتحويل البنكي</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#032a39]/40 p-4">
          <p className="text-xs text-slate-400">مجموع عمولات المنصة المحتسبة</p>
          <p className="mt-2 text-2xl font-bold text-emerald-400">
            {balances.reduce((sum, b) => sum + Number(b.totalCommission || 0), 0).toFixed(2)} <span className="text-xs font-normal">د.أ</span>
          </p>
          <p className="mt-1 text-[11px] text-slate-400">إجمالي الأرباح المستقطعة كرسوم تشغيلية</p>
        </div>
      </div>

      {/* Tabs Nav */}
      <div className="flex border-b border-slate-800">
        <button
          onClick={() => { setActiveTab("balances"); setPage(1); }}
          className={`px-4 py-2.5 text-xs font-medium border-b-2 transition-all ${
            activeTab === "balances"
              ? "border-emerald-500 text-emerald-400 bg-emerald-500/5"
              : "border-transparent text-slate-400 hover:text-slate-200"
          }`}
        >
          أرصدة المتاجر والمستحقات
        </button>
        <button
          onClick={() => { setActiveTab("pending"); setPage(1); }}
          className={`px-4 py-2.5 text-xs font-medium border-b-2 transition-all ${
            activeTab === "pending"
              ? "border-emerald-500 text-emerald-400 bg-emerald-500/5"
              : "border-transparent text-slate-400 hover:text-slate-200"
          }`}
        >
          طلبات تسوية معلقة
        </button>
        <button
          onClick={() => { setActiveTab("completed"); setPage(1); }}
          className={`px-4 py-2.5 text-xs font-medium border-b-2 transition-all ${
            activeTab === "completed"
              ? "border-emerald-500 text-emerald-400 bg-emerald-500/5"
              : "border-transparent text-slate-400 hover:text-slate-200"
          }`}
        >
          سجل التسويات المكتملة
        </button>
      </div>

      {/* Table Container */}
      <div className="overflow-x-auto rounded-xl border border-slate-800 bg-[#032a39]/20">
        {activeTab === "balances" ? (
          loadingBalances ? (
            <div className="flex items-center justify-center h-48">
              <span className="text-slate-400 text-xs">جاري تحميل ميزانيات المتاجر المحاسبية...</span>
            </div>
          ) : balances.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-48 gap-2">
              <span className="text-2xl">🏦</span>
              <span className="text-slate-400 text-xs">لا يوجد متاجر مسجلة حالياً.</span>
            </div>
          ) : (
            <table className="w-full text-right text-xs">
              <thead className="bg-[#032a39]/50 text-slate-400">
                <tr>
                  <th className="px-4 py-3 font-semibold">المتجر (المزود)</th>
                  <th className="px-4 py-3 font-semibold">إجمالي المبيعات (د.أ)</th>
                  <th className="px-4 py-3 font-semibold">العمولات المستقطعة (د.أ)</th>
                  <th className="px-4 py-3 font-semibold">الصافي الإجمالي المستحق (د.أ)</th>
                  <th className="px-4 py-3 font-semibold">تم تحويله مسبقاً (د.أ)</th>
                  <th className="px-4 py-3 font-semibold">الرصيد المعلق (غير مدفوع)</th>
                  <th className="px-4 py-3 font-semibold text-center">الإجراءات</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 text-slate-300">
                {balances.map((b) => (
                  <tr key={b.storeId} className="hover:bg-[#032a39]/10">
                    <td className="px-4 py-3 font-medium text-slate-100">{b.storeName}</td>
                    <td className="px-4 py-3 font-mono">{b.totalGross.toFixed(2)}</td>
                    <td className="px-4 py-3 text-red-400 font-mono">-{b.totalCommission.toFixed(2)}</td>
                    <td className="px-4 py-3 text-slate-100 font-mono">{b.totalNetOwed.toFixed(2)}</td>
                    <td className="px-4 py-3 text-emerald-500 font-mono">+{b.totalPaid.toFixed(2)}</td>
                    <td className="px-4 py-3 font-bold text-amber-400 font-mono">
                      {b.outstandingBalance.toFixed(2)} د.أ
                    </td>
                    <td className="px-4 py-3 text-center flex items-center justify-center gap-2">
                      <button
                        onClick={() => handleViewDetailsClick(b)}
                        className="rounded-lg border border-slate-700 hover:bg-slate-800 px-3 py-1.5 text-[11px] font-semibold text-slate-200 transition-colors shadow-sm"
                      >
                        عرض تفاصيل المعاملات
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )
        ) : (
          loading ? (
            <div className="flex items-center justify-center h-48">
              <span className="text-slate-400 text-xs">جاري تحميل سجل التحويلات...</span>
            </div>
          ) : settlements.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-48 gap-2">
              <span className="text-2xl">🏦</span>
              <span className="text-slate-400 text-xs">لا توجد تسويات في هذا القسم.</span>
            </div>
          ) : (
            <table className="w-full text-right text-xs">
              <thead className="bg-[#032a39]/50 text-slate-400">
                <tr>
                  <th className="px-4 py-3 font-semibold">رقم العملية</th>
                  <th className="px-4 py-3 font-semibold">المتجر (المورد)</th>
                  <th className="px-4 py-3 font-semibold">تاريخ الطلب</th>
                  <th className="px-4 py-3 font-semibold">إجمالي حجم المبيعات (د.أ)</th>
                  <th className="px-4 py-3 font-semibold">حصة المنصة (2%)</th>
                  <th className="px-4 py-3 font-semibold">حصة البنك (3%)</th>
                  <th className="px-4 py-3 font-semibold">الصافي المحول (د.أ)</th>
                  <th className="px-4 py-3 font-semibold">الملاحظات وبيانات التحويل</th>
                  <th className="px-4 py-3 font-semibold">الإجراءات</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800 text-slate-300">
                {settlements.map((s) => {
                  const total = Number(s.totalCollected || 0);
                  const platform = Number(s.platformShare || 0);
                  const bank = Number(s.bankShare || 0);
                  const net = total - platform - bank;
                  const storeName = s.store?.nameAr || s.store?.name || "متجر غير معروف";

                  return (
                    <tr key={s.id} className="hover:bg-[#032a39]/10">
                      <td className="px-4 py-3 font-mono text-[11px] text-slate-400">#{s.id}</td>
                      <td className="px-4 py-3 font-medium text-slate-100">{storeName}</td>
                      <td className="px-4 py-3 text-slate-400">
                        {new Date(s.createdAt).toLocaleDateString("ar-EG", {
                          year: "numeric",
                          month: "short",
                          day: "numeric",
                          hour: "2-digit",
                          minute: "2-digit",
                        })}
                      </td>
                      <td className="px-4 py-3 font-semibold text-slate-100">{total.toFixed(2)}</td>
                      <td className="px-4 py-3 text-red-400">-{platform.toFixed(2)}</td>
                      <td className="px-4 py-3 text-amber-400">-{bank.toFixed(2)}</td>
                      <td className="px-4 py-3 font-bold text-emerald-400">{net.toFixed(2)}</td>
                      <td className="px-4 py-3 text-slate-400 max-w-xs truncate" title={s.notes}>
                        {s.notes || "لا توجد ملاحظات"}
                      </td>
                      <td className="px-4 py-3">
                        {s.status === "pending" ? (
                          <button
                            onClick={() => handleApproveClick(s)}
                            className="rounded-lg bg-emerald-500 hover:bg-emerald-600 px-3 py-1.5 text-[11px] font-semibold text-slate-900 transition-colors shadow-sm"
                          >
                            دفع وتسوية المستحقات
                          </button>
                        ) : (
                          <span className="inline-flex items-center gap-1 text-emerald-400 font-semibold">
                            ✅ تمت التسوية
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )
        )}
      </div>

      {/* Pagination (Only for settlements list tab) */}
      {activeTab !== "balances" && totalPages > 1 && (
        <div className="flex items-center justify-between border-t border-slate-800 pt-4">
          <button
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page === 1}
            className="rounded-lg border border-slate-700 px-3 py-1.5 text-xs text-slate-300 disabled:opacity-50 hover:bg-slate-800"
          >
            السابق
          </button>
          <span className="text-xs text-slate-400">
            الصفحة {page} من {totalPages}
          </span>
          <button
            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
            className="rounded-lg border border-slate-700 px-3 py-1.5 text-xs text-slate-300 disabled:opacity-50 hover:bg-slate-800"
          >
            التالي
          </button>
        </div>
      )}

      {/* Payout Approval Modal */}
      {selectedSettlement && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="w-full max-w-md rounded-xl border border-slate-800 bg-[#021f2a] p-6 shadow-2xl space-y-4">
            <h3 className="text-base font-bold text-slate-100 flex items-center gap-2">
              🏦 تأكيد تسوية ودفع المبيعات
            </h3>
            
            <p className="text-xs text-slate-400 leading-relaxed">
              أنت على وشك تأكيد دفع مستحقات التسوية رقم <span className="font-mono text-slate-200 font-semibold">#{selectedSettlement.id}</span>.
              يرجى كتابة رقم المرجع الخاص بالتحويل البنكي أو أي ملاحظات للتوثيق قبل الحفظ.
            </p>

            <div className="space-y-1.5 text-right">
              <label className="text-[11px] text-slate-400">ملاحظات وبيانات التحويل البنكي</label>
              <textarea
                value={payoutNotes}
                onChange={(e) => setPayoutNotes(e.target.value)}
                className="w-full rounded-lg border border-slate-800 bg-slate-950 px-3 py-2 text-xs text-slate-200 placeholder-slate-600 focus:border-emerald-500 focus:outline-none min-h-[80px]"
                placeholder="اكتب رقم العملية أو المرجع البنكي للتحويل..."
              />
            </div>

            <div className="flex gap-3 justify-end pt-2">
              <button
                onClick={() => setSelectedSettlement(null)}
                className="rounded-lg border border-slate-700 hover:bg-slate-800 px-4 py-2 text-xs font-semibold text-slate-300 transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleConfirmPayout}
                disabled={submitting !== null}
                className="rounded-lg bg-emerald-500 hover:bg-emerald-600 px-4 py-2 text-xs font-semibold text-slate-900 transition-colors"
              >
                {submitting !== null ? "جاري الحفظ..." : "تأكيد وإتمام التسوية"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Store Outstanding Transactions Details Modal */}
      {activeStoreForDetails && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="w-full max-w-4xl rounded-xl border border-slate-800 bg-[#021f2a] p-6 shadow-2xl flex flex-col max-h-[85vh]">
            <div className="flex items-center justify-between pb-3 border-b border-slate-800">
              <h3 className="text-base font-bold text-slate-100 flex items-center gap-2">
                🏦 العمليات غير المسواة لمتجر: {activeStoreForDetails.storeName}
              </h3>
              <button 
                onClick={() => setActiveStoreForDetails(null)}
                className="text-slate-400 hover:text-slate-200 text-lg font-bold"
              >
                ✕
              </button>
            </div>

            <div className="flex-1 overflow-y-auto my-4 space-y-4">
              {loadingOrders ? (
                <div className="flex items-center justify-center h-48">
                  <span className="text-slate-400 text-xs">جاري تحميل العمليات والعمولات الفردية...</span>
                </div>
              ) : storeOrders.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-48 gap-2">
                  <span className="text-2xl">🎉</span>
                  <span className="text-slate-400 text-xs">جميع مبيعات هذا المتجر تمت تسويتها بالكامل!</span>
                </div>
              ) : (
                <div className="space-y-4">
                  <p className="text-xs text-slate-400 leading-relaxed">
                    حدد العمليات (المبيعات) التي ترغب في تسويتها للمتجر الآن. سيتم حساب المجموع الصافي تلقائياً.
                  </p>

                  <div className="overflow-x-auto rounded-lg border border-slate-800 bg-slate-950">
                    <table className="w-full text-right text-xs">
                      <thead className="bg-[#032a39]/30 text-slate-400">
                        <tr>
                          <th className="px-3 py-2 text-center w-10">
                            <input 
                              type="checkbox"
                              checked={selectedOrderIds.length === storeOrders.length}
                              onChange={handleToggleSelectAll}
                              className="rounded border-slate-800 bg-slate-950 text-emerald-500 focus:ring-emerald-500 h-3.5 w-3.5"
                            />
                          </th>
                          <th className="px-3 py-2">رقم الطلب</th>
                          <th className="px-3 py-2">العميل</th>
                          <th className="px-3 py-2">تاريخ الشراء</th>
                          <th className="px-3 py-2">مبلغ البيع (د.أ)</th>
                          <th className="px-3 py-2">عمولة البنك (3%)</th>
                          <th className="px-3 py-2">عمولة المنصة (2%)</th>
                          <th className="px-3 py-2">الصافي للمتجر (د.أ)</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-800/50 text-slate-300">
                        {storeOrders.map((o) => (
                          <tr 
                            key={o.id}
                            onClick={() => handleToggleOrderSelection(o.id)}
                            className={`cursor-pointer hover:bg-[#032a39]/10 ${selectedOrderIds.includes(o.id) ? 'bg-[#032a39]/5' : ''}`}
                          >
                            <td className="px-3 py-2 text-center" onClick={(e) => e.stopPropagation()}>
                              <input 
                                type="checkbox"
                                checked={selectedOrderIds.includes(o.id)}
                                onChange={() => handleToggleOrderSelection(o.id)}
                                className="rounded border-slate-800 bg-slate-950 text-emerald-500 focus:ring-emerald-500 h-3.5 w-3.5"
                              />
                            </td>
                            <td className="px-3 py-2 font-mono text-[11px]">#{o.storeOrderId || o.sessionId.slice(-10)}</td>
                            <td className="px-3 py-2">{o.customerName}</td>
                            <td className="px-3 py-2 text-slate-400">
                              {new Date(o.createdAt).toLocaleDateString("ar-EG", {
                                month: "short",
                                day: "numeric",
                                hour: "2-digit",
                                minute: "2-digit"
                              })}
                            </td>
                            <td className="px-3 py-2 font-semibold font-mono">{o.totalAmount.toFixed(2)}</td>
                            <td className="px-3 py-2 text-amber-500 font-mono">-{o.bankShare.toFixed(2)}</td>
                            <td className="px-3 py-2 text-red-400 font-mono">-{o.platformShare.toFixed(2)}</td>
                            <td className="px-3 py-2 font-bold text-emerald-400 font-mono">{o.netAmount.toFixed(2)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </div>

            {/* Modal Footer / Action controls */}
            {storeOrders.length > 0 && (
              <div className="pt-3 border-t border-slate-800 space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3 bg-[#032a39]/10 rounded-xl p-3 border border-slate-800/40 text-center">
                  <div>
                    <span className="text-[10px] text-slate-400 block">إجمالي مبلغ المبيعات المحددة</span>
                    <span className="text-sm font-bold text-slate-100 font-mono">{selectedGrossTotal.toFixed(2)} د.أ</span>
                  </div>
                  <div>
                    <span className="text-[10px] text-slate-400 block">رسوم المنصة الإجمالية</span>
                    <span className="text-sm font-bold text-red-400 font-mono">{selectedPlatformCommission.toFixed(2)} د.أ</span>
                  </div>
                  <div>
                    <span className="text-[10px] text-slate-400 block">الصافي الإجمالي لتحويله للمتجر</span>
                    <span className="text-base font-black text-emerald-400 font-mono">{selectedNetTotal.toFixed(2)} د.أ</span>
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-[11px] text-slate-400">ملاحظات التحويل أو الإيصال البنكي</label>
                  <input
                    type="text"
                    value={settlementNotes}
                    onChange={(e) => setSettlementNotes(e.target.value)}
                    className="w-full rounded-lg border border-slate-800 bg-slate-950 px-3 py-2 text-xs text-slate-200 placeholder-slate-600 focus:border-emerald-500 focus:outline-none"
                    placeholder="اكتب مرجع الحوالة البنكية أو ملاحظات الدفع..."
                  />
                </div>

                <div className="flex gap-3 justify-end">
                  <button
                    onClick={() => setActiveStoreForDetails(null)}
                    className="rounded-lg border border-slate-700 hover:bg-slate-800 px-4 py-2 text-xs font-semibold text-slate-300 transition-colors"
                  >
                    إلغاء
                  </button>
                  <button
                    onClick={handleConfirmManualSettlement}
                    disabled={selectedOrderIds.length === 0 || submittingManual}
                    className="rounded-lg bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 px-4 py-2 text-xs font-semibold text-slate-900 transition-colors"
                  >
                    {submittingManual ? "جاري تسوية الدفعات..." : `تأكيد ودفع العمليات المحددة (${selectedOrderIds.length})`}
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
