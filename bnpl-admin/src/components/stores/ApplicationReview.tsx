"use client";

import { useState } from "react";
import { Store, storesService } from "@/services/stores.service";

type DocType = "commercial-registration" | "trade-license" | "owner-id";

const DOCS: { type: DocType; column: keyof Store; label: string; required: boolean }[] = [
  { type: "commercial-registration", column: "docCommercialRegistration", label: "السجل التجاري", required: true },
  { type: "owner-id", column: "docOwnerId", label: "هوية المالك", required: true },
  { type: "trade-license", column: "docTradeLicense", label: "رخصة المهن", required: false },
];

const formatDate = (value?: string) =>
  value ? new Date(value).toLocaleString("ar-JO", { dateStyle: "medium", timeStyle: "short" }) : "—";

/**
 * The merchant's application as the admin reviews it: business, owner and
 * bank details, the documents, and the decision.
 */
export default function ApplicationReview({
  store,
  onDecide,
}: {
  store: Store;
  onDecide: (status: "approved" | "rejected" | "suspended") => Promise<void>;
}) {
  const [opening, setOpening] = useState<DocType | null>(null);
  const [error, setError] = useState("");

  const openDocument = async (type: DocType) => {
    setOpening(type);
    setError("");
    try {
      const blob = await storesService.getDocument(store.id, type);
      window.open(URL.createObjectURL(blob), "_blank");
    } catch {
      setError("تعذر فتح المستند");
    } finally {
      setOpening(null);
    }
  };

  const row = (label: string, value?: string, mono = false) => (
    <div>
      <p className="text-xs text-slate-400">{label}</p>
      <p className={`mt-1 text-slate-50 ${mono ? "font-mono" : ""} ${value ? "" : "text-slate-500"}`}>{value || "—"}</p>
    </div>
  );

  const submitted = Boolean(store.applicationSubmittedAt);

  return (
    <section className="rounded-xl border border-sky-500/20 bg-sky-500/5 p-4 space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h3 className="text-sm font-semibold text-sky-300 flex items-center gap-2">
          <span>📋</span> طلب الانضمام
        </h3>
        <span
          className={`rounded-full border px-2 py-0.5 text-[11px] ${
            submitted ? "border-emerald-500/30 text-emerald-400" : "border-amber-500/30 text-amber-400"
          }`}
        >
          {submitted ? `أُرسل ${formatDate(store.applicationSubmittedAt)}` : "لم يُرسل بعد"}
        </span>
      </div>

      <div className="grid gap-4 md:grid-cols-3 text-sm">
        {row("الاسم القانوني", store.legalName)}
        {row("رقم السجل التجاري", store.commercialRegistrationNo, true)}
        {row("رقم رخصة المهن", store.tradeLicenseNo, true)}
        {row("المدينة", store.city)}
        {row("الرقم الوطني للمالك", store.ownerNationalId, true)}
        {row("الشروط", store.termsAcceptedAt ? `وافق ${formatDate(store.termsAcceptedAt)} (${store.termsVersion})` : undefined)}
      </div>

      <div className="grid gap-4 md:grid-cols-3 text-sm border-t border-slate-800 pt-4">
        {row("البنك", store.bankName)}
        {row("صاحب الحساب", store.bankAccountHolder)}
        {row("IBAN", store.iban, true)}
      </div>

      <div className="flex flex-wrap gap-2 border-t border-slate-800 pt-4">
        {DOCS.map((d) => {
          const has = Boolean(store[d.column]);
          return (
            <button
              key={d.type}
              disabled={!has || opening === d.type}
              onClick={() => openDocument(d.type)}
              className={`rounded-lg border px-3 py-2 text-xs ${
                has
                  ? "border-sky-500/40 text-sky-300 hover:bg-sky-500/10"
                  : d.required
                    ? "border-red-500/30 text-red-400/80"
                    : "border-slate-700 text-slate-500"
              } disabled:cursor-default`}
            >
              {opening === d.type ? "جاري الفتح..." : has ? `📄 ${d.label}` : `${d.label}: غير مرفوع`}
            </button>
          );
        })}
      </div>
      {error && <p className="text-xs text-red-400">{error}</p>}

      {(store.status === "rejected" || store.status === "suspended") && store.reviewNote && (
        <p className="rounded-lg border border-red-500/20 bg-red-500/5 p-3 text-xs text-red-300">
          {store.status === "suspended" ? "سبب الإيقاف" : "سبب الرفض السابق"}: {store.reviewNote}
        </p>
      )}

      <div className="flex flex-wrap gap-2 border-t border-slate-800 pt-4">
        {store.status === "approved" && (
          <button
            onClick={() => onDecide("suspended")}
            className="rounded-lg border border-amber-500/40 px-4 py-2 text-sm font-semibold text-amber-300 hover:bg-amber-500/10"
          >
            ⏸ إيقاف المتجر مع ذكر السبب
          </button>
        )}
        {store.status !== "approved" && (
          <button
            onClick={() => onDecide("approved")}
            className="rounded-lg bg-emerald-600 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-500"
          >
            {store.status === "suspended" ? "▶ إعادة تفعيل المتجر" : "✓ قبول وتفعيل المتجر"}
          </button>
        )}
        {(store.status === "pending" || store.status === "rejected" || !store.status) && (
          <button
            onClick={() => onDecide("rejected")}
            className="rounded-lg border border-red-500/40 px-4 py-2 text-sm font-semibold text-red-300 hover:bg-red-500/10"
          >
            ✕ رفض مع ذكر السبب
          </button>
        )}
      </div>
    </section>
  );
}
