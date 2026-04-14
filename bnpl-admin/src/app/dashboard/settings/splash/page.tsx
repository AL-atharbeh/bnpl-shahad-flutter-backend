"use client";

import { useState, useEffect } from "react";
import { configService } from "@/services/config.service";
import { bannersService } from "@/services/banners.service";

export default function SplashSettingsPage() {
  const [imageUrl, setImageUrl] = useState<string>("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [uploadLoading, setUploadLoading] = useState(false);

  useEffect(() => {
    fetchConfig();
  }, []);

  const fetchConfig = async () => {
    try {
      const result = await configService.getSplash();
      if (result.success && result.data) {
        setImageUrl(result.data.splashImageUrl || "");
      }
    } catch (error) {
      console.error("Failed to fetch splash config", error);
    } finally {
      setLoading(false);
    }
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadLoading(true);
    try {
      const result = await bannersService.uploadImage(file);
      if (result.success) {
        setImageUrl(result.data.url);
        alert("تم رفع الصورة بنجاح");
      }
    } catch (err) {
      alert("فشل في رفع الصورة");
    } finally {
      setUploadLoading(false);
    }
  };

  const handleSave = async () => {
    if (!imageUrl) {
      alert("يرجى اختيار صورة أولاً");
      return;
    }

    setSaving(true);
    try {
      await configService.updateSplash(imageUrl);
      alert("تم حفظ إعدادات شاشة الافتتاح بنجاح");
    } catch (error) {
      alert("فشل في حفظ الإعدادات");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex h-96 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-emerald-500 border-t-transparent"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-slate-50">إعدادات شاشة الافتتاح (Splash Screen)</h1>
        <p className="text-sm text-slate-400">تحكم بالصورة التي تظهر للمستخدم عند فتح التطبيق</p>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-8 space-y-8">
        <div className="space-y-4">
          <label className="block text-sm font-medium text-slate-300">معاينة شاشة الافتتاح الحالية</label>
          
          <div className="relative group max-w-sm mx-auto">
            {imageUrl ? (
              <div className="aspect-[9/19] w-full overflow-hidden rounded-2xl border-4 border-slate-800 bg-slate-900 shadow-2xl">
                <img src={imageUrl} alt="Splash Preview" className="h-full w-full object-cover" />
                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                   <button 
                    onClick={() => setImageUrl("")}
                    className="rounded-full bg-red-500 p-3 text-white shadow-xl hover:bg-red-400"
                   >
                    حذف الصورة
                   </button>
                </div>
              </div>
            ) : (
              <label className="flex aspect-[9/19] w-full cursor-pointer flex-col items-center justify-center rounded-2xl border-4 border-dashed border-slate-800 bg-slate-900/40 transition-all hover:border-emerald-500/50 hover:bg-slate-900/60 group">
                <div className="flex flex-col items-center justify-center text-center px-6">
                  <div className="mb-4 rounded-full bg-slate-800 p-4 group-hover:bg-slate-700 transition-colors">
                    <svg className="h-10 w-10 text-slate-500 group-hover:text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                  </div>
                  <p className="text-sm font-medium text-slate-300">اضغط لرفع صورة الـ Splash</p>
                  <p className="mt-2 text-xs text-slate-500">يفضل أبعاد 1242x2688 بيكسل للحصول على أفضل جودة</p>
                </div>
                <input type="file" className="hidden" accept="image/*" onChange={handleFileChange} disabled={uploadLoading} />
              </label>
            )}
          </div>
        </div>

        {uploadLoading && (
          <div className="flex items-center justify-center gap-2 text-sm text-emerald-500">
             <div className="h-4 w-4 animate-spin rounded-full border-2 border-emerald-500 border-t-transparent"></div>
             جاري رفع الصورة...
          </div>
        )}

        <div className="flex justify-center pt-4">
          <button
            onClick={handleSave}
            disabled={saving || uploadLoading || !imageUrl}
            className="flex items-center gap-2 rounded-xl bg-emerald-500 px-12 py-3 text-sm font-bold text-slate-950 hover:bg-emerald-400 transition-all active:scale-95 disabled:opacity-50"
          >
            {saving ? "جاري الحفظ..." : "حفظ شاشة الافتتاح"}
          </button>
        </div>
      </div>

      <div className="rounded-lg bg-emerald-500/5 border border-emerald-500/10 p-4">
        <div className="flex gap-3">
          <svg className="h-5 w-5 text-emerald-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div className="text-xs text-slate-400 leading-relaxed">
            <p className="text-emerald-400 font-semibold mb-1">تلميح احترافي:</p>
            هذه الصورة ستظهر للمستخدمين عند كل عملية فتح للتطبيق. يفضل أن تكون بسيطة، تعبر عن الهوية البصرية، وذات حجم ملف صغير لضمان سرعة التحميل.
          </div>
        </div>
      </div>
    </div>
  );
}
