"use client";

import { useState } from "react";

const teamMembers: any[] = [];

const webhooks = [
  {
    event: "تحصيل قسط",
    url: "https://api.bank.com/webhooks/installments",
    status: "مفعل",
  },
  {
    event: "طلب جديد",
    url: "https://api.partner.com/orders",
    status: "مفعل",
  },
  {
    event: "تحديث مستند",
    url: "https://api.bank.com/webhooks/documents",
    status: "موقوف",
  },
];

export default function SettingsPage() {
  const [companyName, setCompanyName] = useState("Witness BNPL");
  const [companyEmail, setCompanyEmail] =
    useState("support@witness-bnpl.com");
  const [bankName, setBankName] = useState("Bank of BNPL");
  const [bankAccount, setBankAccount] = useState("KUW-1234-5678-9012");
  const [autoTransfer, setAutoTransfer] = useState(true);
  const [reminderDays, setReminderDays] = useState(2);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-lg font-semibold text-slate-50">الإعدادات العامة</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          إدارة بيانات الشركة، سياسات BNPL، التكاملات، وصلاحيات الفريق.
        </p>
      </div>

      <section className="grid gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4">
          <p className="text-xs text-slate-400">نسبة البنك</p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">3%</p>
          <p className="mt-1 text-[11px] text-slate-300">
            يتم خصمها من كل دفعة وتحويلها للبنك
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4">
          <p className="text-xs text-slate-400">عمولة المنصة</p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">2%</p>
          <p className="mt-1 text-[11px] text-slate-300">
            تُخصم قبل تحويل المبلغ للبنك
          </p>
        </div>
        <div className="rounded-xl border border-emerald-500/70 bg-gradient-to-br from-emerald-500 to-emerald-400 p-4 text-slate-950">
          <p className="text-xs font-medium">التحويلات الآلية للبنك</p>
          <p className="mt-2 text-2xl font-semibold">
            {autoTransfer ? "مفعّلة" : "موقوفة"}
          </p>
          <p className="mt-1 text-[11px]">
            تحويل حصص البنك يتم{" "}
            <span className="font-medium">
              {autoTransfer ? "يوميًا" : "يدويًا"}
            </span>
          </p>
        </div>
      </section>

      <form className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-4">
        <h2 className="text-sm font-semibold text-slate-50">بيانات الشركة</h2>
        <div className="grid gap-4 md:grid-cols-2 text-xs text-slate-200">
          <label className="flex flex-col gap-1">
            <span className="text-slate-400">اسم الشركة</span>
            <input
              type="text"
              value={companyName}
              onChange={(e) => setCompanyName(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </label>
          <label className="flex flex-col gap-1">
            <span className="text-slate-400">البريد الإلكتروني</span>
            <input
              type="email"
              value={companyEmail}
              onChange={(e) => setCompanyEmail(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </label>
          <label className="flex flex-col gap-1">
            <span className="text-slate-400">اسم البنك الممول</span>
            <input
              type="text"
              value={bankName}
              onChange={(e) => setBankName(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </label>
          <label className="flex flex-col gap-1">
            <span className="text-slate-400">رقم حساب التسوية</span>
            <input
              type="text"
              value={bankAccount}
              onChange={(e) => setBankAccount(e.target.value)}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
          </label>
        </div>
        <div className="flex items-center justify-between rounded-lg border border-slate-800 bg-[#031824] px-4 py-3 text-xs text-slate-200">
          <div>
            <p className="text-slate-100">التحويلات التلقائية للبنك</p>
            <p className="text-[11px] text-slate-400">
              عند تفعيلها، يتم تحويل حصص البنك بعد التحصيل مباشرة.
            </p>
          </div>
          <label className="inline-flex cursor-pointer items-center">
            <input
              type="checkbox"
              checked={autoTransfer}
              onChange={() => setAutoTransfer((prev) => !prev)}
              className="sr-only peer"
            />
            <div className="peer h-5 w-10 rounded-full bg-slate-700 transition peer-checked:bg-emerald-500">
              <div className="h-5 w-5 rounded-full bg-slate-900 transition peer-checked:translate-x-5" />
            </div>
          </label>
        </div>
        <div className="flex items-center justify-between rounded-lg border border-slate-800 bg-[#031824] px-4 py-3 text-xs text-slate-200">
          <label className="flex flex-col text-slate-100 gap-1">
            <span>تذكير الدفع قبل الاستحقاق</span>
            <select
              value={reminderDays}
              onChange={(e) => setReminderDays(Number(e.target.value))}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-2 text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value={1}>قبل يوم واحد</option>
              <option value={2}>قبل يومين</option>
              <option value={3}>قبل 3 أيام</option>
            </select>
          </label>
          <p className="text-[11px] text-slate-400">
            يتم إرسال SMS + إشعار داخل التطبيق
          </p>
        </div>
        <button className="w-full rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition">
          حفظ التغييرات
        </button>
      </form>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-slate-50">سياسات BNPL</h2>
            <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1 text-xs text-slate-200 hover:bg-slate-900">
              تعديل
            </button>
          </div>
          <ul className="space-y-2 text-xs text-slate-200">
            <li className="rounded-lg border border-slate-800 bg-[#031824] px-3 py-2">
              الحد الأقصى للخطة الواحدة: 8 أقساط / 2000 دينار
            </li>
            <li className="rounded-lg border border-slate-800 bg-[#031824] px-3 py-2">
              فترة السماح قبل اعتبار الدفعة متأخرة: 3 أيام
            </li>
            <li className="rounded-lg border border-slate-800 bg-[#031824] px-3 py-2">
              يتطلب توثيق هوية + حساب بنكي للعميل قبل الموافقة
            </li>
          </ul>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)] space-y-4">
          <h2 className="text-sm font-semibold text-slate-50">صلاحيات الفريق</h2>
          <p className="text-[11px] text-slate-400">
            تحكم في من يمكنه الوصول إلى كل قسم داخل لوحة BNPL.
          </p>
          <div className="space-y-3 text-xs text-slate-200">
            {teamMembers.length === 0 ? (
              <div className="rounded-lg border border-slate-800 bg-[#031824] p-4 text-center text-slate-400">
                لا يوجد أعضاء فريق
              </div>
            ) : (
              teamMembers.map((member) => (
                <div
                  key={member.name}
                  className="rounded-lg border border-slate-800 bg-[#031824] p-3"
                >
                  <div className="flex items-center justify-between text-sm text-slate-100">
                    <span>{member.name}</span>
                    <span className="rounded-full border border-slate-700 bg-slate-900/60 px-2 py-0.5 text-[10px] text-slate-300">
                      {member.role}
                    </span>
                  </div>
                  <div className="mt-2 text-[11px] text-slate-400">
                    الصلاحيات: {member.permissions.join("، ")}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 className="text-sm font-semibold text-slate-50">
              التكاملات والتنبيهات
            </h2>
            <p className="text-[11px] text-slate-400">
              ربط المنصة مع البنك والشركاء عبر Webhooks وتنبيهات الحدث.
            </p>
          </div>
          <button className="rounded-lg bg-emerald-500 px-4 py-2 text-xs font-medium text-slate-950 hover:bg-emerald-400">
            + إضافة Webhook
          </button>
        </div>
        <div className="mt-4 grid gap-3 md:grid-cols-2 text-xs text-slate-200">
          {webhooks.map((hook) => (
            <div
              key={hook.event}
              className="rounded-lg border border-slate-800 bg-[#031824] p-3"
            >
              <div className="flex items-center justify-between text-sm text-slate-100">
                <span>{hook.event}</span>
                <span
                  className={`rounded-full px-2 py-0.5 text-[10px] ${
                    hook.status === "مفعل"
                      ? "bg-emerald-500/15 text-emerald-200 border border-emerald-500/40"
                      : "bg-amber-500/15 text-amber-200 border border-amber-500/40"
                  }`}
                >
                  {hook.status}
                </span>
              </div>
              <p className="mt-2 truncate text-[11px] text-slate-400">
                {hook.url}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

