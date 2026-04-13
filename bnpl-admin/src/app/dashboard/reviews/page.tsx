"use client";

import { useState, useEffect } from "react";
import { Store, storesService } from "@/services/stores.service";
import ReviewManagement from "@/components/stores/ReviewManagement";

export default function ReviewsPage() {
    const [stores, setStores] = useState<Store[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedStoreId, setSelectedStoreId] = useState<number | null>(null);
    const [searchTerm, setSearchTerm] = useState("");

    useEffect(() => {
        fetchStores();
    }, []);

    const fetchStores = async () => {
        setLoading(true);
        try {
            const result = await storesService.getAll();
            if (result && result.data) {
                setStores(result.data);
            }
        } catch (error) {
            console.error("Failed to fetch stores", error);
        } finally {
            setLoading(false);
        }
    };

    const filteredStores = stores.filter(store => 
        store.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (store.nameAr && store.nameAr.includes(searchTerm))
    );

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-lg font-semibold text-slate-50">إدارة التقييمات والتعليقات</h1>
                <p className="mt-1 text-xs text-slate-400">
                    اختر متجراً لإدارة التقييمات والتعليقات الخاصة به وتعديلها.
                </p>
            </div>

            <div className="grid gap-6 lg:grid-cols-3">
                {/* Store Selection List */}
                <div className="lg:col-span-1 space-y-4">
                    <div className="sticky top-0 z-10 space-y-4 bg-[#021f2a] pb-4">
                        <div className="relative">
                            <input
                                type="text"
                                placeholder="بحث عن متجر..."
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                className="w-full rounded-xl border border-slate-800 bg-slate-900/40 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            />
                            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500">🔍</span>
                        </div>
                    </div>

                    <div className="max-h-[70vh] overflow-y-auto space-y-2 pr-2 scrollbar-thin scrollbar-thumb-slate-800 scrollbar-track-transparent">
                        {loading ? (
                            <div className="py-8 text-center text-slate-400">جاري تحميل المتاجر...</div>
                        ) : filteredStores.length === 0 ? (
                            <div className="py-8 text-center text-slate-500 text-xs">لا توجد متاجر تطابق البحث.</div>
                        ) : (
                            filteredStores.map((store) => (
                                <button
                                    key={store.id}
                                    onClick={() => setSelectedStoreId(store.id)}
                                    className={`w-full text-right rounded-xl border p-3 transition-all ${
                                        selectedStoreId === store.id
                                            ? "border-emerald-500/60 bg-emerald-500/10 text-emerald-50 shadow-[0_0_20px_rgba(16,185,129,0.1)]"
                                            : "border-slate-800 bg-[#031824] text-slate-300 hover:border-slate-700 hover:bg-slate-900/40"
                                    }`}
                                >
                                    <div className="flex items-center gap-3">
                                        {store.logoUrl ? (
                                            <img src={store.logoUrl} alt="" className="h-8 w-8 rounded-lg object-contain bg-white/5 p-1" />
                                        ) : (
                                            <div className="h-8 w-8 rounded-lg bg-slate-800 flex items-center justify-center text-[10px]">🏪</div>
                                        )}
                                        <div className="flex-1 min-w-0">
                                            <div className="text-sm font-medium truncate">{store.nameAr || store.name}</div>
                                            <div className="text-[10px] text-slate-500 truncate">{store.name}</div>
                                        </div>
                                        {selectedStoreId === store.id && <span className="text-emerald-400 text-xs">←</span>}
                                    </div>
                                </button>
                            ))
                        )}
                    </div>
                </div>

                {/* Review Management Content */}
                <div className="lg:col-span-2">
                    {selectedStoreId ? (
                        <div className="rounded-2xl border border-slate-800 bg-[#021f2a] p-6 shadow-xl">
                            <ReviewManagement storeId={selectedStoreId} />
                        </div>
                    ) : (
                        <div className="flex h-[60vh] flex-col items-center justify-center rounded-2xl border border-dashed border-slate-800 bg-[#021f2a]/30 p-8 text-center">
                            <div className="mb-4 text-4xl opacity-20">💬</div>
                            <h3 className="text-lg font-medium text-slate-300">لم يتم اختيار متجر</h3>
                            <p className="mt-2 text-sm text-slate-500 max-w-xs">
                                الرجاء اختيار متجر من القائمة الجانبية لبدء إدارة التقييمات والتعليقات الخاصة به.
                            </p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
