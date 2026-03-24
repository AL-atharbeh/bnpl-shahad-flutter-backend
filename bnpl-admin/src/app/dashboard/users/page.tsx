"use client";

import { useState, useEffect } from "react";
import { User, usersService, UserStats } from "@/services/users.service";
import UserModal from "@/components/modals/UserModal";

// Mock data for transactions (will be replaced later)
const mockTransactions = [
  {
    id: 1,
    userId: 1,
    store: "زارا الأردن",
    amount: "120 دينار",
    date: "2025-01-15",
    status: "مكتملة",
    statusColor: "emerald",
  },
  {
    id: 2,
    userId: 1,
    store: "سامسونغ",
    amount: "300 دينار",
    date: "2025-01-10",
    status: "مكتملة",
    statusColor: "emerald",
  },
];

// Mock data for payments (will be replaced later)
const mockPayments = [
  {
    id: 1,
    userId: 1,
    amount: "120 دينار",
    dueDate: "2025-02-15",
    paidDate: "2025-02-14",
    status: "مدفوعة",
    statusColor: "emerald",
    installment: "1/3",
  },
  {
    id: 2,
    userId: 1,
    amount: "120 دينار",
    dueDate: "2025-03-15",
    paidDate: null,
    status: "مستحقة",
    statusColor: "amber",
    installment: "2/3",
  },
];

const statusColors = {
  emerald: "bg-emerald-500/15 text-emerald-300 border-emerald-500/40",
  red: "bg-red-500/15 text-red-300 border-red-500/40",
  amber: "bg-amber-500/15 text-amber-200 border-amber-500/40",
  slate: "bg-slate-500/15 text-slate-400 border-slate-500/40",
};

export default function UsersPage() {
  const [loading, setLoading] = useState(true);
  const [users, setUsers] = useState<User[]>([]);
  const [stats, setStats] = useState<UserStats | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("الكل");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalUsers, setTotalUsers] = useState(0);
  const [selectedUsers, setSelectedUsers] = useState<number[]>([]);
  const [showUserModal, setShowUserModal] = useState(false);
  const [showAddUserModal, setShowAddUserModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const itemsPerPage = 10;

  useEffect(() => {
    fetchUsers();
    fetchStats();
  }, [currentPage, searchQuery, statusFilter]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const result = await usersService.getAll({
        search: searchQuery || undefined,
        status: statusFilter !== "الكل" ? statusFilter : undefined,
        page: currentPage,
        limit: itemsPerPage,
      });

      if (result && result.data) {
        setUsers(result.data.users);
        setTotalUsers(result.data.total);
      }
    } catch (error) {
      console.error("Failed to fetch users", error);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const result = await usersService.getStats();
      if (result && result.data) {
        setStats(result.data);
      }
    } catch (error) {
      console.error("Failed to fetch stats", error);
    }
  };

  const handleUpdateUserStatus = async (userId: number, isActive: boolean) => {
    try {
      await usersService.updateStatus(userId, isActive);
      fetchUsers();
      fetchStats();
    } catch (error) {
      console.error("Failed to update user status", error);
      alert("فشل تحديث حالة المستخدم");
    }
  };

  // Pagination
  const totalPages = Math.ceil(totalUsers / itemsPerPage);

  // Handle select all
  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedUsers(users.map((u) => u.id));
    } else {
      setSelectedUsers([]);
    }
  };

  // Handle individual select
  const handleSelectUser = (userId: number, checked: boolean) => {
    if (checked) {
      setSelectedUsers([...selectedUsers, userId]);
    } else {
      setSelectedUsers(selectedUsers.filter((id) => id !== userId));
    }
  };

  // Handle bulk actions
  const handleBulkAction = (action: string) => {
    if (selectedUsers.length === 0) return;
    // TODO: Implement bulk actions
    alert(`سيتم تنفيذ "${action}" على ${selectedUsers.length} مستخدم`);
    setSelectedUsers([]);
  };

  // Handle export
  const handleExport = () => {
    // TODO: Implement export to CSV/Excel
    alert("سيتم تصدير البيانات إلى ملف Excel");
  };

  // Handle view user details
  const handleViewUser = (user: User) => {
    setSelectedUser(user);
    setShowUserModal(true);
  };

  // Detailed statistics - these would need to come from backend in production
  const detailedStats = {
    avgCreditScore: 0, // TODO: Calculate from backend
    totalCreditLimit: 0,
    totalUsedCredit: 0,
    verifiedUsers: stats?.verifiedUsers || 0,
    totalLatePayments: 0,
    avgTransactionValue: 0,
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-lg font-semibold text-slate-50">إدارة المستخدمين</h1>
        <p className="mt-1 text-[12px] text-slate-400">
          عرض وإدارة جميع حسابات المستخدمين المسجّلة في النظام
        </p>
      </div>

      {/* Statistics Cards */}
      <section className="grid gap-4 md:grid-cols-4">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>👥</span>
            <span>إجمالي المستخدمين</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.totalUsers || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم مسجّل</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>✅</span>
            <span>المستخدمون النشطون</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.activeUsers || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم نشط</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🆕</span>
            <span>جدد هذا الشهر</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.newUsersThisMonth || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم جديد</p>
        </div>

        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400 flex items-center gap-1">
            <span>🚫</span>
            <span>المحظورون</span>
          </p>
          <p className="mt-2 text-2xl font-semibold text-slate-50">
            {stats?.blockedUsers || 0}
          </p>
          <p className="mt-1 text-[11px] text-slate-300">مستخدم محظور</p>
        </div>
      </section>

      {/* Detailed Statistics */}
      <section className="grid gap-4 md:grid-cols-6">
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">متوسط الجدارة الائتمانية</p>
          <p className="mt-2 text-xl font-semibold text-slate-50">
            {detailedStats.avgCreditScore}
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">إجمالي حدود الائتمان</p>
          <p className="mt-2 text-xl font-semibold text-slate-50">
            {detailedStats.totalCreditLimit.toLocaleString()} دينار
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">إجمالي الائتمان المستخدم</p>
          <p className="mt-2 text-xl font-semibold text-slate-50">
            {detailedStats.totalUsedCredit.toLocaleString()} دينار
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">المستخدمون المحققون</p>
          <p className="mt-2 text-xl font-semibold text-slate-50">
            {detailedStats.verifiedUsers}
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">إجمالي التأخيرات</p>
          <p className="mt-2 text-xl font-semibold text-slate-50">
            {detailedStats.totalLatePayments}
          </p>
        </div>
        <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <p className="text-xs text-slate-400">متوسط قيمة المعاملة</p>
          <p className="mt-2 text-xl font-semibold text-slate-50">
            {detailedStats.avgTransactionValue} دينار
          </p>
        </div>
      </section>

      {/* Search and Filters */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div className="flex flex-1 items-center gap-3">
            <div className="relative flex-1">
              <input
                type="text"
                placeholder="ابحث بالاسم، رقم الهاتف، أو البريد الإلكتروني..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setCurrentPage(1);
                }}
                className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
              />
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
                🔍
              </span>
            </div>

            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setCurrentPage(1);
              }}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            >
              <option value="الكل">الكل</option>
              <option value="نشط">نشط</option>
              <option value="محظور">محظور</option>
              <option value="متأخر">متأخر</option>
              <option value="غير نشط">غير نشط</option>
            </select>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleExport}
              className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
            >
              📥 تصدير البيانات
            </button>
            <button
              onClick={() => setShowAddUserModal(true)}
              className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/60 transition-colors"
            >
              + إضافة مستخدم جديد
            </button>
          </div>
        </div>

        <div className="mt-3 text-xs text-slate-400">
          عرض {users.length} من {totalUsers} مستخدم
        </div>
      </div>

      {/* Bulk Actions Bar */}
      {selectedUsers.length > 0 && (
        <div className="rounded-xl border border-emerald-500/40 bg-emerald-500/10 p-4 shadow-[0_14px_35px_rgba(0,0,0,0.6)]">
          <div className="flex items-center justify-between">
            <div className="text-sm text-emerald-300">
              تم تحديد {selectedUsers.length} مستخدم
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => handleBulkAction("إرسال إشعار")}
                className="rounded-lg border border-emerald-500/40 bg-emerald-500/20 px-4 py-2 text-xs font-medium text-emerald-300 hover:bg-emerald-500/30 transition-colors"
              >
                📧 إرسال إشعار
              </button>
              <button
                onClick={() => handleBulkAction("حظر")}
                className="rounded-lg border border-red-500/40 bg-red-500/20 px-4 py-2 text-xs font-medium text-red-300 hover:bg-red-500/30 transition-colors"
              >
                🚫 حظر
              </button>
              <button
                onClick={() => handleBulkAction("إلغاء الحظر")}
                className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-medium text-slate-300 hover:bg-slate-900 transition-colors"
              >
                ✅ إلغاء الحظر
              </button>
              <button
                onClick={() => setSelectedUsers([])}
                className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-xs font-medium text-slate-300 hover:bg-slate-900 transition-colors"
              >
                ✕ إلغاء التحديد
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Users Table */}
      <div className="rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_16px_40px_rgba(0,0,0,0.65)] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-800">
            <thead className="bg-[#041f2e]">
              <tr>
                <th className="px-4 py-3 text-center text-xs font-medium text-slate-300">
                  <input
                    type="checkbox"
                    checked={
                      selectedUsers.length === users.length &&
                      users.length > 0
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="rounded border-slate-600 bg-slate-800 text-emerald-500 focus:ring-emerald-500"
                  />
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  الاسم
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  رقم الهاتف
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  الحالة
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  الجدارة الائتمانية
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  حالة التحقق
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  تاريخ التأخيرات
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  عدد المعاملات
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-slate-300">
                  إجمالي المشتريات
                </th>
                <th className="px-4 py-3 text-center text-xs font-medium text-slate-300">
                  الإجراءات
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800 bg-[#031824]">
              {loading ? (
                <tr>
                  <td
                    colSpan={10}
                    className="px-4 py-8 text-center text-sm text-slate-400"
                  >
                    <div className="flex justify-center">
                      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500"></div>
                    </div>
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td
                    colSpan={10}
                    className="px-4 py-8 text-center text-sm text-slate-400"
                  >
                    لا توجد نتائج
                  </td>
                </tr>
              ) : (
                users.map((user) => (
                  <tr
                    key={user.id}
                    className="hover:bg-slate-900/40 transition-colors"
                  >
                    <td className="px-4 py-3 text-center">
                      <input
                        type="checkbox"
                        checked={selectedUsers.includes(user.id)}
                        onChange={(e) =>
                          handleSelectUser(user.id, e.target.checked)
                        }
                        className="rounded border-slate-600 bg-slate-800 text-emerald-500 focus:ring-emerald-500"
                      />
                    </td>
                    <td className="px-4 py-3 text-sm text-slate-50">
                      {user.name}
                    </td>
                    <td className="px-4 py-3 text-sm text-slate-300">
                      {user.phone}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-medium border ${user.isActive ? statusColors.emerald : statusColors.red}`}
                      >
                        {user.isActive ? "نشط" : "محظور"}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-medium text-slate-50">
                          N/A
                        </span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-medium border ${user.isPhoneVerified ? statusColors.emerald : statusColors.red}`}
                      >
                        {user.isPhoneVerified ? "محقق" : "غير محقق"}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-slate-300">
                      <span className="text-emerald-300">لا يوجد</span>
                    </td>
                    <td className="px-4 py-3 text-sm text-slate-300">
                      {user.payments?.length || 0}
                    </td>
                    <td className="px-4 py-3 text-sm font-medium text-slate-50">
                      N/A
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-center gap-2">
                        <button
                          onClick={() => handleViewUser(user)}
                          className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
                          title="عرض التفاصيل"
                        >
                          👁️
                        </button>
                        <button
                          className="rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-3 py-1.5 text-xs text-emerald-300 hover:bg-emerald-500/20 transition-colors"
                          title="تعديل"
                        >
                          ✏️
                        </button>
                        <button
                          onClick={() => handleUpdateUserStatus(user.id, !user.isActive)}
                          className="rounded-lg border border-red-500/40 bg-red-500/10 px-3 py-1.5 text-xs text-red-300 hover:bg-red-500/20 transition-colors"
                          title={user.isActive ? "حظر" : "إلغاء حظر"}
                        >
                          {user.isActive ? "🚫" : "✅"}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="border-t border-slate-800 bg-[#041f2e] px-4 py-3">
            <div className="flex items-center justify-between">
              <div className="text-xs text-slate-400">
                الصفحة {currentPage} من {totalPages}
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-300 hover:bg-slate-900 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  السابق
                </button>
                <div className="flex items-center gap-1">
                  {Array.from({ length: totalPages }, (_, i) => i + 1).map(
                    (page) => (
                      <button
                        key={page}
                        onClick={() => setCurrentPage(page)}
                        className={`rounded-lg px-3 py-1.5 text-xs transition-colors ${currentPage === page
                          ? "bg-emerald-500 text-slate-950 font-medium"
                          : "border border-slate-700 bg-slate-900/60 text-slate-300 hover:bg-slate-900"
                          }`}
                      >
                        {page}
                      </button>
                    )
                  )}
                </div>
                <button
                  onClick={() =>
                    setCurrentPage((p) => Math.min(totalPages, p + 1))
                  }
                  disabled={currentPage === totalPages}
                  className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-300 hover:bg-slate-900 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  التالي
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* User Details Modal */}
      {showUserModal && selectedUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="relative w-full max-w-4xl max-h-[90vh] overflow-y-auto rounded-xl border border-slate-800 bg-[#021f2a] shadow-[0_20px_50px_rgba(0,0,0,0.8)]">
            {/* Modal Header */}
            <div className="sticky top-0 flex items-center justify-between border-b border-slate-800 bg-[#021f2a] px-6 py-4">
              <div>
                <h2 className="text-lg font-semibold text-slate-50">
                  ملف المستخدم: {selectedUser.name}
                </h2>
                <p className="mt-1 text-xs text-slate-400">
                  {selectedUser.email} • {selectedUser.phone}
                </p>
              </div>
              <button
                onClick={() => {
                  setShowUserModal(false);
                  setSelectedUser(null);
                }}
                className="rounded-lg border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-sm text-slate-300 hover:bg-slate-900 hover:text-slate-50 transition-colors"
              >
                ✕ إغلاق
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6 space-y-6">
              {/* User Profile Section */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <h3 className="text-sm font-semibold text-slate-50 mb-4">
                  📋 المعلومات الشخصية
                </h3>
                <div className="grid gap-4 md:grid-cols-2">
                  <div>
                    <p className="text-xs text-slate-400">الاسم الكامل</p>
                    <p className="mt-1 text-sm text-slate-50">{selectedUser.name}</p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">رقم الهاتف</p>
                    <p className="mt-1 text-sm text-slate-50">{selectedUser.phone}</p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">البريد الإلكتروني</p>
                    <p className="mt-1 text-sm text-slate-50">{selectedUser.email}</p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">رقم الهوية</p>
                    <p className="mt-1 text-sm text-slate-50">{selectedUser.civilIdNumber || "غير متوفر"}</p>
                  </div>
                  <div className="md:col-span-2">
                    <p className="text-xs text-slate-400">العنوان</p>
                    <p className="mt-1 text-sm text-slate-50">{selectedUser.address || "غير متوفر"}</p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">تاريخ التسجيل</p>
                    <p className="mt-1 text-sm text-slate-50">
                      {new Date(selectedUser.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">آخر تحديث</p>
                    <p className="mt-1 text-sm text-slate-50">
                      {new Date(selectedUser.updatedAt).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </section>

              {/* Additional Information */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <h3 className="text-sm font-semibold text-slate-50 mb-4">
                  💼 معلومات إضافية
                </h3>
                <div className="grid gap-4 md:grid-cols-2">
                  <div>
                    <p className="text-xs text-slate-400">الدخل الشهري</p>
                    <p className="mt-1 text-sm text-slate-50">
                      {selectedUser.monthlyIncome ? `${selectedUser.monthlyIncome} دينار` : "غير متوفر"}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">جهة العمل</p>
                    <p className="mt-1 text-sm text-slate-50">{selectedUser.employer || "غير متوفر"}</p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">حالة التحقق من الهاتف</p>
                    <p className="mt-1">
                      <span className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-medium border ${selectedUser.isPhoneVerified ? statusColors.emerald : statusColors.red}`}>
                        {selectedUser.isPhoneVerified ? "محقق" : "غير محقق"}
                      </span>
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">حالة التحقق من البريد</p>
                    <p className="mt-1">
                      <span className={`inline-flex rounded-full px-2.5 py-1 text-[10px] font-medium border ${selectedUser.isEmailVerified ? statusColors.emerald : statusColors.red}`}>
                        {selectedUser.isEmailVerified ? "محقق" : "غير محقق"}
                      </span>
                    </p>
                  </div>
                </div>
              </section>

              {/* Transactions History */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-sm font-semibold text-slate-50">
                    📊 سجل المعاملات
                  </h3>
                  <button className="text-xs text-emerald-300 hover:text-emerald-200">
                    عرض الكل
                  </button>
                </div>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-slate-800 text-xs">
                    <thead className="bg-[#041f2e]">
                      <tr>
                        <th className="px-3 py-2 text-right text-slate-300">المتجر</th>
                        <th className="px-3 py-2 text-right text-slate-300">المبلغ</th>
                        <th className="px-3 py-2 text-right text-slate-300">التاريخ</th>
                        <th className="px-3 py-2 text-right text-slate-300">الحالة</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800">
                      {mockTransactions
                        .filter((t) => t.userId === selectedUser.id)
                        .map((transaction) => (
                          <tr key={transaction.id}>
                            <td className="px-3 py-2 text-slate-50">
                              {transaction.store}
                            </td>
                            <td className="px-3 py-2 text-slate-50">
                              {transaction.amount}
                            </td>
                            <td className="px-3 py-2 text-slate-400">
                              {transaction.date}
                            </td>
                            <td className="px-3 py-2">
                              <span
                                className={`inline-flex rounded-full px-2 py-0.5 text-[10px] border ${statusColors[transaction.statusColor as keyof typeof statusColors]}`}
                              >
                                {transaction.status}
                              </span>
                            </td>
                          </tr>
                        ))}
                    </tbody>
                  </table>
                </div>
              </section>

              {/* Payments History */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-sm font-semibold text-slate-50">
                    💰 سجل الدفعات والقسط
                  </h3>
                  <button className="text-xs text-emerald-300 hover:text-emerald-200">
                    عرض الكل
                  </button>
                </div>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-slate-800 text-xs">
                    <thead className="bg-[#041f2e]">
                      <tr>
                        <th className="px-3 py-2 text-right text-slate-300">القسط</th>
                        <th className="px-3 py-2 text-right text-slate-300">المبلغ</th>
                        <th className="px-3 py-2 text-right text-slate-300">
                          تاريخ الاستحقاق
                        </th>
                        <th className="px-3 py-2 text-right text-slate-300">
                          تاريخ الدفع
                        </th>
                        <th className="px-3 py-2 text-right text-slate-300">الحالة</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800">
                      {mockPayments
                        .filter((p) => p.userId === selectedUser.id)
                        .map((payment) => (
                          <tr key={payment.id}>
                            <td className="px-3 py-2 text-slate-50">
                              {payment.installment}
                            </td>
                            <td className="px-3 py-2 text-slate-50">
                              {payment.amount}
                            </td>
                            <td className="px-3 py-2 text-slate-400">
                              {payment.dueDate}
                            </td>
                            <td className="px-3 py-2 text-slate-400">
                              {payment.paidDate || "—"}
                            </td>
                            <td className="px-3 py-2">
                              <span
                                className={`inline-flex rounded-full px-2 py-0.5 text-[10px] border ${statusColors[payment.statusColor as keyof typeof statusColors]}`}
                              >
                                {payment.status}
                              </span>
                            </td>
                          </tr>
                        ))}
                    </tbody>
                  </table>
                </div>
              </section>

              {/* Send Message/Notification */}
              <section className="rounded-xl border border-slate-800 bg-[#031824] p-4">
                <h3 className="text-sm font-semibold text-slate-50 mb-4">
                  📧 إرسال الرسائل والإشعارات
                </h3>
                <div className="flex flex-col gap-3">
                  <div>
                    <label className="block text-xs text-slate-400 mb-1">
                      نوع الرسالة
                    </label>
                    <select className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20">
                      <option>تذكير بالدفع</option>
                      <option>تنبيه تأخير</option>
                      <option>إشعار عام</option>
                      <option>رسالة مخصصة</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs text-slate-400 mb-1">
                      نص الرسالة
                    </label>
                    <textarea
                      rows={3}
                      placeholder="اكتب رسالتك هنا..."
                      className="w-full rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:border-emerald-500/60 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                    />
                  </div>
                  <div className="flex items-center gap-2">
                    <button className="rounded-lg bg-emerald-500 px-4 py-2 text-sm font-medium text-slate-950 hover:bg-emerald-400 transition-colors">
                      📱 إرسال SMS
                    </button>
                    <button className="rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-4 py-2 text-sm font-medium text-emerald-300 hover:bg-emerald-500/20 transition-colors">
                      📧 إرسال Email
                    </button>
                    <button className="rounded-lg border border-slate-700 bg-slate-900/60 px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-900 transition-colors">
                      🔔 إرسال إشعار
                    </button>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </div>
      )}

      {/* Add User Modal */}
      <UserModal
        isOpen={showAddUserModal}
        onClose={() => setShowAddUserModal(false)}
        onSuccess={() => {
          fetchUsers();
          fetchStats();
        }}
      />
    </div>
  );
}
