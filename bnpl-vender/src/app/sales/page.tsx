"use client";

import { useEffect, useState, Fragment } from "react";
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

    const [expandedRows, setExpandedRows] = useState<Set<number>>(new Set());

    const toggleRow = (id: number) => {
        const newExpanded = new Set(expandedRows);
        if (newExpanded.has(id)) newExpanded.delete(id);
        else newExpanded.add(id);
        setExpandedRows(newExpanded);
    };

    const getStatusStyles = (status: string) => {
        switch (status.toLowerCase()) {
            case 'completed': return 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20';
            case 'approved': return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
            case 'payment_pending': return 'bg-amber-500/10 text-amber-500 border-amber-500/20';
            case 'canceled': return 'bg-red-500/10 text-red-500 border-red-500/20';
            default: return 'bg-slate-500/10 text-slate-500 border-slate-500/20';
        }
    };

    const handlePrintReceipt = (sale: any) => {
        // Simple print functionality
        const printContent = `
            <div dir="${language === 'ar' ? 'rtl' : 'ltr'}" style="padding: 40px; font-family: sans-serif;">
                <h1 style="text-align: center;">${t("receipt")}</h1>
                <hr/>
                <p><strong>${t("orderId")}:</strong> #${sale.orderId}</p>
                <p><strong>${t("customer")}:</strong> ${sale.customerName} (${sale.customerPhone})</p>
                <p><strong>${t("date")}:</strong> ${new Date(sale.createdAt).toLocaleString()}</p>
                <h3>${t("items")}</h3>
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f4f4f4;">
                            <th style="padding: 10px; border: 1px solid #ddd; text-align: start;">${t("product")}</th>
                            <th style="padding: 10px; border: 1px solid #ddd; text-align: center;">${t("quantity")}</th>
                            <th style="padding: 10px; border: 1px solid #ddd; text-align: end;">${t("price")}</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${sale.items.map((item: any) => `
                            <tr>
                                <td style="padding: 10px; border: 1px solid #ddd;">${item.name}</td>
                                <td style="padding: 10px; border: 1px solid #ddd; text-align: center;">${item.quantity}</td>
                                <td style="padding: 10px; border: 1px solid #ddd; text-align: end;">${item.price} ${t("currency")}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
                <h2 style="text-align: end;">${t("totalAmount")}: ${sale.totalAmount} ${t("currency")}</h2>
            </div>
        `;
        const win = window.open('', '_blank');
        win?.document.write(printContent);
        win?.document.close();
        win?.print();
    };

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
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-bold text-white tracking-tight">{t("salesOps")}</h1>
                        <p className="text-sm text-slate-400">{t("salesOpsDescription")}</p>
                    </div>
                    <button 
                        onClick={() => window.print()}
                        className="flex items-center gap-2 rounded-xl border border-white/5 bg-white/5 px-4 py-2.5 text-sm font-bold text-slate-300 hover:bg-white/10 hover:text-white transition-all shadow-xl"
                    >
                        <ArrowUpRight className="h-4 w-4" />
                        {language === 'ar' ? 'تصدير التقارير' : 'Export Reports'}
                    </button>
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
                                    <th className="px-6 py-4">{t("status")}</th>
                                    <th className="px-6 py-4">{t("totalVolume")}</th>
                                    <th className="px-6 py-4">{t("paymentProgress")}</th>
                                    <th className="px-6 py-4">{t("actions")}</th>
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
                                        <Fragment key={sale.id}>
                                            <tr className="hover:bg-white/5 transition-colors group cursor-pointer" onClick={() => toggleRow(sale.id)}>
                                                <td className="px-6 py-4">
                                                    <div className="flex items-center gap-3">
                                                        <div className={`transition-transform duration-200 ${expandedRows.has(sale.id) ? 'rotate-90' : ''}`}>
                                                            <ArrowUpRight className="h-4 w-4 text-slate-500" />
                                                        </div>
                                                        <span className="font-mono text-xs text-slate-300">#{sale.orderId}</span>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4">
                                                    <div className="font-medium text-slate-200">{sale.customerName}</div>
                                                    <div className="text-[11px] text-slate-500">{sale.customerPhone}</div>
                                                </td>
                                                <td className="px-6 py-4">
                                                    <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-[10px] font-bold border ${getStatusStyles(sale.status)}`}>
                                                        {sale.status === 'completed' ? t("paid") : 
                                                         sale.status === 'approved' ? (language === 'ar' ? 'تمت الموافقة' : 'Approved') :
                                                         sale.status === 'payment_pending' ? t("processing") : 
                                                         (language === 'ar' ? 'ملغاة' : 'Canceled')}
                                                    </span>
                                                </td>
                                                <td className="px-6 py-4 font-semibold text-white">
                                                    {sale.totalAmount.toLocaleString()} {t("currency")}
                                                </td>
                                                <td className="px-6 py-4 text-right">
                                                    <div className="w-full max-w-[120px] ml-auto">
                                                        <div className="flex items-center justify-between mb-1 text-[10px] text-slate-500">
                                                            <span>{Math.round((sale.collectedAmount / sale.totalAmount) * 100)}%</span>
                                                            <span>{sale.collectedAmount.toLocaleString()} {t("currency")}</span>
                                                        </div>
                                                        <div className="h-1 w-full bg-emerald-950/40 rounded-full overflow-hidden border border-emerald-900/20">
                                                            <div
                                                                className="h-full bg-emerald-500 transition-all duration-500"
                                                                style={{ width: `${(sale.collectedAmount / sale.totalAmount) * 100}%` }}
                                                            />
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4">
                                                    <button 
                                                        onClick={(e) => { e.stopPropagation(); handlePrintReceipt(sale); }}
                                                        className="p-2 rounded-lg bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500 hover:text-[#011f18] transition-all"
                                                        title={t("receipt")}
                                                    >
                                                        <DollarSign className="h-4 w-4" />
                                                    </button>
                                                </td>
                                            </tr>
                                            {/* Expanded Detailed View */}
                                            {expandedRows.has(sale.id) && (
                                                <tr className="bg-emerald-500/[0.02]">
                                                    <td colSpan={6} className="px-8 py-6 border-l-2 border-emerald-500/30">
                                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                                                            <div>
                                                                <h4 className="text-xs font-bold text-emerald-500 uppercase tracking-wider mb-4 flex items-center gap-2">
                                                                    <Package className="h-3 w-3" />
                                                                    {t("items")}
                                                                </h4>
                                                                <div className="space-y-3">
                                                                    {sale.items.map((item: any, idx: number) => (
                                                                        <div key={idx} className="flex items-center justify-between p-3 rounded-xl bg-white/5 border border-white/5">
                                                                            <div className="flex flex-col">
                                                                                <span className="text-sm font-medium text-slate-200">{item.name}</span>
                                                                                <span className="text-xs text-slate-500">{item.quantity} x {item.price} {t("currency")}</span>
                                                                            </div>
                                                                            <span className="font-bold text-emerald-400">{(item.quantity * item.price).toLocaleString()} {t("currency")}</span>
                                                                        </div>
                                                                    ))}
                                                                </div>
                                                            </div>
                                                            <div className="space-y-4">
                                                                <h4 className="text-xs font-bold text-emerald-500 uppercase tracking-wider mb-4 flex items-center gap-2">
                                                                    <Calendar className="h-3 w-3" />
                                                                    {language === 'ar' ? 'تفاصيل الجلسة' : 'Session Details'}
                                                                </h4>
                                                                <div className="rounded-2xl p-4 bg-[#01281e]/30 border border-emerald-900/30 space-y-3">
                                                                    <div className="flex justify-between text-xs">
                                                                        <span className="text-slate-500">{language === 'ar' ? 'تاريخ الطلب' : 'Order Date'}</span>
                                                                        <span className="text-slate-200">{new Date(sale.createdAt).toLocaleString(language === "ar" ? "ar-JO" : "en-US")}</span>
                                                                    </div>
                                                                    <div className="flex justify-between text-xs">
                                                                        <span className="text-slate-500">{language === 'ar' ? 'رقم الهاتف' : 'Phone Number'}</span>
                                                                        <span className="text-slate-200 font-mono text-emerald-400">{sale.customerPhone}</span>
                                                                    </div>
                                                                    <div className="pt-3 border-t border-emerald-900/10 flex justify-between text-xs transition-all hover:bg-white/5 p-1 rounded">
                                                                        <span className="text-slate-500">{language === 'ar' ? 'المبلغ الإجمالي' : 'Gross Amount'}</span>
                                                                        <span className="text-slate-200">{sale.totalAmount.toLocaleString()} {t("currency")}</span>
                                                                    </div>
                                                                    <div className="flex justify-between text-xs transition-all hover:bg-white/5 p-1 rounded">
                                                                        <span className="text-red-400/80">{language === 'ar' ? 'العمولة المقطوعة (-)' : 'Deducted Commission (-)'}</span>
                                                                        <span className="text-red-400">-{sale.totalCommission?.toLocaleString() || 0} {t("currency")}</span>
                                                                    </div>
                                                                    <div className="pt-3 border-t border-emerald-900/30 flex justify-between font-bold">
                                                                        <span className="text-slate-300">{language === 'ar' ? 'صافي التحصيل النهائي' : 'Final Net Collection'}</span>
                                                                        <span className="text-white text-lg">{sale.netAmount.toLocaleString()} {t("currency")}</span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                            )}
                                        </Fragment>
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
