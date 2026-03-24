"use client";

import { useState, useEffect } from "react";
import { createCategory, updateCategory } from "@/services/api";
import { Upload, X, Image as ImageIcon } from "lucide-react";

interface CategoryModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    category: any | null;
}

export default function CategoryModal({
    isOpen,
    onClose,
    onSuccess,
    category,
}: CategoryModalProps) {
    const [formData, setFormData] = useState({
        name: "",
        nameAr: "",
        genderType: "All",
        imageUrl: "",
        description: "",
        descriptionAr: "",
        isActive: true,
        sortOrder: 1,
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    useEffect(() => {
        if (category) {
            setFormData({
                name: category.name || "",
                nameAr: category.nameAr || "",
                genderType: category.genderType || "All",
                imageUrl: category.imageUrl || "",
                description: category.description || "",
                descriptionAr: category.descriptionAr || "",
                isActive: category.isActive !== undefined ? category.isActive : true,
                sortOrder: category.sortOrder || 1,
            });
        } else {
            setFormData({
                name: "",
                nameAr: "",
                genderType: "All",
                imageUrl: "",
                description: "",
                descriptionAr: "",
                isActive: true,
                sortOrder: 1,
            });
        }
    }, [category, isOpen]);

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            if (file.size > 5 * 1024 * 1024) {
                setError("حجم الصورة كبير جداً (يجب أن يكون أقل من 5 ميجابايت)");
                return;
            }
            const reader = new FileReader();
            reader.onloadend = () => {
                setFormData({ ...formData, imageUrl: reader.result as string });
            };
            reader.readAsDataURL(file);
        }
    };

    const removeImage = () => {
        setFormData({ ...formData, imageUrl: "" });
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            if (category) {
                await updateCategory(category.id, formData);
            } else {
                await createCategory(formData);
            }
            onSuccess();
            onClose();
        } catch (err: any) {
            setError(err.response?.data?.message || "حدث خطأ ما");
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-sm">
            <div className="w-full max-w-2xl rounded-2xl border border-slate-800 bg-[#021f2a] p-6 shadow-2xl">
                <div className="mb-6 flex items-center justify-between border-b border-slate-800 pb-4">
                    <h2 className="text-xl font-bold text-slate-50">
                        {category ? "تعديل فئة" : "إضافة فئة جديدة"}
                    </h2>
                    <button
                        onClick={onClose}
                        className="text-slate-400 hover:text-slate-100 transition-colors"
                    >
                        <X className="h-5 w-5" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4 text-right" dir="rtl">
                    {error && (
                        <div className="rounded-lg bg-red-500/10 border border-red-500/20 p-3 text-xs text-red-400">
                            {error}
                        </div>
                    )}

                    {/* Image Upload Selection */}
                    <div className="space-y-2">
                        <label className="text-xs font-bold text-slate-400 mr-1">صورة الفئة</label>
                        <div className="flex flex-col items-center justify-center border-2 border-dashed border-slate-700 rounded-2xl p-6 bg-slate-900/30 hover:bg-slate-900/50 transition-all group relative overflow-hidden">
                            {formData.imageUrl ? (
                                <div className="relative group">
                                    <img
                                        src={formData.imageUrl}
                                        alt="Category"
                                        className="h-32 w-32 object-cover rounded-xl border-2 border-emerald-500/30 shadow-2xl"
                                    />
                                    <button
                                        type="button"
                                        onClick={removeImage}
                                        className="absolute -top-2 -right-2 h-6 w-6 rounded-full bg-red-500 text-white flex items-center justify-center shadow-lg hover:bg-red-600 transition-colors"
                                    >
                                        <X className="h-4 w-4" />
                                    </button>
                                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded-xl pointer-events-none">
                                        <span className="text-[10px] text-white font-black uppercase tracking-tighter">تغيير الصورة</span>
                                    </div>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        onChange={handleFileChange}
                                        className="absolute inset-0 opacity-0 cursor-pointer"
                                    />
                                </div>
                            ) : (
                                <label className="flex flex-col items-center justify-center cursor-pointer py-4 w-full">
                                    <div className="h-16 w-16 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform shadow-lg shadow-emerald-500/5">
                                        <Upload className="h-8 w-8 text-emerald-500" />
                                    </div>
                                    <span className="text-sm font-bold text-slate-200">اختر صورة للفئة</span>
                                    <span className="text-[10px] text-slate-500 mt-1">PNG, JPG (أقصى حجم 5MB)</span>
                                    <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} />
                                </label>
                            )}
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-1">
                            <label className="text-xs text-slate-400">اسم الفئة (English)</label>
                            <input
                                type="text"
                                required
                                value={formData.name}
                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 outline-none transition-all"
                                dir="ltr"
                            />
                        </div>
                        <div className="space-y-1">
                            <label className="text-xs text-slate-400">اسم الفئة (بالعربية)</label>
                            <input
                                type="text"
                                required
                                value={formData.nameAr}
                                onChange={(e) => setFormData({ ...formData, nameAr: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 outline-none transition-all"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-1">
                            <label className="text-xs text-slate-400">نوع الجمهور</label>
                            <select
                                value={formData.genderType}
                                onChange={(e) => setFormData({ ...formData, genderType: e.target.value })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 outline-none transition-all"
                            >
                                <option value="All">الكل (All)</option>
                                <option value="Women">نساء (Women)</option>
                                <option value="Men">رجال (Men)</option>
                                <option value="Kids">أطفال (Kids)</option>
                            </select>
                        </div>
                        <div className="space-y-1">
                            <label className="text-xs text-slate-400">ترتيب الظهور</label>
                            <input
                                type="number"
                                value={formData.sortOrder}
                                onChange={(e) => setFormData({ ...formData, sortOrder: parseInt(e.target.value) })}
                                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 outline-none transition-all"
                            />
                        </div>
                    </div>

                    <div className="space-y-1">
                        <label className="text-xs text-slate-400">الوصف (English)</label>
                        <textarea
                            value={formData.description}
                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                            className="w-full h-20 rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 outline-none transition-all"
                            dir="ltr"
                        />
                    </div>

                    <div className="space-y-1">
                        <label className="text-xs text-slate-400">الوصف (بالعربية)</label>
                        <textarea
                            value={formData.descriptionAr}
                            onChange={(e) => setFormData({ ...formData, descriptionAr: e.target.value })}
                            className="w-full h-20 rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 outline-none transition-all"
                        />
                    </div>

                    <div className="flex items-center gap-2">
                        <input
                            type="checkbox"
                            role="active-checkbox"
                            checked={formData.isActive}
                            onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                            className="rounded border-slate-700 bg-slate-900 text-emerald-500 focus:ring-emerald-500"
                        />
                        <label className="text-xs font-bold text-slate-400">نشط (متاح في التطبيق)</label>
                    </div>

                    <div className="mt-8 flex justify-end gap-3">
                        <button
                            type="button"
                            onClick={onClose}
                            className="rounded-xl border border-slate-700 bg-slate-900/60 px-6 py-2.5 text-sm text-slate-300 hover:bg-slate-900 transition-all font-bold"
                        >
                            إلغاء
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex items-center gap-2 rounded-xl bg-emerald-500 px-10 py-2.5 text-sm font-black text-slate-950 hover:bg-emerald-400 active:scale-95 transition-all shadow-lg shadow-emerald-500/10 disabled:opacity-50"
                        >
                            {loading && <div className="h-4 w-4 animate-spin border-2 border-slate-950 border-t-transparent rounded-full" />}
                            {category ? "تحديث الفئة" : "إضافة الفئة"}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
