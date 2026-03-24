"use client";

import { useMemo, useState } from "react";

const notifications: any[] = [];

const subscriptions = [
  { label: "تنبيهات الدفعات المتأخرة", enabled: true },
  { label: "موافقات الطلبات الجديدة", enabled: true },
  { label: "تحويلات البنك", enabled: true },
  { label: "تحديث مستندات العملاء", enabled: false },
  { label: "تنبيهات المخاطر", enabled: false },
] as const;

export default function NotificationsPage() {
  const [filter, setFilter] = useState<"الكل" | "غير مقروءة" | "مقروءة">(
    "الكل"
  );
  const [subscribeState, setSubscribeState] = useState(
    subscriptions.map((s) => s.enabled)
  );

  const unreadCount = useMemo(
    () => notifications.filter((n) => !n.read).length,
    []
  );

  const filteredNotifications = notifications.filter((notification) => {
    if (filter === "غير مقروءة") return !notification.read;
    if (filter === "مقروءة") return notification.read;
    return true;
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-lg font-semibold text-slate-50">مركز الإشعارات</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          تنبيهات التحصيل، موافقات البنك، وتحديثات الطلبات—all في مكان واحد.
        </p>
      </div>

      <section className="grid gap-4 md:grid-cols-4">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🔔</span>
            <span>إشعارات اليوم</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {notifications.length}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">آخر 24 ساعة</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>📬</span>
            <span>غير مقروءة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {unreadCount}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">تحتاج متابعة الآن</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>⚠️</span>
            <span>تنبيهات تأخير</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">1</p>
          <p className="mt-1 text-[11px] text-slate-300">دفعة بحاجة لتذكير</p>
        </div>

        <div className="rounded-xl border border-emerald-500/70 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 text-slate-950 shadow-[0_18px_40px_rgba(16,185,129,0.6)]">
          <p className="text-xs font-medium flex items-center gap-1">
            <span>⚙️</span>
            <span>الإعدادات النشطة</span>
          </p>
          <p className="mt-2 text-2xl font-semibold">
            {subscribeState.filter(Boolean).length}
          </p>
          <p className="mt-1 text-[11px] text-emerald-900">قنوات مفعّلة</p>
        </div>
      </section>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div className="flex items-center gap-2 text-xs text-slate-400">
            <span>فلتر الحالة:</span>
            <button
              onClick={() => setFilter("الكل")}
              className={`rounded-full px-3 py-1 ${
                filter === "الكل"
                  ? "bg-emerald-500 text-slate-950"
                  : "border border-slate-700 text-slate-300"
              }`}
            >
              الكل
            </button>
            <button
              onClick={() => setFilter("غير مقروءة")}
              className={`rounded-full px-3 py-1 ${
                filter === "غير مقروءة"
                  ? "bg-emerald-500 text-slate-950"
                  : "border border-slate-700 text-slate-300"
              }`}
            >
              غير مقروءة
            </button>
            <button
              onClick={() => setFilter("مقروءة")}
              className={`rounded-full px-3 py-1 ${
                filter === "مقروءة"
                  ? "bg-emerald-500 text-slate-950"
                  : "border border-slate-700 text-slate-300"
              }`}
            >
              مقروءة
            </button>
          </div>

          <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-medium text-slate-200 hover:bg-slate-900">
            🔕 كتم الإشعارات لمدة ساعة
          </button>
        </div>
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <div className="xl:col-span-2 rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
          <div className="border-b border-slate-800 bg-[#041f2e] px-4 py-3 text-sm font-semibold text-slate-200">
            صندوق الإشعارات
          </div>
          <div className="divide-y divide-slate-800">
            {filteredNotifications.length === 0 ? (
              <p className="px-4 py-6 text-center text-xs text-slate-400">
                لا توجد إشعارات مطابقة للفلتر الحالي.
              </p>
            ) : (
              filteredNotifications.map((notification) => (
                <div
                  key={notification.id}
                  className={`flex flex-col gap-1 px-4 py-3 text-xs ${
                    notification.read ? "bg-[#031824]" : "bg-[#031f2b]"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <p className="text-sm text-slate-50 font-medium">
                      {notification.title}
                    </p>
                    {!notification.read && (
                      <span className="rounded-full bg-emerald-500/15 px-2 py-0.5 text-[10px] text-emerald-200">
                        جديد
                      </span>
                    )}
                  </div>
                  <p className="text-slate-300">{notification.message}</p>
                  <p className="text-[11px] text-slate-500">{notification.time}</p>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
          <div className="border-b border-slate-800 bg-[#041f2e] px-4 py-3 text-xs font-semibold text-slate-200">
            إعدادات الاشتراكات
          </div>
          <div className="divide-y divide-slate-800 text-xs text-slate-200">
            {subscriptions.map((subscription, index) => (
              <label
                key={subscription.label}
                className="flex items-center justify-between px-4 py-3"
              >
                <span>{subscription.label}</span>
                <input
                  type="checkbox"
                  checked={subscribeState[index]}
                  onChange={() =>
                    setSubscribeState((prev) =>
                      prev.map((value, i) => (i === index ? !value : value))
                    )
                  }
                  className="h-4 w-4 rounded border-emerald-500 text-emerald-500 focus:ring-emerald-500"
                />
              </label>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

