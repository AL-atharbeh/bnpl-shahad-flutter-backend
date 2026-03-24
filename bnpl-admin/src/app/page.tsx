"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      // TODO: Replace with real backend auth
      if (!email || !password) {
        throw new Error("Please enter your email and password.");
      }

      // Simulate request
      await new Promise((resolve) => setTimeout(resolve, 800));

      router.push("/dashboard");
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Unable to sign in. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#061c28] text-slate-50 px-4">
      <div className="w-full max-w-sm rounded-3xl bg-[#071f2e] border border-slate-800 px-7 py-8 shadow-[0_26px_60px_rgba(0,0,0,0.75)]">
        <div className="mb-8 space-y-2 text-center">
          <div className="inline-flex items-center gap-2 mb-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-full bg-emerald-500 text-[11px] font-semibold text-slate-950">
              BN
            </div>
            <span className="text-[13px] font-medium tracking-tight">
              لوحة تحكم BNPL
            </span>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight">تسجيل الدخول</h1>
          <p className="text-[12px] text-slate-300">
            قم بتسجيل الدخول وابدأ إدارة عملاء BNPL والمدفوعات.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1.5">
            <label
              htmlFor="email"
              className="block text-[11px] font-medium text-slate-200"
            >
              البريد الإلكتروني
            </label>
            <input
              id="email"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="block w-full rounded-full border border-slate-700 bg-[#081e2b] px-4 py-2.5 text-[13px] text-slate-50 outline-none ring-emerald-500/40 placeholder:text-slate-500 focus:border-emerald-400 focus:ring-1"
              placeholder="you@example.com"
            />
          </div>

          <div className="space-y-1.5">
            <label
              htmlFor="password"
              className="block text-[11px] font-medium text-slate-200"
            >
              كلمة المرور
            </label>
            <input
              id="password"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="block w-full rounded-full border border-slate-700 bg-[#081e2b] px-4 py-2.5 text-[13px] text-slate-50 outline-none ring-emerald-500/40 placeholder:text-slate-500 focus:border-emerald-400 focus:ring-1"
              placeholder="••••••••"
            />
          </div>

          <div className="flex items-center justify-between text-[11px] text-slate-300">
            <label className="inline-flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                className="h-3.5 w-3.5 rounded border border-slate-600 bg-[#081e2b] text-emerald-500 focus:ring-0"
              />
              <span>تذكرني</span>
            </label>
            <button
              type="button"
              className="text-emerald-400 hover:text-emerald-300"
            >
              نسيت كلمة المرور؟
            </button>
          </div>

          {error && (
            <p className="text-[11px] text-rose-300 bg-rose-500/10 border border-rose-500/40 rounded-md px-3 py-2">
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="mt-2 inline-flex w-full items-center justify-center rounded-full bg-emerald-500 px-4 py-2.5 text-[13px] font-medium text-emerald-950 shadow-[0_12px_30px_rgba(16,185,129,0.65)] transition hover:bg-emerald-400 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loading ? "جارِ تسجيل الدخول..." : "تسجيل الدخول"}
          </button>
        </form>
      </div>
    </div>
  );
}

