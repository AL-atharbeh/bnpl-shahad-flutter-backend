"use client";

import { useEffect, useState } from "react";
import { getAllSettlements, updateSettlementStatus, getStoresBalances, createSettlement } from "@/services/api";

export default function SettlementsPage() {
  const [loading, setLoading] = useState(true);
  const [settlements, setSettlements] = useState<any[]>([]);
  const [balances, setBalances] = useState<any[]>([]);
  const [loadingBalances, setLoadingBalances] = useState(true);
  const [activeTab, setActiveTab] = useState<"balances" | "pending" | "completed">("balances");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [submitting, setSubmitting] = useState<number | null>(null);
  
  // Modal state for payout approval
  const [selectedSettlement, setSelectedSettlement] = useState<any | null>(null);
  const [payoutNotes, setPayoutNotes] = useState("");

  // Modal state for manual settlement
  const [selectedStoreForSettlement, setSelectedStoreForSettlement] = useState<any | null>(null);
  const [manualSettlementNotes, setManualSettlementNotes] = useState("");
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

  const handleManualSettlementClick = (store: any) => {
    setSelectedStoreForSettlement(store);
    setManualSettlementNotes(`تسوية يدوية للرصيد المستحق بقيمة ${store.outstandingBalance.toFixed(2)} د.أ`);
  };

  const handleConfirmManualSettlement = async () => {
    if (!selectedStoreForSettlement) return;
    try {
      setSubmittingManual(true);
      // Calculate share breakdowns
      const totalAmount = selectedStoreForSettlement.outstandingBalance;
      const bankShare = totalAmount * 0.03; // Standard 3%
      const platformShare = totalAmount * 0.02; // Standard 2%
      
      const res = await createSettlement({
        settlementDate: new Date(),
        totalCollected: totalAmount,
        bankShare,
        platformShare,
        notes: manualSettlementNotes,
        storeId: selectedStoreForSettlement.storeId,
      });
      
      if (res.data?.success) {
        setSelectedStoreForSettlement(null);
        setManualSettlementNotes("");
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

  return (
    <div className="space-y-6 text-right" dir="rtl">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-lg font-semibold text-slate-50">التسويات والنظام المحاسبي للمزودين 🏦</h1>
          <p className="mt-1 text-[12px] text-slate-400">
            متابعة أرصدة المتاجر، مستحقاتهم المعلقة، إجراء تسويات مبيعات مقدماً، ومطالعة أرشيف الحوالات البنكية الصادرة.
          </p>
        </div>
      </div>

      {/* Quick Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="rounded-xl border border-slate-800 bg-[#032a39]/40 p-4">
          <p className="text-xs text-slate-400">إجمالي ديون المتاجر المستحقة حالياً</p>
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
                  <th className="px-4 py-3 font-semibold">الإجراءات</th>
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
                    <td className="px-4 py-3">
                      {b.outstandingBalance > 0 ? (
                        <button
                          onClick={() => handleManualSettlementClick(b)}
                          className="rounded-lg bg-emerald-500 hover:bg-emerald-600 px-3 py-1.5 text-[11px] font-semibold text-slate-900 transition-colors shadow-sm"
                        >
                          تسوية يدوية للرصيد
                        </button>
                      ) : (
                        <span className="text-[11px] text-slate-500">✅ الحساب مسوى</span>
                      )}
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

      {/* Manual Settlement Request Modal */}
      {selectedStoreForSettlement && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="w-full max-w-md rounded-xl border border-slate-800 bg-[#021f2a] p-6 shadow-2xl space-y-4">
            <h3 className="text-base font-bold text-slate-100 flex items-center gap-2">
              💵 تسوية يدوية للرصيد المستحق
            </h3>
            
            <p className="text-xs text-slate-400 leading-relaxed">
              أنت على وشك تحويل وتصفية مستحقات متجر <span className="font-semibold text-slate-200">{selectedStoreForSettlement.storeName}</span> بالكامل بقيمة:
              <span className="block text-lg font-black text-amber-400 mt-2">{selectedStoreForSettlement.outstandingBalance.toFixed(2)} د.أ</span>
            </p>

            <div className="space-y-1.5 text-right">
              <label className="text-[11px] text-slate-400">ملاحظات أو مرجع التحويل</label>
              <textarea
                value={manualSettlementNotes}
                onChange={(e) => setManualSettlementNotes(e.target.value)}
                className="w-full rounded-lg border border-slate-800 bg-slate-950 px-3 py-2 text-xs text-slate-200 placeholder-slate-600 focus:border-emerald-500 focus:outline-none min-h-[80px]"
                placeholder="اكتب تفاصيل التحويل أو أي ملاحظات للتسجيل..."
              />
            </div>

            <div className="flex gap-3 justify-end pt-2">
              <button
                onClick={() => setSelectedStoreForSettlement(null)}
                className="rounded-lg border border-slate-700 hover:bg-slate-800 px-4 py-2 text-xs font-semibold text-slate-300 transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleConfirmManualSettlement}
                disabled={submittingManual}
                className="rounded-lg bg-emerald-500 hover:bg-emerald-600 px-4 py-2 text-xs font-semibold text-slate-900 transition-colors"
              >
                {submittingManual ? "جاري التسوية..." : "تأكيد وإتمام التسوية اليدوية"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
