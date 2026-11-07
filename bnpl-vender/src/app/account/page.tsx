"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { KeyRound, Loader2, Save, UserRound } from "lucide-react";
import { changeVendorPassword, getVendorAccount, updateVendorProfile } from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";

const errorText = (err: any, fallback: string) => {
    const message = err?.response?.data?.message;
    return Array.isArray(message) ? message.join("، ") : message || fallback;
};

/** The person behind the store: their contact details and password. */
export default function AccountPage() {
    const { language } = useLanguage();
    const ar = language === "ar";

    const [profile, setProfile] = useState({ name: "", email: "", phone: "" });
    const [savingProfile, setSavingProfile] = useState(false);
    const [profileMsg, setProfileMsg] = useState<{ ok: boolean; text: string } | null>(null);

    const [passwords, setPasswords] = useState({ current: "", next: "", confirm: "" });
    const [savingPassword, setSavingPassword] = useState(false);
    const [passwordMsg, setPasswordMsg] = useState<{ ok: boolean; text: string } | null>(null);

    useEffect(() => {
        getVendorAccount()
            .then((res) => {
                const user = res.data?.data?.user || {};
                setProfile({ name: user.name || "", email: user.email || "", phone: user.phone || "" });
            })
            .catch(() => undefined);
    }, []);

    const saveProfile = async () => {
        setSavingProfile(true);
        setProfileMsg(null);
        try {
            const res = await updateVendorProfile({
                name: profile.name.trim(),
                email: profile.email.trim(),
                phone: profile.phone.trim(),
            });
            // The header greets the merchant from what was saved at sign-in.
            try {
                const saved = JSON.parse(localStorage.getItem("vendor_user") || "{}");
                localStorage.setItem("vendor_user", JSON.stringify({ ...saved, ...res.data.data }));
            } catch {
                // Not fatal: the next sign-in refreshes it.
            }
            setProfileMsg({ ok: true, text: ar ? "تم حفظ بياناتك" : "Your details were saved" });
        } catch (err) {
            setProfileMsg({ ok: false, text: errorText(err, ar ? "تعذر الحفظ" : "Could not save") });
        } finally {
            setSavingProfile(false);
        }
    };

    const savePassword = async () => {
        setPasswordMsg(null);
        if (passwords.next.length < 8) {
            setPasswordMsg({ ok: false, text: ar ? "كلمة المرور الجديدة 8 أحرف على الأقل" : "The new password needs at least 8 characters" });
            return;
        }
        if (passwords.next !== passwords.confirm) {
            setPasswordMsg({ ok: false, text: ar ? "تأكيد كلمة المرور غير مطابق" : "The confirmation does not match" });
            return;
        }
        setSavingPassword(true);
        try {
            await changeVendorPassword(passwords.current, passwords.next);
            setPasswords({ current: "", next: "", confirm: "" });
            setPasswordMsg({ ok: true, text: ar ? "تم تغيير كلمة المرور" : "Your password was changed" });
        } catch (err) {
            setPasswordMsg({ ok: false, text: errorText(err, ar ? "تعذر تغيير كلمة المرور" : "Could not change the password") });
        } finally {
            setSavingPassword(false);
        }
    };

    const input =
        "w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 px-4 text-sm text-slate-100 focus:border-emerald-500/50 focus:outline-none";
    const label = `text-xs font-bold text-slate-500 ${ar ? "pr-1" : "pl-1"}`;
    const message = (m: { ok: boolean; text: string } | null) =>
        m && <p className={`text-xs ${m.ok ? "text-emerald-400" : "text-red-400"}`}>{m.text}</p>;

    return (
        <DashboardLayout>
            <div className="max-w-3xl space-y-8">
                <div>
                    <h1 className="text-2xl font-bold text-white tracking-tight">{ar ? "حسابي" : "My account"}</h1>
                    <p className="text-sm text-slate-400">
                        {ar ? "بيانات صاحب الحساب وكلمة المرور." : "The account holder's details and password."}
                    </p>
                </div>

                <section className="glass rounded-2xl p-8 space-y-5 border-emerald-900/20">
                    <h3 className="flex items-center gap-2 border-b border-emerald-900/30 pb-4 text-lg font-bold text-white">
                        <UserRound className="h-5 w-5 text-emerald-500" />
                        {ar ? "البيانات الشخصية" : "Personal details"}
                    </h3>
                    <div className="grid gap-4 md:grid-cols-2">
                        <div className="space-y-2 md:col-span-2">
                            <label className={label}>{ar ? "الاسم" : "Name"}</label>
                            <input className={input} value={profile.name} onChange={(e) => setProfile({ ...profile, name: e.target.value })} />
                        </div>
                        <div className="space-y-2">
                            <label className={label}>{ar ? "البريد الإلكتروني (للدخول)" : "Email (used to sign in)"}</label>
                            <input dir="ltr" type="email" className={input} value={profile.email} onChange={(e) => setProfile({ ...profile, email: e.target.value })} />
                        </div>
                        <div className="space-y-2">
                            <label className={label}>{ar ? "رقم الهاتف" : "Phone"}</label>
                            <input dir="ltr" className={input} value={profile.phone} onChange={(e) => setProfile({ ...profile, phone: e.target.value })} />
                        </div>
                    </div>
                    {message(profileMsg)}
                    <button
                        onClick={saveProfile}
                        disabled={savingProfile}
                        className="btn-financial flex items-center gap-2 rounded-xl px-6 py-3 text-sm font-bold disabled:opacity-50"
                    >
                        {savingProfile ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                        {ar ? "حفظ البيانات" : "Save details"}
                    </button>
                </section>

                <section className="glass rounded-2xl p-8 space-y-5 border-emerald-900/20">
                    <h3 className="flex items-center gap-2 border-b border-emerald-900/30 pb-4 text-lg font-bold text-white">
                        <KeyRound className="h-5 w-5 text-emerald-500" />
                        {ar ? "تغيير كلمة المرور" : "Change password"}
                    </h3>
                    <div className="grid gap-4 md:grid-cols-3">
                        <div className="space-y-2">
                            <label className={label}>{ar ? "كلمة المرور الحالية" : "Current password"}</label>
                            <input type="password" autoComplete="current-password" className={input} value={passwords.current} onChange={(e) => setPasswords({ ...passwords, current: e.target.value })} />
                        </div>
                        <div className="space-y-2">
                            <label className={label}>{ar ? "الجديدة (8 أحرف على الأقل)" : "New (8+ characters)"}</label>
                            <input type="password" autoComplete="new-password" className={input} value={passwords.next} onChange={(e) => setPasswords({ ...passwords, next: e.target.value })} />
                        </div>
                        <div className="space-y-2">
                            <label className={label}>{ar ? "تأكيد الجديدة" : "Confirm new"}</label>
                            <input type="password" autoComplete="new-password" className={input} value={passwords.confirm} onChange={(e) => setPasswords({ ...passwords, confirm: e.target.value })} />
                        </div>
                    </div>
                    <p className="text-[11px] text-slate-500">
                        {ar
                            ? "إذا أعطتك إدارة شهد كلمة مرور مؤقتة، غيّرها هنا."
                            : "If Shahed gave you a temporary password, change it here."}
                    </p>
                    {message(passwordMsg)}
                    <button
                        onClick={savePassword}
                        disabled={savingPassword || !passwords.current || !passwords.next}
                        className="btn-financial flex items-center gap-2 rounded-xl px-6 py-3 text-sm font-bold disabled:opacity-50"
                    >
                        {savingPassword ? <Loader2 className="h-4 w-4 animate-spin" /> : <KeyRound className="h-4 w-4" />}
                        {ar ? "تغيير كلمة المرور" : "Change password"}
                    </button>
                </section>
            </div>
        </DashboardLayout>
    );
}
