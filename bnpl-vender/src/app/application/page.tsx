"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
    Building2, User, Landmark, FileText, Upload, CheckCircle2, AlertCircle,
    Loader2, ArrowRight, Languages, Eye, ShieldCheck,
} from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";
import {
    DocumentType, getStoreDocument, getStoreSettings, getVendorAccount,
    submitStoreApplication, updateStoreSettings, uploadStoreDocument,
} from "@/services/api";

const FIELDS = [
    "legalName", "commercialRegistrationNo", "tradeLicenseNo", "city",
    "ownerNationalId", "bankName", "bankAccountHolder", "iban",
] as const;
type Field = (typeof FIELDS)[number];

const DOCS: { type: DocumentType; column: string; required: boolean }[] = [
    { type: "commercial-registration", column: "docCommercialRegistration", required: true },
    { type: "owner-id", column: "docOwnerId", required: true },
    { type: "trade-license", column: "docTradeLicense", required: false },
];

const TEXT = {
    ar: {
        title: "طلب الانضمام كتاجر",
        subtitle: "هذه البيانات تراجعها إدارة شهد قبل تفعيل متجرك، وتُستخدم لتحويل مستحقاتك.",
        business: "بيانات النشاط التجاري",
        owner: "بيانات المالك",
        bank: "الحساب البنكي للتسويات",
        documents: "المستندات",
        legalName: "الاسم القانوني للمنشأة",
        commercialRegistrationNo: "رقم السجل التجاري",
        tradeLicenseNo: "رقم رخصة المهن (اختياري)",
        city: "المدينة",
        ownerNationalId: "الرقم الوطني للمالك (10 أرقام)",
        bankName: "اسم البنك",
        bankAccountHolder: "اسم صاحب الحساب كما في البنك",
        iban: "رقم الآيبان IBAN",
        ibanHint: "يبدأ بـ JO ومكوّن من 30 خانة",
        "commercial-registration": "صورة السجل التجاري",
        "owner-id": "صورة هوية المالك",
        "trade-license": "رخصة المهن (اختياري)",
        upload: "رفع ملف",
        replace: "استبدال",
        view: "عرض",
        uploaded: "تم الرفع",
        docHint: "JPG أو PNG أو PDF، بحد أقصى 10 ميجابايت",
        terms: "أوافق على الشروط والأحكام واتفاقية العمولة لتجار شهد",
        readTerms: "قراءة الشروط",
        save: "حفظ كمسودة",
        saved: "تم الحفظ",
        submit: "إرسال الطلب للمراجعة",
        submitted: "تم إرسال طلبك، وستراجعه الإدارة قريباً.",
        missing: "أكمل الحقول المعلّمة قبل الإرسال",
        rejectedNote: "سبب الرفض من الإدارة",
        locked: "متجرك مفعّل. لتعديل بيانات المالك أو الحساب البنكي تواصل مع إدارة شهد.",
        back: "رجوع",
        invalid: "غير صحيح",
    },
    en: {
        title: "Merchant application",
        subtitle: "Shahed reviews these details before activating your store, and uses them to pay you.",
        business: "Business details",
        owner: "Owner",
        bank: "Bank account for settlements",
        documents: "Documents",
        legalName: "Legal business name",
        commercialRegistrationNo: "Commercial registration number",
        tradeLicenseNo: "Trade licence number (optional)",
        city: "City",
        ownerNationalId: "Owner's national number (10 digits)",
        bankName: "Bank name",
        bankAccountHolder: "Account holder name, as at the bank",
        iban: "IBAN",
        ibanHint: "Starts with JO, 30 characters",
        "commercial-registration": "Commercial registration",
        "owner-id": "Owner's ID",
        "trade-license": "Trade licence (optional)",
        upload: "Upload",
        replace: "Replace",
        view: "View",
        uploaded: "Uploaded",
        docHint: "JPG, PNG or PDF, up to 10 MB",
        terms: "I accept the Shahed merchant terms and commission agreement",
        readTerms: "Read the terms",
        save: "Save draft",
        saved: "Saved",
        submit: "Submit for review",
        submitted: "Your application was sent. Shahed will review it shortly.",
        missing: "Complete the marked fields before submitting",
        rejectedNote: "Reason given by Shahed",
        locked: "Your store is active. To change owner or bank details, contact Shahed.",
        back: "Back",
        invalid: "invalid",
    },
};

export default function ApplicationPage() {
    const router = useRouter();
    const { language, setLanguage } = useLanguage();
    const tx = TEXT[language === "ar" ? "ar" : "en"];
    const ar = language === "ar";

    const [storeId, setStoreId] = useState<number | null>(null);
    const [form, setForm] = useState<Record<Field, string>>(
        Object.fromEntries(FIELDS.map((f) => [f, ""])) as Record<Field, string>,
    );
    const [docs, setDocs] = useState<Record<string, boolean>>({});
    const [status, setStatus] = useState("pending");
    const [reviewNote, setReviewNote] = useState<string | null>(null);
    const [missing, setMissing] = useState<string[]>([]);
    const [submittedAt, setSubmittedAt] = useState<string | null>(null);
    const [terms, setTerms] = useState(false);
    const [busy, setBusy] = useState<"" | "save" | "submit" | DocumentType>("");
    const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);
    const fileInputs = useRef<Record<string, HTMLInputElement | null>>({});

    const load = async (id: number) => {
        const [storeRes, meRes] = await Promise.all([getStoreSettings(id), getVendorAccount()]);
        const store = storeRes.data.data;
        setForm(Object.fromEntries(FIELDS.map((f) => [f, store[f] || ""])) as Record<Field, string>);
        setDocs(Object.fromEntries(DOCS.map((d) => [d.type, Boolean(store[d.column])])));
        setStatus(store.status);
        const app = meRes.data.data.application || {};
        setMissing(app.missing || []);
        setReviewNote(app.reviewNote || null);
        setSubmittedAt(app.submittedAt || null);
    };

    useEffect(() => {
        const userStr = localStorage.getItem("vendor_user");
        if (!userStr) {
            router.push("/auth/login");
            return;
        }
        const id = Number(JSON.parse(userStr).storeId);
        setStoreId(id);
        load(id).catch(() => setMessage({ ok: false, text: "Failed to load" }));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [router]);

    const locked = status === "approved";

    const errorText = (err: any) => {
        const m = err?.response?.data?.message;
        return Array.isArray(m) ? m.join(", ") : typeof m === "string" ? m : "Error";
    };

    const save = async () => {
        if (!storeId) return;
        setBusy("save");
        setMessage(null);
        try {
            await updateStoreSettings(storeId, form);
            await load(storeId);
            setMessage({ ok: true, text: tx.saved });
        } catch (err) {
            setMessage({ ok: false, text: errorText(err) });
        } finally {
            setBusy("");
        }
    };

    const upload = async (type: DocumentType, file?: File) => {
        if (!storeId || !file) return;
        setBusy(type);
        setMessage(null);
        try {
            await uploadStoreDocument(storeId, type, file);
            await load(storeId);
        } catch (err) {
            setMessage({ ok: false, text: errorText(err) });
        } finally {
            setBusy("");
            const input = fileInputs.current[type];
            if (input) input.value = "";
        }
    };

    const view = async (type: DocumentType) => {
        if (!storeId) return;
        const res = await getStoreDocument(storeId, type);
        window.open(URL.createObjectURL(res.data), "_blank");
    };

    const submit = async () => {
        if (!storeId) return;
        setBusy("submit");
        setMessage(null);
        try {
            await updateStoreSettings(storeId, form);
            await submitStoreApplication(storeId);
            await load(storeId);
            setMessage({ ok: true, text: tx.submitted });
        } catch (err: any) {
            if (err?.response?.data?.missing) setMissing(err.response.data.missing);
            setMessage({ ok: false, text: err?.response?.data?.missing ? tx.missing : errorText(err) });
        } finally {
            setBusy("");
        }
    };

    const fieldClass = (f: string) =>
        `w-full rounded-xl border ${missing.includes(f) ? "border-red-500/60" : "border-slate-800"} bg-slate-900/50 py-3 px-4 text-sm text-slate-200 outline-none focus:border-emerald-500/50 transition-all disabled:opacity-50`;

    const input = (f: Field, opts: { dir?: "ltr" | "rtl"; placeholder?: string; hint?: string; lockable?: boolean } = {}) => (
        <div className="space-y-2">
            <label className="text-xs font-bold text-slate-500 px-1 flex justify-between">
                <span>{tx[f]}</span>
                {missing.includes(f) && form[f] && <span className="text-red-400">{tx.invalid}</span>}
            </label>
            <input
                value={form[f]}
                onChange={(e) => setForm({ ...form, [f]: e.target.value })}
                dir={opts.dir}
                placeholder={opts.placeholder}
                disabled={locked && opts.lockable !== false}
                className={fieldClass(f)}
            />
            {opts.hint && <p className="text-[11px] text-slate-600 px-1">{opts.hint}</p>}
        </div>
    );

    const section = (icon: React.ReactNode, title: string, children: React.ReactNode) => (
        <div className="glass rounded-3xl p-6 space-y-5">
            <h2 className="flex items-center gap-2 text-sm font-black text-white">{icon}{title}</h2>
            {children}
        </div>
    );

    return (
        <div className="min-h-screen bg-[#01160e] p-6 py-12 relative" dir={ar ? "rtl" : "ltr"}>
            <button
                onClick={() => setLanguage(ar ? "en" : "ar")}
                className={`absolute top-8 ${ar ? "left-8" : "right-8"} flex items-center gap-2 rounded-xl border border-emerald-500/20 bg-[#011f18]/80 px-4 py-2 text-xs font-bold text-emerald-400`}
            >
                <Languages className="h-4 w-4" />
                {ar ? "English" : "العربية"}
            </button>

            <div className="mx-auto w-full max-w-2xl space-y-6">
                <div>
                    <Link href="/" className="text-xs text-slate-500 hover:text-slate-300">← {tx.back}</Link>
                    <h1 className="mt-3 text-3xl font-black text-white">{tx.title}</h1>
                    <p className="mt-2 text-sm text-slate-400 leading-7">{tx.subtitle}</p>
                </div>

                {status === "rejected" && reviewNote && (
                    <div className="rounded-2xl border border-red-500/30 bg-red-500/10 p-4 text-sm text-red-300">
                        <div className="font-black mb-1">{tx.rejectedNote}</div>
                        {reviewNote}
                    </div>
                )}
                {locked && (
                    <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-4 text-sm text-emerald-300 flex gap-2">
                        <ShieldCheck className="h-5 w-5 flex-shrink-0" />{tx.locked}
                    </div>
                )}

                {section(<Building2 className="h-4 w-4 text-emerald-500" />, tx.business, (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                        {input("legalName")}
                        {input("commercialRegistrationNo", { dir: "ltr" })}
                        {input("tradeLicenseNo", { dir: "ltr", lockable: false })}
                        {input("city", { lockable: false })}
                    </div>
                ))}

                {section(<User className="h-4 w-4 text-emerald-500" />, tx.owner, input("ownerNationalId", { dir: "ltr", placeholder: "9871234567" }))}

                {section(<Landmark className="h-4 w-4 text-emerald-500" />, tx.bank, (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                        {input("bankName")}
                        {input("bankAccountHolder")}
                        <div className="md:col-span-2">{input("iban", { dir: "ltr", placeholder: "JO94 CBJO 0010 0000 0000 0131 0003 02", hint: tx.ibanHint })}</div>
                    </div>
                ))}

                {section(<FileText className="h-4 w-4 text-emerald-500" />, tx.documents, (
                    <div className="space-y-3">
                        {DOCS.map((d) => {
                            const has = docs[d.type];
                            const flagged = missing.includes(d.column);
                            return (
                                <div key={d.type} className={`rounded-2xl border ${flagged ? "border-red-500/60" : "border-slate-800"} bg-slate-900/40 p-4 flex items-center gap-3`}>
                                    {has ? <CheckCircle2 className="h-5 w-5 text-emerald-400" /> : <Upload className="h-5 w-5 text-slate-500" />}
                                    <div className="flex-1">
                                        <div className="text-sm font-bold text-slate-200">{tx[d.type]}</div>
                                        <div className="text-[11px] text-slate-500">{has ? tx.uploaded : tx.docHint}</div>
                                    </div>
                                    {has && (
                                        <button onClick={() => view(d.type)} className="rounded-lg px-3 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 flex items-center gap-1">
                                            <Eye className="h-4 w-4" />{tx.view}
                                        </button>
                                    )}
                                    {!locked && (
                                        <>
                                            <input
                                                type="file"
                                                accept="image/jpeg,image/png,application/pdf"
                                                className="hidden"
                                                ref={(el) => { fileInputs.current[d.type] = el; }}
                                                onChange={(e) => upload(d.type, e.target.files?.[0])}
                                            />
                                            <button
                                                onClick={() => fileInputs.current[d.type]?.click()}
                                                disabled={busy === d.type}
                                                className="rounded-lg border border-emerald-500/30 bg-emerald-500/10 px-3 py-2 text-xs font-bold text-emerald-400 disabled:opacity-50 flex items-center gap-1"
                                            >
                                                {busy === d.type ? <Loader2 className="h-4 w-4 animate-spin" /> : <Upload className="h-4 w-4" />}
                                                {has ? tx.replace : tx.upload}
                                            </button>
                                        </>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                ))}

                {message && (
                    <div className={`rounded-xl p-4 text-sm flex gap-2 ${message.ok ? "bg-emerald-500/10 text-emerald-300 border border-emerald-500/20" : "bg-red-500/10 text-red-300 border border-red-500/20"}`}>
                        {message.ok ? <CheckCircle2 className="h-5 w-5" /> : <AlertCircle className="h-5 w-5" />}
                        {message.text}
                    </div>
                )}

                {!locked && (
                    <div className="glass rounded-3xl p-6 space-y-4">
                        <label className="flex items-start gap-3 text-sm text-slate-300 cursor-pointer">
                            <input type="checkbox" checked={terms} onChange={(e) => setTerms(e.target.checked)} className="mt-1 h-4 w-4 accent-emerald-500" />
                            <span>
                                {tx.terms}{" "}
                                <a href="https://shahedapp.com/terms" target="_blank" rel="noreferrer" className="text-emerald-400 underline">{tx.readTerms}</a>
                            </span>
                        </label>
                        <div className="flex gap-3">
                            <button
                                onClick={save}
                                disabled={busy !== ""}
                                className="flex-1 rounded-xl border border-slate-700 py-3 text-sm font-bold text-slate-300 hover:bg-white/5 disabled:opacity-50"
                            >
                                {busy === "save" ? <Loader2 className="h-5 w-5 animate-spin mx-auto" /> : tx.save}
                            </button>
                            <button
                                onClick={submit}
                                disabled={busy !== "" || !terms}
                                className="btn-financial flex-1 rounded-xl py-3 text-sm font-bold flex items-center justify-center gap-2 disabled:opacity-40"
                            >
                                {busy === "submit" ? <Loader2 className="h-5 w-5 animate-spin" /> : (<>{tx.submit}<ArrowRight className={`h-4 w-4 ${ar ? "rotate-180" : ""}`} /></>)}
                            </button>
                        </div>
                        {submittedAt && status === "pending" && (
                            <p className="text-xs text-emerald-400/80 text-center">{tx.submitted}</p>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
}
