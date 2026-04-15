"use client";

import { useEffect, useState } from "react";

const API = process.env.NEXT_PUBLIC_API_URL || "https://enthusiastic-stillness-production-5dce.up.railway.app/api/v1";

type CashoutStatus = "pending" | "approved" | "rejected";

interface CashoutRequest {
  id: number;
  userId: number;
  pointsRequested: number;
  amountJod: number;
  clickPayLink: string;
  status: CashoutStatus;
  adminNote: string | null;
  createdAt: string;
  user?: {
    id: number;
    name: string;
    email: string;
    phone: string;
  };
}

const statusConfig: Record<CashoutStatus, { label: string; color: string; bg: string }> = {
  pending: { label: "معلق", color: "text-amber-700", bg: "bg-amber-50 border-amber-200" },
  approved: { label: "مُوافَق عليه", color: "text-emerald-700", bg: "bg-emerald-50 border-emerald-200" },
  rejected: { label: "مرفوض", color: "text-red-700", bg: "bg-red-50 border-red-200" },
};

export default function RewardsPage() {
  const [requests, setRequests] = useState<CashoutRequest[]>([]);
  const [filter, setFilter] = useState<CashoutStatus | "all">("all");
  const [loading, setLoading] = useState(true);
  const [processingId, setProcessingId] = useState<number | null>(null);
  const [noteInput, setNoteInput] = useState<Record<number, string>>({});
  const [error, setError] = useState<string | null>(null);

  const fetchRequests = async (status?: string) => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem("admin_token") || "";
      const url = status && status !== "all"
        ? `${API}/rewards/admin/cashout-requests?status=${status}`
        : `${API}/rewards/admin/cashout-requests`;
      const res = await fetch(url, { headers: { Authorization: `Bearer ${token}` } });
      const data = await res.json();
      if (data.success) {
        setRequests(data.data || []);
      } else {
        setError("تعذّر تحميل الطلبات.");
      }
    } catch {
      setError("تعذّر الاتصال بالخادم.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequests(filter);
  }, [filter]);

  const updateStatus = async (id: number, status: CashoutStatus) => {
    setProcessingId(id);
    try {
      const token = localStorage.getItem("admin_token") || "";
      const res = await fetch(`${API}/rewards/admin/cashout-requests/${id}/status`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ status, adminNote: noteInput[id] || "" }),
      });
      const data = await res.json();
      if (data.success) {
        await fetchRequests(filter);
      } else {
        alert("فشل التحديث: " + (data.message || "خطأ غير معروف"));
      }
    } catch {
      alert("خطأ في الاتصال.");
    } finally {
      setProcessingId(null);
    }
  };

  const pending = requests.filter((r) => r.status === "pending");
  const totalJodPending = pending.reduce((s, r) => s + Number(r.amountJod), 0);

  return (
    <div className="p-6 space-y-6" dir="rtl">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-100">النقاط والمكافآت 🏆</h1>
          <p className="text-sm text-slate-400 mt-1">إدارة طلبات صرف نقاط المستخدمين</p>
        </div>
        <button
          onClick={() => fetchRequests(filter)}
          className="rounded-xl bg-slate-800 border border-slate-700 px-4 py-2 text-sm text-slate-200 hover:bg-slate-700 transition-colors"
        >
          ↺ تحديث
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard label="طلبات معلقة" value={pending.length} color="amber" icon="⏳" />
        <StatCard label="إجمالي مبالغ معلقة" value={`${totalJodPending.toFixed(2)} JOD`} color="emerald" icon="💰" />
        <StatCard label="إجمالي الطلبات" value={requests.length} color="blue" icon="📋" />
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-2 flex-wrap">
        {(["all", "pending", "approved", "rejected"] as const).map((s) => (
          <button
            key={s}
            onClick={() => setFilter(s)}
            className={`rounded-full px-4 py-1.5 text-sm font-medium border transition-colors ${
              filter === s
                ? "bg-emerald-500/20 border-emerald-500/60 text-emerald-200"
                : "bg-slate-800 border-slate-700 text-slate-300 hover:bg-slate-700"
            }`}
          >
            {s === "all" ? "الكل" : statusConfig[s].label}
            {s === "pending" && pending.length > 0 && (
              <span className="mr-2 inline-flex items-center justify-center w-5 h-5 text-[10px] rounded-full bg-amber-500 text-white font-bold">
                {pending.length}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Error */}
      {error && (
        <div className="rounded-xl border border-red-500/30 bg-red-900/20 p-4 text-red-300 text-sm">
          ⚠️ {error}
        </div>
      )}

      {/* Table */}
      {loading ? (
        <div className="text-center py-16 text-slate-400">جاري التحميل...</div>
      ) : requests.length === 0 ? (
        <div className="text-center py-16 text-slate-400">لا توجد طلبات.</div>
      ) : (
        <div className="space-y-4">
          {requests.map((req) => (
            <RequestCard
              key={req.id}
              req={req}
              noteInput={noteInput[req.id] || ""}
              onNoteChange={(v) => setNoteInput((prev) => ({ ...prev, [req.id]: v }))}
              onApprove={() => updateStatus(req.id, "approved")}
              onReject={() => updateStatus(req.id, "rejected")}
              isProcessing={processingId === req.id}
            />
          ))}
        </div>
      )}
    </div>
  );
}

// ── Sub-components ──────────────────────────────────────────────────

function StatCard({
  label,
  value,
  color,
  icon,
}: {
  label: string;
  value: string | number;
  color: "amber" | "emerald" | "blue";
  icon: string;
}) {
  const colorMap = {
    amber: "border-amber-500/30 bg-amber-900/10",
    emerald: "border-emerald-500/30 bg-emerald-900/10",
    blue: "border-blue-500/30 bg-blue-900/10",
  };
  return (
    <div className={`rounded-2xl border p-5 ${colorMap[color]}`}>
      <p className="text-2xl mb-1">{icon}</p>
      <p className="text-2xl font-extrabold text-slate-100">{value}</p>
      <p className="text-sm text-slate-400 mt-1">{label}</p>
    </div>
  );
}

function RequestCard({
  req,
  noteInput,
  onNoteChange,
  onApprove,
  onReject,
  isProcessing,
}: {
  req: CashoutRequest;
  noteInput: string;
  onNoteChange: (v: string) => void;
  onApprove: () => void;
  onReject: () => void;
  isProcessing: boolean;
}) {
  const cfg = statusConfig[req.status];
  const isPending = req.status === "pending";

  return (
    <div className="rounded-2xl border border-slate-700/60 bg-slate-800/60 p-5 space-y-4">
      {/* Top Row */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-300 font-bold text-sm">
            {req.user?.name?.charAt(0)?.toUpperCase() || "#"}
          </div>
          <div>
            <p className="text-sm font-bold text-slate-100">{req.user?.name || `User #${req.userId}`}</p>
            <p className="text-xs text-slate-400">{req.user?.phone || req.user?.email || ""}</p>
          </div>
        </div>
        <span className={`text-xs font-semibold px-3 py-1 rounded-full border ${cfg.bg} ${cfg.color}`}>
          {cfg.label}
        </span>
      </div>

      {/* Points & JOD */}
      <div className="flex gap-4 flex-wrap">
        <div className="rounded-xl bg-slate-700/50 px-4 py-2 text-center">
          <p className="text-xs text-slate-400">النقاط</p>
          <p className="text-lg font-extrabold text-amber-400">{req.pointsRequested.toLocaleString()}</p>
        </div>
        <div className="rounded-xl bg-slate-700/50 px-4 py-2 text-center">
          <p className="text-xs text-slate-400">المبلغ</p>
          <p className="text-lg font-extrabold text-emerald-400">{Number(req.amountJod).toFixed(2)} JOD</p>
        </div>
        <div className="flex-1 rounded-xl bg-slate-700/50 px-4 py-2">
          <p className="text-xs text-slate-400 mb-1">رابط ClickPay</p>
          <a
            href={req.clickPayLink}
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-400 hover:underline text-xs break-all"
          >
            {req.clickPayLink}
          </a>
        </div>
      </div>

      {/* Date & Admin Note */}
      <div className="flex justify-between items-center text-xs text-slate-500">
        <span>{new Date(req.createdAt).toLocaleString("ar-JO")}</span>
        {req.adminNote && (
          <span className="text-amber-400">ملاحظة: {req.adminNote}</span>
        )}
      </div>

      {/* Actions (pending only) */}
      {isPending && (
        <div className="space-y-2 border-t border-slate-700 pt-4">
          <input
            type="text"
            placeholder="ملاحظة اختيارية للمستخدم..."
            value={noteInput}
            onChange={(e) => onNoteChange(e.target.value)}
            className="w-full rounded-xl bg-slate-700/50 border border-slate-600 px-3 py-2 text-sm text-slate-200 placeholder-slate-500 focus:outline-none focus:border-emerald-500"
          />
          <div className="flex gap-3">
            <button
              onClick={onApprove}
              disabled={isProcessing}
              className="flex-1 rounded-xl bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 text-white text-sm font-bold py-2 transition-colors"
            >
              {isProcessing ? "..." : "✓ موافقة"}
            </button>
            <button
              onClick={onReject}
              disabled={isProcessing}
              className="flex-1 rounded-xl bg-red-500/20 hover:bg-red-500/30 border border-red-500/40 disabled:opacity-50 text-red-300 text-sm font-bold py-2 transition-colors"
            >
              {isProcessing ? "..." : "✗ رفض"}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
