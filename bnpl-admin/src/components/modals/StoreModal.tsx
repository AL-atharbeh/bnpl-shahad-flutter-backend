"use client";

import { useState, useEffect } from "react";
import { Store, Vendor, storesService } from "@/services/stores.service";

interface StoreModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    editStore?: Store | null; // If provided, modal is in edit mode
}

const initialFormData = {
    name: "",
    nameAr: "",
    description: "",
    descriptionAr: "",
    categoryId: "",
    logoUrl: "",
    websiteUrl: "",
    storeUrl: "",
    commissionRate: "5.0",
    bankCommissionRate: "3.0",
    platformCommissionRate: "2.0",
    minOrderAmount: "50",
    maxOrderAmount: "5000",
    vendorId: "",
};

export default function StoreModal({ isOpen, onClose, onSuccess, editStore }: StoreModalProps) {
    const [formData, setFormData] = useState(initialFormData);
    const [vendors, setVendors] = useState<Vendor[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const isEditMode = !!editStore;

    useEffect(() => {
        if (isOpen) {
            fetchVendors();
            if (editStore) {
                setFormData({
                    name: editStore.name || "",
                    nameAr: editStore.nameAr || "",
                    description: editStore.description || "",
                    descriptionAr: editStore.descriptionAr || "",
                    categoryId: editStore.categoryId?.toString() || "",
                    logoUrl: editStore.logoUrl || "",
                    websiteUrl: editStore.websiteUrl || "",
                    storeUrl: editStore.storeUrl || "",
                    commissionRate: editStore.commissionRate?.toString() || "5.0",
                    bankCommissionRate: editStore.bankCommissionRate?.toString() || "3.0",
                    platformCommissionRate: editStore.platformCommissionRate?.toString() || "2.0",
                    minOrderAmount: editStore.minOrderAmount?.toString() || "50",
                    maxOrderAmount: editStore.maxOrderAmount?.toString() || "5000",
                    vendorId: editStore.vendorId?.toString() || "",
                });
            } else {
                setFormData(initialFormData);
            }
        }
    }, [isOpen, editStore]);

    const fetchVendors = async () => {
        try {
            const result = await storesService.getVendors();
            console.log("Vendors result:", result);
            if (result && result.data) {
                setVendors(result.data);
            } else if (Array.isArray(result)) {
                setVendors(result);
            }
        } catch (error) {
            console.error("Failed to fetch vendors", error);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");

        if (!formData.name) {
            setError("اسم المتجر مطلوب");
            return;
        }

        setLoading(true);
        try {
            const payload: any = {
                name: formData.name,
                nameAr: formData.nameAr || undefined,
                description: formData.description || undefined,
                descriptionAr: formData.descriptionAr || undefined,
                categoryId: formData.categoryId ? Number(formData.categoryId) : undefined,
                logoUrl: formData.logoUrl || undefined,
                websiteUrl: formData.websiteUrl || undefined,
                storeUrl: formData.storeUrl || undefined,
                commissionRate: Number(formData.commissionRate),
                bankCommissionRate: Number(formData.bankCommissionRate),
                platformCommissionRate: Number(formData.platformCommissionRate),
                minOrderAmount: Number(formData.minOrderAmount),
                maxOrderAmount: Number(formData.maxOrderAmount),
                vendorId: formData.vendorId ? Number(formData.vendorId) : undefined,
            };

            if (isEditMode && editStore) {
                await storesService.updateStore(editStore.id, payload);
            } else {
                await storesService.createStore(payload);
            }

            onSuccess();
            onClose();
            setFormData(initialFormData);
        } catch (error) {
            console.error(isEditMode ? "Failed to update store" : "Failed to create store", error);
            setError(isEditMode ? "فشل في تحديث المتجر. حاول مرة أخرى." : "فشل في إضافة المتجر. حاول مرة أخرى.");
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    const inputClass = "w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20";

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
            <div className="relative w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
                {/* Header */}
                <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4 z-10">
                    <h2 className="text-lg font-semibold text-slate-50">
                        {isEditMode ? "تعديل المتجر" : "إضافة متجر جديد"}
                    </h2>
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

                    {/* Vendor Selection */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            الفيندر (المورّد) <span className="text-slate-500 text-xs">(اختياري)</span>
                        </label>
                        <select
                            value={formData.vendorId}
                            onChange={(e) => setFormData({ ...formData, vendorId: e.target.value })}
                            className={inputClass}
                        >
                            <option value="">بدون فيندر</option>
                            {vendors.map((vendor) => (
                                <option key={vendor.id} value={vendor.id}>
                                    {vendor.name} — {vendor.phone}
                                </option>
                            ))}
                        </select>
                    </div>

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
                                className={inputClass}
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
                                className={inputClass}
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
                            className={inputClass}
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
                            className={inputClass}
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
                                className={inputClass}
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
                                className={inputClass}
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
                                className={inputClass}
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
                                className={inputClass}
                                placeholder="https://..."
                            />
                        </div>
                    </div>

                    <div className="grid gap-4 md:grid-cols-3">
                        {/* Commission Rate */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                إجمالي العمولة (%)
                            </label>
                            <input
                                type="number"
                                step="0.1"
                                value={formData.commissionRate}
                                onChange={(e) => setFormData({ ...formData, commissionRate: e.target.value })}
                                className={inputClass}
                            />
                        </div>

                        {/* Bank Commission Rate */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                حصة البنك (%)
                            </label>
                            <input
                                type="number"
                                step="0.1"
                                value={formData.bankCommissionRate}
                                onChange={(e) => setFormData({ ...formData, bankCommissionRate: e.target.value })}
                                className={inputClass}
                            />
                        </div>

                        {/* Platform Commission Rate */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-2">
                                حصة المنصة (%)
                            </label>
                            <input
                                type="number"
                                step="0.1"
                                value={formData.platformCommissionRate}
                                onChange={(e) => setFormData({ ...formData, platformCommissionRate: e.target.value })}
                                className={inputClass}
                            />
                        </div>
                    </div>

                    <div className="grid gap-4 md:grid-cols-2">

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
                            {loading
                                ? (isEditMode ? "جاري التحديث..." : "جاري الحفظ...")
                                : (isEditMode ? "تحديث المتجر" : "حفظ المتجر")}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
