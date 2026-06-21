"use client";

import { useState, useEffect } from "react";
import { FeaturedBrand, featuredBrandsService } from "@/services/featured-brands.service";
import { Store, storesService } from "@/services/stores.service";
import { bannersService } from "@/services/banners.service";
import { X, Upload, Store as StoreIcon, ImageIcon, CheckCircle2, ChevronDown } from "lucide-react";

interface FeaturedBrandModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  editBrand?: FeaturedBrand | null;
}

const initialFormData = {
  storeId: "",
  imageUrl: "",
  isActive: true,
  sortOrder: "0",
};

export default function FeaturedBrandModal({ isOpen, onClose, onSuccess, editBrand }: FeaturedBrandModalProps) {
  const [formData, setFormData] = useState(initialFormData);
  const [stores, setStores] = useState<Store[]>([]);
  const [loading, setLoading] = useState(false);
  const [uploadLoading, setUploadLoading] = useState(false);
  const [error, setError] = useState("");

  const isEditMode = !!editBrand;

  useEffect(() => {
    if (isOpen) {
      fetchStores();
      if (editBrand) {
        setFormData({
          storeId: editBrand.storeId?.toString() || "",
          imageUrl: editBrand.imageUrl || "",
          isActive: editBrand.isActive,
          sortOrder: editBrand.sortOrder?.toString() || "0",
        });
      } else {
        setFormData(initialFormData);
      }
    }
  }, [isOpen, editBrand]);

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

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadLoading(true);
    setError("");
    try {
      const result = await bannersService.uploadImage(file);
      if (result.success) {
        setFormData(prev => ({ ...prev, imageUrl: result.data.url }));
      }
    } catch (err: any) {
      console.error("Upload failed", err);
      const errorMessage = err.response?.data?.message || err.message || "فشل في رفع الصورة";
      setError(`خطأ في الرفع: ${errorMessage}`);
    } finally {
      setUploadLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!formData.storeId) {
      setError("يرجى اختيار المتجر");
      return;
    }

    if (!formData.imageUrl) {
      setError("صورة العرض مطلوبة");
      return;
    }

    setLoading(true);
    try {
      const payload = {
        storeId: Number(formData.storeId),
        imageUrl: formData.imageUrl,
        isActive: formData.isActive,
        sortOrder: Number(formData.sortOrder),
      };

      if (isEditMode && editBrand) {
        await featuredBrandsService.update(editBrand.id, payload);
      } else {
        await featuredBrandsService.create(payload);
      }

      onSuccess();
      onClose();
    } catch (error: any) {
      console.error("Failed to save featured brand", error);
      setError("فشل في حفظ البيانات. تأكد من صحة المدخلات.");
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  const inputClass = "w-full rounded-xl border border-slate-700 bg-slate-900/60 px-4 py-2.5 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/50 focus:outline-none focus:ring-4 focus:ring-emerald-500/10 transition-all shadow-inner";
  const labelClass = "block text-[11px] font-black text-slate-500 uppercase tracking-[0.1em] mb-2 ml-1";

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/85 backdrop-blur-md p-4">
      <div className="relative w-full max-w-2xl max-h-[92vh] overflow-y-auto rounded-3xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
        {/* Visual Accent */}
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-emerald-500 to-transparent opacity-50" />

        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-800 bg-slate-900/10 px-8 py-5">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-400">
              <StoreIcon className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-slate-50">
                {isEditMode ? "تعديل العلامة المميزة" : "إضافة علامة مميزة جديدة"}
              </h2>
              <p className="text-xs text-slate-400 mt-1">تحديد متجر ليظهر كعلامة تجارية مميزة في التطبيق</p>
            </div>
          </div>
          <button onClick={onClose} className="rounded-xl border border-slate-800 bg-slate-900/40 p-2 text-slate-400 hover:text-slate-50 hover:bg-slate-800 transition-colors">✕</button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-8 space-y-6">
          {error && <div className="rounded-xl bg-red-500/10 border border-red-500/40 p-4 text-red-200 text-sm">{error}</div>}

          {/* Store Selection */}
          <div className="space-y-2">
            <label className={labelClass}>المتجر المختار *</label>
            <div className="relative">
              <select
                value={formData.storeId}
                onChange={e => setFormData({ ...formData, storeId: e.target.value })}
                className={`${inputClass} appearance-none pr-10`}
                required
              >
                <option value="">اختر المتجر...</option>
                {stores.map((store) => (
                  <option key={store.id} value={store.id}>
                    {store.nameAr || store.name}
                  </option>
                ))}
              </select>
              <ChevronDown className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500 pointer-events-none" />
            </div>
          </div>

          {/* Image Upload */}
          <div className="space-y-2">
            <label className={labelClass}>صورة العرض المستطيلة *</label>
            <div className="flex flex-col gap-4">
              {formData.imageUrl ? (
                <div className="relative aspect-[21/9] w-full overflow-hidden rounded-2xl border border-slate-700 bg-slate-800 shadow-inner group">
                  <img src={formData.imageUrl} alt="Preview" className="h-full w-full object-cover" />
                  <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center backdrop-blur-sm">
                    <button
                      type="button"
                      onClick={() => setFormData({ ...formData, imageUrl: "" })}
                      className="rounded-xl bg-red-500 px-5 py-2 text-xs font-bold text-white shadow-lg hover:bg-red-400 transition-all hover:scale-105 active:scale-95"
                    >
                      حذف الصورة
                    </button>
                  </div>
                </div>
              ) : (
                <label className="flex aspect-[21/9] w-full cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed border-slate-700 bg-slate-900/40 hover:border-emerald-500/50 hover:bg-emerald-500/[0.01] transition-all group">
                  <div className="flex flex-col items-center justify-center p-6 text-center">
                    {uploadLoading ? (
                      <div className="flex flex-col items-center gap-3">
                        <div className="h-8 w-8 animate-spin rounded-full border-3 border-emerald-500 border-t-transparent" />
                        <span className="text-xs text-emerald-400 font-bold">جاري رفع الصورة...</span>
                      </div>
                    ) : (
                      <>
                        <div className="mb-4 rounded-2xl bg-white/[0.02] p-4 text-slate-400 group-hover:bg-emerald-500/10 group-hover:text-emerald-400 transition-all">
                          <Upload className="h-8 w-8" />
                        </div>
                        <p className="text-sm font-bold text-slate-200">اضغط لرفع صورة العرض</p>
                        <p className="mt-1 text-xs text-slate-500">أو اسحب وأفلت الملف هنا (يُفضل تصميم مستطيل)</p>
                      </>
                    )}
                  </div>
                  <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} disabled={uploadLoading} />
                </label>
              )}
            </div>
          </div>

          {/* Settings */}
          <div className="grid grid-cols-2 gap-6 pt-2">
            <div className="flex items-center justify-between p-4 rounded-2xl bg-white/[0.01] border border-slate-800">
              <span className="text-xs font-bold text-slate-300">نشط الآن</span>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.isActive}
                  onChange={e => setFormData({ ...formData, isActive: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:left-1 after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
              </label>
            </div>

            <div className="flex items-center justify-between p-4 rounded-2xl bg-white/[0.01] border border-slate-800">
              <span className="text-xs font-bold text-slate-300">ترتيب الظهور:</span>
              <input
                type="number"
                value={formData.sortOrder}
                onChange={e => setFormData({ ...formData, sortOrder: e.target.value })}
                className={`${inputClass} w-20 text-center py-1.5 px-2`}
              />
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex justify-end gap-3 pt-6 border-t border-slate-800">
            <button
              type="button"
              onClick={onClose}
              className="text-sm font-bold text-slate-400 hover:text-slate-200 transition-colors px-4 py-2"
              disabled={loading}
            >
              إلغاء
            </button>
            <button
              type="submit"
              disabled={loading || uploadLoading}
              className="rounded-xl bg-emerald-500 px-8 py-2.5 text-sm font-bold text-slate-950 hover:bg-emerald-400 transition-all hover:shadow-[0_0_20px_rgba(16,185,129,0.3)] disabled:opacity-50"
            >
              {loading ? "جاري الحفظ..." : isEditMode ? "حفظ التغييرات" : "إضافة الآن"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
