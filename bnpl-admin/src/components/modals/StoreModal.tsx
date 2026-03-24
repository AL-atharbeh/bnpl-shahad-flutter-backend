"use client";

import { useState } from "react";
import { storesService } from "@/services/stores.service";

interface StoreModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

export default function StoreModal({ isOpen, onClose, onSuccess }: StoreModalProps) {
    const [formData, setFormData] = useState({
        name: "",
        nameAr: "",
        description: "",
        descriptionAr: "",
        categoryId: "",
        logoUrl: "",
        websiteUrl: "",
        storeUrl: "",
        commissionRate: "2.5",
        minOrderAmount: "50",
        maxOrderAmount: "5000",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");

        if (!formData.name) {
            setError("اسم المتجر مطلوب");
            return;
        }

        setLoading(true);
        try {
            await storesService.createStore({
                name: formData.name,
                nameAr: formData.nameAr || undefined,
                description: formData.description || undefined,
                descriptionAr: formData.descriptionAr || undefined,
                categoryId: formData.categoryId ? Number(formData.categoryId) : undefined,
                logoUrl: formData.logoUrl || undefined,
                websiteUrl: formData.websiteUrl || undefined,
                storeUrl: formData.storeUrl || undefined,
                commissionRate: Number(formData.commissionRate),
                minOrderAmount: Number(formData.minOrderAmount),
                maxOrderAmount: Number(formData.maxOrderAmount),
            });

            onSuccess();
            onClose();

            // Reset form
            setFormData({
                name: "",
                nameAr: "",
                description: "",
                descriptionAr: "",
                categoryId: "",
                logoUrl: "",
                websiteUrl: "",
                storeUrl: "",
                commissionRate: "2.5",
                minOrderAmount: "50",
                maxOrderAmount: "5000",
            });
        } catch (error) {
            console.error("Failed to create store", error);
            setError("فشل في إضافة المتجر. حاول مرة أخرى.");
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
            <div className="relative w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
                {/* Header */}
                <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4">
                    <h2 className="text-lg font-semibold text-slate-50">إضافة متجر جديد</h2>
                    <button
                        onClick={onClose}
                        className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-sm text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
                    >
                        ✕ إغلاق
                    </button>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {error && (
                        <div className="rounded-lg border border-red-500/40 bg-red-500/10 p-3 text-sm text-red-200">
                            {error}
                        </div>
                    )}

                    <div className="grid gap-4 md:grid-cols-2">
                        {/* Store Name */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                اسم المتجر (English) <span className="text-red-400">*</span>
                            </label>
                            <input
                                type="text"
                                value={formData.name}
                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                                placeholder="Store Name"
                                required
                            />
                        </div>

                        {/* Store Name Arabic */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                اسم المتجر (العربية)
                            </label>
                            <input
                                type="text"
                                value={formData.nameAr}
                                onChange={(e) => setFormData({ ...formData, nameAr: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                                placeholder="اسم المتجر"
                            />
                        </div>
                    </div>

                    {/* Description */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            الوصف (English)
                        </label>
                        <textarea
                            value={formData.description}
                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                            rows={3}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="Store description"
                        />
                    </div>

                    {/* Description Arabic */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            الوصف (العربية)
                        </label>
                        <textarea
                            value={formData.descriptionAr}
                            onChange={(e) => setFormData({ ...formData, descriptionAr: e.target.value })}
                            rows={3}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="وصف المتجر"
                        />
                    </div>

                    <div className="grid gap-4 md:grid-cols-2">
                        {/* Category ID */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                رقم الفئة
                            </label>
                            <input
                                type="number"
                                value={formData.categoryId}
                                onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                                placeholder="1"
                            />
                        </div>

                        {/* Logo URL */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                رابط الشعار
                            </label>
                            <input
                                type="url"
                                value={formData.logoUrl}
                                onChange={(e) => setFormData({ ...formData, logoUrl: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                                placeholder="https://..."
                            />
                        </div>
                    </div>

                    <div className="grid gap-4 md:grid-cols-2">
                        {/* Website URL */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                رابط الموقع
                            </label>
                            <input
                                type="url"
                                value={formData.websiteUrl}
                                onChange={(e) => setFormData({ ...formData, websiteUrl: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                                placeholder="https://..."
                            />
                        </div>

                        {/* Store URL */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                رابط المتجر
                            </label>
                            <input
                                type="url"
                                value={formData.storeUrl}
                                onChange={(e) => setFormData({ ...formData, storeUrl: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                                placeholder="https://..."
                            />
                        </div>
                    </div>

                    <div className="grid gap-4 md:grid-cols-3">
                        {/* Commission Rate */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                نسبة العمولة (%)
                            </label>
                            <input
                                type="number"
                                step="0.1"
                                value={formData.commissionRate}
                                onChange={(e) => setFormData({ ...formData, commissionRate: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            />
                        </div>

                        {/* Min Order Amount */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                الحد الأدنى للطلب
                            </label>
                            <input
                                type="number"
                                value={formData.minOrderAmount}
                                onChange={(e) => setFormData({ ...formData, minOrderAmount: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            />
                        </div>

                        {/* Max Order Amount */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                الحد الأقصى للطلب
                            </label>
                            <input
                                type="number"
                                value={formData.maxOrderAmount}
                                onChange={(e) => setFormData({ ...formData, maxOrderAmount: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            />
                        </div>
                    </div>

                    {/* Buttons */}
                    <div className="flex items-center justify-end gap-3 pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 transition-colors"
                            disabled={loading}
                        >
                            إلغاء
                        </button>
                        <button
                            type="submit"
                            className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                            disabled={loading}
                        >
                            {loading ? "جاري الحفظ..." : "حفظ المتجر"}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
