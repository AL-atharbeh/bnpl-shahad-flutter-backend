"use client";

import { useState, useEffect } from "react";
import {
    Plus,
    Trash2,
    Calendar,
    DollarSign,
    Star,
    Check,
    X,
    Clock,
    Edit2
} from "lucide-react";

import { getExtensionOptions, deleteExtensionOption, createExtensionOption, updateExtensionOption } from "@/services/api";

export default function ExtensionOptionsPage() {
    const [options, setOptions] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [showAddForm, setShowAddForm] = useState(false);
    const [editingId, setEditingId] = useState<number | null>(null);
    const [newOption, setNewOption] = useState({
        days: 7,
        fee: 0.5,
        nameAr: "",
        nameEn: "",
        isPopular: false
    });

    useEffect(() => {
        fetchOptions();
    }, []);

    const fetchOptions = async () => {
        setLoading(true);
        try {
            const res = await getExtensionOptions();
            setOptions(res.data.data);
        } catch (error) {
            console.error("Failed to fetch extension options", error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id: number) => {
        if (!confirm("هل أنت متأكد من حذف خيار التمديد هذا؟")) return;
        try {
            await deleteExtensionOption(id);
            fetchOptions();
        } catch (error) {
            console.error("Failed to delete option", error);
        }
    };

    const handleCreate = async () => {
        if (!newOption.nameAr || !newOption.nameEn) {
            alert("يرجى ملء جميع الحقول");
            return;
        }
        try {
            if (editingId) {
                await updateExtensionOption(editingId, newOption);
            } else {
                await createExtensionOption(newOption);
            }
            setShowAddForm(false);
            setEditingId(null);
            setNewOption({
                days: 7,
                fee: 0.5,
                nameAr: "",
                nameEn: "",
                isPopular: false
            });
            fetchOptions();
        } catch (error) {
            console.error("Failed to save option", error);
        }
    };

    const handleEdit = (option: any) => {
        setEditingId(option.id);
        setNewOption({
            days: option.days,
            fee: parseFloat(option.fee),
            nameAr: option.nameAr,
            nameEn: option.nameEn,
            isPopular: option.isPopular
        });
        setShowAddForm(true);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    const handleCancel = () => {
        setShowAddForm(false);
        setEditingId(null);
        setNewOption({
            days: 7,
            fee: 0.5,
            nameAr: "",
            nameEn: "",
            isPopular: false
        });
    };

    return (
        <div className="space-y-6" dir="rtl">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-slate-50">إدارة خيارات التمديد (Extension Options)</h1>
                    <p className="mt-1 text-xs text-slate-400">تحديد مدد التمديد المتاحة للمستخدمين وأسعارها.</p>
                </div>
                <button
                    onClick={showAddForm ? handleCancel : () => setShowAddForm(true)}
                    className="flex items-center gap-2 rounded-xl bg-emerald-500 px-5 py-2.5 text-sm font-bold text-slate-950 hover:bg-emerald-400 transition-all active:scale-95 shadow-lg shadow-emerald-500/20"
                >
                    {showAddForm ? <X className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
                    {showAddForm ? "إلغاء" : "إضافة خيار جديد"}
                </button>
            </div>

            {showAddForm && (
                <div className="rounded-2xl border border-emerald-500/30 bg-[#022a3a] p-6 shadow-xl animate-in fade-in slide-in-from-top-4 duration-300">
                    <h2 className="text-sm font-bold text-emerald-400 mb-4 flex items-center gap-2">
                        {editingId ? <Edit2 className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
                        {editingId ? "تعديل خيار التمديد" : "تفاصيل الخيار الجديد"}
                    </h2>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                        <div className="space-y-1.5">
                            <label className="text-xs text-slate-400 mr-1">الاسم بالعربية</label>
                            <input
                                type="text"
                                value={newOption.nameAr}
                                onChange={(e) => setNewOption({ ...newOption, nameAr: e.target.value })}
                                className="w-full rounded-xl border border-slate-700 bg-slate-900/50 px-4 py-2.5 text-sm text-slate-200 outline-none focus:border-emerald-500"
                                placeholder="مثال: تمديد لمدة أسبوع"
                            />
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-slate-400 mr-1">الاسم بالإنجليزية</label>
                            <input
                                type="text"
                                value={newOption.nameEn}
                                onChange={(e) => setNewOption({ ...newOption, nameEn: e.target.value })}
                                className="w-full rounded-xl border border-slate-700 bg-slate-900/50 px-4 py-2.5 text-sm text-slate-200 outline-none focus:border-emerald-500"
                                placeholder="Example: 1 Week Extension"
                            />
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-slate-400 mr-1">عدد الأيام</label>
                            <input
                                type="number"
                                value={newOption.days}
                                onChange={(e) => setNewOption({ ...newOption, days: parseInt(e.target.value) })}
                                className="w-full rounded-xl border border-slate-700 bg-slate-900/50 px-4 py-2.5 text-sm text-slate-200 outline-none focus:border-emerald-500"
                            />
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-slate-400 mr-1">الرسوم (Fee)</label>
                            <input
                                type="number"
                                step="0.01"
                                value={newOption.fee}
                                onChange={(e) => setNewOption({ ...newOption, fee: parseFloat(e.target.value) })}
                                className="w-full rounded-xl border border-slate-700 bg-slate-900/50 px-4 py-2.5 text-sm text-slate-200 outline-none focus:border-emerald-500"
                            />
                        </div>
                        <div className="flex items-center gap-2 pt-6">
                            <input
                                type="checkbox"
                                id="isPopular"
                                checked={newOption.isPopular}
                                onChange={(e) => setNewOption({ ...newOption, isPopular: e.target.checked })}
                                className="h-4 w-4 rounded border-slate-700 bg-slate-900 text-emerald-500"
                            />
                            <label htmlFor="isPopular" className="text-sm text-slate-300 cursor-pointer">خيار شائع (Most Popular)</label>
                        </div>
                        <div className="pt-4 lg:pt-0 flex items-end">
                            <button
                                onClick={handleCreate}
                                className="w-full rounded-xl bg-emerald-500 py-2.5 text-sm font-bold text-slate-950 hover:bg-emerald-400 transition-all"
                            >
                                {editingId ? "تحديث الخيار" : "حفظ الخيار"}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {loading ? (
                    <div className="col-span-full py-20 text-center">
                        <div className="flex justify-center flex-col items-center gap-4">
                            <div className="h-10 w-10 animate-spin border-4 border-emerald-500 border-t-transparent rounded-full" />
                            <span className="text-slate-500 font-medium">جاري تحميل خيارات التمديد...</span>
                        </div>
                    </div>
                ) : options.length === 0 ? (
                    <div className="col-span-full py-20 text-center text-slate-500 border-2 border-dashed border-slate-800 rounded-3xl">
                        لا توجد خيارات تمديد حالياً. قم بإضافة خيار جديد.
                    </div>
                ) : options.map((option) => (
                    <div key={option.id} className="group relative rounded-3xl border border-slate-800 bg-[#021f2a] p-6 shadow-xl transition-all hover:border-emerald-500/30 hover:shadow-emerald-500/5">
                        {option.isPopular && (
                            <div className="absolute -top-3 left-6 flex items-center gap-1 rounded-full bg-emerald-500 px-3 py-1 text-[10px] font-black text-slate-950 shadow-lg">
                                <Star className="h-2.5 w-2.5 fill-slate-950" />
                                الأكثر طلباً
                            </div>
                        )}
                        
                        <div className="flex items-start justify-between mb-4">
                            <div className="h-12 w-12 rounded-2xl bg-slate-900/50 flex items-center justify-center text-emerald-500 border border-slate-800">
                                <Clock className="h-6 w-6" />
                            </div>
                            <div className="flex items-center gap-1">
                                <button
                                    onClick={() => handleEdit(option)}
                                    className="text-slate-600 hover:text-emerald-500 transition-colors p-2"
                                >
                                    <Edit2 className="h-4 w-4" />
                                </button>
                                <button
                                    onClick={() => handleDelete(option.id)}
                                    className="text-slate-600 hover:text-red-500 transition-colors p-2"
                                >
                                    <Trash2 className="h-5 w-5" />
                                </button>
                            </div>
                        </div>

                        <div className="space-y-1">
                            <h3 className="text-lg font-black text-slate-50">{option.nameAr}</h3>
                            <p className="text-xs text-slate-500 font-mono tracking-wider">{option.nameEn}</p>
                        </div>

                        <div className="mt-6 flex items-center justify-between border-t border-slate-800 pt-5">
                            <div className="flex items-center gap-2">
                                <Calendar className="h-4 w-4 text-emerald-500" />
                                <span className="text-sm font-bold text-slate-200">{option.days} يوم</span>
                            </div>
                            <div className="flex items-center gap-1">
                                <span className="text-xs text-slate-500">الرسوم:</span>
                                <span className="text-lg font-black text-emerald-400">{option.fee} JD</span>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
