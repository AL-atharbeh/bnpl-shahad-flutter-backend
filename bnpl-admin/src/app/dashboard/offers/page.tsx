"use client";

import { useState, useEffect } from "react";
import { Deal, dealsService } from "@/services/deals.service";
import DealModal from "@/components/modals/DealModal";

const statusColors = {
    emerald: "bg-emerald-500/15 text-emerald-300 border-emerald-500/40",
    red: "bg-red-500/15 text-red-300 border-red-500/40",
    amber: "bg-amber-500/15 text-amber-200 border-amber-500/40",
    slate: "bg-slate-500/15 text-slate-400 border-slate-500/40",
};

export default function OffersPage() {
    const [loading, setLoading] = useState(true);
    const [deals, setDeals] = useState<Deal[]>([]);
    const [searchQuery, setSearchQuery] = useState("");
    const [statusFilter, setStatusFilter] = useState("الكل");
    const [categoryFilter, setCategoryFilter] = useState("الكل");
    const [currentPage, setCurrentPage] = useState(1);
    const [selectedOffer, setSelectedOffer] = useState<Deal | null>(null);
    const [showOfferModal, setShowOfferModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);
    const [dealToEdit, setDealToEdit] = useState<Deal | null>(null);
    const itemsPerPage = 6;

    useEffect(() => {
        fetchDeals();
    }, []);

    const fetchDeals = async () => {
        setLoading(true);
        try {
            const result = await dealsService.getAll({ includeExpired: true });
            if (Array.isArray(result)) {
                setDeals(result);
            } else if (result && (result as any).data) {
                setDeals((result as any).data);
            }
        } catch (error) {
            console.error("Failed to fetch deals", error);
        } finally {
            setLoading(false);
        }
    };

    const handleDeleteDeal = async (id: number) => {
        if (confirm("هل أنت متأكد من حذف هذا العرض؟")) {
            try {
                await dealsService.delete(id);
                fetchDeals();
            } catch (error) {
                console.error("Failed to delete deal", error);
                alert("فشل حذف العرض");
            }
        }
    };

    const filteredOffers = deals.filter((offer) => {
        const matchesSearch =
            offer.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (offer.titleAr && offer.titleAr.toLowerCase().includes(searchQuery.toLowerCase())) ||
            offer.store.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (offer.store.nameAr && offer.store.nameAr.toLowerCase().includes(searchQuery.toLowerCase()));

        const status = offer.isActive ? "نشط" : "منتهي"; // Simplified status logic
        const matchesStatus = statusFilter === "الكل" || status === statusFilter;

        const category = offer.store.categoryAr || "غير مصنف";
        const matchesCategory = categoryFilter === "الكل" || category === categoryFilter;

        return matchesSearch && matchesStatus && matchesCategory;
    });

    const totalPages = Math.ceil(filteredOffers.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedOffers = filteredOffers.slice(
        startIndex,
        startIndex + itemsPerPage
    );

    const offerStats = {
        totalOffers: deals.length,
        activeOffers: deals.filter((o) => o.isActive).length,
        expiredOffers: deals.filter((o) => !o.isActive).length,
        totalViews: deals.reduce((sum, o) => sum + (o.views || 0), 0),
        totalClicks: deals.reduce((sum, o) => sum + (o.clicks || 0), 0),
        totalConversions: deals.reduce((sum, o) => sum + (o.conversions || 0), 0),
        conversionRate: (
            (deals.reduce((sum, o) => sum + (o.conversions || 0), 0) /
                Math.max(1, deals.reduce((sum, o) => sum + (o.clicks || 0), 0))) *
            100
        ).toFixed(1),
    };

    const categories = Array.from(
        new Set(deals.map((o) => o.store.categoryAr).filter(Boolean))
    );

    const handleViewOffer = (offer: Deal) => {
        setSelectedOffer(offer);
        setShowOfferModal(true);
    };

    const handleEditOffer = (offer: Deal) => {
        setDealToEdit(offer);
        setShowEditModal(true);
    };

    const handleCreateOffer = () => {
        setDealToEdit(null);
        setShowEditModal(true);
    };

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-lg font-semibold text-slate-50">إدارة العروض</h1>
                <p className="mt-1 text-[12px] text-slate-400">
                    متابعة العروض والخصومات، الأداء، والتحويلات
                </p>
            </div>

            {/* Statistics */}
            <section className="grid gap-4 md:grid-cols-4">
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <p className="text-xs text-slate-400 flex items-center gap-1">
                        <span>🎁</span>
                        <span>إجمالي العروض</span>
                    </p>
                    <p className="mt-2 text-2xl font-semibold text-slate-50">
                        {offerStats.totalOffers}
                    </p>
                    <p className="mt-1 text-[11px] text-slate-300">عرض متاح</p>
                </div>
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <p className="text-xs text-slate-400 flex items-center gap-1">
                        <span>✅</span>
                        <span>العروض النشطة</span>
                    </p>
                    <p className="mt-2 text-2xl font-semibold text-slate-50">
                        {offerStats.activeOffers}
                    </p>
                    <p className="mt-1 text-[11px] text-slate-300">عرض قيد التشغيل</p>
                </div>
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <p className="text-xs text-slate-400 flex items-center gap-1">
                        <span>⏰</span>
                        <span>العروض المنتهية</span>
                    </p>
                    <p className="mt-2 text-2xl font-semibold text-slate-50">
                        {offerStats.expiredOffers}
                    </p>
                    <p className="mt-1 text-[11px] text-slate-300">عرض انتهى</p>
                </div>
                <div className="rounded-xl border border-emerald-500/70 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 text-slate-950 shadow-[0_18px_40px_rgba(16,185,129,0.6)]">
                    <p className="text-xs font-medium">معدل التحويل</p>
                    <p className="mt-2 text-2xl font-semibold">
                        {offerStats.conversionRate}%
                    </p>
                    <p className="mt-1 text-[11px]">
                        {offerStats.totalConversions} تحويل من {offerStats.totalClicks} نقرة
                    </p>
                </div>
            </section>

            {/* Performance Stats */}
            <section className="grid gap-4 md:grid-cols-3">
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <p className="text-xs text-slate-400">إجمالي المشاهدات</p>
                    <p className="mt-2 text-2xl font-semibold text-slate-50">
                        {offerStats.totalViews.toLocaleString()}
                    </p>
                </div>
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <p className="text-xs text-slate-400">إجمالي النقرات</p>
                    <p className="mt-2 text-2xl font-semibold text-slate-50">
                        {offerStats.totalClicks.toLocaleString()}
                    </p>
                </div>
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <p className="text-xs text-slate-400">إجمالي التحويلات</p>
                    <p className="mt-2 text-2xl font-semibold text-slate-50">
                        {offerStats.totalConversions.toLocaleString()}
                    </p>
                </div>
            </section>

            {/* Filters */}
            <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <div className="flex flex-1 flex-col gap-3 md:flex-row md:items-center">
                        <div className="relative flex-1">
                            <input
                                type="text"
                                placeholder="ابحث بالعنوان أو المتجر..."
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
                            <option value="منتهي">منتهي</option>
                        </select>
                        <select
                            value={categoryFilter}
                            onChange={(e) => {
                                setCategoryFilter(e.target.value);
                                setCurrentPage(1);
                            }}
                            className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                        >
                            <option value="الكل">كل الفئات</option>
                            {categories.map((cat) => (
                                <option key={cat as string} value={cat as string}>
                                    {cat}
                                </option>
                            ))}
                        </select>
                    </div>
                    <div className="flex items-center gap-2">
                        <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors">
                            📥 تصدير البيانات
                        </button>
                        <button
                            onClick={handleCreateOffer}
                            className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
                        >
                            + إضافة عرض جديد
                        </button>
                    </div>
                </div>
                <div className="mt-3 text-xs text-slate-400">
                    عرض {paginatedOffers.length} من {filteredOffers.length} عرض
                </div>
            </div>

            {/* Offers Grid */}
            {loading ? (
                <div className="flex justify-center py-20">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-500"></div>
                </div>
            ) : (
                <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                    {paginatedOffers.map((offer: Deal) => (
                        <div
                            key={offer.id}
                            className="group rounded-xl border border-slate-800 bg-[#021f2a] overflow-hidden shadow-[0_14px_35px_rgba(0,0,0,0.6)] hover:shadow-[0_20px_50px_rgba(16,185,129,0.15)] transition-all duration-300"
                        >
                            {/* Offer Image */}
                            <div className="relative h-48 overflow-hidden">
                                <img
                                    src={offer.imageUrl || "https://via.placeholder.com/400x200?text=No+Image"}
                                    alt={offer.titleAr || offer.title}
                                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

                                {/* Discount Badge */}
                                {offer.discountValue && (
                                    <div className="absolute top-3 right-3 rounded-full bg-gradient-to-br from-red-500 to-red-600 px-3 py-1.5 shadow-lg">
                                        <p className="text-sm font-bold text-white">
                                            {offer.discountValue}
                                        </p>
                                    </div>
                                )}

                                {/* Status Badge */}
                                <div className="absolute top-3 left-3">
                                    <span
                                        className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-medium border ${offer.isActive ? statusColors.emerald : statusColors.slate}`}
                                    >
                                        {offer.isActive ? "نشط" : "منتهي"}
                                    </span>
                                </div>

                                {/* Store Logo */}
                                <div className="absolute bottom-3 left-3 flex items-center gap-2 bg-black/60 backdrop-blur-sm rounded-lg px-3 py-1.5">
                                    <div className="w-6 h-6 rounded-full overflow-hidden border border-white/20">
                                        <img
                                            src={offer.store.logoUrl || "https://via.placeholder.com/50"}
                                            alt={offer.store.nameAr}
                                            className="w-full h-full object-cover"
                                        />
                                    </div>
                                    <span className="text-xs text-white font-medium">
                                        {offer.store.nameAr}
                                    </span>
                                </div>
                            </div>

                            {/* Offer Details */}
                            <div className="p-4">
                                <h3 className="text-sm font-semibold text-slate-50 mb-1">
                                    {offer.titleAr || offer.title}
                                </h3>
                                <p className="text-xs text-slate-400 mb-3 line-clamp-2">
                                    {offer.descriptionAr || offer.description}
                                </p>

                                {/* Stats */}
                                <div className="grid grid-cols-3 gap-2 mb-3">
                                    <div className="text-center">
                                        <p className="text-xs text-slate-400">مشاهدات</p>
                                        <p className="text-sm font-semibold text-slate-50">
                                            {offer.views || 0}
                                        </p>
                                    </div>
                                    <div className="text-center">
                                        <p className="text-xs text-slate-400">نقرات</p>
                                        <p className="text-sm font-semibold text-slate-50">
                                            {offer.clicks || 0}
                                        </p>
                                    </div>
                                    <div className="text-center">
                                        <p className="text-xs text-slate-400">تحويلات</p>
                                        <p className="text-sm font-semibold text-emerald-300">
                                            {offer.conversions || 0}
                                        </p>
                                    </div>
                                </div>

                                {/* Dates */}
                                <div className="flex items-center justify-between text-xs text-slate-400 mb-3 pb-3 border-b border-slate-800">
                                    <span>📅 {offer.startDate ? new Date(offer.startDate).toLocaleDateString() : 'N/A'}</span>
                                    <span>→</span>
                                    <span>📅 {offer.endDate ? new Date(offer.endDate).toLocaleDateString() : 'N/A'}</span>
                                </div>

                                {/* Actions */}
                                <div className="flex items-center gap-2">
                                    <button
                                        onClick={() => handleViewOffer(offer)}
                                        className="flex-1 rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-xs font-medium text-slate-200 hover:bg-slate-900 transition-colors"
                                    >
                                        👁️ عرض التفاصيل
                                    </button>
                                    <button
                                        onClick={() => handleEditOffer(offer)}
                                        className="rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-3 py-2 text-xs font-medium text-emerald-200 hover:bg-emerald-500/20 transition-colors"
                                    >
                                        ✏️
                                    </button>
                                    <button
                                        onClick={() => handleDeleteDeal(offer.id)}
                                        className="rounded-lg border border-red-500/40 bg-red-500/10 px-3 py-2 text-xs font-medium text-red-200 hover:bg-red-500/20 transition-colors"
                                    >
                                        🗑️
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Pagination */}
            {totalPages > 1 && (
                <div className="rounded-xl border border-slate-800 bg-[#021f2a] px-4 py-3 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
                    <div className="flex items-center justify-between text-xs text-slate-400">
                        <span>
                            الصفحة {currentPage} من {totalPages}
                        </span>
                        <div className="flex items-center gap-2">
                            <button
                                onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                                disabled={currentPage === 1}
                                className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-300 hover:bg-slate-900 disabled:opacity-40 transition-colors"
                            >
                                السابق
                            </button>
                            {Array.from({ length: totalPages }, (_, i) => i + 1).map(
                                (page) => (
                                    <button
                                        key={page}
                                        onClick={() => setCurrentPage(page)}
                                        className={`rounded-lg px-3 py-1.5 transition-colors ${currentPage === page
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
                                className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-slate-300 hover:bg-slate-900 disabled:opacity-40 transition-colors"
                            >
                                التالي
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Offer Details Modal */}
            {showOfferModal && selectedOffer && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4">
                    <div className="relative w-full max-w-3xl max-h-[90vh] overflow-y-auto rounded-2xl border border-slate-800 bg-[#021f2a] shadow-[0_25px_60px_rgba(0,0,0,0.9)]">
                        <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4">
                            <div>
                                <h2 className="text-lg font-semibold text-slate-50">
                                    {selectedOffer.titleAr || selectedOffer.title}
                                </h2>
                                <p className="mt-1 text-xs text-slate-400">
                                    {selectedOffer.store.nameAr} • {selectedOffer.store.categoryAr || "غير مصنف"}
                                </p>
                            </div>
                            <button
                                onClick={() => {
                                    setShowOfferModal(false);
                                    setSelectedOffer(null);
                                }}
                                className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-sm text-slate-200 hover:bg-slate-900 transition-colors"
                            >
                                ✕ إغلاق
                            </button>
                        </div>

                        <div className="p-6 space-y-6">
                            {/* Offer Image */}
                            <div className="rounded-xl overflow-hidden">
                                <img
                                    src={selectedOffer.imageUrl || "https://via.placeholder.com/800x400"}
                                    alt={selectedOffer.titleAr}
                                    className="w-full h-64 object-cover"
                                />
                            </div>

                            {/* Details Grid */}
                            <div className="grid gap-4 md:grid-cols-2">
                                <div className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                                    <p className="text-xs text-slate-400">الخصم</p>
                                    <p className="mt-1 text-2xl font-bold text-emerald-300">
                                        {selectedOffer.discountValue || "N/A"}
                                    </p>
                                </div>
                                <div className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                                    <p className="text-xs text-slate-400">الحالة</p>
                                    <p className="mt-1">
                                        <span
                                            className={`inline-flex rounded-full px-3 py-1 text-xs font-medium border ${selectedOffer.isActive ? statusColors.emerald : statusColors.slate}`}
                                        >
                                            {selectedOffer.isActive ? "نشط" : "منتهي"}
                                        </span>
                                    </p>
                                </div>
                                <div className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                                    <p className="text-xs text-slate-400">تاريخ البداية</p>
                                    <p className="mt-1 text-sm text-slate-50">
                                        {selectedOffer.startDate ? new Date(selectedOffer.startDate).toLocaleDateString() : 'N/A'}
                                    </p>
                                </div>
                                <div className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                                    <p className="text-xs text-slate-400">تاريخ النهاية</p>
                                    <p className="mt-1 text-sm text-slate-50">
                                        {selectedOffer.endDate ? new Date(selectedOffer.endDate).toLocaleDateString() : 'N/A'}
                                    </p>
                                </div>
                            </div>

                            {/* Performance Stats */}
                            <div className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                                <h3 className="text-sm font-semibold text-slate-50 mb-4">
                                    📊 إحصائيات الأداء
                                </h3>
                                <div className="grid gap-4 md:grid-cols-3">
                                    <div>
                                        <p className="text-xs text-slate-400">المشاهدات</p>
                                        <p className="mt-1 text-xl font-semibold text-slate-50">
                                            {(selectedOffer.views || 0).toLocaleString()}
                                        </p>
                                    </div>
                                    <div>
                                        <p className="text-xs text-slate-400">النقرات</p>
                                        <p className="mt-1 text-xl font-semibold text-slate-50">
                                            {(selectedOffer.clicks || 0).toLocaleString()}
                                        </p>
                                    </div>
                                    <div>
                                        <p className="text-xs text-slate-400">التحويلات</p>
                                        <p className="mt-1 text-xl font-semibold text-emerald-300">
                                            {(selectedOffer.conversions || 0).toLocaleString()}
                                        </p>
                                    </div>
                                </div>
                                <div className="mt-4 pt-4 border-t border-slate-800">
                                    <p className="text-xs text-slate-400">معدل التحويل</p>
                                    <p className="mt-1 text-lg font-semibold text-emerald-300">
                                        {(((selectedOffer.conversions || 0) / Math.max(1, (selectedOffer.clicks || 0))) * 100).toFixed(2)}%
                                    </p>
                                </div>
                            </div>

                            {/* Description */}
                            <div className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                                <h3 className="text-sm font-semibold text-slate-50 mb-2">
                                    📝 الوصف
                                </h3>
                                <p className="text-sm text-slate-300">
                                    {selectedOffer.descriptionAr || selectedOffer.description}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Create/Edit Modal */}
            <DealModal
                isOpen={showEditModal}
                onClose={() => setShowEditModal(false)}
                onSuccess={() => {
                    fetchDeals();
                }}
                deal={dealToEdit}
            />
        </div>
    );
}
