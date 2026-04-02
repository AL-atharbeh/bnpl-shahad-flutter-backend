import { useState, useEffect } from "react";
import { Deal, CreateDealDto, dealsService } from "@/services/deals.service";
import { Store, storesService } from "@/services/stores.service";
import { Product, productsService } from "@/services/products.service";
import { bannersService } from "@/services/banners.service";

interface DealModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    deal?: Deal | null;
}

export default function DealModal({
    isOpen,
    onClose,
    onSuccess,
    deal,
}: DealModalProps) {
    const [loading, setLoading] = useState(false);
    const [stores, setStores] = useState<Store[]>([]);
    const [products, setProducts] = useState<Product[]>([]);
    const [loadingProducts, setLoadingProducts] = useState(false);
    const [uploadLoading, setUploadLoading] = useState(false);

    const [formData, setFormData] = useState<Partial<CreateDealDto>>({
        title: "",
        titleAr: "",
        description: "",
        descriptionAr: "",
        discountLabel: "خصم",
        discountValue: "",
        imageUrl: "",
        badgeColor: "#EF4444",
        accentColor: "#F87171",
        isActive: true,
        showInHome: true,
        sortOrder: 0,
    });

    useEffect(() => {
        if (isOpen) {
            fetchStores();
            if (deal) {
                setFormData({
                    storeId: deal.storeId,
                    productId: deal.productId,
                    title: deal.title,
                    titleAr: deal.titleAr,
                    description: deal.description,
                    descriptionAr: deal.descriptionAr,
                    discountLabel: deal.discountLabel,
                    discountValue: deal.discountValue,
                    imageUrl: deal.imageUrl,
                    badgeColor: deal.badgeColor,
                    accentColor: deal.accentColor,
                    startDate: deal.startDate ? new Date(deal.startDate) : undefined,
                    endDate: deal.endDate ? new Date(deal.endDate) : undefined,
                    isActive: deal.isActive,
                    showInHome: deal.showInHome,
                    sortOrder: deal.sortOrder,
                });
                if (deal.storeId) {
                    fetchProducts(deal.storeId);
                }
            } else {
                // Reset form for new deal
                setFormData({
                    title: "",
                    titleAr: "",
                    description: "",
                    descriptionAr: "",
                    discountLabel: "خصم",
                    discountValue: "",
                    imageUrl: "",
                    badgeColor: "#EF4444",
                    accentColor: "#F87171",
                    isActive: true,
                    showInHome: true,
                    sortOrder: 0,
                });
                setProducts([]);
            }
        }
    }, [isOpen, deal]);

    const fetchStores = async () => {
        try {
            const result = await storesService.getAll();
            if (Array.isArray(result)) {
                setStores(result);
            } else if (result && (result as any).data) {
                setStores((result as any).data);
            }
        } catch (error) {
            console.error("Failed to fetch stores", error);
        }
    };

    const fetchProducts = async (storeId: number) => {
        setLoadingProducts(true);
        try {
            // Try fetching from stores/:id/products first as it's more likely to exist
            // Note: We need to update productsService to support this if needed
            // For now assuming productsService.getAll(storeId) works or we fix it
            const result = await productsService.getAll(storeId);
            if (Array.isArray(result)) {
                setProducts(result);
            } else if (result && (result as any).data) {
                setProducts((result as any).data);
            }
        } catch (error) {
            console.error("Failed to fetch products", error);
        } finally {
            setLoadingProducts(false);
        }
    };

    const handleStoreChange = (storeId: number) => {
        setFormData({ ...formData, storeId, productId: undefined });
        fetchProducts(storeId);
    };

    const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setUploadLoading(true);
        try {
            const result = await bannersService.uploadImage(file);
            if (result.success) {
                setFormData((prev) => ({ ...prev, imageUrl: result.data.url }));
            }
        } catch (err: any) {
            console.error("Upload failed", err);
            const errorMessage = err.response?.data?.message || err.message || "فشل في رفع الصورة";
            alert(`خطأ في الرفع: ${errorMessage}`);
        } finally {
            setUploadLoading(false);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            if (!formData.storeId || !formData.productId || !formData.title || !formData.imageUrl) {
                alert("يرجى تعبئة الحقول الإلزامية (المتجر، المنتج، العنوان، صورة العرض)");
                setLoading(false);
                return;
            }

            const payload = {
                ...formData,
                storeId: Number(formData.storeId),
                productId: Number(formData.productId),
                sortOrder: Number(formData.sortOrder),
            } as CreateDealDto;

            if (deal) {
                await dealsService.update(deal.id, payload);
            } else {
                await dealsService.create(payload);
            }
            onSuccess();
            onClose();
        } catch (error) {
            console.error("Failed to save deal", error);
            alert("حدث خطأ أثناء حفظ العرض");
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 overflow-y-auto">
            <div className="relative w-full max-w-2xl rounded-2xl border border-slate-800 bg-[#021f2a] shadow-[0_25px_60px_rgba(0,0,0,0.9)] my-8">
                <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4 rounded-t-2xl z-10">
                    <h2 className="text-lg font-semibold text-slate-50">
                        {deal ? "تعديل العرض" : "إضافة عرض جديد"}
                    </h2>
                    <button
                        onClick={onClose}
                        className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-sm text-slate-200 hover:bg-slate-900 transition-colors"
                    >
                        ✕ إغلاق
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-6">
                    {/* Store & Product Selection */}
                    <div className="grid gap-4 md:grid-cols-2">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">المتجر *</label>
                            <select
                                value={formData.storeId || ""}
                                onChange={(e) => handleStoreChange(Number(e.target.value))}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                                required
                            >
                                <option value="">اختر المتجر</option>
                                {stores.map((store) => (
                                    <option key={store.id} value={store.id}>
                                        {store.name}
                                    </option>
                                ))}
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">المنتج *</label>
                            <select
                                value={formData.productId || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, productId: Number(e.target.value) })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                                required
                                disabled={!formData.storeId || loadingProducts}
                            >
                                <option value="">
                                    {loadingProducts ? "جاري التحميل..." : "اختر المنتج"}
                                </option>
                                {products.map((product) => (
                                    <option key={product.id} value={product.id}>
                                        {product.name} ({product.price} د.ك)
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>

                    {/* Titles */}
                    <div className="grid gap-4 md:grid-cols-2">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                العنوان (English) *
                            </label>
                            <input
                                type="text"
                                value={formData.title || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, title: e.target.value })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                                required
                            />
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                العنوان (عربي)
                            </label>
                            <input
                                type="text"
                                value={formData.titleAr || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, titleAr: e.target.value })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                                dir="rtl"
                            />
                        </div>
                    </div>

                    {/* Descriptions */}
                    <div className="grid gap-4 md:grid-cols-2">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                الوصف (English)
                            </label>
                            <textarea
                                value={formData.description || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, description: e.target.value })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none h-20 resize-none"
                            />
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                الوصف (عربي)
                            </label>
                            <textarea
                                value={formData.descriptionAr || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, descriptionAr: e.target.value })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none h-20 resize-none"
                                dir="rtl"
                            />
                        </div>
                    </div>

                    {/* Discount & Image */}
                    <div className="grid gap-4 md:grid-cols-3">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                قيمة الخصم (مثال: 20%)
                            </label>
                            <input
                                type="text"
                                value={formData.discountValue || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, discountValue: e.target.value })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                نص الخصم (مثال: خصم)
                            </label>
                            <input
                                type="text"
                                value={formData.discountLabel || ""}
                                onChange={(e) =>
                                    setFormData({ ...formData, discountLabel: e.target.value })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                            />
                        </div>
                        <div className="col-span-1 md:col-span-3">
                            <label className="block text-xs font-medium text-slate-400 mb-2">صورة العرض</label>
                            <div className="flex flex-col gap-4">
                                {formData.imageUrl && (
                                    <div className="relative h-48 w-full md:w-1/2 overflow-hidden rounded-lg border border-slate-700 bg-slate-800 shadow-inner">
                                        <img src={formData.imageUrl} alt="Preview" className="h-full w-full object-cover" />
                                        <div className="absolute inset-0 bg-black/20 opacity-0 hover:opacity-100 transition-opacity flex items-center justify-center">
                                            <button
                                                type="button"
                                                onClick={() => setFormData({ ...formData, imageUrl: "" })}
                                                className="rounded-full bg-red-500 p-2 text-white shadow-lg hover:bg-red-400 text-xs"
                                            >
                                                حذف الصورة
                                            </button>
                                        </div>
                                    </div>
                                )}

                                {!formData.imageUrl && (
                                    <label className="flex h-32 w-full md:w-1/2 cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed border-slate-700 bg-slate-900/40 transition-all hover:border-emerald-500/50 hover:bg-slate-900/60 group">
                                        <div className="flex flex-col items-center justify-center pb-6 pt-5">
                                            <div className="mb-2 rounded-full bg-slate-800 p-2 group-hover:bg-slate-700 group-hover:text-emerald-400 transition-colors">
                                                <svg className="h-6 w-6 text-slate-400 group-hover:text-emerald-400" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 16">
                                                    <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 13h3a3 3 0 0 0 0-6h-.025A5.56 5.56 0 0 0 16 6.5 5.5 5.5 0 0 0 5.207 5.021C5.137 5.017 5.071 5 5 5a4 4 0 0 0 0 8h2.167M10 15V6m0 0L8 8m2-2 2 2" />
                                                </svg>
                                            </div>
                                            <p className="mb-1 text-xs text-slate-400 text-center px-4">
                                                {uploadLoading ? (
                                                    <span className="flex items-center gap-2">
                                                        <span className="h-3 w-3 animate-spin rounded-full border-2 border-emerald-500 border-t-transparent"></span>
                                                        جاري الرفع...
                                                    </span>
                                                ) : (
                                                    <>
                                                        <span className="font-semibold text-emerald-500">اضغط لرفع الصورة</span> أو اسحبها هنا
                                                    </>
                                                )}
                                            </p>
                                        </div>
                                        <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} disabled={uploadLoading} />
                                    </label>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Colors & Sort */}
                    <div className="grid gap-4 md:grid-cols-3">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                لون الشارة (Hex)
                            </label>
                            <div className="flex gap-2">
                                <input
                                    type="color"
                                    value={formData.badgeColor || "#EF4444"}
                                    onChange={(e) =>
                                        setFormData({ ...formData, badgeColor: e.target.value })
                                    }
                                    className="h-9 w-9 rounded cursor-pointer bg-transparent border-0 p-0"
                                />
                                <input
                                    type="text"
                                    value={formData.badgeColor || ""}
                                    onChange={(e) =>
                                        setFormData({ ...formData, badgeColor: e.target.value })
                                    }
                                    className="flex-1 rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                                />
                            </div>
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                لون التمييز (Hex)
                            </label>
                            <div className="flex gap-2">
                                <input
                                    type="color"
                                    value={formData.accentColor || "#F87171"}
                                    onChange={(e) =>
                                        setFormData({ ...formData, accentColor: e.target.value })
                                    }
                                    className="h-9 w-9 rounded cursor-pointer bg-transparent border-0 p-0"
                                />
                                <input
                                    type="text"
                                    value={formData.accentColor || ""}
                                    onChange={(e) =>
                                        setFormData({ ...formData, accentColor: e.target.value })
                                    }
                                    className="flex-1 rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                                />
                            </div>
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                الترتيب
                            </label>
                            <input
                                type="number"
                                value={formData.sortOrder || 0}
                                onChange={(e) =>
                                    setFormData({ ...formData, sortOrder: Number(e.target.value) })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                            />
                        </div>
                    </div>

                    {/* Dates */}
                    <div className="grid gap-4 md:grid-cols-2">
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                تاريخ البداية
                            </label>
                            <input
                                type="datetime-local"
                                value={
                                    formData.startDate
                                        ? new Date(formData.startDate).toISOString().slice(0, 16)
                                        : ""
                                }
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        startDate: e.target.value ? new Date(e.target.value) : undefined,
                                    })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-xs text-slate-400 mb-1">
                                تاريخ النهاية
                            </label>
                            <input
                                type="datetime-local"
                                value={
                                    formData.endDate
                                        ? new Date(formData.endDate).toISOString().slice(0, 16)
                                        : ""
                                }
                                onChange={(e) =>
                                    setFormData({
                                        ...formData,
                                        endDate: e.target.value ? new Date(e.target.value) : undefined,
                                    })
                                }
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                            />
                        </div>
                    </div>

                    {/* Toggles */}
                    <div className="flex gap-6">
                        <label className="flex items-center gap-2 cursor-pointer">
                            <input
                                type="checkbox"
                                checked={formData.isActive}
                                onChange={(e) =>
                                    setFormData({ ...formData, isActive: e.target.checked })
                                }
                                className="rounded border-slate-600 bg-slate-800 text-emerald-500 focus:ring-emerald-500"
                            />
                            <span className="text-sm text-slate-300">نشط</span>
                        </label>
                        <label className="flex items-center gap-2 cursor-pointer">
                            <input
                                type="checkbox"
                                checked={formData.showInHome}
                                onChange={(e) =>
                                    setFormData({ ...formData, showInHome: e.target.checked })
                                }
                                className="rounded border-slate-600 bg-slate-800 text-emerald-500 focus:ring-emerald-500"
                            />
                            <span className="text-sm text-slate-300">عرض في الرئيسية</span>
                        </label>
                    </div>

                    {/* Actions */}
                    <div className="flex justify-end gap-3 pt-4 border-t border-slate-800">
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
                            className="rounded-lg bg-emerald-500 px-6 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors disabled:opacity-50"
                            disabled={loading}
                        >
                            {loading ? "جاري الحفظ..." : "حفظ العرض"}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
