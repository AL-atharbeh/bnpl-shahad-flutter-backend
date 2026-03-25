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
import { getVendorProducts, createBnplSession, getBnplSession } from "@/services/api";
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
    const [installments, setInstallments] = useState(4);
    const [paymentMethod, setPaymentMethod] = useState<"phone" | "qr">("phone");

    // Session Flow State
    const [creatingSession, setCreatingSession] = useState(false);
    const [activeSession, setActiveSession] = useState<any>(null);
    const [sessionStatus, setSessionStatus] = useState<string>("PENDING");

    const statusInterval = useRef<NodeJS.Timeout | null>(null);

    useEffect(() => {
        loadProducts();
    }, []);

    useEffect(() => {
        if (activeSession && (sessionStatus === "PENDING" || sessionStatus === "PAYMENT_PENDING")) {
            statusInterval.current = setInterval(pollSessionStatus, 3000);
        } else {
            if (statusInterval.current) clearInterval(statusInterval.current);
        }
        return () => {
            if (statusInterval.current) clearInterval(statusInterval.current);
        };
    }, [activeSession, sessionStatus]);

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

    const totalAmount = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    const handleCreateSession = async () => {
        if (totalAmount <= 0) return;
        if (paymentMethod === "phone" && !customerPhone) return;

        setCreatingSession(true);
        const userStr = localStorage.getItem("vendor_user");
        const user = JSON.parse(userStr!);

        try {
            const payload = {
                store_id: Number(user.storeId),
                store_order_id: `POS_${Date.now()}`,
                total_amount: Number(totalAmount),
                customer_phone: customerPhone || undefined,
                installments_count: Number(installments),
                items: cart.map(item => ({
                    name: language === "ar" ? item.name_ar : item.name,
                    quantity: Number(item.quantity),
                    price: Number(item.price)
                }))
            };

            const res = await createBnplSession(payload);
            setActiveSession(res.data);
            setSessionStatus("PENDING");
        } catch (err) {
            console.error("Failed to create session", err);
            alert("Failed to initiate payment. Please try again.");
        } finally {
            setCreatingSession(false);
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
                        {sessionStatus === "PENDING" || sessionStatus === "PAYMENT_PENDING" ? (
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
            <div className="space-y-8 pb-20">
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-bold text-white tracking-tight">{t("pos")}</h1>
                        <p className="text-sm text-slate-400">{t("posDescription")}</p>
                    </div>
                    {cart.length > 0 && (
                        <button
                            onClick={() => setCart([])}
                            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-red-500/10 text-red-400 hover:bg-red-500/20 transition-all text-sm font-bold"
                        >
                            <Trash2 className="h-4 w-4" />
                            {t("clearCart")}
                        </button>
                    )}
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                    {/* Left: Product Selector */}
                    <div className="lg:col-span-12 xl:col-span-8 space-y-6">
                        <div className="glass rounded-2xl p-2 border-emerald-900/10 overflow-hidden">
                            <div className="relative">
                                <Search className={`absolute ${language === "ar" ? "right-4" : "left-4"} top-1/2 h-5 w-5 -translate-y-1/2 text-slate-500`} />
                                <input
                                    type="text"
                                    placeholder={t("searchProduct")}
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className={`w-full bg-transparent py-4 ${language === "ar" ? "pr-12 pl-4" : "pl-12 pr-4"} text-lg text-white outline-none placeholder:text-slate-600`}
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                            {loadingProducts ? (
                                [1, 2, 3, 4].map(i => <div key={i} className="aspect-square glass rounded-2xl animate-pulse"></div>)
                            ) : filteredProducts.map((p) => (
                                <button
                                    key={p.id}
                                    onClick={() => addToCart(p)}
                                    className="group relative aspect-square glass rounded-2xl overflow-hidden border-emerald-900/10 hover:border-emerald-500/50 transition-all text-start"
                                >
                                    {p.image_url ? (
                                        <img src={p.image_url} alt="" className="absolute inset-0 w-full h-full object-cover group-hover:scale-110 transition-transform" />
                                    ) : (
                                        <div className="absolute inset-0 bg-emerald-500/5 flex items-center justify-center text-emerald-500/20">
                                            <ShoppingCart className="h-10 w-10" />
                                        </div>
                                    )}
                                    <div className="absolute inset-0 bg-gradient-to-t from-[#01160e] via-transparent to-black/20"></div>
                                    <div className="absolute bottom-3 left-3 right-3">
                                        <div className="text-xs font-bold text-white line-clamp-2 mb-1">{language === "ar" ? p.name_ar : p.name}</div>
                                        <div className="text-emerald-400 font-black">{p.price} {t("currency")}</div>
                                    </div>
                                    <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <div className="p-2 rounded-lg bg-emerald-500 text-[#01160e] shadow-lg">
                                            <Plus className="h-4 w-4" />
                                        </div>
                                    </div>
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Right: Checkout Sidebar */}
                    <div className="lg:col-span-12 xl:col-span-4 sticky top-24">
                        <div className="glass rounded-3xl p-6 border-emerald-900/20 shadow-2xl flex flex-col gap-6">
                            {/* Summary */}
                            <div className="space-y-4">
                                <h3 className="text-lg font-black text-white flex items-center gap-2 pb-4 border-b border-emerald-900/30">
                                    <ShoppingCart className="h-5 w-5 text-emerald-500" />
                                    {t("cartTitle")} ({cart.length})
                                </h3>

                                <div className="space-y-4 max-h-[30vh] overflow-y-auto pr-2 custom-scrollbar">
                                    {cart.length === 0 ? (
                                        <div className="py-12 text-center space-y-3">
                                            <div className="inline-flex h-12 w-12 rounded-full bg-white/5 items-center justify-center text-slate-500">
                                                <ShoppingCart className="h-6 w-6" />
                                            </div>
                                            <p className="text-xs text-slate-500">{language === "ar" ? "سلة المشتريات فارغة" : "Shopping cart is empty"}</p>
                                        </div>
                                    ) : cart.map((item) => (
                                        <div key={item.id} className="flex gap-3">
                                            <div className="h-12 w-12 rounded-lg bg-white/5 flex-shrink-0 overflow-hidden border border-white/5">
                                                {item.image_url ? (
                                                    <img src={item.image_url} alt="" className="h-full w-full object-cover" />
                                                ) : <ShoppingCart className="h-4 w-4 text-white/10 m-auto mt-4" />}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <div className="text-xs font-bold text-slate-200 line-clamp-1">{language === "ar" ? item.name_ar : item.name}</div>
                                                <div className="text-[10px] text-slate-500 mt-0.5">{item.price} {t("currency")} x {item.quantity}</div>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <div className="flex items-center bg-white/5 rounded-lg p-0.5">
                                                    <button onClick={() => updateQuantity(item.id, -1)} className="p-1 hover:text-white text-slate-500"><Minus className="h-3 w-3" /></button>
                                                    <span className="text-[11px] font-bold text-white px-2 min-w-[20px] text-center">{item.quantity}</span>
                                                    <button onClick={() => updateQuantity(item.id, 1)} className="p-1 hover:text-white text-slate-500"><Plus className="h-3 w-3" /></button>
                                                </div>
                                                <button onClick={() => removeFromCart(item.id)} className="p-1.5 text-red-500/50 hover:text-red-500"><X className="h-4 w-4" /></button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {/* Payment Options */}
                            <div className="space-y-6 pt-6 border-t border-emerald-900/30">
                                {/* Total Bar */}
                                <div className="flex items-center justify-between p-4 rounded-2xl bg-emerald-500/5 border border-emerald-500/10">
                                    <span className="text-slate-400 text-sm font-bold">{t("total")}</span>
                                    <span className="text-2xl font-black text-emerald-400">{totalAmount.toLocaleString()} {t("currency")}</span>
                                </div>

                                {/* Flow Selector */}
                                <div className="space-y-3">
                                    <label className="text-[10px] font-black text-emerald-500 uppercase tracking-widest">{t("paymentMethod")}</label>
                                    <div className="grid grid-cols-2 gap-2">
                                        <button
                                            onClick={() => setPaymentMethod("phone")}
                                            className={`flex flex-col items-center gap-2 p-3 rounded-2xl border transition-all ${paymentMethod === "phone" ? "bg-emerald-500/10 border-emerald-500 text-emerald-400" : "bg-white/5 border-white/5 text-slate-500"}`}
                                        >
                                            <Phone className="h-5 w-5" />
                                            <span className="text-[10px] font-bold text-center">{t("sendToPhone")}</span>
                                        </button>
                                        <button
                                            onClick={() => setPaymentMethod("qr")}
                                            className={`flex flex-col items-center gap-2 p-3 rounded-2xl border transition-all ${paymentMethod === "qr" ? "bg-emerald-500/10 border-emerald-500 text-emerald-400" : "bg-white/5 border-white/5 text-slate-500"}`}
                                        >
                                            <QrCode className="h-5 w-5" />
                                            <span className="text-[10px] font-bold text-center">{t("scanQR")}</span>
                                        </button>
                                    </div>
                                </div>

                                {/* Method Specifics */}
                                <div className="space-y-4">
                                    {paymentMethod === "phone" && (
                                        <div className="space-y-2">
                                            <label className="text-xs font-bold text-slate-500">{t("customerPhone")}</label>
                                            <div className="relative">
                                                <Phone className={`absolute ${language === "ar" ? "right-3" : "left-3"} top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600`} />
                                                <input
                                                    type="text"
                                                    value={customerPhone}
                                                    onChange={e => setCustomerPhone(e.target.value)}
                                                    placeholder="07xxxxxxxx"
                                                    className={`w-full rounded-xl border border-emerald-900/30 bg-[#011f18] py-3 ${language === "ar" ? "pr-10 pl-4" : "pl-10 pr-4"} text-sm text-slate-200 outline-none focus:border-emerald-500/50`}
                                                />
                                            </div>
                                        </div>
                                    )}

                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-slate-500">{t("installmentsCount")}</label>
                                        <div className="flex gap-2">
                                            {[2, 3, 4].map(n => (
                                                <button
                                                    key={n}
                                                    onClick={() => setInstallments(n)}
                                                    className={`flex-1 py-2 rounded-xl border text-sm font-bold transition-all ${installments === n ? "bg-emerald-500 text-[#01160e] border-emerald-500 shadow-lg shadow-emerald-500/20" : "bg-white/5 border-white/5 text-slate-500 hover:text-slate-200"}`}
                                                >
                                                    {n}
                                                </button>
                                            ))}
                                        </div>
                                    </div>
                                </div>

                                {/* Action */}
                                <button
                                    onClick={handleCreateSession}
                                    disabled={creatingSession || totalAmount === 0 || (paymentMethod === "phone" && !customerPhone)}
                                    className="btn-financial w-full py-4 rounded-2xl flex items-center justify-center gap-3 text-lg font-black disabled:opacity-30 disabled:grayscale transition-all"
                                >
                                    {creatingSession ? <Loader2 className="h-6 w-6 animate-spin" /> : (
                                        <>
                                            {t("createSession")}
                                            {language === "ar" ? <ArrowLeft className="h-6 w-6" /> : <ArrowRight className="h-6 w-6" />}
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
