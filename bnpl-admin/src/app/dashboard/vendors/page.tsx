"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Vendor, storesService } from "@/services/stores.service";

const STORE_STATUS: Record<string, { label: string; className: string }> = {
  approved: { label: "نشط", className: "border-emerald-500/30 text-emerald-400" },
  pending: { label: "قيد المراجعة", className: "border-amber-500/30 text-amber-400" },
  rejected: { label: "مرفوض", className: "border-red-500/30 text-red-400" },
  suspended: { label: "موقوف", className: "border-red-500/30 text-red-400" },
};

const formatDate = (value?: string) =>
  value ? new Date(value).toLocaleDateString("ar-JO", { dateStyle: "medium" }) : "—";

/**
 * Merchant accounts: who signs in for each store, and the admin's levers on
 * the account itself (suspend, restore, reset password). The store's own
 * approval lives on the stores page.
 */
export default function VendorsPage() {
  const [vendors, setVendors] = useState<Vendor[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [busyId, setBusyId] = useState<number | null>(null);
  const [newPassword, setNewPassword] = useState<{ vendor: Vendor; password: string } | null>(null);
  const [copied, setCopied] = useState(false);

  const load = async () => {
    try {
      const res = await storesService.getVendors();
      setVendors(res.data || []);
      setError("");
    } catch {
      setError("تعذر تحميل حسابات التجار");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const toggleActive = async (vendor: Vendor) => {
    const suspending = vendor.isActive;
    if (
      !confirm(
        suspending
          ? `إيقاف حساب «${vendor.name}»؟ سيُسجَّل خروجه فوراً ولن يستطيع الدخول. المتجر نفسه لا يتوقف عن البيع؛ لإيقافه استخدم صفحة المتاجر.`
          : `إعادة تفعيل حساب «${vendor.name}»؟`,
      )
    ) {
      return;
    }
    setBusyId(vendor.id);
    try {
      await storesService.setVendorActive(vendor.id, !suspending);
      await load();
    } catch {
      alert("تعذر تحديث الحساب");
    } finally {
      setBusyId(null);
    }
  };

  const resetPassword = async (vendor: Vendor) => {
    if (!confirm(`إنشاء كلمة مرور جديدة لـ «${vendor.name}»؟ كلمة المرور الحالية ستتوقف عن العمل.`)) return;
    setBusyId(vendor.id);
    try {
      const res = await storesService.resetVendorPassword(vendor.id);
      setCopied(false);
      setNewPassword({ vendor, password: res.data.temporaryPassword });
    } catch {
      alert("تعذر إعادة تعيين كلمة المرور");
    } finally {
      setBusyId(null);
    }
  };

  const q = search.trim().toLowerCase();
  const shown = vendors.filter(
    (v) =>
      !q ||
      [v.name, v.email, v.phone, v.store?.name, v.store?.nameAr].some((f) => f?.toLowerCase().includes(q)),
  );

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="text-lg font-semibold text-slate-50">حسابات التجار</h1>
          <p className="text-xs text-slate-400">
            إيقاف حساب أو إعادة تفعيله، وإعادة تعيين كلمة المرور لتاجر لا يستطيع الدخول.
          </p>
        </div>
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="ابحث بالاسم أو الإيميل أو الهاتف أو المتجر..."
          className="w-full max-w-xs rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none"
        />
      </div>

      {error && <p className="rounded-lg border border-red-500/30 bg-red-500/10 p-3 text-sm text-red-300">{error}</p>}

      <div className="overflow-x-auto rounded-xl border border-slate-800 bg-slate-900/30">
        <table className="w-full text-right text-sm">
          <thead className="border-b border-slate-800 text-xs text-slate-400">
            <tr>
              <th className="px-3 py-3 font-medium">التاجر</th>
              <th className="px-3 py-3 font-medium">التواصل</th>
              <th className="px-3 py-3 font-medium">المتجر</th>
              <th className="px-3 py-3 font-medium">الحساب</th>
              <th className="px-3 py-3 font-medium">تاريخ التسجيل</th>
              <th className="px-3 py-3 font-medium text-center">إجراءات</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-800">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-3 py-8 text-center text-slate-500">جاري التحميل...</td>
              </tr>
            ) : shown.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-3 py-8 text-center text-slate-500">لا يوجد تجار</td>
              </tr>
            ) : (
              shown.map((v) => {
                const status = STORE_STATUS[v.store?.status || ""];
                return (
                  <tr key={v.id} className="hover:bg-slate-900/40">
                    <td className="px-3 py-3 font-medium text-slate-100">{v.name}</td>
                    <td className="px-3 py-3 text-xs text-slate-300">
                      <div dir="ltr" className="text-right">{v.email}</div>
                      <div dir="ltr" className="text-right text-slate-500">{v.phone}</div>
                    </td>
                    <td className="px-3 py-3">
                      {v.store ? (
                        <div className="flex flex-col items-start gap-1">
                          <Link href="/dashboard/stores" className="text-slate-100 hover:text-emerald-300">
                            {v.store.nameAr || v.store.name}
                          </Link>
                          {status && (
                            <span className={`rounded-full border px-2 py-0.5 text-[10px] ${status.className}`}>
                              {status.label}
                              {v.store.status === "pending" && (v.store.applicationSubmittedAt ? " · طلب مُرسل" : " · غير مكتمل")}
                            </span>
                          )}
                        </div>
                      ) : (
                        <span className="text-slate-500">—</span>
                      )}
                    </td>
                    <td className="px-3 py-3">
                      <span
                        className={`rounded-full border px-2 py-0.5 text-[11px] ${
                          v.isActive ? "border-emerald-500/30 text-emerald-400" : "border-red-500/30 text-red-400"
                        }`}
                      >
                        {v.isActive ? "فعّال" : "موقوف"}
                      </span>
                    </td>
                    <td className="px-3 py-3 text-xs text-slate-400">{formatDate(v.createdAt)}</td>
                    <td className="px-3 py-3">
                      <div className="flex justify-center gap-2">
                        <button
                          disabled={busyId === v.id}
                          onClick={() => toggleActive(v)}
                          className={`rounded-lg border px-3 py-1 text-xs disabled:opacity-50 ${
                            v.isActive
                              ? "border-red-500/40 text-red-300 hover:bg-red-500/10"
                              : "border-emerald-500/40 text-emerald-300 hover:bg-emerald-500/10"
                          }`}
                        >
                          {v.isActive ? "إيقاف الحساب" : "إعادة التفعيل"}
                        </button>
                        <button
                          disabled={busyId === v.id}
                          onClick={() => resetPassword(v)}
                          className="rounded-lg border border-sky-500/40 px-3 py-1 text-xs text-sky-300 hover:bg-sky-500/10 disabled:opacity-50"
                        >
                          كلمة مرور جديدة
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {newPassword && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4">
          <div className="w-full max-w-md space-y-4 rounded-2xl border border-slate-700 bg-[#021f2a] p-6">
            <h2 className="text-base font-semibold text-slate-50">كلمة مرور جديدة لـ «{newPassword.vendor.name}»</h2>
            <p className="text-xs leading-6 text-slate-400">
              أعطها للتاجر بطريقة آمنة. <span className="text-amber-300">لن تظهر مرة أخرى</span>، وكلمة المرور القديمة لم تعد تعمل.
            </p>
            <div className="flex items-center justify-between gap-3 rounded-lg border border-slate-700 bg-slate-900/60 p-3">
              <span dir="ltr" className="select-all font-mono text-lg tracking-wider text-emerald-300">
                {newPassword.password}
              </span>
              <button
                onClick={async () => {
                  try {
                    await navigator.clipboard.writeText(newPassword.password);
                    setCopied(true);
                  } catch {
                    setCopied(false);
                  }
                }}
                className="rounded-lg border border-slate-600 px-3 py-1 text-xs text-slate-200 hover:bg-slate-800"
              >
                {copied ? "✓ نُسخت" : "نسخ"}
              </button>
            </div>
            <button
              onClick={() => setNewPassword(null)}
              className="w-full rounded-lg bg-emerald-600 py-2 text-sm font-semibold text-white hover:bg-emerald-500"
            >
              تم
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
