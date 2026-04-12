"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
    CreditCard,
    ArrowUpRight,
    Calendar,
    CheckCircle2
} from "lucide-react";
import { getVendorSettlements, getVendorSettlementStats } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

export default function FinancePage() {
    const [mounted, setMounted] = useState(false);
    const [settlements, setSettlements] = useState<any[]>([]);
    const [stats, setStats] = useState<{ pendingBalance: number, lastTransfer: any } | null>(null);
    const [loading, setLoading] = useState(true);
    const { t, language } = useLanguage();

    useEffect(() => {
        setMounted(true);
        async function fetchFinance() {
            const userStr = typeof window !== "undefined" ? localStorage.getItem("vendor_user") : null;
            if (!userStr) return;

            try {
                const user = JSON.parse(userStr);
                const [settlementsRes, statsRes] = await Promise.all([
                    getVendorSettlements({ page: 1, limit: 50 }, user.storeId).catch(() => ({ data: { data: { settlements: [] } } })),
                    getVendorSettlementStats(user.storeId).catch(() => ({ data: { data: { pendingBalance: 0, lastTransfer: null } } }))
                ]);
                setSettlements(settlementsRes?.data?.data?.settlements || []);
                setStats(statsRes?.data?.data || null);
            } catch (error) {
                console.error("Failed to fetch settlements", error);
            } finally {
                setLoading(false);
            }
        }
        fetchFinance();
    }, []);

    if (!mounted) return null;

    return (
        <DashboardLayout>
            <div className="space-y-8">
                <div>
                    <h1 className="text-2xl font-bold text-white tracking-tight">{t("financialSettlements")}</h1>
                    <p className="text-sm text-slate-400">{t("manageProfits")}</p>
                </div>

                <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                    {/* Pending Balance Card */}
                    <div className="glass-emerald rounded-2xl p-6">
                        <div className="flex items-center justify-between">
                            <div className="h-10 w-10 rounded-xl bg-emerald-500 flex items-center justify-center shadow-lg shadow-emerald-500/20">
                                <CreditCard className="h-5 w-5 text-[#01160e]" />
                            </div>
                            <span className="text-[10px] font-bold text-emerald-400 uppercase tracking-wider">{t("pendingBalance")}</span>
                        </div>
                        <div className="mt-4">
                            <h3 className="text-3xl font-black text-white">{(stats?.pendingBalance || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} {t("currency")}</h3>
                            <p className="mt-1 text-xs text-slate-400">{t("nextSettlementDateDetail")}</p>
                        </div>
                    </div>

                    {/* Last Transfer Card */}
                    <div className="glass rounded-2xl p-6 border-emerald-900/10">
                        <div className="flex items-center justify-between">
                            <div className="h-10 w-10 rounded-xl bg-emerald-900/20 flex items-center justify-center border border-emerald-900/30">
                                <ArrowUpRight className="h-5 w-5 text-emerald-400" />
                            </div>
                            <span className="text-[10px] font-bold text-emerald-600 uppercase tracking-wider">{t("lastTransfer")}</span>
                        </div>
                        <div className="mt-4">
                            <h3 className="text-3xl font-black text-white text-opacity-80">{(stats?.lastTransfer?.amount || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} {t("currency")}</h3>
                            <p className="mt-1 text-xs text-slate-500 flex items-center gap-2">
                                <CheckCircle2 className="h-3 w-3 text-emerald-500" />
                                {stats?.lastTransfer ? (
                                    <>
                                        {t("transferredOn")} {stats?.lastTransfer?.date ? new Date(stats.lastTransfer.date).toLocaleDateString(language === "ar" ? "ar-JO" : "en-US", { day: 'numeric', month: 'long' }) : "-"}
                                    </>
                                ) : (
                                    t("noTransfersYet")
                                )}
                            </p>
                        </div>
                    </div>
                </div>

                <div className="space-y-4">
                    <h2 className="text-lg font-bold text-white">{t("settlementHistory")}</h2>
                    <div className="rounded-2xl border border-emerald-900/30 bg-[#011f18] overflow-hidden shadow-xl">
                        <div className="divide-y divide-emerald-900/20">
                            {loading ? (
                                <div className="p-12 text-center text-slate-500 text-sm italic">{t("loadingSettlements")}</div>
                            ) : settlements.length === 0 ? (
                                <div className="p-12 text-center text-slate-500 text-sm">{t("noSettlements")}</div>
                            ) : (
                                settlements.map((s) => (
                                    <div key={s.id} className="flex items-center justify-between p-6 hover:bg-emerald-500/5 transition-all cursor-pointer group">
                                        <div className="flex items-center gap-4">
                                            <div className="h-10 w-10 rounded-full bg-[#01281e] flex items-center justify-center border border-emerald-900/30 group-hover:bg-emerald-500/10 transition-colors">
                                                <Calendar className="h-4 w-4 text-emerald-500/60" />
                                            </div>
                                            <div>
                                                <h4 className="text-sm font-bold text-slate-200">
                                                    {t("monthlySettlement")} - {s.settlementDate ? new Date(s.settlementDate).toLocaleDateString(language === "ar" ? "ar-JO" : "en-US", { month: 'long', year: 'numeric' }) : "-"}
                                                </h4>
                                                <p className="text-[11px] text-slate-500 mt-0.5 font-mono">{t("reference")}: #{s.id}</p>
                                            </div>
                                        </div>
                                        <div className={`${language === "ar" ? "text-left" : "text-right"}`}>
                                            <div className="text-sm font-black text-emerald-400">{(s.totalCollected || 0).toLocaleString()} {t("currency")}</div>
                                            <div className="text-[10px] font-bold text-emerald-600 mt-1 uppercase">{t("transferSuccess")}</div>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
}
