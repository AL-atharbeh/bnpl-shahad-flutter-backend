"use client";

import { useState, useEffect } from "react";
import { Banner, LinkType, bannersService } from "@/services/banners.service";
import BannerModal from "@/components/modals/BannerModal";

export default function BannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState<Banner | null>(null);

  useEffect(() => {
    fetchBanners();
  }, []);

  const fetchBanners = async () => {
    setLoading(true);
    try {
      const result = await bannersService.getAll();
      if (result.success) {
        setBanners(result.data);
      }
    } catch (error) {
      console.error("Failed to fetch banners", error);
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (banner: Banner) => {
    setEditingBanner(banner);
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm("هل أنت متأكد من حذف هذا البانر؟")) {
      try {
        await bannersService.delete(id);
        fetchBanners();
      } catch (error) {
        alert("فشل في حذف البانر");
      }
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-50">إدارة البانرات</h1>
          <p className="text-sm text-slate-400">إدارة البانرات الدعائية التي تظهر في تطبيق الهاتف</p>
        </div>
        <button
          onClick={() => { setEditingBanner(null); setIsModalOpen(true); }}
          className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-semibold text-slate-950 hover:bg-emerald-400 transition-colors"
        >
          + إضافة بانر جديد
        </button>
      </div>

      <div className="overflow-hidden rounded-xl border border-slate-800 bg-[#021f2a]">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-slate-800 bg-slate-900/50 text-slate-300">
              <tr>
                <th className="px-6 py-4 font-medium italic">المعاينة</th>
                <th className="px-6 py-4 font-medium italic">العنوان</th>
                <th className="px-6 py-4 font-medium italic">نوع الرابط</th>
                <th className="px-6 py-4 font-medium italic">الترتيب</th>
                <th className="px-6 py-4 font-medium italic">الحالة</th>
                <th className="px-6 py-4 font-medium italic">النقرات</th>
                <th className="px-6 py-4 font-medium italic text-right">الإجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 text-slate-300">
              {loading ? (
                <tr><td colSpan={7} className="px-6 py-12 text-center text-slate-500">جاري التحميل...</td></tr>
              ) : banners.length === 0 ? (
                <tr><td colSpan={7} className="px-6 py-12 text-center text-slate-500">لا توجد بانرات متاحة</td></tr>
              ) : (
                banners.map((banner) => (
                  <tr key={banner.id} className="hover:bg-slate-900/30 transition-colors">
                    <td className="px-6 py-4">
                      <div className="h-12 w-24 overflow-hidden rounded-md border border-slate-700 bg-slate-800">
                        <img src={banner.imageUrl} alt={banner.title} className="h-full w-full object-cover" />
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-medium text-slate-50">{banner.titleAr || banner.title}</div>
                      <div className="text-[11px] text-slate-500">{banner.title}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="rounded-full bg-slate-800 px-2 py-0.5 text-[10px] uppercase text-slate-400 border border-slate-700">
                        {banner.linkType}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-mono text-xs">{banner.sortOrder}</td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-[10px] ${banner.isActive ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/30" : "bg-red-500/10 text-red-400 border border-red-500/30"}`}>
                        <span className={`h-1 w-1 rounded-full ${banner.isActive ? "bg-emerald-400" : "bg-red-400"}`} />
                        {banner.isActive ? "نشط" : "معطل"}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-mono text-xs">{banner.clickCount}</td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex justify-end gap-2">
                        <button onClick={() => handleEdit(banner)} className="rounded-md p-1.5 text-slate-400 hover:bg-slate-800 hover:text-emerald-400 transition-colors">
                          تعديل
                        </button>
                        <button onClick={() => handleDelete(banner.id)} className="rounded-md p-1.5 text-slate-400 hover:bg-slate-800 hover:text-red-400 transition-colors">
                          حذف
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      <BannerModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSuccess={fetchBanners}
        editBanner={editingBanner}
      />
    </div>
  );
}
