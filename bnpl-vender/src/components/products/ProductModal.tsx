"use client";

import { Fragment, useEffect, useState, useRef } from "react";
import { Dialog, Transition } from "@headlessui/react";
import {
    X,
    CheckCircle2,
    AlertCircle,
    Package,
    Type,
    Languages,
    DollarSign,
    ImageIcon,
    Layers,
    FileText,
    Upload,
    Loader2
} from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";
import { createProduct, updateProduct, getCategories, uploadProductImage } from "@/services/api";
import { Product } from "@/types";

type ProductModalProps = {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    product?: Product;
};

export default function ProductModal({ isOpen, onClose, onSuccess, product }: ProductModalProps) {
    const { t, language } = useLanguage();
    const [loading, setLoading] = useState(false);
    const [uploading, setUploading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [categories, setCategories] = useState<any[]>([]);

    // Create a ref for the file input
    const fileInputRef = useRef<HTMLInputElement>(null);

    const [formData, setFormData] = useState({
        name: "",
        name_ar: "",
        description: "",
        description_ar: "",
        price: "",
        category_id: "",
        image_url: "",
        in_stock: true
    });

    useEffect(() => {
        async function fetchCategories() {
            try {
                const res = await getCategories();
                setCategories(res.data.data || []);
            } catch (err) {
                console.error("Failed to load categories", err);
            }
        }
        if (isOpen) {
            fetchCategories();
        }
    }, [isOpen]);

    useEffect(() => {
        if (product) {
            setFormData({
                name: product.name || "",
                name_ar: product.name_ar || "",
                description: product.description || "",
                description_ar: product.description_ar || "",
                price: product.price?.toString() || "",
                category_id: product.category_id?.toString() || "",
                image_url: product.image_url || "",
                in_stock: product.in_stock !== false
            });
        } else {
            setFormData({
                name: "",
                name_ar: "",
                description: "",
                description_ar: "",
                price: "",
                category_id: "",
                image_url: "",
                in_stock: true
            });
        }
        setError(null);
    }, [product, isOpen]);

    const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setUploading(true);
        setError(null);

        try {
            const res = await uploadProductImage(file);
            // Construct full URL using explicit base URL + filename
            // The backend returns { url: '/api/v1/...', filename: '...' }
            // We use the filename to construct the full absolute URL for the frontend to render correctly
            const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';
            // Assuming the API_URL points to /api/v1, we need to go up one level to hit the root if serve-static was root,
            // BUT our controller serves at /api/v1/products/uploads/:filename.
            // So baseUrl + '/products/uploads/' + filename should work.

            const uploadedUrl = `${baseUrl}/products/uploads/${res.data.data.filename}`;
            setFormData(prev => ({ ...prev, image_url: uploadedUrl }));
        } catch (err: any) {
            console.error("Upload failed", err);
            setError("Failed to upload image");
        } finally {
            setUploading(false);
            // Clear input value so same file can be selected again if needed
            if (fileInputRef.current) fileInputRef.current.value = "";
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            const userStr = localStorage.getItem("vendor_user");
            const user = userStr ? JSON.parse(userStr) : null;
            if (!user?.storeId) throw new Error("Store ID missing");

            const payload = {
                ...formData,
                price: parseFloat(formData.price),
                category_id: formData.category_id ? parseInt(formData.category_id) : undefined,
                in_stock: formData.in_stock,
                store_id: user.storeId,
            };

            if (product) {
                await updateProduct(product.id, payload);
            } else {
                await createProduct(payload);
            }

            onSuccess();
            onClose();
        } catch (err: any) {
            console.error("Failed to save product", err);
            setError(err.response?.data?.message || err.message || "Something went wrong");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Transition.Root show={isOpen} as={Fragment}>
            <Dialog as="div" className="relative z-50" onClose={onClose}>
                <Transition.Child
                    as={Fragment}
                    enter="ease-out duration-300"
                    enterFrom="opacity-0"
                    enterTo="opacity-100"
                    leave="ease-in duration-200"
                    leaveFrom="opacity-100"
                    leaveTo="opacity-0"
                >
                    <div className="fixed inset-0 bg-black/90 backdrop-blur-md transition-opacity" />
                </Transition.Child>

                <div className="fixed inset-0 z-10 w-screen overflow-y-auto">
                    <div className="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
                        <Transition.Child
                            as={Fragment}
                            enter="ease-out duration-300"
                            enterFrom="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                            enterTo="opacity-100 translate-y-0 sm:scale-100"
                            leave="ease-in duration-200"
                            leaveFrom="opacity-100 translate-y-0 sm:scale-100"
                            leaveTo="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                        >
                            <Dialog.Panel className="relative transform overflow-hidden rounded-2xl bg-[#0B1215] border border-white/10 text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-4xl">
                                {/* Header */}
                                <div className="px-6 py-5 border-b border-white/10 flex items-center justify-between bg-white/5">
                                    <div className="flex items-center gap-3">
                                        <div className="p-2 rounded-lg bg-emerald-500/20 text-emerald-500">
                                            <Package className="h-6 w-6" />
                                        </div>
                                        <Dialog.Title as="h3" className="text-xl font-bold leading-6 text-white">
                                            {product ? t("editProduct") : t("addProduct")}
                                        </Dialog.Title>
                                    </div>
                                    <button
                                        type="button"
                                        className="rounded-lg p-2 text-slate-400 hover:bg-white/10 hover:text-white transition-colors"
                                        onClick={onClose}
                                    >
                                        <X className="h-5 w-5" />
                                    </button>
                                </div>

                                <form onSubmit={handleSubmit}>
                                    <div className="px-6 py-6 space-y-8">
                                        {/* Error Alert */}
                                        {error && (
                                            <div className="rounded-xl bg-red-500/10 p-4 border border-red-500/20 flex items-center gap-3 animate-in fade-in slide-in-from-top-2">
                                                <AlertCircle className="h-5 w-5 text-red-400 flex-shrink-0" />
                                                <p className="text-sm text-red-400 font-medium">{error}</p>
                                            </div>
                                        )}

                                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                                            {/* Left Column: Basic Info */}
                                            <div className="space-y-6">
                                                <div className="space-y-4">
                                                    <h4 className="text-sm font-semibold text-emerald-500 uppercase tracking-wider flex items-center gap-2">
                                                        <Type className="h-4 w-4" />
                                                        Basic Information
                                                    </h4>

                                                    {/* English Name */}
                                                    <div className="space-y-2">
                                                        <label className="text-sm font-medium text-slate-300">{t("productName")}</label>
                                                        <div className="relative">
                                                            <input
                                                                type="text"
                                                                required
                                                                value={formData.name}
                                                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                                                className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 pl-10 text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition-all"
                                                                placeholder="e.g. iPhone 15 Pro"
                                                            />
                                                            <Type className="absolute left-3 top-3.5 h-4 w-4 text-slate-500" />
                                                        </div>
                                                    </div>

                                                    {/* Arabic Name */}
                                                    <div className="space-y-2">
                                                        <label className="text-sm font-medium text-slate-300">{t("productNameAr")}</label>
                                                        <div className="relative">
                                                            <input
                                                                type="text"
                                                                value={formData.name_ar}
                                                                onChange={(e) => setFormData({ ...formData, name_ar: e.target.value })}
                                                                className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 pl-10 text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition-all"
                                                                placeholder="مثال: ايفون 15 برو"
                                                                dir="rtl"
                                                            />
                                                            <Languages className="absolute left-3 top-3.5 h-4 w-4 text-slate-500" />
                                                        </div>
                                                    </div>

                                                    {/* Category */}
                                                    <div className="space-y-2">
                                                        <label className="text-sm font-medium text-slate-300">{t("category")}</label>
                                                        <div className="relative">
                                                            <select
                                                                required
                                                                value={formData.category_id}
                                                                onChange={(e) => setFormData({ ...formData, category_id: e.target.value })}
                                                                className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 pl-10 text-white focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 appearance-none transition-all"
                                                            >
                                                                <option value="" disabled className="bg-[#0B1215]">Select Category</option>
                                                                {categories.map((cat) => (
                                                                    <option key={cat.id} value={cat.id} className="bg-[#0B1215]">
                                                                        {language === 'ar' ? cat.nameAr : cat.name}
                                                                    </option>
                                                                ))}
                                                            </select>
                                                            <Layers className="absolute left-3 top-3.5 h-4 w-4 text-slate-500" />
                                                            <div className="absolute right-3 top-3.5 pointer-events-none text-slate-500">
                                                                <svg className="h-4 w-4 fill-current" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" /></svg>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Description Section */}
                                                <div className="space-y-4 pt-4 border-t border-white/5">
                                                    <h4 className="text-sm font-semibold text-emerald-500 uppercase tracking-wider flex items-center gap-2">
                                                        <FileText className="h-4 w-4" />
                                                        Descriptions
                                                    </h4>

                                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                        <div className="space-y-2">
                                                            <label className="text-xs font-medium text-slate-400">Description (EN)</label>
                                                            <textarea
                                                                rows={3}
                                                                value={formData.description}
                                                                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                                                className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition-all resize-none"
                                                                placeholder="Product details..."
                                                            />
                                                        </div>
                                                        <div className="space-y-2">
                                                            <label className="text-xs font-medium text-slate-400">Description (AR)</label>
                                                            <textarea
                                                                rows={3}
                                                                value={formData.description_ar}
                                                                onChange={(e) => setFormData({ ...formData, description_ar: e.target.value })}
                                                                className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition-all resize-none"
                                                                placeholder="تفاصيل المنتج..."
                                                                dir="rtl"
                                                            />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Right Column: Pricing & Media */}
                                            <div className="space-y-6">
                                                <div className="space-y-4">
                                                    <h4 className="text-sm font-semibold text-emerald-500 uppercase tracking-wider flex items-center gap-2">
                                                        <DollarSign className="h-4 w-4" />
                                                        Pricing & Inventory
                                                    </h4>

                                                    {/* Price */}
                                                    <div className="space-y-2">
                                                        <label className="text-sm font-medium text-slate-300">{t("productPrice")}</label>
                                                        <div className="relative group">
                                                            <input
                                                                type="number"
                                                                required
                                                                min="0"
                                                                step="0.01"
                                                                value={formData.price}
                                                                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                                                className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 pl-10 text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition-all font-mono text-lg"
                                                                placeholder="0.00"
                                                            />
                                                            <div className="absolute left-3 top-3.5 text-slate-500 group-focus-within:text-emerald-500 transition-colors">
                                                                {t("currency")}
                                                            </div>
                                                        </div>
                                                    </div>

                                                    {/* Stock Toggle */}
                                                    <div className="flex items-center justify-between p-4 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 transition-colors cursor-pointer" onClick={() => setFormData({ ...formData, in_stock: !formData.in_stock })}>
                                                        <div className="flex flex-col">
                                                            <span className="text-sm font-medium text-white">{t("stockStatus")}</span>
                                                            <span className={`text-xs ${formData.in_stock ? 'text-emerald-400' : 'text-slate-400'}`}>
                                                                {formData.in_stock ? t("inStock") : t("outOfStock")}
                                                            </span>
                                                        </div>
                                                        <div className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 focus:ring-offset-[#0B1215] ${formData.in_stock ? 'bg-emerald-500' : 'bg-slate-700'}`}>
                                                            <span
                                                                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${formData.in_stock ? 'translate-x-6' : 'translate-x-1'}`}
                                                            />
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Image Section */}
                                                <div className="space-y-4 pt-4 border-t border-white/5">
                                                    <h4 className="text-sm font-semibold text-emerald-500 uppercase tracking-wider flex items-center gap-2">
                                                        <ImageIcon className="h-4 w-4" />
                                                        Product Media
                                                    </h4>

                                                    <div className="space-y-3">
                                                        <label className="text-sm font-medium text-slate-300">{t("image")}</label>

                                                        <input
                                                            type="file"
                                                            ref={fileInputRef}
                                                            className="hidden"
                                                            accept="image/*"
                                                            onChange={handleImageUpload}
                                                        />

                                                        {formData.image_url ? (
                                                            <div className="relative group rounded-xl overflow-hidden border border-white/10 bg-black/40 aspect-video flex items-center justify-center">
                                                                <img
                                                                    src={formData.image_url}
                                                                    alt="Preview"
                                                                    className="w-full h-full object-contain"
                                                                    onError={(e) => (e.target as HTMLImageElement).src = "https://placehold.co/600x400/000000/FFF?text=Invalid+Image"}
                                                                />
                                                                {/* Loading overlay when overwriting? No, uploading is global for the area */}
                                                                {uploading && (
                                                                    <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
                                                                        <Loader2 className="h-8 w-8 text-emerald-500 animate-spin" />
                                                                    </div>
                                                                )}

                                                                {!uploading && (
                                                                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100 gap-2">
                                                                        <button
                                                                            type="button"
                                                                            onClick={() => fileInputRef.current?.click()}
                                                                            className="p-2 rounded-lg bg-white/10 text-white hover:bg-emerald-500 hover:text-[#0B1215] transition-all"
                                                                        >
                                                                            <Upload className="h-5 w-5" />
                                                                        </button>
                                                                        <button
                                                                            type="button"
                                                                            onClick={() => setFormData({ ...formData, image_url: "" })}
                                                                            className="p-2 rounded-lg bg-white/10 text-white hover:bg-red-500 hover:text-white transition-all"
                                                                        >
                                                                            <X className="h-5 w-5" />
                                                                        </button>
                                                                    </div>
                                                                )}
                                                            </div>
                                                        ) : (
                                                            <div
                                                                onClick={() => !uploading && fileInputRef.current?.click()}
                                                                className={`relative rounded-xl border-2 border-dashed border-white/10 bg-white/5 p-8 text-center transition-all group cursor-pointer ${uploading ? 'opacity-50 cursor-wait' : 'hover:border-emerald-500/50 hover:bg-white/10'}`}
                                                            >
                                                                {uploading ? (
                                                                    <div className="flex flex-col items-center gap-2">
                                                                        <Loader2 className="h-10 w-10 text-emerald-500 animate-spin" />
                                                                        <span className="text-sm font-medium text-slate-400">Uploading...</span>
                                                                    </div>
                                                                ) : (
                                                                    <>
                                                                        <ImageIcon className="mx-auto h-12 w-12 text-slate-400 group-hover:text-emerald-400 transition-colors" />
                                                                        <div className="mt-4 flex flex-col items-center gap-1">
                                                                            <span className="text-sm font-medium text-slate-300">Click to upload image</span>
                                                                            <span className="text-xs text-slate-500">SVG, PNG, JPG or GIF</span>
                                                                        </div>
                                                                    </>
                                                                )}
                                                            </div>
                                                        )}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Footer */}
                                    <div className="px-6 py-4 bg-white/5 border-t border-white/10 flex items-center justify-between">
                                        <button
                                            type="button"
                                            onClick={onClose}
                                            className="px-6 py-2.5 rounded-xl text-sm font-medium text-slate-300 hover:text-white hover:bg-white/10 transition-colors"
                                        >
                                            Cancel
                                        </button>
                                        <button
                                            type="submit"
                                            disabled={loading || uploading}
                                            className="flex items-center gap-2 px-8 py-2.5 rounded-xl bg-emerald-500 text-[#0B1215] text-sm font-bold hover:bg-emerald-400 focus:ring-4 focus:ring-emerald-500/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed transform active:scale-95"
                                        >
                                            {loading ? (
                                                <>
                                                    <Loader2 className="h-4 w-4 animate-spin" />
                                                    Saving...
                                                </>
                                            ) : (
                                                <>
                                                    <CheckCircle2 className="h-4 w-4" />
                                                    {product ? "Save Changes" : "Create Product"}
                                                </>
                                            )}
                                        </button>
                                    </div>
                                </form>
                            </Dialog.Panel>
                        </Transition.Child>
                    </div>
                </div>
            </Dialog>
        </Transition.Root>
    );
}
