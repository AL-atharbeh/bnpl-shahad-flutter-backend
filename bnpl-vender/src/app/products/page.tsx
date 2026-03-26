"use client";

import { useEffect, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import {
    Plus,
    Search,
    Edit2,
    Trash2,
    Package
} from "lucide-react";
import { useLanguage } from "@/contexts/LanguageContext";
import { getVendorProducts, deleteProduct } from "@/services/api";
import ProductModal from "@/components/products/ProductModal";
import { Product } from "@/types";

export default function ProductsPage() {
    const { t, language } = useLanguage();
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

    async function fetchProducts() {
        setLoading(true);
        try {
            const userStr = localStorage.getItem("vendor_user");
            if (!userStr) return;
            const user = JSON.parse(userStr);

            const res = await getVendorProducts(user.storeId);
            setProducts(res.data.data || []);
        } catch (error) {
            console.error("Failed to load products", error);
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => {
        fetchProducts();
    }, []);

    const handleEdit = (product: Product) => {
        setSelectedProduct(product);
        setIsModalOpen(true);
    };

    const handleDelete = async (id: number) => {
        if (!confirm(t("deleteConfirm"))) return;

        try {
            await deleteProduct(id);
            fetchProducts();
        } catch (error) {
            console.error("Failed to delete product", error);
            alert("Failed to delete product");
        }
    };

    const handleModalClose = () => {
        setIsModalOpen(false);
        setSelectedProduct(null);
    };

    const handleModalSuccess = () => {
        fetchProducts();
    };

    const filteredProducts = products.filter(p =>
        p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (p.name_ar && p.name_ar.includes(searchTerm))
    );

    return (
        <DashboardLayout>
            <div className="space-y-6">
                {/* Header */}
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div>
                        <h1 className="text-2xl font-bold text-white tracking-tight">{t("productList")}</h1>
                        <p className="text-sm text-slate-400 mt-1">{t("products")} ({products.length})</p>
                    </div>
                    <button
                        onClick={() => setIsModalOpen(true)}
                        className="flex items-center justify-center gap-2 rounded-xl bg-emerald-500 px-4 py-2.5 text-sm font-bold text-[#01160e] hover:bg-emerald-400 transition-colors shadow-lg shadow-emerald-500/10"
                    >
                        <Plus className="h-4 w-4" />
                        {t("addProduct")}
                    </button>
                </div>

                {/* Search and Filters */}
                <div className="flex items-center gap-4 bg-[#011f18] p-2 rounded-2xl border border-emerald-900/30">
                    <div className="relative flex-1">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
                        <input
                            type="text"
                            placeholder={t("searchPlaceholder")}
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full bg-transparent border-none text-sm text-white placeholder-slate-500 focus:ring-0 pl-10"
                        />
                    </div>
                </div>

                {/* Products Grid/Table */}
                <div className="rounded-2xl border border-emerald-900/30 bg-[#011f18] overflow-hidden shadow-xl">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left">
                            <thead className="bg-[#01281e] text-xs uppercase text-slate-400 border-b border-emerald-900/30">
                                <tr>
                                    <th className="px-6 py-4 font-bold">{t("productName")}</th>
                                    <th className="px-6 py-4 font-bold">{t("productPrice")}</th>
                                    <th className="px-6 py-4 font-bold">{language === 'ar' ? 'المبيعات' : 'Sales'}</th>
                                    <th className="px-6 py-4 font-bold">{language === 'ar' ? 'الأرباح' : 'Earnings'}</th>
                                    <th className="px-6 py-4 font-bold">{t("stockStatus")}</th>
                                    <th className="px-6 py-4 font-bold text-right">{t("actions")}</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-emerald-900/10 text-sm">
                                {loading ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-12 text-center text-slate-500 italic">
                                            {t("loading")}
                                        </td>
                                    </tr>
                                ) : filteredProducts.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-12 text-center text-slate-500">
                                            <div className="flex flex-col items-center justify-center gap-2">
                                                <Package className="h-8 w-8 text-slate-600 mb-2" />
                                                <p>{t("noTransactions")?.replace("transactions", "products") || "No products found"}</p>
                                            </div>
                                        </td>
                                    </tr>
                                ) : filteredProducts.map((product) => {
                                    const stockCount = (product as any).stockQuantity || 0;
                                    const stockStatus = stockCount === 0 ? 'out' : stockCount <= 10 ? 'low' : 'in';
                                    
                                    return (
                                    <tr key={product.id} className="hover:bg-emerald-500/5 transition-colors group">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="h-10 w-10 shrink-0 rounded-lg bg-slate-800 border border-slate-700 overflow-hidden">
                                                    {product.image_url ? (
                                                        <img src={product.image_url} alt={product.name} className="h-full w-full object-cover" />
                                                    ) : (
                                                        <div className="h-full w-full flex items-center justify-center text-slate-500 bg-slate-900">
                                                            <Package className="h-5 w-5" />
                                                        </div>
                                                    )}
                                                </div>
                                                <div>
                                                    <div className="font-bold text-white max-w-[200px] truncate">{language === 'ar' ? (product.name_ar || product.name) : product.name}</div>
                                                    <div className="text-xs text-slate-500 mt-0.5 max-w-[200px] truncate">{product.description}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex flex-col">
                                                {product.discountPrice ? (
                                                    <>
                                                        <span className="text-emerald-400 font-bold">{product.discountPrice} <span className="text-[10px] uppercase font-normal">{t("currency")}</span></span>
                                                        <span className="text-xs text-slate-500 line-through decoration-red-500/50">{product.price}</span>
                                                    </>
                                                ) : (
                                                    <span className="text-white font-bold">{product.price} <span className="text-[10px] uppercase font-normal">{t("currency")}</span></span>
                                                )}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-slate-300 font-medium">
                                            {(product as any).salesCount || 0}
                                        </td>
                                        <td className="px-6 py-4 text-emerald-400 font-bold">
                                            {(product as any).totalRevenue || 0} <span className="text-[10px] font-normal text-slate-500">{t("currency")}</span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium ${
                                                stockStatus === 'in' ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" :
                                                stockStatus === 'low' ? "bg-orange-500/10 text-orange-400 border border-orange-500/20" :
                                                "bg-red-500/10 text-red-400 border border-red-500/20"
                                            }`}>
                                                <span className={`h-1.5 w-1.5 rounded-full ${
                                                    stockStatus === 'in' ? "bg-emerald-400" :
                                                    stockStatus === 'low' ? "bg-orange-400" :
                                                    "bg-red-400"
                                                }`} />
                                                {stockStatus === 'in' ? (language === 'ar' ? 'متوفر' : 'In Stock') :
                                                 stockStatus === 'low' ? (language === 'ar' ? 'كمية منخفضة' : 'Low Stock') :
                                                 (language === 'ar' ? 'نفذت الكمية' : 'Out of Stock')}
                                                <span className="ml-1 opacity-60">({stockCount})</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <div className="flex items-center justify-end gap-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                                                <button
                                                    onClick={() => handleEdit(product)}
                                                    className="rounded-lg p-2 text-slate-400 hover:bg-emerald-500/10 hover:text-emerald-400 transition-colors"
                                                    title={t("editProduct")}
                                                >
                                                    <Edit2 className="h-4 w-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(product.id)}
                                                    className="rounded-lg p-2 text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-colors"
                                                    title={t("deleteProduct")}
                                                >
                                                    <Trash2 className="h-4 w-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                )})}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <ProductModal
                isOpen={isModalOpen}
                onClose={handleModalClose}
                onSuccess={handleModalSuccess}
                product={selectedProduct || undefined}
            />
        </DashboardLayout>
    );
}
