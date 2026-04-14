"use client";

import { useState, useEffect } from "react";
import { Banner, LinkType, bannersService } from "@/services/banners.service";

interface BannerModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  editBanner?: Banner | null;
}

const initialFormData = {
  title: "",
  titleAr: "",
  imageUrl: "",
  linkUrl: "",
  linkType: LinkType.NONE,
  linkId: "",
  categoryId: "",
  description: "",
  descriptionAr: "",
  isActive: true,
  sortOrder: "0",
  startDate: "",
  endDate: "",
};

export default function BannerModal({ isOpen, onClose, onSuccess, editBanner }: BannerModalProps) {
  const [formData, setFormData] = useState(initialFormData);
  const [loading, setLoading] = useState(false);
  const [uploadLoading, setUploadLoading] = useState(false);
  const [error, setError] = useState("");

  const isEditMode = !!editBanner;

  useEffect(() => {
    if (isOpen) {
      if (editBanner) {
        setFormData({
          title: editBanner.title || "",
          titleAr: editBanner.titleAr || "",
          imageUrl: editBanner.imageUrl || "",
          linkUrl: editBanner.linkUrl || "",
          linkType: editBanner.linkType || LinkType.NONE,
          linkId: editBanner.linkId?.toString() || "",
          categoryId: editBanner.categoryId?.toString() || "",
          description: editBanner.description || "",
          descriptionAr: editBanner.descriptionAr || "",
          isActive: editBanner.isActive,
          sortOrder: editBanner.sortOrder?.toString() || "0",
          startDate: editBanner.startDate ? new Date(editBanner.startDate).toISOString().split('T')[0] : "",
          endDate: editBanner.endDate ? new Date(editBanner.endDate).toISOString().split('T')[0] : "",
        });
      } else {
        setFormData(initialFormData);
      }
    }
  }, [isOpen, editBanner]);

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

    if (!formData.imageUrl) {
      setError("صورة البانر مطلوبة");
      return;
    }

    setLoading(true);
    try {
      const payload: any = {
        ...formData,
        linkId: formData.linkId ? Number(formData.linkId) : undefined,
        categoryId: formData.categoryId ? Number(formData.categoryId) : undefined,
        sortOrder: Number(formData.sortOrder),
        startDate: formData.startDate || undefined,
        endDate: formData.endDate || undefined,
      };

      if (isEditMode && editBanner) {
        await bannersService.update(editBanner.id, payload);
      } else {
        await bannersService.create(payload);
      }

      onSuccess();
      onClose();
    } catch (error: any) {
      console.error("Failed to save banner", error);
      setError("فشل في حفظ البانر. تأكد من صحة البيانات.");
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  const inputClass = "w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20";

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="relative w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
        <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4 z-10">
          <h2 className="text-lg font-semibold text-slate-50">
            {isEditMode ? "تعديل البانر" : "إضافة بانر جديد"}
          </h2>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-50">✕</button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && <div className="rounded-lg bg-red-500/10 border border-red-500/50 p-3 text-red-200 text-sm">{error}</div>}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">العنوان (EN)</label>
              <input type="text" value={formData.title} onChange={e => setFormData({ ...formData, title: e.target.value })} className={inputClass} placeholder="Summer Sale" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">العنوان (AR)</label>
              <input type="text" value={formData.titleAr} onChange={e => setFormData({ ...formData, titleAr: e.target.value })} className={inputClass} placeholder="عروض الصيف" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">صورة البانر *</label>
            <div className="flex flex-col gap-4">
              {formData.imageUrl && (
                <div className="relative h-48 w-full overflow-hidden rounded-lg border border-slate-700 bg-slate-800 shadow-inner">
                  <img src={formData.imageUrl} alt="Preview" className="h-full w-full object-cover" />
                  <div className="absolute inset-0 bg-black/20 opacity-0 hover:opacity-100 transition-opacity flex items-center justify-center">
                     <button
                        type="button"
                        onClick={() => setFormData({ ...formData, imageUrl: "" })}
                        className="rounded-full bg-red-500 p-2 text-white shadow-lg hover:bg-red-400"
                      >
                        حذف الصورة
                      </button>
                  </div>
                </div>
              )}
              
              {!formData.imageUrl && (
                <label className="flex h-48 w-full cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed border-slate-700 bg-slate-900/40 transition-all hover:border-emerald-500/50 hover:bg-slate-900/60 group">
                  <div className="flex flex-col items-center justify-center pb-6 pt-5">
                    <div className="mb-3 rounded-full bg-slate-800 p-3 group-hover:bg-slate-700 group-hover:text-emerald-400 transition-colors">
                      <svg className="h-8 w-8 text-slate-400 group-hover:text-emerald-400" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 16">
                        <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 13h3a3 3 0 0 0 0-6h-.025A5.56 5.56 0 0 0 16 6.5 5.5 5.5 0 0 0 5.207 5.021C5.137 5.017 5.071 5 5 5a4 4 0 0 0 0 8h2.167M10 15V6m0 0L8 8m2-2 2 2"/>
                      </svg>
                    </div>
                    <p className="mb-2 text-sm text-slate-400 text-center px-4">
                      {uploadLoading ? (
                        <span className="flex items-center gap-2">
                          <span className="h-4 w-4 animate-spin rounded-full border-2 border-emerald-500 border-t-transparent"></span>
                          جاري الرفع...
                        </span>
                      ) : (
                        <>
                          <span className="font-semibold text-emerald-500">اضغط لرفع الصورة</span> أو اسحبها هنا
                        </>
                      )}
                    </p>
                    <p className="text-xs text-slate-500">PNG, JPG, JPEG or WEBP (يفضل 1200x600)</p>
                  </div>
                  <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} disabled={uploadLoading} />
                </label>
              )}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">نوع الرابط</label>
              <select value={formData.linkType} onChange={e => setFormData({ ...formData, linkType: e.target.value as LinkType })} className={inputClass}>
                <option value={LinkType.NONE}>بدون رابط</option>
                <option value={LinkType.STORE}>متجر (Store)</option>
                <option value={LinkType.CATEGORY}>تصنيف (Category)</option>
                <option value={LinkType.PRODUCT}>منتج (Product)</option>
                <option value={LinkType.EXTERNAL}>رابط خارجي (External)</option>
                <option value={LinkType.NONE}>بدون رابط</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">ID الرابط / URL</label>
              {formData.linkType === LinkType.EXTERNAL ? (
                <input type="url" value={formData.linkUrl} onChange={e => setFormData({ ...formData, linkUrl: e.target.value })} className={inputClass} placeholder="https://external.com" />
              ) : (
                <input type="number" value={formData.linkId} onChange={e => setFormData({ ...formData, linkId: e.target.value })} className={inputClass} placeholder="ID" disabled={formData.linkType === LinkType.NONE} />
              )}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">تاريخ البدء</label>
              <input type="date" value={formData.startDate} onChange={e => setFormData({ ...formData, startDate: e.target.value })} className={inputClass} />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">تاريخ الانتهاء</label>
              <input type="date" value={formData.endDate} onChange={e => setFormData({ ...formData, endDate: e.target.value })} className={inputClass} />
            </div>
          </div>

          <div className="flex items-center gap-6 pt-2">
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" checked={formData.isActive} onChange={e => setFormData({ ...formData, isActive: e.target.checked })} className="h-4 w-4 rounded border-slate-700 bg-slate-900 text-emerald-500" />
              <span className="text-sm text-slate-300">نشط</span>
            </label>
            <div className="flex items-center gap-2 flex-1">
              <label className="text-sm font-medium text-slate-300 whitespace-nowrap">الترتيب:</label>
              <input type="number" value={formData.sortOrder} onChange={e => setFormData({ ...formData, sortOrder: e.target.value })} className={`${inputClass} w-24`} />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-6 border-t border-slate-800">
            <button type="button" onClick={onClose} className="px-4 py-2 text-sm text-slate-300 hover:text-slate-50 transition-colors">إلغاء</button>
            <button type="submit" disabled={loading || uploadLoading} className="rounded-lg bg-emerald-500 px-6 py-2 text-sm font-semibold text-slate-950 hover:bg-emerald-400 transition-colors disabled:opacity-50">
              {loading ? "جاري الحفظ..." : "حفظ البانر"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
