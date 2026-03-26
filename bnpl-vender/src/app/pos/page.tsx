"use client";

import { useEffect, useState, useRef } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
    Search,
    Plus,
    Minus,
    Trash2,
    Loader2,
    Phone,
    Smartphone,
    QrCode,
    CheckCircle2,
    Clock,
    X,
    ShoppingCart,
    ArrowRight,
    ArrowLeft
} from "lucide-react";
import {
    getVendorProducts,
    createBnplSession,
    getBnplSession,
    verifyBnplOtp,
    findUserByPhone,
    getRecentSessions
} from "@/services/api";
import { useLanguage } from "@/contexts/LanguageContext";
import { QRCodeSVG } from "qrcode.react";

export default function POSPage() {
    const { t, language } = useLanguage();
    const [products, setProducts] = useState<any[]>([]);
    const [loadingProducts, setLoadingProducts] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    // POS State
    const [cart, setCart] = useState<any[]>([]);
    const [customerPhone, setCustomerPhone] = useState("");
    const [foundUser, setFoundUser] = useState<{ name: string; isVerified: boolean } | null>(null);
    const [installments, setInstallments] = useState(4);
    const [discount, setDiscount] = useState(0); // Optional manual discount
    const [paymentMethod, setPaymentMethod] = useState<"phone" | "qr">("phone");
    const [recentSessions, setRecentSessions] = useState<any[]>([]);

    // Session Flow State
    const [creatingSession, setCreatingSession] = useState(false);
    const [activeSession, setActiveSession] = useState<any>(null);
    const [sessionStatus, setSessionStatus] = useState<string>("PENDING");
    const [otpCode, setOtpCode] = useState("");
    const [isOtpVerified, setIsOtpVerified] = useState(false);
    const [verifyingOtp, setVerifyingOtp] = useState(false);

    const statusInterval = useRef<NodeJS.Timeout | null>(null);

    useEffect(() => {
        loadProducts();
        loadRecentSessions();
    }, []);

    useEffect(() => {
        if (customerPhone && customerPhone.length >= 10) {
            const timer = setTimeout(async () => {
                let formattedPhone = customerPhone.trim();
                if (formattedPhone.startsWith("07")) {
                    formattedPhone = "962" + formattedPhone.substring(1);
                }
                try {
                    const res = await findUserByPhone(formattedPhone);
                    if (res.data.success) {
                        setFoundUser(res.data.data);
                    } else {
                        setFoundUser(null);
                    }
                } catch (err) {
                    setFoundUser(null);
                }
            }, 500);
            return () => clearTimeout(timer);
        } else {
            setFoundUser(null);
        }
    }, [customerPhone]);

    useEffect(() => {
        if (activeSession && (sessionStatus === "PENDING" || sessionStatus === "PAYMENT_PENDING")) {
            statusInterval.current = setInterval(pollSessionStatus, 3000);
        } else {
            if (statusInterval.current) clearInterval(statusInterval.current);
            if (sessionStatus === "APPROVED" || sessionStatus === "COMPLETED") {
                loadRecentSessions();
            }
        }
        return () => {
            if (statusInterval.current) clearInterval(statusInterval.current);
        };
    }, [activeSession, sessionStatus]);

    async function loadRecentSessions() {
        const userStr = localStorage.getItem("vendor_user");
        if (!userStr) return;
        const user = JSON.parse(userStr);
        try {
            const res = await getRecentSessions(user.storeId);
            setRecentSessions(res.data);
        } catch (err) {
            console.error("Failed to load recent sessions", err);
        }
    }

    async function loadProducts() {
        const userStr = localStorage.getItem("vendor_user");
        if (!userStr) return;
        const user = JSON.parse(userStr);
        try {
            const res = await getVendorProducts(user.storeId);
            setProducts(res.data.data);
        } catch (err) {
            console.error("Failed to load products", err);
        } finally {
            setLoadingProducts(false);
        }
    }

    const pollSessionStatus = async () => {
        if (!activeSession) return;
        try {
            const res = await getBnplSession(activeSession.session_id);
            setSessionStatus(res.data.status);
            if (res.data.status === "APPROVED" || res.data.status === "COMPLETED") {
                if (statusInterval.current) clearInterval(statusInterval.current);
            }
        } catch (err) {
            console.error("Polling failed", err);
        }
    };

    const addToCart = (product: any) => {
        setCart(prev => {
            const existing = prev.find(item => item.id === product.id);
            if (existing) {
                return prev.map(item => item.id === product.id ? { ...item, quantity: item.quantity + 1 } : item);
            }
            return [...prev, { ...product, quantity: 1 }];
        });
    };

    const updateQuantity = (id: number, delta: number) => {
        setCart(prev => prev.map(item => {
            if (item.id === id) {
                const newQty = Math.max(1, item.quantity + delta);
                return { ...item, quantity: newQty };
            }
            return item;
        }));
    };

    const removeFromCart = (id: number) => {
        setCart(prev => prev.filter(item => item.id !== id));
    };

    const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const totalAmount = Math.max(0, subtotal - discount);
    const installmentAmount = totalAmount / installments;

    const handleCreateSession = async () => {
        if (totalAmount <= 0) return;
        if (paymentMethod === "phone" && !customerPhone) return;

        setCreatingSession(true);
        setIsOtpVerified(false);
        setOtpCode("");
        
        const userStr = localStorage.getItem("vendor_user");
        const user = JSON.parse(userStr!);

        try {
            if (!user.storeId) {
                alert("Store ID is missing from your account. Please log in again.");
                return;
            }

            let formattedPhone = customerPhone?.trim();
            if (formattedPhone?.startsWith("07")) {
                formattedPhone = "962" + formattedPhone.substring(1);
            }

            const payload = {
                store_id: Number(user.storeId),
                store_order_id: `POS_${Date.now()}`,
                total_amount: Number(totalAmount.toFixed(2)),
                customer_phone: paymentMethod === "phone" ? formattedPhone : undefined,
                installments_count: Number(installments),
                items: cart.map(item => ({
                    name: (language === "ar" ? item.name_ar : item.name) || item.name,
                    quantity: Number(item.quantity),
                    price: Number(Number(item.price).toFixed(2))
                })),
                metadata: {
                   discount_applied: discount,
                   subtotal: subtotal
                }
            };

            const res = await createBnplSession(payload);
            setActiveSession(res.data);
            setSessionStatus("PENDING");
            
            // If QR, consider OTP verified (or not applicable)
            if (paymentMethod === "qr") {
                setIsOtpVerified(true);
            }
        } catch (err: any) {
            console.error("Failed to create session", err);
            const errorMsg = err.response?.data?.message || err.message || "Unknown error";
            alert(`Failed to initiate payment: ${errorMsg}`);
        } finally {
            setCreatingSession(false);
        }
    };

    const handleVerifyOtp = async () => {
        if (!otpCode || otpCode.length !== 6 || !activeSession) return;
        
        setVerifyingOtp(true);
        try {
            const res = await verifyBnplOtp(activeSession.session_id, otpCode);
            setIsOtpVerified(true);
            alert(res.data.message);
        } catch (err: any) {
            console.error("OTP Verification failed", err);
            const errorMsg = err.response?.data?.message || "Invalid code";
            alert(errorMsg);
        } finally {
            setVerifyingOtp(false);
        }
    };

    const filteredProducts = products.filter(p =>
    (p.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.name_ar?.includes(searchQuery))
    );

    if (activeSession) {
        return (
            <DashboardLayout>
                <div className="max-w-2xl mx-auto py-12">
                    <div className="glass rounded-3xl p-12 border-emerald-900/20 text-center space-y-8 animate-in fade-in zoom-in duration-500">
                        {!isOtpVerified ? (
                            <>
                                <div className="flex justify-center">
                                    <div className="h-20 w-20 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center">
                                        <Smartphone className="h-10 w-10 text-emerald-500" />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <h2 className="text-2xl font-black text-white">{language === "ar" ? "أدخل رمز التحقق" : "Enter Verification Code"}</h2>
                                    <p className="text-slate-400">{language === "ar" ? `تم إرسال رمز إلى العميل على الرقم ${customerPhone}` : `A code has been sent to the customer at ${customerPhone}`}</p>
                                </div>
                                
                                <div className="max-w-xs mx-auto">
                                    <input
                                        type="text"
                                        maxLength={6}
                                        value={otpCode}
                                        onChange={(e) => setOtpCode(e.target.value)}
                                        placeholder="------"
                                        className="w-full bg-[#011f18] border-2 border-emerald-900/30 rounded-2xl py-4 text-center text-3xl font-black tracking-[1em] text-emerald-400 outline-none focus:border-emerald-500 shadow-inner"
                                    />
                                </div>

                                <button
                                    onClick={handleVerifyOtp}
                                    disabled={verifyingOtp || otpCode.length !== 6}
                                    className="btn-financial w-full py-4 rounded-2xl text-lg font-black disabled:opacity-30 flex items-center justify-center gap-2"
                                >
                                    {verifyingOtp ? <Loader2 className="h-6 w-6 animate-spin" /> : (language === "ar" ? "تحقق من الرمز" : "Verify Code")}
                                </button>

                                <button
                                    onClick={() => setActiveSession(null)}
                                    className="text-slate-500 hover:text-slate-300 transition-colors text-sm"
                                >
                                    {t("cancel")}
                                </button>
                            </>
                        ) : sessionStatus === "PENDING" || sessionStatus === "PAYMENT_PENDING" ? (
                            <>
                                <div className="flex justify-center">
                                    <div className="relative">
                                        <div className="absolute inset-0 bg-emerald-500/20 blur-2xl rounded-full"></div>
                                        <div className="relative h-24 w-24 rounded-full bg-[#011f18] border-2 border-emerald-500/50 flex items-center justify-center animate-pulse">
                                            {paymentMethod === "qr" ? <QrCode className="h-12 w-12 text-emerald-400" /> : <Smartphone className="h-12 w-12 text-emerald-400" />}
                                        </div>
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <h2 className="text-2xl font-black text-white">{t("sessionActive")}</h2>
                                    <p className="text-slate-400">{t("waitingCustomerApproval")}</p>
                                </div>

                                {paymentMethod === "qr" && (
                                    <div className="bg-white p-6 rounded-2xl inline-block shadow-2xl shadow-emerald-900/20 border-8 border-white">
                                        <QRCodeSVG value={activeSession.web_redirect_url} size={200} level="M" />
                                    </div>
                                )}

                                <div className="p-4 bg-emerald-500/10 rounded-2xl border border-emerald-500/20">
                                    <div className="text-xs text-emerald-500/60 uppercase font-black tracking-widest mb-1">{t("total")}</div>
                                    <div className="text-3xl font-black text-white">{totalAmount.toLocaleString()} {t("currency")}</div>
                                </div>

                                <button
                                    onClick={() => {
                                        setActiveSession(null);
                                        setCart([]);
                                        setCustomerPhone("");
                                        setDiscount(0);
                                    }}
                                    className="text-slate-500 hover:text-slate-300 transition-colors text-sm flex items-center justify-center gap-2 w-full pt-4"
                                >
                                    <X className="h-4 w-4" />
                                    {t("clearCart")}
                                </button>
                            </>
                        ) : (
                            <>
                                <div className="flex justify-center">
                                    <div className="h-24 w-24 rounded-full bg-emerald-500 flex items-center justify-center shadow-lg shadow-emerald-500/20">
                                        <CheckCircle2 className="h-12 w-12 text-[#01160e]" />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <h2 className="text-3xl font-black text-white">{language === "ar" ? "تم الدفع بنجاح!" : "Payment Successful!"}</h2>
                                    <p className="text-slate-400">{language === "ar" ? "يمكنك الآن تسليم المنتجات للعميل." : "You can now hand over the items to the customer."}</p>
                                </div>
                                <button
                                    onClick={() => {
                                        setActiveSession(null);
                                        setCart([]);
                                        setCustomerPhone("");
                                        setDiscount(0);
                                    }}
                                    className="btn-financial px-12 py-4 rounded-2xl w-full text-lg font-black"
                                >
                                    {t("backToPOS")}
                                </button>
                            </>
                        )}
                    </div>
                </div>
            </DashboardLayout>
        );
    }

    return (
        <DashboardLayout>
            <div className="space-y-8 pb-10">
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-black text-white tracking-tight">{t("pos")}</h1>
                        <p className="text-sm text-slate-400">{t("posDescription")}</p>
                    </div>
                    {cart.length > 0 && (
                        <button
                            onClick={() => {
                                setCart([]);
                                setDiscount(0);
                            }}
                            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-red-500/10 text-red-400 hover:bg-red-500/20 transition-all text-xs font-bold"
                        >
                            <Trash2 className="h-4 w-4" />
                            {t("clearCart")}
                        </button>
                    )}
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                    {/* Left: Product Selector */}
                    <div className="lg:col-span-12 xl:col-span-8 space-y-6">
                        <div className="glass rounded-2xl p-1 border-white/5 overflow-hidden">
                            <div className="relative">
                                <Search className={`absolute ${language === "ar" ? "right-4" : "left-4"} top-1/2 h-5 w-5 -translate-y-1/2 text-slate-500`} />
                                <input
                                    type="text"
                                    placeholder={t("searchProduct")}
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className={`w-full bg-transparent py-4 ${language === "ar" ? "pr-12 pl-4" : "pl-12 pr-4"} text-sm text-white outline-none placeholder:text-slate-600`}
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                            {loadingProducts ? (
                                [1, 2, 3, 4, 5, 8].map(i => <div key={i} className="aspect-square glass rounded-2xl animate-pulse"></div>)
                            ) : filteredProducts.map((p) => (
                                <button
                                    key={p.id}
                                    onClick={() => addToCart(p)}
                                    className="group relative aspect-square glass rounded-2xl overflow-hidden border-white/5 hover:border-emerald-500/30 transition-all text-start"
                                >
                                    {p.image_url ? (
                                        <img src={p.image_url} alt="" className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                                    ) : (
                                        <div className="absolute inset-0 bg-emerald-500/5 flex items-center justify-center text-emerald-500/10">
                                            <ShoppingCart className="h-10 w-10" />
                                        </div>
                                    )}
                                    <div className="absolute inset-0 bg-gradient-to-t from-[#01160e] via-transparent to-black/10"></div>
                                    <div className="absolute bottom-3 left-3 right-3">
                                        <div className="text-[10px] font-bold text-slate-300 line-clamp-1 mb-0.5 uppercase tracking-tighter">{language === "ar" ? p.name_ar : p.name}</div>
                                        <div className="text-emerald-400 font-black text-sm">{p.price} {t("currency")}</div>
                                    </div>
                                    <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <div className="p-1.5 rounded-lg bg-emerald-500 text-[#01160e] shadow-lg">
                                            <Plus className="h-3 w-3" />
                                        </div>
                                    </div>
                                </button>
                            ))}
                        </div>

                        {/* Recent Activity Section */}
                        <div className="pt-10 space-y-4">
                            <h3 className="text-sm font-black text-white flex items-center gap-2 px-2">
                                <Clock className="h-4 w-4 text-emerald-500" />
                                {language === "ar" ? "آخر العمليات المالية" : "Recent Activity"}
                            </h3>
                            <div className="glass rounded-3xl border-white/5 overflow-hidden">
                                <div className="overflow-x-auto">
                                    <table className="w-full text-left font-bold">
                                        <thead className="bg-white/5 text-[10px] uppercase tracking-widest text-slate-500">
                                            <tr>
                                                <th className="px-6 py-4">{language === "ar" ? "العميل" : "Customer"}</th>
                                                <th className="px-6 py-4">{language === "ar" ? "المبلغ" : "Amount"}</th>
                                                <th className="px-6 py-4">{language === "ar" ? "الحالة" : "Status"}</th>
                                                <th className="px-6 py-4">{language === "ar" ? "الوقت" : "Time"}</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-white/5">
                                            {recentSessions.length === 0 ? (
                                                <tr>
                                                    <td colSpan={4} className="px-6 py-8 text-center text-xs text-slate-600">
                                                        {language === "ar" ? "لا توجد عمليات مسبقة" : "No recent activity"}
                                                    </td>
                                                </tr>
                                            ) : recentSessions.map((session) => (
                                                <tr key={session.sessionId} className="hover:bg-white/5 transition-colors">
                                                    <td className="px-6 py-4 border-none">
                                                        <div className="flex flex-col">
                                                            <span className="text-xs text-slate-200">{session.user?.name || session.customerPhone || "Unknown"}</span>
                                                            <span className="text-[10px] text-slate-500">{session.customerPhone}</span>
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4 text-xs text-emerald-400 border-none">{session.totalAmount} {session.currency}</td>
                                                    <td className="px-6 py-4 border-none">
                                                        <span className={`inline-flex px-2 py-0.5 rounded-full text-[10px] font-black ${
                                                            session.status === 'APPROVED' || session.status === 'COMPLETED' ? 'bg-emerald-500/10 text-emerald-500' :
                                                            session.status === 'REJECTED' ? 'bg-red-500/10 text-red-500' : 'bg-amber-500/10 text-amber-500'
                                                        }`}>
                                                            {session.status}
                                                        </span>
                                                    </td>
                                                    <td className="px-6 py-4 text-[10px] text-slate-500 border-none">
                                                        {new Date(session.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right: Checkout Sidebar */}
                    <div className="lg:col-span-12 xl:col-span-4 sticky top-24">
                        <div className="glass rounded-3xl p-6 border-emerald-900/10 shadow-2xl flex flex-col gap-6">
                            {/* Summary */}
                            <div className="space-y-4">
                                <h3 className="text-sm font-black text-white flex items-center gap-2 pb-4 border-b border-white/5">
                                    <ShoppingCart className="h-4 w-4 text-emerald-500" />
                                    {t("cartTitle")} ({cart.length})
                                </h3>

                                <div className="space-y-4 max-h-[25vh] overflow-y-auto pr-2 custom-scrollbar">
                                    {cart.length === 0 ? (
                                        <div className="py-8 text-center space-y-3">
                                            <div className="inline-flex h-10 w-10 rounded-full bg-white/5 items-center justify-center text-slate-600">
                                                <ShoppingCart className="h-5 w-5" />
                                            </div>
                                            <p className="text-[10px] text-slate-600">{language === "ar" ? "سلة المشتريات فارغة" : "Shopping cart is empty"}</p>
                                        </div>
                                    ) : cart.map((item) => (
                                        <div key={item.id} className="flex gap-3">
                                            <div className="h-10 w-10 rounded-lg bg-white/5 flex-shrink-0 overflow-hidden border border-white/5">
                                                {item.image_url ? (
                                                    <img src={item.image_url} alt="" className="h-full w-full object-cover" />
                                                ) : <ShoppingCart className="h-4 w-4 text-white/10 m-auto mt-3" />}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <div className="text-[10px] font-bold text-slate-200 line-clamp-1">{language === "ar" ? item.name_ar : item.name}</div>
                                                <div className="text-[9px] text-slate-500 mt-0.5">{item.price} {t("currency")} x {item.quantity}</div>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <div className="flex items-center bg-white/5 rounded-lg p-0.5">
                                                    <button onClick={() => updateQuantity(item.id, -1)} className="p-1 hover:text-white text-slate-600"><Minus className="h-3 w-3" /></button>
                                                    <span className="text-[10px] font-bold text-white px-2 min-w-[15px] text-center">{item.quantity}</span>
                                                    <button onClick={() => updateQuantity(item.id, 1)} className="p-1 hover:text-white text-slate-600"><Plus className="h-3 w-3" /></button>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {/* Payment Options */}
                            <div className="space-y-6 pt-6 border-t border-white/5">
                                {/* Totals Section */}
                                <div className="space-y-2 bg-[#01160e]/50 p-4 rounded-2xl border border-white/5">
                                    <div className="flex justify-between text-[10px] font-bold">
                                        <span className="text-slate-500">{language === "ar" ? "المجموع الفرعي" : "Subtotal"}</span>
                                        <span className="text-slate-300">{subtotal.toLocaleString()} {t("currency")}</span>
                                    </div>
                                    
                                    {/* Manual Discount Field */}
                                    <div className="flex items-center gap-2">
                                        <span className="text-[10px] font-bold text-slate-500 flex-1">{language === "ar" ? "الخصم اليدوي" : "Manual Discount"}</span>
                                        <input
                                          type="number"
                                          value={discount || ''}
                                          onChange={(e) => setDiscount(Number(e.target.value))}
                                          placeholder="0.00"
                                          className="w-16 bg-transparent border-b border-red-500/20 text-red-400 text-[10px] text-center outline-none focus:border-red-500 transition-all font-black"
                                        />
                                    </div>

                                    <div className="flex justify-between items-center pt-2 border-t border-white/5">
                                        <span className="text-xs font-black text-white">{t("total")}</span>
                                        <span className="text-xl font-black text-emerald-400">{totalAmount.toLocaleString()} {t("currency")}</span>
                                    </div>
                                    
                                    {/* Monthly Breakdown Point 1 */}
                                    <div className="mt-4 p-3 bg-emerald-500/10 rounded-xl border border-emerald-500/20 flex items-center justify-between">
                                        <div className="flex items-center gap-2">
                                            <Clock className="h-3 w-3 text-emerald-500" />
                                            <span className="text-[10px] font-black text-emerald-500 uppercase">{language === "ar" ? "القسط الشهري" : "Monthly Installment"}</span>
                                        </div>
                                        <span className="text-sm font-black text-white">{installmentAmount.toFixed(2)} {t("currency")}</span>
                                    </div>
                                </div>

                                {/* Customer Info */}
                                <div className="space-y-4">
                                    <div className="space-y-2">
                                        <label className="text-[10px] font-black text-emerald-500 uppercase tracking-widest px-1">{t("customerPhone")}</label>
                                        <div className="relative">
                                            <Phone className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                            <input
                                                type="text"
                                                value={customerPhone}
                                                onChange={e => setCustomerPhone(e.target.value)}
                                                placeholder="07xxxxxxxx"
                                                className={`w-full rounded-2xl border border-white/5 bg-[#011f18] py-3.5 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-xs text-slate-200 outline-none focus:border-emerald-500/50 transition-all`}
                                            />
                                            {/* Found User Indicator Point 4 */}
                                            {foundUser && (
                                                <div className="absolute top-full left-0 right-0 mt-2 px-3 py-2 bg-emerald-500/10 rounded-xl border border-emerald-500/20 flex items-center gap-2 animate-in slide-in-from-top-1 duration-300">
                                                    <CheckCircle2 className="h-3 w-3 text-emerald-500" />
                                                    <span className="text-[10px] font-black text-emerald-400">{foundUser.name}</span>
                                                    {foundUser.isVerified && <span className="bg-emerald-500/20 text-emerald-500 px-1 rounded text-[8px]">{language === 'ar' ? 'موثق' : 'Verified'}</span>}
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                </div>

                                {/* Action */}
                                <button
                                    onClick={handleCreateSession}
                                    disabled={creatingSession || totalAmount === 0 || !customerPhone}
                                    className="btn-financial w-full py-4 rounded-2xl flex items-center justify-center gap-3 text-sm font-black disabled:opacity-30 disabled:grayscale transition-all shadow-xl shadow-emerald-500/10"
                                >
                                    {creatingSession ? <Loader2 className="h-5 w-5 animate-spin" /> : (
                                        <>
                                            {t("createSession")}
                                            {language === "ar" ? <ArrowLeft className="h-5 w-5" /> : <ArrowRight className="h-5 w-5" />}
                                        </>
                                    )}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
}
