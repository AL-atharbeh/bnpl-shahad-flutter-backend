"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Bell, CheckCheck } from "lucide-react";
import { getVendorNotifications, markVendorNotificationsRead } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

type Notice = {
    id: number;
    type: string;
    title: string;
    body: string;
    titleEn: string;
    bodyEn: string;
    readAt: string | null;
    createdAt: string;
};

const ICONS: Record<string, string> = {
    sale_approved: "🛍️",
    settlement_completed: "💰",
    settlement_failed: "⚠️",
    store_approved: "✅",
    store_rejected: "📝",
    store_suspended: "⛔",
    api_keys_regenerated: "🔑",
};

/** The merchant's notices: review decisions, new sales and payouts. */
export default function NotificationBell() {
    const { language } = useLanguage();
    const ar = language === "ar";
    const [items, setItems] = useState<Notice[]>([]);
    const [unread, setUnread] = useState(0);
    const [open, setOpen] = useState(false);
    const box = useRef<HTMLDivElement>(null);

    const load = useCallback(async () => {
        try {
            const res = await getVendorNotifications();
            setItems(res.data?.data?.items || []);
            setUnread(res.data?.data?.unread || 0);
        } catch {
            // A missed refresh is retried on the next tick.
        }
    }, []);

    useEffect(() => {
        load();
        const timer = setInterval(load, 60000);
        return () => clearInterval(timer);
    }, [load]);

    useEffect(() => {
        if (!open) return;
        const close = (e: MouseEvent) => {
            if (box.current && !box.current.contains(e.target as Node)) setOpen(false);
        };
        document.addEventListener("mousedown", close);
        return () => document.removeEventListener("mousedown", close);
    }, [open]);

    const markAll = async () => {
        setUnread(0);
        setItems((list) => list.map((n) => ({ ...n, readAt: n.readAt || new Date().toISOString() })));
        try {
            await markVendorNotificationsRead();
        } catch {
            load();
        }
    };

    const when = (iso: string) =>
        new Date(iso).toLocaleString(ar ? "ar-JO" : "en-GB", { dateStyle: "medium", timeStyle: "short" });

    return (
        <div className="relative" ref={box}>
            <button
                onClick={() => setOpen((v) => !v)}
                className="relative flex h-9 w-9 items-center justify-center rounded-full border border-emerald-500/30 bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 transition-all"
                aria-label={ar ? "الإشعارات" : "Notifications"}
            >
                <Bell className="h-4 w-4" />
                {unread > 0 && (
                    <span className="absolute -top-1 -right-1 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-amber-500 px-1 text-[10px] font-bold text-amber-950">
                        {unread > 9 ? "9+" : unread}
                    </span>
                )}
            </button>

            {open && (
                <div className={`absolute top-11 ${ar ? "left-0" : "right-0"} z-30 w-80 max-w-[90vw] rounded-2xl border border-emerald-900/40 bg-[#011f18] shadow-2xl`}>
                    <div className="flex items-center justify-between border-b border-emerald-900/30 px-4 py-3">
                        <span className="text-sm font-bold text-white">{ar ? "الإشعارات" : "Notifications"}</span>
                        {unread > 0 && (
                            <button onClick={markAll} className="flex items-center gap-1 text-[11px] text-emerald-400 hover:text-emerald-300">
                                <CheckCheck className="h-3.5 w-3.5" />
                                {ar ? "تعليم الكل كمقروء" : "Mark all read"}
                            </button>
                        )}
                    </div>
                    <div className="max-h-96 overflow-y-auto">
                        {items.length === 0 ? (
                            <p className="px-4 py-8 text-center text-xs text-slate-500">{ar ? "لا توجد إشعارات بعد" : "No notifications yet"}</p>
                        ) : (
                            items.map((n) => (
                                <div
                                    key={n.id}
                                    className={`flex gap-3 border-b border-emerald-900/20 px-4 py-3 last:border-0 ${n.readAt ? "" : "bg-emerald-500/5"}`}
                                >
                                    <span className="text-lg leading-none">{ICONS[n.type] || "🔔"}</span>
                                    <div className="min-w-0 flex-1 space-y-1">
                                        <p className={`text-xs font-bold ${n.readAt ? "text-slate-300" : "text-white"}`}>{ar ? n.title : n.titleEn}</p>
                                        <p className="text-[11px] leading-5 text-slate-400">{ar ? n.body : n.bodyEn}</p>
                                        <p className="text-[10px] text-slate-600">{when(n.createdAt)}</p>
                                    </div>
                                    {!n.readAt && <span className="mt-1 h-2 w-2 flex-shrink-0 rounded-full bg-amber-400" />}
                                </div>
                            ))
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
