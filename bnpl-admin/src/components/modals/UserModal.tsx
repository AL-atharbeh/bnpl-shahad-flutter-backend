"use client";

import { useState } from "react";
import { User, usersService } from "@/services/users.service";

interface UserModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

export default function UserModal({ isOpen, onClose, onSuccess }: UserModalProps) {
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        name: "",
        phone: "",
        email: "",
        password: "",
        civilIdNumber: "",
        address: "",
        monthlyIncome: "",
        employer: "",
    });

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            // Prepare data for API
            const userData = {
                name: formData.name,
                phone: formData.phone,
                email: formData.email || undefined,
                password: formData.password,
                civilIdNumber: formData.civilIdNumber || undefined,
                address: formData.address || undefined,
                monthlyIncome: formData.monthlyIncome ? parseFloat(formData.monthlyIncome) : undefined,
                employer: formData.employer || undefined,
            };

            // Call API to create user
            await usersService.create(userData);

            // Reset form
            setFormData({
                name: "",
                phone: "",
                email: "",
                password: "",
                civilIdNumber: "",
                address: "",
                monthlyIncome: "",
                employer: "",
            });

            onSuccess();
            onClose();
        } catch (error: any) {
            console.error("Failed to create user", error);
            alert(error.response?.data?.message || "فشل إضافة المستخدم");
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
            <div className="relative w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
                {/* Header */}
                <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4">
                    <h2 className="text-lg font-semibold text-slate-50">
                        إضافة مستخدم جديد
                    </h2>
                    <button
                        onClick={onClose}
                        className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-sm text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
                    >
                        ✕ إغلاق
                    </button>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {/* Name */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            الاسم الكامل <span className="text-red-400">*</span>
                        </label>
                        <input
                            type="text"
                            name="name"
                            value={formData.name}
                            onChange={handleChange}
                            required
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="أدخل الاسم الكامل"
                        />
                    </div>

                    {/* Phone */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            رقم الهاتف <span className="text-red-400">*</span>
                        </label>
                        <input
                            type="tel"
                            name="phone"
                            value={formData.phone}
                            onChange={handleChange}
                            required
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="+965 XXXX XXXX"
                        />
                    </div>

                    {/* Email */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            البريد الإلكتروني
                        </label>
                        <input
                            type="email"
                            name="email"
                            value={formData.email}
                            onChange={handleChange}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="example@email.com"
                        />
                    </div>

                    {/* Password */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            كلمة المرور <span className="text-red-400">*</span>
                        </label>
                        <input
                            type="password"
                            name="password"
                            value={formData.password}
                            onChange={handleChange}
                            required
                            minLength={6}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="أدخل كلمة المرور (6 أحرف على الأقل)"
                        />
                    </div>

                    {/* Civil ID Number */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            رقم الهوية المدنية
                        </label>
                        <input
                            type="text"
                            name="civilIdNumber"
                            value={formData.civilIdNumber}
                            onChange={handleChange}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="أدخل رقم الهوية"
                        />
                    </div>

                    {/* Address */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            العنوان
                        </label>
                        <textarea
                            name="address"
                            value={formData.address}
                            onChange={handleChange}
                            rows={2}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="أدخل العنوان"
                        />
                    </div>

                    {/* Monthly Income */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            الدخل الشهري (دينار)
                        </label>
                        <input
                            type="number"
                            name="monthlyIncome"
                            value={formData.monthlyIncome}
                            onChange={handleChange}
                            min="0"
                            step="0.01"
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="أدخل الدخل الشهري"
                        />
                    </div>

                    {/* Employer */}
                    <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2">
                            جهة العمل
                        </label>
                        <input
                            type="text"
                            name="employer"
                            value={formData.employer}
                            onChange={handleChange}
                            className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                            placeholder="أدخل جهة العمل"
                        />
                    </div>

                    {/* Buttons */}
                    <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-800">
                        <button
                            type="button"
                            onClick={onClose}
                            className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 transition-colors"
                        >
                            إلغاء
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/60 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {loading ? "جاري الإضافة..." : "إضافة مستخدم"}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
