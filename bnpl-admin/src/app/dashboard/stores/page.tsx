"use client";

import { useState, useEffect } from "react";
import { Store, storesService, StoreStats } from "@/services/stores.service";
import StoreModal from "@/components/modals/StoreModal";

const mockStoreTransactions: any[] = [];
const mockStorePayouts: any[] = [];

const statusColors = {
  emerald: "bg-emerald-500/15 text-emerald-300 border-emerald-500/40",
  red: "bg-red-500/15 text-red-300 border-red-500/40",
  amber: "bg-amber-500/15 text-amber-200 border-amber-500/40",
  slate: "bg-slate-500/15 text-slate-400 border-slate-500/40",
};

export default function StoresPage() {
  const [loading, setLoading] = useState(true);
  const [stores, setStores] = useState<Store[]>([]);
  const [stats, setStats] = useState<StoreStats | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("الكل");
  const [riskFilter, setRiskFilter] = useState("الكل");
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedStores, setSelectedStores] = useState<number[]>([]);
  const [selectedStore, setSelectedStore] = useState<Store | null>(null);
  const [showStoreModal, setShowStoreModal] = useState(false);
  const [selectedFeaturedStore, setSelectedFeaturedStore] = useState("");
  const [showAddStoreModal, setShowAddStoreModal] = useState(false);
  const itemsPerPage = 10;

  useEffect(() => {
    fetchStores();
    fetchStats();
  }, []);

  const fetchStores = async () => {
    setLoading(true);
    try {
      const result = await storesService.getAll();
      if (result && result.data) {
        setStores(result.data);
      } else if (Array.isArray(result)) {
        setStores(result);
      }
    } catch (error) {
      console.error("Failed to fetch stores", error);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const result = await storesService.getStats();
      setStats(result);
    } catch (error) {
      console.error("Failed to fetch stats", error);
    }
  };

  const filteredStores = stores.filter((store) => {
    const matchesSearch =
      store.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (store.category || "").toLowerCase().includes(searchQuery.toLowerCase()) ||
      (store.location || "").toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus =
      statusFilter === "الكل" || (store.isActive ? "نشط" : "غير نشط") === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const totalPages = Math.ceil(filteredStores.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedStores = filteredStores.slice(
    startIndex,
    startIndex + itemsPerPage
  );

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedStores(paginatedStores.map((s) => s.id));
    } else {
      setSelectedStores([]);
    }
  };

  const handleSelectStore = (storeId: number, checked: boolean) => {
    if (checked) {
      setSelectedStores([...selectedStores, storeId]);
    } else {
      setSelectedStores(selectedStores.filter((id) => id !== storeId));
    }
  };

  const handleBulkAction = (action: string) => {
    if (selectedStores.length === 0) return;
    alert(`سيتم تنفيذ "${action}" على ${selectedStores.length} متجر`);
    setSelectedStores([]);
  };

  const handleExport = () => {
    alert("سيتم تصدير بيانات المتاجر إلى ملف Excel");
  };

  const handleViewStore = (store: Store) => {
    setSelectedStore(store);
    setShowStoreModal(true);
  };

  const displayStats = stats || {
    totalStores: stores.length,
    activeStores: stores.filter((s) => s.isActive).length,
    highRiskStores: stores.filter((s) => s.riskLevel === "مرتفع").length,
    reviewStores: stores.filter((s) => !s.isActive).length,
    totalSalesValue: stores.reduce(
      (sum, store) =>
        sum +
        parseFloat((store.totalSales || "0").replace(/,/g, "").replace(" دينار", "")),
      0
    ),
    totalPendingPayouts: stores.reduce(
      (sum, store) =>
        sum +
        parseFloat((store.pendingPayouts || "0").replace(/,/g, "").replace(" دينار", "")),
      0
    ),
  };

  const topStores = [...stores]
    .sort(
      (a, b) =>
        parseFloat((b.totalSales || "0").replace(/,/g, "")) -
        parseFloat((a.totalSales || "0").replace(/,/g, ""))
    )
    .slice(0, 3);

  const manualTopStores = stores.filter((store) => store.topStore);

  const handleAddFeaturedStore = async () => {
    if (!selectedFeaturedStore) return;
    const storeId = Number(selectedFeaturedStore);
    const store = stores.find(s => s.id === storeId);
    if (store && !store.topStore) {
      try {
        await storesService.toggleTopStore(storeId);
        await fetchStores(); // Refresh stores list
      } catch (error) {
        console.error("Failed to add top store", error);
      }
    }
    setSelectedFeaturedStore("");
  };

  const handleRemoveFeaturedStore = async (storeId: number) => {
    try {
      await storesService.toggleTopStore(storeId);
      await fetchStores(); // Refresh stores list
    } catch (error) {
      console.error("Failed to remove top store", error);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-lg font-semibold text-slate-50">إدارة المتاجر</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          متابعة المتاجر المتعاونة، الأداء، المخاطر، والمدفوعات المستحقة
        </p>
      </div>

      <section className="grid gap-4 md:grid-cols-4">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🏪</span>
            <span>إجمالي المتاجر</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {displayStats.totalStores}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">متجر متعاقد</p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>✅</span>
            <span>المتاجر النشطة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {displayStats.activeStores}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">متجر متاح للعملاء</p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⚠️</span>
            <span>المتاجر عالية المخاطر</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {displayStats.highRiskStores}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">بحاجة لمتابعة</p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⏳</span>
            <span>تحت المراجعة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {displayStats.reviewStores}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">
            متاجر بانتظار التفعيل
          </p>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">إجمالي المبيعات عبر BNPL</p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {displayStats.totalSalesValue.toLocaleString()} دينار
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">إجمالي المستحقات للمتاجر</p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {displayStats.totalPendingPayouts.toLocaleString()} دينار
          </p>
        </div>
        <div className="rounded-xl border border-emerald-500/70 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 text-slate-950 shadow-[0_18px_40px_rgba(16,185,129,0.6)]">
          <p className="text-xs font-medium">أفضل 3 متاجر أداءً</p>
          <div className="mt-3 space-y-2 text-sm">
            {topStores.map((store, index) => (
              <div
                key={store.id}
                className="flex items-center justify-between"
              >
                <span>
                  #{index + 1} {store.name}
                </span>
                <span className="font-semibold">{store.totalSales}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h3 className="text-sm font-semibold text-slate-50">
              المتاجر المختارة لظهور خاص (Top Stores)
            </h3>
            <p className="mt-1 text-[11px] text-slate-400">
              اختر متجرًا لإبرازه في قسم المتاجر المميزة داخل الحملات أو الصفحة
              الرئيسية.
            </p>
          </div>
          <div className="flex flex-col gap-2 md:flex-row md:items-center">
            <select
              value={selectedFeaturedStore}
              onChange={(e) => setSelectedFeaturedStore(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value="">اختر متجرًا</option>
              {stores.map((store) => (
                <option key={store.id} value={store.id}>
                  {store.name} • {store.category}
                </option>
              ))}
            </select>
            <button
              onClick={handleAddFeaturedStore}
              className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
            >
              ✔️ إضافة للـ Top Store
            </button>
          </div>
        </div>

        {manualTopStores.length > 0 ? (
          <div className="mt-4 grid gap-3 md:grid-cols-3">
            {manualTopStores.map((store) => (
              <div
                key={store.id}
                className="rounded-xl border border-slate-800 bg-[#03202d] p-4"
              >
                <div className="flex items-center justify-between text-sm text-slate-50">
                  <span className="font-semibold">{store.name}</span>
                  <button
                    onClick={() => handleRemoveFeaturedStore(store.id)}
                    className="text-xs text-slate-400 hover:text-red-300"
                  >
                    إزالة
                  </button>
                </div>
                <p className="mt-1 text-[11px] text-slate-400">
                  الفئة: {store.category}
                </p>
                <p className="mt-1 text-xs text-emerald-200">
                  آخر مبيعات: {store.totalSales}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <p className="mt-4 text-xs text-slate-400">
            لم يتم اختيار أي متجر بعد. اختر متجرًا وأضفه للقائمة.
          </p>
        )}
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div className="flex flex-1 flex-col gap-3 md:flex-row md:items-center">
            <div className="relative flex-1">
              <input
                type="text"
                placeholder="ابحث بالمتجر، الفئة، أو المدينة..."
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
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setCurrentPage(1);
              }}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value="الكل">كل الحالات</option>
              <option value="نشط">نشط</option>
              <option value="قيد المراجعة">قيد المراجعة</option>
              <option value="متوقف مؤقتًا">متوقف مؤقتًا</option>
            </select>
            <select
              value={riskFilter}
              onChange={(e) => {
                setRiskFilter(e.target.value);
                setCurrentPage(1);
              }}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value="الكل">كل مستويات المخاطر</option>
              <option value="منخفض">منخفض</option>
              <option value="متوسط">متوسط</option>
              <option value="مرتفع">مرتفع</option>
            </select>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={handleExport}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
            >
              📥 تصدير البيانات
            </button>
            <button
              onClick={() => setShowAddStoreModal(true)}
              className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
            >
              + إضافة متجر جديد
            </button>
          </div>
        </div>
        <div className="mt-3 text-xs text-slate-400">
          عرض {paginatedStores.length} من {filteredStores.length} متجر
        </div>
      </div>

      {selectedStores.length > 0 && (
        <div className="rounded-xl border border-emerald-500/40 bg-emerald-500/10 p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <span className="text-sm text-emerald-200">
              تم تحديد {selectedStores.length} متجر
            </span>
            <div className="flex flex-wrap items-center gap-2">
              <button
                onClick={() => handleBulkAction("إرسال تحذير")}
                className="rounded-lg border border-amber-500/40 bg-amber-500/15 px-4 py-2 text-xs font-medium text-amber-100 hover:bg-amber-500/30 transition-colors"
              >
                ⚠️ إرسال تحذير
              </button>
              <button
                onClick={() => handleBulkAction("إيقاف مؤقت")}
                className="rounded-lg border border-red-500/40 bg-red-500/15 px-4 py-2 text-xs font-medium text-red-200 hover:bg-red-500/30 transition-colors"
              >
                🚫 إيقاف مؤقت
              </button>
              <button
                onClick={() => handleBulkAction("تغيير العمولة")}
                className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-medium text-slate-200 hover:bg-slate-900 transition-colors"
              >
                💼 تعديل العمولة
              </button>
              <button
                onClick={() => setSelectedStores([])}
                className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-medium text-slate-200 hover:bg-slate-900 transition-colors"
              >
                ✕ إلغاء التحديد
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800 text-sm">
            <thead className="bg-[#041f2e] text-xs text-slate-300">
              <tr>
                <th className="px-3 py-3 text-center">
                  <input
                    type="checkbox"
                    checked={
                      paginatedStores.length > 0 &&
                      selectedStores.length === paginatedStores.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="rounded border-slate-600 bg-slate-800 text-emerald-500 focus:ring-emerald-500"
                  />
                </th>
                <th className="px-3 py-3 text-right">المتجر</th>
                <th className="px-3 py-3 text-right">الفئة</th>
                <th className="px-3 py-3 text-right">إجمالي المبيعات</th>
                <th className="px-3 py-3 text-right">عدد العملاء</th>
                <th className="px-3 py-3 text-right">متوسط الطلب</th>
                <th className="px-3 py-3 text-right">الحالة</th>
                <th className="px-3 py-3 text-right">المخاطر</th>
                <th className="px-3 py-3 text-right">الالتزام</th>
                <th className="px-3 py-3 text-right">التمويل</th>
                <th className="px-3 py-3 text-right">المستحقات</th>
                <th className="px-3 py-3 text-center">الإجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824] text-xs">
              {loading ? (
                <tr>
                  <td colSpan={11} className="px-3 py-8 text-center text-slate-400">
                    <div className="flex justify-center items-center gap-2">
                      <div className="w-4 h-4 border-2 border-slate-400 border-t-transparent rounded-full animate-spin"></div>
                      جاري تحميل المتاجر...
                    </div>
                  </td>
                </tr>
              ) : paginatedStores.length === 0 ? (
                <tr>
                  <td colSpan={11} className="px-3 py-8 text-center text-slate-400">
                    لا توجد متاجر تطابق بحثك
                  </td>
                </tr>
              ) : (
                paginatedStores.map((store) => (
                  <tr
                    key={store.id}
                    className={`group transition-colors hover:bg-slate-800/30 ${selectedStores.includes(store.id) ? "bg-emerald-500/5" : ""
                      }`}
                  >
                    <td className="px-3 py-3 text-center">
                      <input
                        type="checkbox"
                        checked={selectedStores.includes(store.id)}
                        onChange={(e) =>
                          handleSelectStore(store.id, e.target.checked)
                        }
                        className="rounded border-slate-600 bg-slate-800 text-emerald-500 focus:ring-emerald-500"
                      />
                    </td>
                    <td className="px-3 py-3">
                      <div className="flex items-center gap-3">
                        <div className="h-8 w-8 flex-shrink-0 rounded-lg bg-slate-800 flex items-center justify-center text-xs font-bold text-slate-400">
                          {store.logoUrl ? (
                            <img src={store.logoUrl} alt={store.name} className="h-full w-full object-cover rounded-lg" />
                          ) : (
                            store.name.charAt(0)
                          )}
                        </div>
                        <div>
                          <div className="font-medium text-slate-100">
                            {store.name}
                          </div>
                          <div className="text-xs text-slate-500">
                            {store.category || "عام"}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-3 py-3 text-slate-400">{store.category || "عام"}</td>
                    <td className="px-3 py-3 text-slate-300 font-medium">
                      {store.totalSales || "0"}
                    </td>
                    <td className="px-3 py-3 text-slate-400">
                      {store.customers || 0}
                    </td>
                    <td className="px-3 py-3 text-slate-400">
                      {store.avgOrder || "0"}
                    </td>
                    <td className="px-3 py-3">
                      <span
                        className={`inline-flex rounded-full px-2 py-0.5 text-xs font-medium border ${store.isActive ? statusColors.emerald : statusColors.slate}`}
                      >
                        {store.isActive ? "نشط" : "غير نشط"}
                      </span>
                    </td>
                    <td className="px-3 py-3">
                      <span
                        className={`inline-flex rounded-full px-2 py-0.5 text-xs font-medium border ${statusColors.emerald}`}
                      >
                        منخفض
                      </span>
                    </td>
                    <td className="px-3 py-3">
                      <div className="text-slate-100">
                        95%
                      </div>
                    </td>
                    <td className="px-3 py-3 text-[11px] text-slate-300">
                      <div className="flex items-center gap-2">
                        <span className="rounded-full border border-slate-700 bg-slate-900/60 px-2 py-0.5 text-[10px]">
                          ممول عبر البنك
                        </span>
                      </div>
                    </td>
                    <td className="px-3 py-3 text-slate-100">
                      {store.pendingPayouts || "0"}
                      <div className="text-[11px] text-slate-400">
                        آخر تسوية: {store.lastSettlement || "-"}
                      </div>
                    </td>
                    <td className="px-3 py-3">
                      <div className="flex items-center justify-center gap-2 opacity-0 transition-opacity group-hover:opacity-100">
                        <button
                          onClick={() => handleViewStore(store)}
                          className="rounded-lg border border-slate-700 bg-slate-900/60 px-2.5 py-1 text-[11px] text-slate-200 hover:bg-slate-900"
                        >
                          👁️
                        </button>
                        <button className="rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-2.5 py-1 text-[11px] text-emerald-200 hover:bg-emerald-500/20">
                          ✏️
                        </button>
                        <button className="rounded-lg border border-red-500/40 bg-red-500/10 px-2.5 py-1 text-[11px] text-red-200 hover:bg-red-500/20">
                          🚫
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

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
                {Array.from({ length: totalPages }, (_, i) => i + 1).map(
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
        )}
      </div>

      {showStoreModal && selectedStore && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="relative w-full max-w-4xl max-h-[90vh] overflow-y-auto rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
            {/* Header */}
            <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4">
              <div className="flex items-center gap-4">
                <div className="h-12 w-12 flex-shrink-0 rounded-lg bg-slate-800 flex items-center justify-center text-lg font-bold text-slate-400">
                  {selectedStore.logoUrl ? (
                    <img src={selectedStore.logoUrl} alt={selectedStore.name} className="h-full w-full object-cover rounded-lg" />
                  ) : (
                    selectedStore.name.charAt(0)
                  )}
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-slate-50">
                    {selectedStore.name}
                  </h2>
                  <div className="flex items-center gap-2 text-sm text-slate-400">
                    <span>{selectedStore.category || "عام"}</span>
                    <span>•</span>
                    <span>{selectedStore.location || "غير محدد"}</span>
                    <span>•</span>
                    <span
                      className={`inline-flex rounded-full px-2 py-0.5 text-[10px] font-medium border ${selectedStore.isActive ? statusColors.emerald : statusColors.slate}`}
                    >
                      {selectedStore.isActive ? "نشط" : "غير نشط"}
                    </span>
                  </div>
                </div>
              </div>
              <button
                onClick={() => setShowStoreModal(false)}
                className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-sm text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
              >
                ✕ إغلاق
              </button>
            </div>

            {/* Content */}
            <div className="p-6 space-y-6">
              {/* Store Info */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <h3 className="text-sm font-semibold text-slate-50 mb-3">
                  📋 معلومات المتجر
                </h3>
                <div className="grid gap-4 md:grid-cols-2 text-sm">
                  <div>
                    <p className="text-xs text-slate-400">جهة الاتصال</p>
                    <p className="mt-1 text-slate-50">
                      {selectedStore.contactPerson || "غير متوفر"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">رقم الهاتف</p>
                    <p className="mt-1 text-slate-50">
                      {selectedStore.contactPhone || "غير متوفر"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">البريد الإلكتروني</p>
                    <p className="mt-1 text-slate-50">
                      {selectedStore.contactEmail || "غير متوفر"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">العنوان</p>
                    <p className="mt-1 text-slate-50">
                      {selectedStore.address || "غير متوفر"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">تاريخ الانضمام</p>
                    <p className="mt-1 text-slate-50">
                      {selectedStore.createdAt ? new Date(selectedStore.createdAt).toLocaleDateString('ar-KW') : "غير متوفر"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">رقم العقد</p>
                    <p className="mt-1 text-slate-50">
                      {"CNT-" + selectedStore.id}
                    </p>
                  </div>
                </div>
              </section>

              {/* Stats */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <h3 className="text-sm font-semibold text-slate-50 mb-3">
                  📊 الأداء والمخاطر
                </h3>
                <div className="grid gap-4 md:grid-cols-4 text-sm">
                  <div>
                    <p className="text-xs text-slate-400">إجمالي المبيعات</p>
                    <p className="mt-1 text-xl font-semibold text-slate-50">
                      {selectedStore.totalSales || "0 د.ك"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">العملاء</p>
                    <p className="mt-1 text-xl font-semibold text-slate-50">
                      {selectedStore.customers || 0}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">متوسط الطلب</p>
                    <p className="mt-1 text-xl font-semibold text-slate-50">
                      {selectedStore.avgOrder || "0 د.ك"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">مستوى المخاطر</p>
                    <span
                      className={`mt-1 inline-flex rounded-full px-3 py-1 text-[11px] font-medium border ${statusColors.emerald}`}
                    >
                      منخفض
                    </span>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">نسبة الالتزام</p>
                    <p className="mt-1 text-xl font-semibold text-slate-50">
                      95%
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">التأخيرات</p>
                    <p className="mt-1 text-xl font-semibold text-amber-300">
                      0 طلب
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">العمولة</p>
                    <p className="mt-1 text-xl font-semibold text-slate-50">
                      {selectedStore.commissionRate}%
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">دورية التحويل</p>
                    <p className="mt-1 text-xl font-semibold text-slate-50">
                      أسبوعي
                    </p>
                  </div>
                </div>
              </section>

              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="text-sm font-semibold text-slate-50">
                    💰 التحويلات المالية
                  </h3>
                  <span className="text-xs text-slate-400">
                    آخر تسوية: {selectedStore.pendingPayouts || "لا يوجد"}
                  </span>
                </div>
                <div className="text-center py-4 text-slate-400 text-sm">
                  لا توجد تحويلات حالياً
                </div>
              </section>

              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="text-sm font-semibold text-slate-50">
                    🧾 معاملات المتجر
                  </h3>
                  <button className="text-xs text-emerald-300 hover:text-emerald-200">
                    عرض جميع معاملات المتجر
                  </button>
                </div>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-slate-800 text-xs">
                    <thead className="bg-[#041f2e] text-slate-300">
                      <tr>
                        <th className="px-3 py-2 text-right">العميل</th>
                        <th className="px-3 py-2 text-right">المبلغ</th>
                        <th className="px-3 py-2 text-right">التاريخ</th>
                        <th className="px-3 py-2 text-right">الحالة</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800 text-slate-100">
                      <tr>
                        <td colSpan={4} className="px-3 py-8 text-center text-xs text-slate-400">
                          لا توجد معاملات
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </section>

              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <h3 className="text-sm font-semibold text-slate-50 mb-3">
                  ✉️ إرسال إشعار للمتجر
                </h3>
                <div className="flex flex-col gap-3">
                  <select className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20">
                    <option>تذكير بالتسوية</option>
                    <option>تنبيه تأخير</option>
                    <option>إشعار تحديث سياسات</option>
                    <option>رسالة مخصصة</option>
                  </select>
                  <textarea
                    rows={3}
                    placeholder="اكتب رسالتك للمتجر..."
                    className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                  />
                  <div className="flex flex-wrap gap-2">
                    <button className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400">
                      📧 إرسال بريد
                    </button>
                    <button className="rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-4 py-2 text-sm font-medium text-emerald-200 hover:bg-emerald-500/20">
                      🔔 إرسال إشعار
                    </button>
                    <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-200 hover:bg-slate-900">
                      📱 إرسال SMS
                    </button>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </div>
      )}

      {/* Add Store Modal */}
      <StoreModal
        isOpen={showAddStoreModal}
        onClose={() => setShowAddStoreModal(false)}
        onSuccess={fetchStores}
      />
    </div>
  );
}
