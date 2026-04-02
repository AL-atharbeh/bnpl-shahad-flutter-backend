"use client";

import { useState, useEffect } from "react";
import { Deal, dealsService } from "@/services/deals.service";
import DealModal from "@/components/modals/DealModal";
import { 
    Plus, 
    Search, 
    Filter, 
    Download, 
    Eye, 
    Edit2, 
    Trash2, 
    TrendingUp, 
    MousePointer2, 
    Target,
    Calendar as CalendarIcon,
    Store as StoreIcon,
    Tag,
    ChevronLeft,
    ChevronRight,
    MoreVertical
} from "lucide-react";

const statusColors = {
    emerald: "bg-emerald-500/10 text-emerald-400 border-emerald-500/20",
    red: "bg-red-500/10 text-red-400 border-red-500/20",
    amber: "bg-amber-500/10 text-amber-300 border-amber-500/20",
    slate: "bg-slate-500/10 text-slate-400 border-slate-500/20",
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

        const status = offer.isActive ? "نشط" : "منتهي";
        const matchesStatus = statusFilter === "الكل" || status === statusFilter;

        const category = offer.store.categoryAr || "غير مصنف";
        const matchesCategory = categoryFilter === "الكل" || category === categoryFilter;

        return matchesSearch && matchesStatus && matchesCategory;
    });

    const totalPages = Math.ceil(filteredOffers.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedOffers = filteredOffers.slice(startIndex, startIndex + itemsPerPage);

    const offerStats = {
        totalOffers: deals.length,
        activeOffers: deals.filter((o) => o.isActive).length,
        conversionRate: (
            (deals.reduce((sum, o) => sum + (o.conversions || 0), 0) /
                Math.max(1, deals.reduce((sum, o) => sum + (o.clicks || 0), 0))) *
            100
        ).toFixed(1),
        totalClicks: deals.reduce((sum, o) => sum + (o.clicks || 0), 0),
    };

    const categories = Array.from(new Set(deals.map((o) => o.store.categoryAr).filter(Boolean)));

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
        <div className="min-h-screen space-y-8 animate-in fade-in duration-700">
            {/* Header Section */}
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                <div>
                    <h1 className="text-3xl font-bold bg-gradient-to-r from-emerald-400 to-teal-200 bg-clip-text text-transparent">
                        إدارة العروض المميزة
                    </h1>
                    <p className="mt-1 text-sm text-slate-400 font-medium">
                        تتبع أداء العروض والخصومات بشكل لحظي ومفصل
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <button 
                        onClick={handleCreateOffer}
                        className="group relative flex items-center gap-2 rounded-xl bg-emerald-500 px-6 py-3 text-sm font-bold text-slate-950 transition-all hover:bg-emerald-400 hover:shadow-[0_0_20px_rgba(16,185,129,0.4)] active:scale-95"
                    >
                        <Plus className="h-5 w-5" />
                        <span>إضافة عرض جديد</span>
                    </button>
                </div>
            </div>

            {/* Stats Section with Glassmorphism */}
            <section className="grid gap-6 md:grid-cols-4">
                {[
                    { label: "إجمالي العروض", value: offerStats.totalOffers, icon: Tag, color: "from-blue-500/20 to-indigo-500/20", border: "border-blue-500/20" },
                    { label: "العروض النشطة", value: offerStats.activeOffers, icon: TrendingUp, color: "from-emerald-500/20 to-teal-500/20", border: "border-emerald-500/20" },
                    { label: "إجمالي النقرات", value: offerStats.totalClicks.toLocaleString(), icon: MousePointer2, color: "from-amber-500/20 to-orange-500/20", border: "border-amber-500/20" },
                    { label: "معدل التحويل", value: `${offerStats.conversionRate}%`, icon: Target, color: "from-fuchsia-500/20 to-purple-500/20", border: "border-fuchsia-500/20" },
                ].map((stat, i) => (
                    <div 
                        key={i}
                        className={`relative overflow-hidden rounded-2xl border ${stat.border} bg-slate-900/40 p-6 backdrop-blur-md shadow-2xl transition-transform hover:-translate-y-1`}
                    >
                        <div className={`absolute -right-4 -top-4 h-24 w-24 rounded-full bg-gradient-to-br ${stat.color} opacity-30 blur-2xl`} />
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-400">{stat.label}</p>
                                <p className="mt-2 text-3xl font-bold text-slate-50">{stat.value}</p>
                            </div>
                            <div className="rounded-xl bg-white/5 p-3 text-slate-300">
                                <stat.icon className="h-6 w-6" />
                            </div>
                        </div>
                    </div>
                ))}
            </section>

            {/* Filters Bar */}
            <div className="rounded-2xl border border-slate-800 bg-[#021f2a]/90 p-5 backdrop-blur-xl shadow-xl">
                <div className="flex flex-col gap-4 md:flex-row md:items-center">
                    <div className="relative flex-1 group">
                        <Search className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-500 group-focus-within:text-emerald-500 transition-colors" />
                        <input
                            type="text"
                            placeholder="ابحث بالعنوان أو اسم المتجر..."
                            value={searchQuery}
                            onChange={(e) => { setSearchQuery(e.target.value); setCurrentPage(1); }}
                            className="w-full rounded-xl border border-slate-700 bg-slate-900/60 pl-12 pr-4 py-3 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/50 focus:outline-none focus:ring-2 focus:ring-emerald-500/10 transition-all"
                        />
                    </div>
                    <div className="flex flex-wrap items-center gap-3">
                        <div className="flex items-center gap-2 rounded-xl bg-slate-900/60 p-1 border border-slate-700">
                            {["الكل", "نشط", "منتهي"].map((status) => (
                                <button
                                    key={status}
                                    onClick={() => setStatusFilter(status)}
                                    className={`px-4 py-2 text-xs font-semibold rounded-lg transition-all ${
                                        statusFilter === status 
                                        ? "bg-emerald-500 text-slate-950 shadow-lg" 
                                        : "text-slate-400 hover:text-slate-50"
                                    }`}
                                >
                                    {status}
                                </button>
                            ))}
                        </div>
                        <select
                            value={categoryFilter}
                            onChange={(e) => setCategoryFilter(e.target.value)}
                            className="rounded-xl border border-slate-700 bg-slate-900/60 px-4 py-2.5 text-sm font-medium text-slate-200 focus:border-emerald-500 focus:outline-none transition-all"
                        >
                            <option value="الكل">جميع الفئات</option>
                            {categories.map((cat) => (
                                <option key={cat as string} value={cat as string}>{cat}</option>
                            ))}
                        </select>
                        <button className="flex items-center gap-2 rounded-xl border border-slate-700 bg-slate-900/60 px-4 py-2.5 text-sm font-bold text-slate-300 hover:bg-slate-900 hover:text-white transition-all shadow-xl">
                            <Download className="h-4 w-4" />
                            <span>تصدير</span>
                        </button>
                    </div>
                </div>
            </div>

            {/* Offers Grid */}
            {loading ? (
                <div className="flex flex-col items-center justify-center py-32 space-y-4">
                    <div className="relative h-16 w-16">
                        <div className="absolute inset-0 animate-ping rounded-full bg-emerald-500/20" />
                        <div className="relative flex h-full w-full items-center justify-center rounded-full border-4 border-emerald-500 border-t-transparent animate-spin" />
                    </div>
                    <p className="text-slate-400 font-medium animate-pulse">جاري تحميل العروض الحصرية...</p>
                </div>
            ) : (
                <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
                    {paginatedOffers.map((offer: Deal) => (
                        <div
                            key={offer.id}
                            className="group relative flex flex-col rounded-3xl border border-slate-800 bg-[#021f2a]/80 shadow-2xl overflow-hidden hover:border-emerald-500/30 hover:shadow-emerald-500/5 transition-all duration-500"
                        >
                            {/* Image Wrapper */}
                            <div className="relative h-56 w-full overflow-hidden">
                                <img
                                    src={offer.imageUrl || "https://via.placeholder.com/400x200?text=No+Image"}
                                    alt={offer.titleAr || offer.title}
                                    className="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110"
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-[#021f2a] via-transparent to-transparent opacity-90" />
                                
                                {/* Badges */}
                                <div className="absolute top-4 flex w-full justify-between px-4">
                                    <span className={`flex items-center gap-1.5 rounded-full border px-3 py-1 text-[10px] font-black uppercase tracking-wider backdrop-blur-md ${offer.isActive ? statusColors.emerald : statusColors.red}`}>
                                        <span className={`h-1.5 w-1.5 rounded-full ${offer.isActive ? "bg-emerald-400" : "bg-red-400"} animate-pulse`} />
                                        {offer.isActive ? "نشط" : "منتهي"}
                                    </span>
                                    {offer.discountValue && (
                                        <div className="rounded-xl bg-emerald-500 px-3 py-1 shadow-lg shadow-emerald-500/40">
                                            <p className="text-xs font-black text-slate-950">{offer.discountValue}</p>
                                        </div>
                                    )}
                                </div>

                                {/* Store Floating Label */}
                                <div className="absolute bottom-4 left-4 flex items-center gap-2 rounded-2xl bg-slate-900/80 p-2 backdrop-blur-xl border border-white/5">
                                    <div className="h-8 w-8 rounded-xl border border-slate-700 bg-white p-0.5">
                                        <img src={offer.store.logoUrl} alt={offer.store.name} className="h-full w-full object-contain rounded-lg" />
                                    </div>
                                    <span className="text-xs font-bold text-slate-50">{offer.store.nameAr}</span>
                                </div>
                            </div>

                            {/* Content */}
                            <div className="flex flex-1 flex-col p-6 space-y-4">
                                <div className="space-y-1">
                                    <div className="flex items-center justify-between">
                                        <span className="text-[10px] text-emerald-400 font-bold uppercase tracking-widest">{offer.store.categoryAr || "عام"}</span>
                                        <span className="text-[10px] text-slate-500 font-mono">#{offer.id}</span>
                                    </div>
                                    <h3 className="text-lg font-bold text-slate-50 group-hover:text-emerald-400 transition-colors line-clamp-1">
                                        {offer.titleAr || offer.title}
                                    </h3>
                                    <p className="text-xs font-medium text-slate-400 line-clamp-2 leading-relaxed">
                                        {offer.descriptionAr || offer.description}
                                    </p>
                                </div>

                                {/* Stats Mini-Dashboard */}
                                <div className="grid grid-cols-3 gap-2 rounded-2xl bg-white/[0.03] p-4 border border-white/5">
                                    {[
                                        { label: "المشاهدات", value: offer.views || 0, icon: Eye },
                                        { label: "النقرات", value: offer.clicks || 0, icon: MousePointer2 },
                                        { label: "التحويلات", value: offer.conversions || 0, icon: Target },
                                    ].map((s, idx) => (
                                        <div key={idx} className="text-center group/stat">
                                            <p className="text-[9px] font-bold text-slate-500 uppercase tracking-tighter mb-1">{s.label}</p>
                                            <div className="flex items-center justify-center gap-1">
                                                <span className="text-sm font-black text-slate-200 group-hover/stat:text-emerald-400 transition-colors">{s.value}</span>
                                            </div>
                                        </div>
                                    ))}
                                </div>

                                {/* Dates & Actions */}
                                <div className="pt-2">
                                    <div className="flex items-center justify-between text-[11px] text-slate-500 mb-4 px-1">
                                        <div className="flex items-center gap-1.5">
                                            <CalendarIcon className="h-3 w-3" />
                                            <span>{offer.startDate ? new Date(offer.startDate).toLocaleDateString() : '--'}</span>
                                        </div>
                                        <ChevronLeft className="h-3 w-3" />
                                        <span>{offer.endDate ? new Date(offer.endDate).toLocaleDateString() : '--'}</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <button 
                                            onClick={() => handleViewOffer(offer)}
                                            className="flex flex-1 items-center justify-center gap-2 rounded-xl bg-white/5 px-4 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition-all"
                                        >
                                            <Eye className="h-3.5 w-3.5" />
                                            <span>التفاصيل</span>
                                        </button>
                                        <div className="flex gap-2">
                                            <button 
                                                onClick={() => handleEditOffer(offer)}
                                                className="rounded-xl bg-blue-500/10 p-2.5 text-blue-400 hover:bg-blue-500 hover:text-slate-950 transition-all"
                                            >
                                                <Edit2 className="h-4 w-4" />
                                            </button>
                                            <button 
                                                onClick={() => handleDeleteDeal(offer.id)}
                                                className="rounded-xl bg-red-500/10 p-2.5 text-red-500 hover:bg-red-500 hover:text-slate-950 transition-all"
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Pagination */}
            {totalPages > 1 && (
                <div className="flex items-center justify-between rounded-2xl border border-slate-800 bg-[#021f2a]/90 p-4 backdrop-blur-xl">
                    <p className="text-xs font-bold text-slate-500 uppercase tracking-widest">
                        الصفحة <span className="text-emerald-500">{currentPage}</span> من {totalPages}
                    </p>
                    <div className="flex items-center gap-2">
                        <button
                            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                            disabled={currentPage === 1}
                            className="flex items-center gap-1 rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-bold text-slate-300 transition-all hover:bg-slate-900 disabled:opacity-30"
                        >
                            <ChevronRight className="h-4 w-4" />
                            السابق
                        </button>
                        <div className="flex items-center gap-1">
                            {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                                <button
                                    key={page}
                                    onClick={() => setCurrentPage(page)}
                                    className={`h-8 w-8 rounded-lg text-xs font-bold transition-all ${
                                        currentPage === page
                                            ? "bg-emerald-500 text-slate-950 shadow-lg shadow-emerald-500/20"
                                            : "text-slate-400 hover:bg-white/5 hover:text-slate-50"
                                    }`}
                                >
                                    {page}
                                </button>
                            ))}
                        </div>
                        <button
                            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                            disabled={currentPage === totalPages}
                            className="flex items-center gap-1 rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-bold text-slate-300 transition-all hover:bg-slate-900 disabled:opacity-30"
                        >
                            التالي
                            <ChevronLeft className="h-4 w-4" />
                        </button>
                    </div>
                </div>
            )}

            {/* Modals Support */}
            <DealModal
                isOpen={showEditModal}
                onClose={() => setShowEditModal(false)}
                onSuccess={() => fetchDeals()}
                deal={dealToEdit}
            />

            {/* Offer View Modal Overlay */}
            {showOfferModal && selectedOffer && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4 animate-in fade-in duration-300">
                    <div className="relative w-full max-w-4xl max-h-[90vh] overflow-hidden rounded-3xl border border-slate-800 bg-[#021f2a] shadow-2xl flex flex-col md:flex-row">
                        <div className="relative w-full md:w-1/2 h-64 md:h-auto">
                            <img src={selectedOffer.imageUrl} className="h-full w-full object-cover" />
                            <div className="absolute inset-0 bg-gradient-to-r from-[#021f2a] md:to-transparent" />
                        </div>
                        <div className="flex-1 p-8 overflow-y-auto">
                            <div className="flex justify-between items-start mb-6">
                                <div>
                                    <span className="text-xs font-black text-emerald-500 uppercase tracking-widest">{selectedOffer.store.nameAr}</span>
                                    <h2 className="text-3xl font-black text-white mt-1">{selectedOffer.titleAr || selectedOffer.title}</h2>
                                </div>
                                <button onClick={() => setShowOfferModal(false)} className="h-10 w-10 flex items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:text-white transition-colors">✕</button>
                            </div>
                            
                            <div className="grid grid-cols-2 gap-4 mb-8">
                                <div className="rounded-2xl bg-white/5 p-4 border border-white/5">
                                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">الخصم المتاح</p>
                                    <p className="text-2xl font-black text-emerald-400">{selectedOffer.discountValue || 'N/A'}</p>
                                </div>
                                <div className="rounded-2xl bg-white/5 p-4 border border-white/5">
                                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">الحالة الحالية</p>
                                    <p className={`text-sm font-bold ${selectedOffer.isActive ? 'text-emerald-400' : 'text-red-400'}`}>{selectedOffer.isActive ? 'نشط ومفعل' : 'منتهي الصلاحية'}</p>
                                </div>
                            </div>

                            <div className="space-y-6">
                                <div>
                                    <h3 className="text-xs font-bold text-slate-300 uppercase tracking-widest mb-3 pb-2 border-b border-white/5">وصف العرض</h3>
                                    <p className="text-sm text-slate-400 leading-relaxed font-medium">{selectedOffer.descriptionAr || selectedOffer.description}</p>
                                </div>
                                <div className="flex items-center gap-8 py-4 px-6 rounded-2xl bg-emerald-500/5 border border-emerald-500/20">
                                    <div className="text-center">
                                        <p className="text-[10px] font-bold text-emerald-500/60 uppercase mb-1">المشاهدات</p>
                                        <p className="text-xl font-black text-emerald-400">{selectedOffer.views || 0}</p>
                                    </div>
                                    <div className="h-8 w-px bg-emerald-500/20" />
                                    <div className="text-center">
                                        <p className="text-[10px] font-bold text-emerald-500/60 uppercase mb-1">النقرات</p>
                                        <p className="text-xl font-black text-emerald-400">{selectedOffer.clicks || 0}</p>
                                    </div>
                                    <div className="h-8 w-px bg-emerald-500/20" />
                                    <div className="text-center">
                                        <p className="text-[10px] font-bold text-emerald-500/60 uppercase mb-1">التحويل</p>
                                        <p className="text-xl font-black text-white">{(((selectedOffer.conversions || 0) / Math.max(1, (selectedOffer.clicks || 0))) * 100).toFixed(1)}%</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
