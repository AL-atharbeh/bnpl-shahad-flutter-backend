"use client";

import { useEffect, useState, type ReactNode } from "react";
import { useRouter } from "next/navigation";
import api from "@/services/api";

/**
 * Blocks the dashboard until the stored token is confirmed by the backend to
 * belong to an admin. The check runs server side on every load, so clearing it
 * is not something a visitor can do from the browser.
 */
export function AuthGuard({ children }: { children: ReactNode }) {
  const router = useRouter();
  const [allowed, setAllowed] = useState(false);

  useEffect(() => {
    let cancelled = false;

    const check = async () => {
      let token: string | null = null;

      try {
        token = localStorage.getItem("token");
      } catch {
        token = null;
      }

      if (!token) {
        router.replace("/");
        return;
      }

      try {
        await api.get("/auth/admin/me");
        if (!cancelled) setAllowed(true);
      } catch {
        try {
          localStorage.removeItem("token");
        } catch {
          // ignore - storage may be unavailable
        }
        router.replace("/");
      }
    };

    check();

    return () => {
      cancelled = true;
    };
  }, [router]);

  if (!allowed) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#021820] text-slate-400">
        <p className="text-sm">جارٍ التحقق من الصلاحيات…</p>
      </div>
    );
  }

  return <>{children}</>;
}
