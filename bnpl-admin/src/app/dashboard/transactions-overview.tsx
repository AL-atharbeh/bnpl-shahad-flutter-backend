"use client";

import {
  ResponsiveContainer,
  CartesianGrid,
  Line,
  LineChart,
  Tooltip,
  XAxis,
  YAxis,
  Legend,
} from "recharts";

const data = [
  { name: "سبت", purchases: 0, payments: 0 },
  { name: "أحد", purchases: 0, payments: 0 },
  { name: "اثن", purchases: 0, payments: 0 },
  { name: "ثلاث", purchases: 0, payments: 0 },
  { name: "أربع", purchases: 0, payments: 0 },
  { name: "خمي", purchases: 0, payments: 0 },
  { name: "جمعة", purchases: 0, payments: 0 },
];

export function TransactionsOverview() {
  return (
    <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
      <div className="flex items-center justify-between pb-3">
        <div>
          <h2 className="text-sm font-semibold text-slate-50">
            نظرة عامة على المعاملات
          </h2>
          <p className="mt-1 text-[11px] text-slate-400">
            عدد عمليات الشراء والسداد خلال الأيام الماضية.
          </p>
        </div>
        <span className="rounded-full bg-slate-900/70 px-3 py-1 text-[11px] text-slate-300 border border-slate-700">
          آخر 7 أيام
        </span>
      </div>

      <div className="mt-4 h-64 rounded-lg bg-[#031824] px-3 py-3 border border-slate-800">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" />
            <XAxis dataKey="name" stroke="#9ca3af" tick={{ fontSize: 11 }} />
            <YAxis stroke="#9ca3af" tick={{ fontSize: 11 }} />
            <Tooltip
              contentStyle={{
                backgroundColor: "#020617",
                borderColor: "#1f2937",
                borderRadius: 8,
                fontSize: 11,
                padding: 8,
              }}
            />
            <Legend wrapperStyle={{ fontSize: 11 }} />
            <Line
              type="monotone"
              dataKey="purchases"
              name="شراء"
              stroke="#22c55e"
              strokeWidth={2}
              dot={false}
            />
            <Line
              type="monotone"
              dataKey="payments"
              name="سداد"
              stroke="#38bdf8"
              strokeWidth={2}
              dot={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}


