"use client";

import { useState, useEffect } from "react";
import { StoreReview, storesService } from "@/services/stores.service";

interface ReviewManagementProps {
    storeId: number;
}

export default function ReviewManagement({ storeId }: ReviewManagementProps) {
    const [reviews, setReviews] = useState<StoreReview[]>([]);
    const [loading, setLoading] = useState(true);
    const [isAdding, setIsAdding] = useState(false);
    const [formData, setFormData] = useState({
        authorName: "",
        rating: 5,
        comment: "",
        commentAr: "",
    });

    useEffect(() => {
        fetchReviews();
    }, [storeId]);

    const fetchReviews = async () => {
        setLoading(true);
        try {
            const result = await storesService.getStoreReviews(storeId);
            if (result && result.data) {
                setReviews(result.data);
            }
        } catch (error) {
            console.error("Failed to fetch reviews", error);
        } finally {
            setLoading(false);
        }
    };

    const handleAddReview = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await storesService.createReview({
                ...formData,
                storeId,
            });
            setIsAdding(false);
            setFormData({ authorName: "", rating: 5, comment: "", commentAr: "" });
            fetchReviews();
        } catch (error: any) {
            console.error("Failed to add review:", error);
            const errorMessage = error.response?.data?.message || "فشل في إضافة التقييم";
            alert(Array.isArray(errorMessage) ? errorMessage.join(", ") : errorMessage);
        }
    };

    const handleDeleteReview = async (id: number) => {
        if (!confirm("هل أنت متأكد من حذف هذا التقييم؟")) return;
        try {
            await storesService.deleteReview(id);
            fetchReviews();
        } catch (error) {
            console.error("Failed to delete review", error);
        }
    };

    const inputClass = "w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20";

    if (loading && reviews.length === 0) {
        return <div className="text-center py-8 text-slate-400">جاري تحميل التقييمات...</div>;
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h3 className="text-sm font-semibold text-slate-50">إدارة التقييمات والتعليقات</h3>
                <button
                    onClick={() => setIsAdding(!isAdding)}
                    className="rounded-lg bg-emerald-500 px-3 py-1.5 text-xs font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
                >
                    {isAdding ? "إلغاء الأمر" : "+ إضافة تقييم جديد"}
                </button>
            </div>

            {isAdding && (
                <form onSubmit={handleAddReview} className="rounded-xl border border-slate-700 bg-slate-900/30 p-4 space-y-4">
                    <div className="grid gap-4 md:grid-cols-2">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1.5">اسم الكاتب</label>
                            <input
                                type="text"
                                value={formData.authorName}
                                onChange={(e) => setFormData({ ...formData, authorName: e.target.value })}
                                className={inputClass}
                                placeholder="مثال: أحمد محمد"
                                required
                            />
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1.5">التقييم (1-5)</label>
                            <select
                                value={formData.rating}
                                onChange={(e) => setFormData({ ...formData, rating: Number(e.target.value) })}
                                className={inputClass}
                            >
                                <option value={5}>5 نجوم</option>
                                <option value={4}>4 نجوم</option>
                                <option value={3}>3 نجوم</option>
                                <option value={2}>2 نجمة</option>
                                <option value={1}>1 نجمة</option>
                            </select>
                        </div>
                    </div>
                    <div>
                        <label className="block text-xs text-slate-400 mb-1.5">التعليق (English)</label>
                        <textarea
                            value={formData.comment}
                            onChange={(e) => setFormData({ ...formData, comment: e.target.value })}
                            className={inputClass}
                            rows={2}
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-xs text-slate-400 mb-1.5">التعليق (العربية)</label>
                        <textarea
                            value={formData.commentAr}
                            onChange={(e) => setFormData({ ...formData, commentAr: e.target.value })}
                            className={inputClass}
                            rows={2}
                        />
                    </div>
                    <div className="flex justify-end">
                        <button
                            type="submit"
                            className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors"
                        >
                            حفظ التقييم
                        </button>
                    </div>
                </form>
            )}

            <div className="space-y-3">
                {reviews.length === 0 ? (
                    <p className="text-center py-4 text-xs text-slate-500">لا توجد تقييمات لهذا المتجر بعد.</p>
                ) : (
                    reviews.map((review) => (
                        <div key={review.id} className="rounded-xl border border-slate-800 bg-[#031824] p-4 group">
                            <div className="flex items-start justify-between">
                                <div>
                                    <div className="flex items-center gap-2">
                                        <span className="font-semibold text-slate-100 text-sm">{review.authorName}</span>
                                        <div className="flex text-amber-400 text-[10px]">
                                            {Array.from({ length: 5 }).map((_, i) => (
                                                <span key={i}>{i < review.rating ? "★" : "☆"}</span>
                                            ))}
                                        </div>
                                    </div>
                                    <p className="mt-1 text-xs text-slate-300">{review.commentAr || review.comment}</p>
                                    <span className="mt-2 block text-[10px] text-slate-500">
                                        {new Date(review.createdAt).toLocaleDateString('ar-EG')}
                                    </span>
                                </div>
                                <button
                                    onClick={() => handleDeleteReview(review.id)}
                                    className="text-slate-500 hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
                                    title="حذف"
                                >
                                    🗑️
                                </button>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
