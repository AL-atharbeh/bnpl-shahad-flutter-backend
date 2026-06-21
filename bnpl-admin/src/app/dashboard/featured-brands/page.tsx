"use client";

import { useState, useEffect } from "react";
import { FeaturedBrand, featuredBrandsService } from "@/services/featured-brands.service";
import FeaturedBrandModal from "@/components/modals/FeaturedBrandModal";

export default function FeaturedBrandsPage() {
  const [brands, setBrands] = useState<FeaturedBrand[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBrand, setEditingBrand] = useState<FeaturedBrand | null>(null);

  useEffect(() => {
    fetchBrands();
  }, []);

  const fetchBrands = async () => {
    setLoading(true);
    try {
      const result = await featuredBrandsService.getAll();
      if (result.success) {
        setBrands(result.data);
      }
    } catch (error) {
      console.error("Failed to fetch featured brands", error);
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (brand: FeaturedBrand) => {
    setEditingBrand(brand);
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm("هل أنت متأكد من حذف هذه العلامة التجارية المميزة؟")) {
      try {
        await featuredBrandsService.delete(id);
        fetchBrands();
      } catch (error) {
        alert("فشل في حذف العلامة التجارية المميزة");
      }
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-55">العلامات التجارية المميزة</h1>
          <p className="text-sm text-slate-400">إدارة المتاجر التي تظهر كعلامات مميزة في الجزء العلوي من شاشة التطبيق الرئيسية</p>
        </div>
        <button
          onClick={() => { setEditingBrand(null); setIsModalOpen(true); }}
          className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-semibold text-slate-950 hover:bg-emerald-400 transition-colors"
        >
          + إضافة علامة مميزة جديدة
        </button>
      </div>

      <div className="overflow-hidden rounded-xl border border-slate-800 bg-[#021f2a]">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-slate-800 bg-slate-900/50 text-slate-300">
              <tr>
                <th className="px-6 py-4 font-medium italic">المعاينة</th>
                <th className="px-6 py-4 font-medium italic">المتجر</th>
                <th className="px-6 py-4 font-medium italic">الترتيب</th>
                <th className="px-6 py-4 font-medium italic">الحالة</th>
                <th className="px-6 py-4 font-medium italic text-right">الإجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 text-slate-300">
              {loading ? (
                <tr><td colSpan={5} className="px-6 py-12 text-center text-slate-500">جاري التحميل...</td></tr>
              ) : brands.length === 0 ? (
                <tr><td colSpan={5} className="px-6 py-12 text-center text-slate-500">لا توجد علامات تجارية مميزة مضافة بعد</td></tr>
              ) : (
                brands.map((brand) => (
                  <tr key={brand.id} className="hover:bg-slate-900/30 transition-colors">
                    <td className="px-6 py-4">
                      <div className="h-16 w-36 overflow-hidden rounded-md border border-slate-700 bg-slate-800">
                        <img src={brand.imageUrl} alt="Featured Brand Card" className="h-full w-full object-cover" />
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="h-9 w-9 overflow-hidden rounded-full border border-slate-700 bg-slate-800">
                          {brand.store?.logoUrl ? (
                            <img src={brand.store.logoUrl} alt={brand.store.name} className="h-full w-full object-cover" />
                          ) : (
                            <div className="flex h-full w-full items-center justify-center text-xs text-slate-400 font-bold bg-slate-850">
                              {brand.store?.nameAr?.[0] || brand.store?.name?.[0] || "S"}
                            </div>
                          )}
                        </div>
                        <div>
                          <div className="font-medium text-slate-50">{brand.store?.nameAr || brand.store?.name}</div>
                          <div className="text-[11px] text-slate-500">{brand.store?.name}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 font-mono text-xs">{brand.sortOrder}</td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-[10px] ${brand.isActive ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/30" : "bg-red-500/10 text-red-400 border border-red-500/30"}`}>
                        <span className={`h-1.5 w-1.5 rounded-full ${brand.isActive ? "bg-emerald-400" : "bg-red-400"}`} />
                        {brand.isActive ? "نشط" : "معطل"}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex justify-end gap-2">
                        <button onClick={() => handleEdit(brand)} className="rounded-md p-1.5 text-slate-400 hover:bg-slate-800 hover:text-emerald-400 transition-colors">
                          تعديل
                        </button>
                        <button onClick={() => handleDelete(brand.id)} className="rounded-md p-1.5 text-slate-400 hover:bg-slate-800 hover:text-red-400 transition-colors">
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

      <FeaturedBrandModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSuccess={fetchBrands}
        editBrand={editingBrand}
      />
    </div>
  );
}
