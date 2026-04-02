"use client";

import { useState, useEffect } from "react";
import { Deal, CreateDealDto, dealsService } from "@/services/deals.service";
import { Store, storesService } from "@/services/stores.service";
import { Product, productsService } from "@/services/products.service";
import { bannersService } from "@/services/banners.service";
import { 
    X, 
    Upload, 
    Store as StoreIcon, 
    Package, 
    Type, 
    AlignLeft, 
    Tag, 
    Link as LinkIcon, 
    Calendar as CalendarIcon, 
    Palette, 
    ChevronDown,
    Image as ImageIcon,
    CheckCircle2,
    Clock,
    Layout,
    AlertCircle
} from "lucide-react";

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
        storeUrl: "",
        badgeColor: "#10b981",
        accentColor: "#34d399",
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
                    storeUrl: deal.storeUrl,
                    badgeColor: deal.badgeColor || "#10b981",
                    accentColor: deal.accentColor || "#34d399",
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
                setFormData({
                    title: "",
                    titleAr: "",
                    description: "",
                    descriptionAr: "",
                    discountLabel: "خصم",
                    discountValue: "",
                    imageUrl: "",
                    storeUrl: "",
                    badgeColor: "#10b981",
                    accentColor: "#34d399",
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
            alert("فشل في رفع الصورة");
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

    const inputClasses = "w-full rounded-xl border border-slate-700 bg-slate-900/60 px-4 py-2.5 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/50 focus:outline-none focus:ring-4 focus:ring-emerald-500/10 transition-all shadow-inner";
    const labelClasses = "block text-[11px] font-black text-slate-500 uppercase tracking-[0.1em] mb-2 ml-1";

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/90 backdrop-blur-xl p-4 animate-in fade-in duration-500">
            <div className="relative w-full max-w-5xl max-h-[92vh] overflow-hidden rounded-[40px] border border-white/5 bg-[#021f2a] shadow-[0_32px_120px_rgba(0,0,0,1)] flex flex-col scale-in duration-500">
                
                {/* Visual Accent */}
                <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-emerald-500 to-transparent opacity-50" />

                {/* Header */}
                <div className="flex items-center justify-between border-b border-white/5 bg-white/[0.01] px-10 py-7">
                    <div>
                        <div className="flex items-center gap-4">
                            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-500/10 text-emerald-400 shadow-[0_0_20px_rgba(16,185,129,0.1)]">
                                <Tag className="h-6 w-6" />
                            </div>
                            <div>
                                <h2 className="text-2xl font-black text-white tracking-tight leading-none">
                                    {deal ? "تحديث بيانات العرض" : "إطلاق عرض جديد"}
                                </h2>
                                <p className="mt-2 text-sm text-slate-500 font-medium tracking-wide">أكمل تفاصيل القسيمة الشرائية والخصومات الترويجية</p>
                            </div>
                        </div>
                    </div>
                    <button
                        onClick={onClose}
                        className="group rounded-2xl border border-white/5 bg-white/5 p-3 text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-all duration-300"
                    >
                        <X className="h-6 w-6 group-hover:rotate-90 transition-transform duration-300" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-10 space-y-12 custom-scrollbar">
                    
                    {/* Grid Layout for Main Content */}
                    <div className="grid gap-12 lg:grid-cols-12">
                        
                        {/* Left Side: Form Fields */}
                        <div className="lg:col-span-7 space-y-12">
                            
                            {/* Section: Relations */}
                            <div className="space-y-6">
                                <div className="flex items-center gap-3 text-xs font-black text-emerald-500 uppercase tracking-[0.2em] opacity-80">
                                    <StoreIcon className="h-4 w-4" />
                                    <span>الربط الأساسي</span>
                                </div>
                                <div className="grid gap-6 md:grid-cols-2">
                                    <div className="space-y-2">
                                        <label className={labelClasses}>المتجر المختار *</label>
                                        <div className="relative group">
                                            <select
                                                value={formData.storeId || ""}
                                                onChange={(e) => handleStoreChange(Number(e.target.value))}
                                                className={`${inputClasses} appearance-none pr-10`}
                                                required
                                            >
                                                <option value="">اختر المتجر...</option>
                                                {stores.map((store) => (
                                                    <option key={store.id} value={store.id}>{store.nameAr || store.name}</option>
                                                ))}
                                            </select>
                                            <ChevronDown className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 group-focus-within:text-emerald-500 transition-colors pointer-events-none" />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <label className={labelClasses}>المنتج المستهدف *</label>
                                        <div className="relative group">
                                            <select
                                                value={formData.productId || ""}
                                                onChange={(e) => setFormData({ ...formData, productId: Number(e.target.value) })}
                                                className={`${inputClasses} appearance-none pr-10`}
                                                required
                                                disabled={!formData.storeId || loadingProducts}
                                            >
                                                <option value="">{loadingProducts ? "جاري التحميل..." : "اختر المنتج..."}</option>
                                                {products.map((product) => (
                                                    <option key={product.id} value={product.id}>{product.nameAr || product.name}</option>
                                                ))}
                                            </select>
                                            <ChevronDown className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 group-focus-within:text-emerald-500 transition-colors pointer-events-none" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* Section: Content */}
                            <div className="space-y-6">
                                <div className="flex items-center gap-3 text-xs font-black text-emerald-500 uppercase tracking-[0.2em] opacity-80">
                                    <Type className="h-4 w-4" />
                                    <span>نصوص العرض</span>
                                </div>
                                <div className="grid gap-6 md:grid-cols-2">
                                    <div className="space-y-2">
                                        <label className={labelClasses}>عنوان العرض (EN) *</label>
                                        <input
                                            type="text"
                                            value={formData.title || ""}
                                            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                            className={inputClasses}
                                            placeholder="Mega Flash Sale"
                                            required
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className={labelClasses}>عنوان العرض (AR)</label>
                                        <input
                                            type="text"
                                            value={formData.titleAr || ""}
                                            onChange={(e) => setFormData({ ...formData, titleAr: e.target.value })}
                                            className={`${inputClasses} text-right`}
                                            placeholder="عرض الفلاش الميجا"
                                            dir="rtl"
                                        />
                                    </div>
                                    <div className="space-y-2 lg:col-span-2">
                                        <label className={labelClasses}>الوصف التفصيلي (عربي)</label>
                                        <textarea
                                            value={formData.descriptionAr || ""}
                                            onChange={(e) => setFormData({ ...formData, descriptionAr: e.target.value })}
                                            className={`${inputClasses} min-h-[120px] resize-none py-4 leading-relaxed text-right`}
                                            placeholder="اكتب تفاصيل العرض التي ستظهر للمستخدمين..."
                                            dir="rtl"
                                        />
                                    </div>
                                </div>
                            </div>

                            {/* Section: Configuration */}
                            <div className="space-y-6">
                                <div className="flex items-center gap-3 text-xs font-black text-emerald-500 uppercase tracking-[0.2em] opacity-80">
                                    <Layout className="h-4 w-4" />
                                    <span>الإعدادات المتقدمة</span>
                                </div>
                                <div className="grid gap-6 md:grid-cols-2">
                                    <div className="space-y-2">
                                        <label className={labelClasses}>قيمة الخصم</label>
                                        <input
                                            type="text"
                                            value={formData.discountValue || ""}
                                            onChange={(e) => setFormData({ ...formData, discountValue: e.target.value })}
                                            className={inputClasses}
                                            placeholder="25% / د.ك 15"
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className={labelClasses}>رابط خارجي (اختياري)</label>
                                        <div className="relative group">
                                            <input
                                                type="url"
                                                value={formData.storeUrl || ""}
                                                onChange={(e) => setFormData({ ...formData, storeUrl: e.target.value })}
                                                className={`${inputClasses} pl-10`}
                                                placeholder="https://..."
                                            />
                                            <LinkIcon className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-600 group-focus-within:text-emerald-500" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Right Side: Media & Settings */}
                        <div className="lg:col-span-5 space-y-12">
                            
                            {/* Visual Asset */}
                            <div className="space-y-6">
                                <div className="flex items-center justify-between text-xs font-black text-emerald-500 uppercase tracking-[0.2em] opacity-80 border-b border-emerald-500/10 pb-2">
                                    <div className="flex items-center gap-3">
                                        <ImageIcon className="h-4 w-4" />
                                        <span>صورة العرض الأساسية</span>
                                    </div>
                                    <span className="text-[10px] text-slate-600">1200 x 600 PX</span>
                                </div>
                                <div className="relative aspect-[12/7] w-full group overflow-hidden rounded-3xl border-2 border-dashed border-slate-700 bg-slate-900/40 hover:border-emerald-500/50 hover:bg-emerald-500/[0.02] transition-all duration-500">
                                    {formData.imageUrl ? (
                                        <div className="relative h-full w-full">
                                            <img src={formData.imageUrl} className="h-full w-full object-cover transition-transform duration-700 group-hover:scale-105" />
                                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center backdrop-blur-sm">
                                                <button
                                                    type="button"
                                                    onClick={() => setFormData({ ...formData, imageUrl: "" })}
                                                    className="rounded-2xl bg-red-500 px-6 py-2.5 text-xs font-black text-white shadow-2xl hover:bg-red-400 transition-all hover:scale-110 active:scale-95"
                                                >
                                                    حذف وإعادة الرفع
                                                </button>
                                            </div>
                                        </div>
                                    ) : (
                                        <label className="flex h-full w-full cursor-pointer flex-col items-center justify-center p-8 text-center">
                                            {uploadLoading ? (
                                                <div className="flex flex-col items-center gap-4">
                                                    <div className="relative h-12 w-12 flex items-center justify-center">
                                                        <div className="absolute inset-0 animate-ping rounded-full bg-emerald-500/20" />
                                                        <div className="h-full w-full animate-spin rounded-full border-4 border-emerald-500 border-t-transparent" />
                                                    </div>
                                                    <span className="text-xs font-black text-emerald-400">جاري المعالجة...</span>
                                                </div>
                                            ) : (
                                                <>
                                                    <div className="mb-6 rounded-3xl bg-white/[0.03] p-6 text-slate-400 group-hover:bg-emerald-500/10 group-hover:text-emerald-400 transition-all duration-500 group-hover:scale-110">
                                                        <Upload className="h-10 w-10" />
                                                    </div>
                                                    <p className="text-sm font-black text-slate-200">اضغط لرفع الصورة</p>
                                                    <p className="mt-2 text-xs text-slate-500 font-medium">أو اسحب الملف وأفلته هنا</p>
                                                    <div className="mt-6 flex items-center gap-2 rounded-full bg-white/5 px-4 py-1.5 border border-white/5">
                                                        <AlertCircle className="h-3 w-3 text-slate-500" />
                                                        <span className="text-[10px] font-bold text-slate-400">يدعم JPG, PNG, WebP</span>
                                                    </div>
                                                </>
                                            )}
                                            <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} disabled={uploadLoading} />
                                        </label>
                                    )}
                                </div>
                            </div>

                            {/* Colors & Visibility */}
                            <div className="space-y-6">
                                <div className="flex items-center gap-3 text-xs font-black text-emerald-500 uppercase tracking-[0.2em] opacity-80 border-b border-emerald-500/10 pb-2">
                                    <Palette className="h-4 w-4" />
                                    <span>التخصيص والظهور</span>
                                </div>
                                <div className="grid gap-6">
                                    <div className="flex items-center justify-between p-5 rounded-3xl bg-white/[0.02] border border-white/5">
                                        <div className="space-y-1">
                                            <p className="text-xs font-black text-slate-200">لون الشارة</p>
                                            <p className="text-[10px] text-slate-500 font-medium">اللون المميز لعنصر الخصم</p>
                                        </div>
                                        <div className="flex items-center gap-3">
                                            <div className="relative h-12 w-12 group/color">
                                                <input
                                                    type="color"
                                                    value={formData.badgeColor || "#10b981"}
                                                    onChange={(e) => setFormData({ ...formData, badgeColor: e.target.value })}
                                                    className="absolute inset-0 h-full w-full opacity-0 cursor-pointer z-10"
                                                />
                                                <div 
                                                    className="h-full w-full rounded-2xl border-2 border-white/10 shadow-lg group-hover/color:scale-110 transition-transform duration-300" 
                                                    style={{ backgroundColor: formData.badgeColor || "#10b981" }} 
                                                />
                                            </div>
                                            <input
                                                type="text"
                                                value={formData.badgeColor || ""}
                                                onChange={(e) => setFormData({ ...formData, badgeColor: e.target.value })}
                                                className={`${inputClasses} font-mono text-[11px] w-28 text-center`}
                                            />
                                        </div>
                                    </div>

                                    <div className="flex items-center justify-between p-5 rounded-3xl bg-white/[0.02] border border-white/5">
                                        <div className="space-y-1">
                                            <p className="text-xs font-black text-slate-200">اللون الثانوي</p>
                                            <p className="text-[10px] text-slate-500 font-medium">لون التمييز (Accent Color)</p>
                                        </div>
                                        <div className="flex items-center gap-3">
                                            <div className="relative h-12 w-12 group/color">
                                                <input
                                                    type="color"
                                                    value={formData.accentColor || "#34d399"}
                                                    onChange={(e) => setFormData({ ...formData, accentColor: e.target.value })}
                                                    className="absolute inset-0 h-full w-full opacity-0 cursor-pointer z-10"
                                                />
                                                <div 
                                                    className="h-full w-full rounded-2xl border-2 border-white/10 shadow-lg group-hover/color:scale-110 transition-transform duration-300" 
                                                    style={{ backgroundColor: formData.accentColor || "#34d399" }} 
                                                />
                                            </div>
                                            <input
                                                type="text"
                                                value={formData.accentColor || ""}
                                                onChange={(e) => setFormData({ ...formData, accentColor: e.target.value })}
                                                className={`${inputClasses} font-mono text-[11px] w-28 text-center`}
                                            />
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-2 gap-4">
                                        <label className={`flex items-center justify-between p-5 rounded-3xl border transition-all cursor-pointer ${formData.isActive ? 'bg-emerald-500/5 border-emerald-500/20' : 'bg-slate-900/40 border-white/5 opacity-60'}`}>
                                            <span className="text-xs font-black text-slate-200">نشط الآن</span>
                                            <div className={`h-6 w-11 rounded-full relative transition-colors ${formData.isActive ? 'bg-emerald-500' : 'bg-slate-800'}`}>
                                                <div className={`absolute top-1 h-4 w-4 bg-white rounded-full transition-all ${formData.isActive ? 'right-6' : 'right-1'}`} />
                                            </div>
                                            <input type="checkbox" className="hidden" checked={formData.isActive} onChange={e => setFormData({...formData, isActive: e.target.checked})} />
                                        </label>
                                        <label className={`flex items-center justify-between p-5 rounded-3xl border transition-all cursor-pointer ${formData.showInHome ? 'bg-indigo-500/5 border-indigo-500/20' : 'bg-slate-900/40 border-white/5 opacity-60'}`}>
                                            <span className="text-xs font-black text-slate-200">في الرئيسية</span>
                                            <div className={`h-6 w-11 rounded-full relative transition-colors ${formData.showInHome ? 'bg-indigo-500' : 'bg-slate-800'}`}>
                                                <div className={`absolute top-1 h-4 w-4 bg-white rounded-full transition-all ${formData.showInHome ? 'right-6' : 'right-1'}`} />
                                            </div>
                                            <input type="checkbox" className="hidden" checked={formData.showInHome} onChange={e => setFormData({...formData, showInHome: e.target.checked})} />
                                        </label>
                                    </div>
                                </div>
                            </div>

                            {/* Scheduling */}
                            <div className="space-y-6">
                                <div className="flex items-center gap-3 text-xs font-black text-emerald-500 uppercase tracking-[0.2em] opacity-80 border-b border-emerald-500/10 pb-2">
                                    <Clock className="h-4 w-4" />
                                    <span>الجدولة الزمنية</span>
                                </div>
                                <div className="grid gap-6">
                                    <div className="relative group/date">
                                        <label className={labelClasses}>فترة العرض (من - إلى)</label>
                                        <div className="grid grid-cols-2 gap-3">
                                            <input
                                                type="datetime-local"
                                                value={formData.startDate ? new Date(formData.startDate).toISOString().slice(0, 16) : ""}
                                                onChange={(e) => setFormData({ ...formData, startDate: e.target.value ? new Date(e.target.value) : undefined })}
                                                className={inputClasses}
                                            />
                                            <input
                                                type="datetime-local"
                                                value={formData.endDate ? new Date(formData.endDate).toISOString().slice(0, 16) : ""}
                                                onChange={(e) => setFormData({ ...formData, endDate: e.target.value ? new Date(e.target.value) : undefined })}
                                                className={inputClasses}
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>

                {/* Footer */}
                <div className="border-t border-white/5 bg-white/[0.01] px-10 py-8 flex items-center justify-between">
                    <div className="hidden md:flex items-center gap-3 text-slate-500">
                        <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                        <span className="text-[10px] font-black uppercase tracking-widest">جميع البيانات مشفرة وآمنة</span>
                    </div>
                    <div className="flex items-center gap-6">
                        <button
                            type="button"
                            onClick={onClose}
                            className="text-sm font-black text-slate-500 hover:text-white transition-colors"
                            disabled={loading}
                        >
                            إلغاء الأمر
                        </button>
                        <button
                            type="submit"
                            disabled={loading || uploadLoading}
                            onClick={handleSubmit}
                            className="relative flex items-center gap-3 overflow-hidden rounded-[20px] bg-emerald-500 px-10 py-4 text-sm font-black text-slate-950 shadow-[0_15px_35px_rgba(16,185,129,0.3)] hover:bg-emerald-400 hover:shadow-emerald-500/40 transition-all duration-300 hover:-translate-y-1 active:translate-y-0 active:scale-95 disabled:opacity-50"
                        >
                            {loading ? (
                                <>
                                    <div className="h-4 w-4 animate-spin rounded-full border-2 border-slate-950 border-t-transparent" />
                                    <span>جاري المعالجة...</span>
                                </>
                            ) : (
                                <>
                                    <span>{deal ? "حفظ التغييرات" : "إطلاق العرض الآن"}</span>
                                    {!deal && <CheckCircle2 className="h-4 w-4" />}
                                </>
                            )}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
