"use client";

import { useMemo, useState, useEffect } from "react";
import { notificationsService } from "@/services/notifications.service";
import { usersService, User } from "@/services/users.service";
import { getUpcomingPayments, sendPaymentReminder } from "@/services/api";

type TabType = "logs" | "send" | "payments";

export default function NotificationsPage() {
  const [activeTab, setActiveTab] = useState<TabType>("send");
  const [loading, setLoading] = useState(false);
  const [successMsg, setSuccessMsg] = useState("");
  const [errorMsg, setErrorMsg] = useState("");

  // FCM Form State
  const [targetType, setTargetType] = useState<"user" | "all">("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [userList, setUserList] = useState<User[]>([]);
  const [selectedUserId, setSelectedUserId] = useState("");
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [imageUrl, setImageUrl] = useState("");

  // Payments / Reminders State
  const [payments, setPayments] = useState<any[]>([]);
  const [paymentsLoading, setPaymentsLoading] = useState(false);

  // Search users when targetType is 'user' and query changes
  useEffect(() => {
    if (targetType === "user" && searchQuery.length >= 2) {
      const delaySearch = setTimeout(async () => {
        try {
          const res = await usersService.getAll({ search: searchQuery, limit: 10 });
          if (res && res.data) {
            setUserList(res.data.users);
          }
        } catch (e) {
          console.error(e);
        }
      }, 500);
      return () => clearTimeout(delaySearch);
    }
  }, [searchQuery, targetType]);

  // Load upcoming payments
  const fetchUpcomingPayments = async () => {
    setPaymentsLoading(true);
    try {
      const res = await getUpcomingPayments();
      if (res && res.data) {
        // Backend returns: { success: true, data: [...] } or direct array
        const data = res.data?.data || res.data;
        const paymentsList = data?.upcomingPayments || (Array.isArray(data) ? data : []);
        setPayments(paymentsList);
      }
    } catch (e) {
      console.error("Failed to load upcoming payments", e);
    } finally {
      setPaymentsLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === "payments") {
      fetchUpcomingPayments();
    }
  }, [activeTab]);

  const handleSendNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setSuccessMsg("");
    setErrorMsg("");

    try {
      if (targetType === "user" && !selectedUserId) {
        throw new Error("يرجى اختيار المستخدم أولاً");
      }
      if (!title || !body) {
        throw new Error("يرجى ملء حقول العنوان ونص الإشعار");
      }

      if (targetType === "user") {
        await notificationsService.sendToUser({
          userId: selectedUserId,
          title,
          body,
          imageUrl: imageUrl || undefined,
        });
      } else {
        await notificationsService.sendAll({
          title,
          body,
          imageUrl: imageUrl || undefined,
        });
      }

      setSuccessMsg("✅ تم إرسال الإشعار بنجاح إلى الهاتف المستهدف!");
      setTitle("");
      setBody("");
      setImageUrl("");
      setSelectedUserId("");
      setSearchQuery("");
      setUserList([]);
    } catch (e: any) {
      setErrorMsg(e.message || "فشل إرسال الإشعار. يرجى التحقق من المدخلات.");
    } finally {
      setLoading(false);
    }
  };

  const handleSendReminder = async (paymentId: number) => {
    try {
      const confirmReminder = confirm("هل أنت متأكد من إرسال إشعار تذكير دفع يدوي لهذا العميل؟");
      if (!confirmReminder) return;

      const res = await sendPaymentReminder(paymentId);
      if (res.data && res.data.success) {
        alert("✅ تم إرسال تذكير الدفع بنجاح إلى هاتف العميل!");
      } else {
        alert("❌ فشل إرسال التذكير: " + (res.data.message || "خطأ غير معروف"));
      }
    } catch (e: any) {
      console.error(e);
      alert("❌ حدث خطأ أثناء محاولة إرسال التذكير.");
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-lg font-semibold text-slate-50">مركز الإشعارات والتحصيل</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          إرسال إشعارات مخصصة للعملاء، ومتابعة تذكيرات التحصيل اليدوية والتلقائية.
        </p>
      </div>

      {/* Tab Navigation */}
      <div className="border-b border-slate-800 flex gap-4 text-xs">
        <button
          onClick={() => setActiveTab("send")}
          className={`pb-3 font-semibold transition-colors ${
            activeTab === "send"
              ? "text-emerald-400 border-b-2 border-emerald-400"
              : "text-slate-400 hover:text-slate-200"
          }`}
        >
          📣 إرسال إشعار جديد (FCM)
        </button>
        <button
          onClick={() => setActiveTab("payments")}
          className={`pb-3 font-semibold transition-colors ${
            activeTab === "payments"
              ? "text-emerald-400 border-b-2 border-emerald-400"
              : "text-slate-400 hover:text-slate-200"
          }`}
        >
          💰 تذكير دفعات التحصيل
        </button>
        <button
          onClick={() => setActiveTab("logs")}
          className={`pb-3 font-semibold transition-colors ${
            activeTab === "logs"
              ? "text-emerald-400 border-b-2 border-emerald-400"
              : "text-slate-400 hover:text-slate-200"
          }`}
        >
          ⚙️ إعدادات الإشعارات وسجل المحاكاة
        </button>
      </div>

      {/* FCM SEND TAB */}
      {activeTab === "send" && (
        <div className="grid gap-6 md:grid-cols-3">
          <div className="md:col-span-2 rounded-xl border border-slate-800 bg-[#021f2a] p-6 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
            <h2 className="text-sm font-semibold text-slate-50 mb-4">إنشاء إشعار دفع جديد (Push Notification)</h2>
            
            {successMsg && (
              <div className="mb-4 rounded-lg bg-emerald-500/10 border border-emerald-500/40 p-3 text-xs text-emerald-300">
                {successMsg}
              </div>
            )}
            {errorMsg && (
              <div className="mb-4 rounded-lg bg-red-500/10 border border-red-500/40 p-3 text-xs text-red-300">
                {errorMsg}
              </div>
            )}

            <form onSubmit={handleSendNotification} className="space-y-4 text-xs">
              {/* Target Type selection */}
              <div>
                <label className="block text-slate-400 mb-2 font-medium">الجمهور المستهدف</label>
                <div className="flex gap-4">
                  <label className="flex items-center gap-2 text-slate-200 cursor-pointer">
                    <input
                      type="radio"
                      name="targetType"
                      checked={targetType === "all"}
                      onChange={() => setTargetType("all")}
                      className="h-4 w-4 border-slate-700 bg-slate-900 text-emerald-500 focus:ring-emerald-500"
                    />
                    <span>كل مستخدمي التطبيق (بث عام)</span>
                  </label>
                  <label className="flex items-center gap-2 text-slate-200 cursor-pointer">
                    <input
                      type="radio"
                      name="targetType"
                      checked={targetType === "user"}
                      onChange={() => setTargetType("user")}
                      className="h-4 w-4 border-slate-700 bg-slate-900 text-emerald-500 focus:ring-emerald-500"
                    />
                    <span>عميل محدد (شخصي)</span>
                  </label>
                </div>
              </div>

              {/* User search (if targetType === 'user') */}
              {targetType === "user" && (
                <div className="rounded-lg border border-slate-800 bg-slate-950/40 p-3 space-y-3">
                  <div>
                    <label className="block text-slate-400 mb-1">ابحث عن العميل (بالاسم أو رقم الهاتف)</label>
                    <input
                      type="text"
                      placeholder="اكتب حرفين على الأقل للبحث..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                    />
                  </div>

                  {userList.length > 0 && (
                    <div>
                      <label className="block text-slate-400 mb-1">اختر العميل المستهدف:</label>
                      <select
                        value={selectedUserId}
                        onChange={(e) => setSelectedUserId(e.target.value)}
                        className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none"
                      >
                        <option value="">-- اختر من القائمة --</option>
                        {userList.map((u) => (
                          <option key={u.id} value={u.id}>
                            {u.name} ({u.phone})
                          </option>
                        ))}
                      </select>
                    </div>
                  )}
                </div>
              )}

              {/* Notification Details */}
              <div className="space-y-3 pt-2">
                <div>
                  <label className="block text-slate-400 mb-1 font-medium">عنوان الإشعار (Title)</label>
                  <input
                    type="text"
                    required
                    placeholder="مثال: خصومات مميزة على المشتريات 🛍️"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                  />
                </div>

                <div>
                  <label className="block text-slate-400 mb-1 font-medium">محتوى الإشعار (Body)</label>
                  <textarea
                    required
                    rows={4}
                    placeholder="اكتب تفاصيل الإشعار الذي سيظهر للمستخدم في شريط التنبيهات..."
                    value={body}
                    onChange={(e) => setBody(e.target.value)}
                    className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                  />
                </div>

                <div>
                  <label className="block text-slate-400 mb-1 font-medium">رابط الصورة (Image URL) - اختياري</label>
                  <input
                    type="url"
                    placeholder="https://example.com/promo-image.jpg"
                    value={imageUrl}
                    onChange={(e) => setImageUrl(e.target.value)}
                    className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none"
                  />
                  <p className="mt-1 text-[10px] text-slate-500">
                    * يتم تحميل وعرض الصورة كإشعار غني (Rich Notification) على الهواتف الذكية.
                  </p>
                </div>
              </div>

              {/* Submit button */}
              <div className="pt-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full rounded-lg bg-emerald-500 py-3 text-sm font-semibold text-slate-950 hover:bg-emerald-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/60 transition-colors disabled:opacity-50"
                >
                  {loading ? "جاري الإرسال الآن..." : "🚀 إرسال الإشعار فوراً للموبايل"}
                </button>
              </div>
            </form>
          </div>

          {/* Tips card */}
          <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-6 shadow-[0_14px_35px_rgba(0,0,0,0.6)] space-y-4 text-xs text-slate-200">
            <h3 className="text-sm font-semibold text-slate-50">💡 نصائح وإرشادات الإشعارات</h3>
            <ul className="space-y-2 list-disc list-inside text-slate-300 leading-relaxed">
              <li>
                <strong>بث عام للجميع:</strong> يقوم بإرسال الإشعار دفعة واحدة لجميع مستخدمي التطبيق عبر FCM.
              </li>
              <li>
                <strong>العميل المحدد:</strong> ممتاز لإرسال التنبيهات المخصصة مثل تذكير بالهوية المدنية أو عروض مفصلة.
              </li>
              <li>
                <strong>إشعارات الهواتف المقفلة:</strong> يتم إرسال الإشعار بأولوية قصوى (High Priority)، وسيظهر على شاشة القفل حتى لو كان الهاتف مغلقاً أو التطبيق في الخلفية.
              </li>
              <li>
                <strong>أبعاد الصورة المقترحة:</strong> يفضل استخدام صور بنسبة عرض إلى ارتفاع 2:1 (مثال: 800x400) لتعرض بشكل جذاب.
              </li>
            </ul>
          </div>
        </div>
      )}

      {/* PAYMENTS REMINDERS TAB */}
      {activeTab === "payments" && (
        <div className="space-y-4">
          <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-semibold text-slate-50">الدفعات المستحقة قريباً (خلال 7 أيام)</h3>
                <p className="text-[11px] text-slate-400 mt-1">
                  يمكنك إرسال تذكير إشعارات يدوي فوري للعميل الذي لديه دفعة مستحقة ومكتوب بجانبها زر التذكير.
                </p>
              </div>
              <button
                onClick={fetchUpcomingPayments}
                disabled={paymentsLoading}
                className="rounded-lg bg-emerald-500/10 border border-emerald-500/40 px-3 py-1.5 text-xs text-emerald-300 hover:bg-emerald-500/20"
              >
                {paymentsLoading ? "جاري التحديث..." : "🔄 تحديث القائمة"}
              </button>
            </div>
          </div>

          <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-slate-800 text-xs">
                <thead className="bg-[#041f2e] text-slate-300">
                  <tr>
                    <th className="px-4 py-3 text-right">رقم الدفعة</th>
                    <th className="px-4 py-3 text-right">العميل</th>
                    <th className="px-4 py-3 text-right">المتجر</th>
                    <th className="px-4 py-3 text-right">القسط</th>
                    <th className="px-4 py-3 text-right">تاريخ الاستحقاق</th>
                    <th className="px-4 py-3 text-right">المبلغ</th>
                    <th className="px-4 py-3 text-center">إجراء تذكير</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800 bg-[#031824] text-slate-200">
                  {paymentsLoading ? (
                    <tr>
                      <td colSpan={7} className="px-4 py-8 text-center text-slate-400">
                        جاري تحميل الدفعات القادمة...
                      </td>
                    </tr>
                  ) : payments.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="px-4 py-8 text-center text-slate-400">
                        لا توجد دفعات معلقة مستحقة خلال الأيام القادمة.
                      </td>
                    </tr>
                  ) : (
                    payments.map((p: any) => (
                      <tr key={p.id} className="hover:bg-slate-900/40 transition-colors">
                        <td className="px-4 py-3 font-semibold text-slate-50">#{p.id}</td>
                        <td className="px-4 py-3">{p.customer || p.user?.name || "غير معروف"}</td>
                        <td className="px-4 py-3 text-slate-300">
                          {p.storeName || (typeof p.store === 'string' ? p.store : (p.store?.nameAr || p.store?.name || "غير معروف"))}
                        </td>
                        <td className="px-4 py-3">
                          قسط {p.installmentNumber} من {p.installmentsCount}
                        </td>
                        <td className="px-4 py-3 text-red-300">
                          {p.dueDate ? new Date(p.dueDate).toLocaleDateString("ar-JO", {
                            day: "numeric",
                            month: "long",
                          }) : "—"}
                        </td>
                        <td className="px-4 py-3 font-bold text-emerald-400">{p.amount} JOD</td>
                        <td className="px-4 py-3 text-center">
                          <button
                            onClick={() => handleSendReminder(p.id)}
                            className="rounded bg-blue-500 hover:bg-blue-600 px-3 py-1.5 text-[11px] text-white font-medium flex items-center gap-1 mx-auto"
                          >
                            <span>🔔</span>
                            <span>تذكير يدوي</span>
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* SIMULATED LOGS TAB (Original layout) */}
      {activeTab === "logs" && (
        <div className="space-y-6">
          <section className="grid gap-4 md:grid-cols-4">
            <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
              <p className="text-xs text-slate-400 flex items-center gap-1">
                <span>🔔</span>
                <span>إشعارات اليوم</span>
              </p>
              <p className="mt-2 text-2xl font-semibold text-slate-50">0</p>
              <p className="mt-1 text-[11px] text-slate-300">آخر 24 ساعة</p>
            </div>

            <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
              <p className="text-xs text-slate-400 flex items-center gap-1">
                <span>📬</span>
                <span>غير مقروءة</span>
              </p>
              <p className="mt-2 text-2xl font-semibold text-slate-50">0</p>
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
                <span>القنوات النشطة</span>
              </p>
              <p className="mt-2 text-2xl font-semibold">3</p>
              <p className="mt-1 text-[11px] text-emerald-900">قنوات مفعّلة</p>
            </div>
          </section>

          <div className="grid gap-4 xl:grid-cols-3">
            <div className="xl:col-span-2 rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
              <div className="border-b border-slate-800 bg-[#041f2e] px-4 py-3 text-sm font-semibold text-slate-200">
                صندوق إشعارات محاكاة السيرفر
              </div>
              <div className="divide-y divide-slate-800">
                <p className="px-4 py-6 text-center text-xs text-slate-400">
                  لا توجد إشعارات مسجلة في سجل المحاكاة.
                </p>
              </div>
            </div>

            <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)]">
              <div className="border-b border-slate-800 bg-[#041f2e] px-4 py-3 text-xs font-semibold text-slate-200">
                قنوات التنبيه التلقائية المفعّلة
              </div>
              <div className="divide-y divide-slate-800 text-xs text-slate-200">
                <label className="flex items-center justify-between px-4 py-3">
                  <span>تنبيهات الدفعات المتأخرة</span>
                  <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-emerald-500 text-emerald-500 focus:ring-emerald-500" />
                </label>
                <label className="flex items-center justify-between px-4 py-3">
                  <span>موافقات الطلبات الجديدة</span>
                  <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-emerald-500 text-emerald-500 focus:ring-emerald-500" />
                </label>
                <label className="flex items-center justify-between px-4 py-3">
                  <span>تحويلات البنك</span>
                  <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-emerald-500 text-emerald-500 focus:ring-emerald-500" />
                </label>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
