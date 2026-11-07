"use client";

import { useEffect, useState } from "react";
import { Landmark } from "lucide-react";
import { getMySettlements } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

type Settlement = {
    id: number;
    status: "pending" | "completed" | "failed";
    requestedAt: string;
    settlementDate?: string;
    totalCollected: number;
    bankShare: number;
    platformShare: number;
    netAmount: number;
    ordersCount: number;
    notes?: string;
};

const money = (v: number) => v.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Every payout the store asked for or received, and where each one stands. */
export default function SettlementHistory() {
    const { language } = useLanguage();
    const ar = language === "ar";
    const [items, setItems] = useState<Settlement[]>([]);
    const [page, setPage] = useState(1);
    const [pages, setPages] = useState(1);
    const [loading, setLoading] = useState(true);
    const [failed, setFailed] = useState(false);

    useEffect(() => {
        setLoading(true);
        getMySettlements(page)
            .then((res) => {
                setItems(res.data?.data?.settlements || []);
                setPages(res.data?.data?.totalPages || 1);
                setFailed(false);
            })
            .catch(() => setFailed(true))
            .finally(() => setLoading(false));
    }, [page]);

    const status = {
        pending: { label: ar ? "قيد التحويل" : "Processing", className: "border-amber-500/30 text-amber-400" },
        completed: { label: ar ? "تم التحويل" : "Transferred", className: "border-emerald-500/30 text-emerald-400" },
        failed: { label: ar ? "لم يتم" : "Failed", className: "border-red-500/30 text-red-400" },
    };
    const date = (iso?: string) =>
        iso ? new Date(iso).toLocaleDateString(ar ? "ar-JO" : "en-GB", { day: "numeric", month: "short", year: "numeric" }) : "—";

    return (
        <section className="space-y-4">
            <h2 className="flex items-center gap-2 px-2 text-lg font-bold text-white">
                <Landmark className="h-5 w-5 text-emerald-500" />
                {ar ? "سجل التسويات" : "Settlement history"}
            </h2>
            <div className="overflow-hidden rounded-3xl border border-emerald-900/30 bg-[#011f18] shadow-2xl">
                <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                        <thead>
                            <tr className="border-b border-emerald-900/20 bg-emerald-500/5 text-[10px] font-bold uppercase tracking-wider text-slate-400">
                                <th className="px-6 py-4 text-start">{ar ? "التسوية" : "Settlement"}</th>
                                <th className="px-6 py-4 text-start">{ar ? "الطلبات" : "Orders"}</th>
                                <th className="px-6 py-4 text-start">{ar ? "المحصّل" : "Collected"}</th>
                                <th className="px-6 py-4 text-start">{ar ? "العمولات" : "Fees"}</th>
                                <th className="px-6 py-4 text-start">{ar ? "الصافي لك" : "Your net"}</th>
                                <th className="px-6 py-4 text-start">{ar ? "الحالة" : "Status"}</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-emerald-900/10">
                            {loading ? (
                                <tr><td colSpan={6} className="p-10 text-center text-slate-500">{ar ? "جاري التحميل..." : "Loading..."}</td></tr>
                            ) : failed ? (
                                <tr><td colSpan={6} className="p-10 text-center text-red-400">{ar ? "تعذر تحميل التسويات" : "Could not load settlements"}</td></tr>
                            ) : items.length === 0 ? (
                                <tr><td colSpan={6} className="p-10 text-center italic text-slate-500">{ar ? "لا توجد تسويات بعد" : "No settlements yet"}</td></tr>
                            ) : (
                                items.map((s) => (
                                    <tr key={s.id} className="hover:bg-emerald-500/[0.03]">
                                        <td className="px-6 py-4">
                                            <div className="font-bold text-slate-200">#{s.id}</div>
                                            <div className="text-[10px] text-slate-500">
                                                {s.status === "completed" ? date(s.settlementDate) : date(s.requestedAt)}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-slate-300">{s.ordersCount}</td>
                                        <td className="px-6 py-4 text-slate-300">JOD {money(s.totalCollected)}</td>
                                        <td className="px-6 py-4 text-slate-500">JOD {money(s.bankShare + s.platformShare)}</td>
                                        <td className="px-6 py-4 font-black text-emerald-400">JOD {money(s.netAmount)}</td>
                                        <td className="px-6 py-4">
                                            <span className={`rounded-full border px-2 py-0.5 text-[10px] ${status[s.status]?.className || "border-slate-700 text-slate-400"}`}>
                                                {status[s.status]?.label || s.status}
                                            </span>
                                            {s.status === "failed" && s.notes && <div className="mt-1 text-[10px] text-red-400/80">{s.notes}</div>}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
                {pages > 1 && (
                    <div className="flex items-center justify-center gap-3 border-t border-emerald-900/20 py-3 text-xs text-slate-400">
                        <button disabled={page <= 1} onClick={() => setPage(page - 1)} className="rounded-lg border border-emerald-900/40 px-3 py-1 disabled:opacity-40">
                            {ar ? "السابق" : "Previous"}
                        </button>
                        <span>{page} / {pages}</span>
                        <button disabled={page >= pages} onClick={() => setPage(page + 1)} className="rounded-lg border border-emerald-900/40 px-3 py-1 disabled:opacity-40">
                            {ar ? "التالي" : "Next"}
                        </button>
                    </div>
                )}
            </div>
        </section>
    );
}
