"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
    Search,
    Filter,
    Download,
    Eye
} from "lucide-react";
import { getVendorTransactions } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

export default function TransactionsPage() {
    const [transactions, setTransactions] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const { t, language } = useLanguage();

    useEffect(() => {
        async function fetchTransactions() {
            const userStr = localStorage.getItem("vendor_user");
            if (!userStr) return;

            try {
                const user = JSON.parse(userStr);
                const res = await getVendorTransactions({ page: 1, limit: 50 }, user.storeId);
                setTransactions(res.data.data || []);
            } catch (error) {
                console.error("Failed to fetch transactions", error);
            } finally {
                setLoading(false);
            }
        }
        fetchTransactions();
    }, []);

    const filteredTransactions = transactions.filter(t =>
        t.user?.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        t.orderId?.toString().toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <DashboardLayout>
            <div className="space-y-6">
                <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <div>
                        <h1 className="text-2xl font-bold text-white tracking-tight">{t("transactions")}</h1>
                        <p className="text-sm text-slate-400">{t("transactionsDescription")}</p>
                    </div>
                    <button className="flex items-center gap-2 rounded-xl border border-emerald-900/30 bg-emerald-500/10 px-4 py-2 text-xs font-bold text-emerald-400 hover:bg-emerald-500/20 transition-all">
                        <Download className="h-4 w-4" />
                        {t("export")}
                    </button>
                </div>

                <div className="flex items-center gap-4">
                    <div className="relative flex-1">
                        <Search className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-500`} />
                        <input
                            type="text"
                            placeholder={t("searchPlaceholder")}
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 focus:border-emerald-500/50 focus:outline-none focus:ring-1 focus:ring-emerald-500/20`}
                        />
                    </div>
                    <button className="flex items-center gap-2 rounded-xl border border-emerald-900/30 bg-[#011f18] px-4 py-2 text-sm text-slate-400 hover:text-slate-200">
                        <Filter className="h-4 w-4" />
                        {t("filter")}
                    </button>
                </div>

                <div className="overflow-hidden rounded-2xl border border-emerald-900/30 bg-[#011f18] shadow-xl">
                    <div className="overflow-x-auto">
                        <table className={`w-full ${language === "ar" ? "text-right" : "text-left"} text-sm`}>
                            <thead className="bg-[#01281e] text-xs font-semibold uppercase text-emerald-500/60">
                                <tr>
                                    <th className="px-6 py-4">{t("orderId")}</th>
                                    <th className="px-6 py-4">{t("customer")}</th>
                                    <th className="px-6 py-4">{t("productValue")}</th>
                                    <th className="px-6 py-4">{t("status")}</th>
                                    <th className="px-6 py-4">{t("date")}</th>
                                    <th className="px-6 py-4">{t("actions")}</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-800">
                                {loading ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-12 text-center text-slate-500">{t("loading")}</td>
                                    </tr>
                                ) : filteredTransactions.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-12 text-center text-slate-500">{t("noTransactions")}</td>
                                    </tr>
                                ) : (
                                    filteredTransactions.map((t) => (
                                        <tr key={t.id} className="hover:bg-slate-800/30 transition-colors">
                                            <td className="px-6 py-4 font-mono text-xs text-slate-300">#{t.orderId || t.id}</td>
                                            <td className="px-6 py-4">
                                                <div className="font-medium text-slate-200">{t.user?.name || t("unknownCustomer")}</div>
                                                <div className="text-[11px] text-slate-500">{t.user?.phone}</div>
                                            </td>
                                            <td className="px-6 py-4 font-semibold text-emerald-400">{(t.amount * (t.installmentsCount || 1)).toLocaleString("en-US")} {useLanguage().t("currency")}</td>
                                            <td className="px-6 py-4">
                                                <span className={`inline-flex rounded-full px-2 py-1 text-[10px] font-bold ${t.status === "completed" ? "bg-emerald-500/10 text-emerald-500" : "bg-amber-500/10 text-amber-500"
                                                    }`}>
                                                    {t.status === "completed" ? useLanguage().t("paid") : useLanguage().t("processing")}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 text-slate-400">{new Date(t.createdAt).toLocaleDateString("en-US")}</td>
                                            <td className="px-6 py-4">
                                                <button className="text-slate-500 hover:text-emerald-400">
                                                    <Eye className="h-4 w-4" />
                                                </button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
}
