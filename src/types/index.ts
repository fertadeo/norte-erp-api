// Common types for the ERP system

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
  timestamp: string;
}

export interface PaginationParams {
  page: number;
  limit: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    currentPage: number;
    totalPages: number;
    totalItems: number;
    itemsPerPage: number;
  };
}

// User and Authentication types
export interface User {
  id: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export enum UserRole {
  ADMIN = 'admin',
  MANAGER = 'manager',
  EMPLOYEE = 'employee',
  VIEWER = 'viewer'
}

// Dashboard types
export interface DashboardStats {
  dailySales: number;
  activeOrders: number;
  activeClients: number;
  criticalProducts: number;
  stockMinority: number;
  stockMajority: number;
  customOrders: number;
}

// Stock types
export interface Product {
  id: number;
  code: string;
  name: string;
  description?: string;
  category: string;
  price: number;
  stock: number;
  minStock: number;
  maxStock: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Client types
export interface Client {
  id: number;
  code: string;
  name: string;
  email?: string;
  phone?: string;
  address?: string;
  city?: string;
  country?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Order types
export interface Order {
  id: number;
  orderNumber: string;
  clientId: number;
  status: OrderStatus;
  totalAmount: number;
  orderDate: Date;
  deliveryDate?: Date;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export enum OrderStatus {
  PENDING = 'pending',
  IN_PROCESS = 'in_process',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export interface OrderItem {
  id: number;
  orderId: number;
  productId: number;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

// Production types
export interface ProductionOrder {
  id: number;
  orderNumber: string;
  productId: number;
  quantity: number;
  status: ProductionStatus;
  startDate?: Date;
  endDate?: Date;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export enum ProductionStatus {
  PENDING = 'pending',
  IN_PROCESS = 'in_process',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}
