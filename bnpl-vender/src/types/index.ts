export interface Product {
    id: number;
    store_id: number;
    name: string;
    name_ar: string;
    description: string;
    description_ar: string;
    price: number;
    currency: string;
    category: string;
    category_id: number;
    image_url: string;
    product_url?: string;
    images?: string[];
    in_stock: boolean;
    stockQuantity?: number;
    discountPrice?: number;
    salesCount?: number;
    totalRevenue?: number;
    rating?: number;
    reviews_count?: number;
    is_active: boolean;
    created_at?: string;
    updated_at?: string;
}
