"use client";

import { useState, useEffect } from "react";
import { getCategoriesAdmin, deleteCategory } from "@/services/api";
import CategoryModal from "@/components/modals/CategoryModal";
import {
    Tag,
    Plus,
    Search,
    Edit2,
    Trash2,
    Eye,
    EyeOff,
    LayoutGrid,
    Users,
    ArrowUpDown
} from "lucide-react";

export default function CategoriesPage() {
    const [categories, setCategories] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [selectedCategory, setSelectedCategory] = useState<any | null>(null);

    useEffect(() => {
        fetchCategories();
    }, []);

    const fetchCategories = async () => {
        setLoading(true);
        try {
            const res = await getCategoriesAdmin();
            setCategories(res.data.data);
        } catch (error) {
            console.error("Failed to fetch categories", error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id: number) => {
        if (!confirm("هل أنت متأكد من حذف هذه الفئة؟ سيتم إخفاؤها من التطبيق.")) return;
        try {
            await deleteCategory(id);
            fetchCategories();
        } catch (error) {
            console.error("Failed to delete category", error);
        }
    };

    const handleEdit = (category: any) => {
        setSelectedCategory(category);
        setShowModal(true);
    };

    const handleAdd = () => {
        setSelectedCategory(null);
        setShowModal(true);
    };

    const filteredCategories = categories.filter(cat =>
        cat.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        cat.nameAr.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <div className="space-y-6" dir="rtl">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-slate-50">إدارة التصنيفات (Categories)</h1>
                    <p className="mt-1 text-xs text-slate-400">إنشاء وتعديل تصنيفات المتاجر والمنتجات في التطبيق.</p>
                </div>
                <button
                    onClick={handleAdd}
                    className="flex items-center gap-2 rounded-xl bg-emerald-500 px-5 py-2.5 text-sm font-bold text-slate-950 hover:bg-emerald-400 transition-all active:scale-95 shadow-lg shadow-emerald-500/20"
                >
                    <Plus className="h-4 w-4" />
                    إضافة فئة جديدة
                </button>
            </div>

            <section className="grid gap-4 md:grid-cols-4">
                <div className="rounded-2xl border border-slate-800 bg-[#021f2a] p-4 shadow-xl">
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">إجمالي الفئات</p>
                    <p className="mt-1 text-2xl font-black text-slate-50">{categories.length}</p>
                </div>
                <div className="rounded-2xl border border-slate-800 bg-[#021f2a] p-4 shadow-xl">
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">الفئات النشطة</p>
                    <p className="mt-1 text-2xl font-black text-emerald-400">{categories.filter(c => c.isActive).length}</p>
                </div>
                <div className="rounded-2xl border border-slate-800 bg-[#021f2a] p-4 shadow-xl">
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">فئات النساء</p>
                    <p className="mt-1 text-2xl font-black text-pink-400">{categories.filter(c => c.genderType === 'Women').length}</p>
                </div>
                <div className="rounded-2xl border border-slate-800 bg-[#021f2a] p-4 shadow-xl">
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">فئات الرجال</p>
                    <p className="mt-1 text-2xl font-black text-blue-400">{categories.filter(c => c.genderType === 'Men').length}</p>
                </div>
            </section>

            <div className="rounded-2xl border border-slate-800 bg-[#021f2a] p-4 shadow-xl">
                <div className="relative mb-6">
                    <Search className="absolute right-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-500" />
                    <input
                        type="text"
                        placeholder="ابحث عن فئة..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full rounded-xl border border-slate-800 bg-slate-900/50 py-2.5 pr-11 pl-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all placeholder:text-slate-600"
                    />
                </div>

                <div className="overflow-x-auto rounded-xl">
                    <table className="w-full text-right text-sm">
                        <thead className="bg-slate-900/80 text-xs font-bold text-slate-500 uppercase">
                            <tr>
                                <th className="px-6 py-4">الفئة</th>
                                <th className="px-6 py-4">الجمهور</th>
                                <th className="px-6 py-4">الترتيب</th>
                                <th className="px-6 py-4">المتاجر</th>
                                <th className="px-6 py-4">الحالة</th>
                                <th className="px-6 py-4 text-center">الإجراءات</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-800/50">
                            {loading ? (
                                <tr>
                                    <td colSpan={6} className="py-20 text-center">
                                        <div className="flex justify-center flex-col items-center gap-4">
                                            <div className="h-8 w-8 animate-spin border-4 border-emerald-500 border-t-transparent rounded-full" />
                                            <span className="text-slate-500 font-medium">جاري تحميل التصنيفات...</span>
                                        </div>
                                    </td>
                                </tr>
                            ) : filteredCategories.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="py-20 text-center text-slate-500">
                                        لا توجد نتائج مطابقة لبحثك.
                                    </td>
                                </tr>
                            ) : filteredCategories.map((cat) => (
                                <tr key={cat.id} className="hover:bg-slate-800/20 transition-colors group">
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            <div className="h-10 w-10 flex-shrink-0 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center">
                                                {cat.imageUrl ? (
                                                    <img src={cat.imageUrl} alt={cat.name} className="h-full w-full object-cover rounded-lg" />
                                                ) : (
                                                    <Tag className="h-5 w-5 text-emerald-500" />
                                                )}
                                            </div>
                                            <div>
                                                <div className="font-bold text-slate-100">{cat.nameAr}</div>
                                                <div className="text-[10px] text-slate-500">{cat.name}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-1.5 text-xs text-slate-300">
                                            <Users className="h-3 w-3 text-slate-500" />
                                            {cat.genderType === 'Women' ? 'نساء' :
                                                cat.genderType === 'Men' ? 'رجال' :
                                                    cat.genderType === 'Kids' ? 'أطفال' : 'الكل'}
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-1.5 text-xs font-bold text-slate-400">
                                            <ArrowUpDown className="h-3 w-3" />
                                            {cat.sortOrder}
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-1.5">
                                            <LayoutGrid className="h-3 w-3 text-emerald-500/50" />
                                            <span className="font-black text-slate-200">{cat.storesCount || 0}</span>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">
                                        {cat.isActive ? (
                                            <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/10 px-2 py-1 text-[10px] font-bold text-emerald-400 border border-emerald-500/20">
                                                <Eye className="h-2.5 w-2.5" />
                                                نشط
                                            </span>
                                        ) : (
                                            <span className="inline-flex items-center gap-1 rounded-full bg-red-500/10 px-2 py-1 text-[10px] font-bold text-red-400 border border-red-500/20">
                                                <EyeOff className="h-2.5 w-2.5" />
                                                معطل
                                            </span>
                                        )}
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center justify-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <button
                                                onClick={() => handleEdit(cat)}
                                                className="h-8 w-8 rounded-lg bg-slate-800 flex items-center justify-center text-slate-400 hover:text-emerald-400 hover:bg-emerald-500/10 transition-all shadow-xl"
                                            >
                                                <Edit2 className="h-4 w-4" />
                                            </button>
                                            <button
                                                onClick={() => handleDelete(cat.id)}
                                                className="h-8 w-8 rounded-lg bg-slate-800 flex items-center justify-center text-slate-400 hover:text-red-400 hover:bg-red-500/10 transition-all shadow-xl"
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            <CategoryModal
                isOpen={showModal}
                onClose={() => setShowModal(false)}
                onSuccess={fetchCategories}
                category={selectedCategory}
            />
        </div>
    );
}
