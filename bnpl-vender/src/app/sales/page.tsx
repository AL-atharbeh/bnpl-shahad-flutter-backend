"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
    TrendingUp,
    Package,
    Users,
    DollarSign,
    Calendar,
    ArrowUpRight,
    Search,
    Filter
} from "lucide-react";
import { getSalesDetailed } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

export default function SalesPage() {
    const [salesData, setSalesData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const { t, language } = useLanguage();

    useEffect(() => {
        async function fetchSales() {
            const userStr = localStorage.getItem("vendor_user");
            if (!userStr) return;

            try {
                const user = JSON.parse(userStr);
                const res = await getSalesDetailed(user.storeId);
                setSalesData(res.data.data);
            } catch (error) {
                console.error("Failed to fetch sales data", error);
            } finally {
                setLoading(false);
            }
        }
        fetchSales();
    }, []);

    const filteredSales = salesData?.sales?.filter((s: any) =>
        s.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        s.orderId.toString().toLowerCase().includes(searchQuery.toLowerCase())
    ) || [];

    const metrics = [
        {
            title: t("piecesSold"),
            value: salesData?.metrics?.totalPiecesSold || 0,
            icon: Package,
            color: "emerald"
        },
        {
            title: t("activeCustomers"),
            value: salesData?.metrics?.totalCustomers || 0,
            icon: Users,
            color: "blue"
        },
        {
            title: t("totalVolume"),
            value: `${(salesData?.metrics?.totalVolume || 0).toLocaleString()} ${t("currency")}`,
            icon: TrendingUp,
            color: "emerald"
        },
        {
            title: t("totalCollections"),
            value: `${(salesData?.metrics?.totalCollected || 0).toLocaleString()} ${t("currency")}`,
            icon: DollarSign,
            color: "blue"
        }
    ];

    return (
        <DashboardLayout>
            <div className="space-y-8">
                <div>
                    <h1 className="text-2xl font-bold text-white tracking-tight">{t("salesOps")}</h1>
                    <p className="text-sm text-slate-400">{t("salesOpsDescription")}</p>
                </div>

                {/* Metrics Grid */}
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
                    {metrics.map((metric, i) => (
                        <div key={i} className="glass rounded-2xl p-6 border-white/5 hover:border-white/10 transition-all">
                            <div className="flex items-center justify-between mb-4">
                                <div className={`h-10 w-10 rounded-xl bg-${metric.color}-500/20 flex items-center justify-center border border-${metric.color}-500/20`}>
                                    <metric.icon className={`h-5 w-5 text-${metric.color}-400`} />
                                </div>
                            </div>
                            <div>
                                <h3 className="text-sm font-medium text-slate-400 mb-1">{metric.title}</h3>
                                <div className="text-2xl font-black text-white">{loading ? "..." : metric.value}</div>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Toolbar */}
                <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <div className="relative flex-1 max-w-md">
                        <Search className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-500`} />
                        <input
                            type="text"
                            placeholder={t("searchPlaceholder")}
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-2.5 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 focus:border-emerald-500/50 focus:outline-none focus:ring-1 focus:ring-emerald-500/20 transition-all`}
                        />
                    </div>
                </div>

                {/* Detailed Table */}
                <div className="overflow-hidden rounded-2xl border border-emerald-900/30 bg-[#011f18] shadow-xl">
                    <div className="overflow-x-auto">
                        <table className={`w-full ${language === "ar" ? "text-right" : "text-left"} text-sm`}>
                            <thead className="bg-[#01281e] text-xs font-semibold uppercase text-emerald-500/60">
                                <tr>
                                    <th className="px-6 py-4">{t("orderId")}</th>
                                    <th className="px-6 py-4">{t("customer")}</th>
                                    <th className="px-6 py-4">{t("itemsCount")}</th>
                                    <th className="px-6 py-4">{t("totalVolume")}</th>
                                    <th className="px-6 py-4">{t("paymentProgress")}</th>
                                    <th className="px-6 py-4">{t("orderDate")}</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-emerald-900/10">
                                {loading ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-12 text-center text-slate-500">{t("loading")}</td>
                                    </tr>
                                ) : filteredSales.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-12 text-center text-slate-500">{t("noTransactions")}</td>
                                    </tr>
                                ) : (
                                    filteredSales.map((sale: any) => (
                                        <tr key={sale.id} className="hover:bg-white/5 transition-colors group">
                                            <td className="px-6 py-4">
                                                <span className="font-mono text-xs text-slate-300">#{sale.orderId}</span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="font-medium text-slate-200">{sale.customerName}</div>
                                                <div className="text-[11px] text-slate-500">{sale.customerPhone}</div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-2">
                                                    <span className="text-slate-300 font-bold">{sale.piecesSold}</span>
                                                    <span className="text-[11px] text-slate-500">{t("piecesSold")}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 font-semibold text-white">
                                                {sale.totalAmount.toLocaleString()} {t("currency")}
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="w-full max-w-[120px]">
                                                    <div className="flex items-center justify-between mb-1 text-[10px] text-slate-500">
                                                        <span>{Math.round((sale.collectedAmount / sale.totalAmount) * 100)}%</span>
                                                        <span>{sale.collectedAmount.toLocaleString()} {t("currency")}</span>
                                                    </div>
                                                    <div className="h-1.5 w-full bg-emerald-999/20 rounded-full overflow-hidden border border-emerald-900/30">
                                                        <div
                                                            className="h-full bg-emerald-500 transition-all duration-500"
                                                            style={{ width: `${(sale.collectedAmount / sale.totalAmount) * 100}%` }}
                                                        />
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-slate-400">
                                                <div className="flex items-center gap-2 text-xs">
                                                    <Calendar className="h-3 w-3 text-slate-500" />
                                                    {new Date(sale.createdAt).toLocaleDateString(language === "ar" ? "ar-JO" : "en-US")}
                                                </div>
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
