export interface Product {
  id: number;
  code: string;
  name: string;
  description?: string;
  category_id?: number;
  price: number;
  stock: number;
  min_stock: number;
  max_stock: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ProductWithCategory extends Product {
  category_name?: string;
}

export interface CreateProductData {
  code: string;
  name: string;
  description?: string;
  category_id?: number;
  price: number;
  stock?: number;
  min_stock?: number;
  max_stock?: number;
}

export interface UpdateProductData extends Partial<CreateProductData> {
  is_active?: boolean;
}
