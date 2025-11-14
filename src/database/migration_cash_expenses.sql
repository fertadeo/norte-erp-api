-- Migration: Cash module - payments and operational expenses
USE norte_erp_db;

-- Payments table (incomes breakdown by method)
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NULL,
  method ENUM('efectivo','tarjeta','transferencia') NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  created_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_payment_date (payment_date),
  INDEX idx_payment_method (method),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Operational expenses
CREATE TABLE IF NOT EXISTS expenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  concept VARCHAR(200) NOT NULL,
  category ENUM('servicios','sueldos','impuestos','logistica','insumos','otros') DEFAULT 'otros',
  method ENUM('efectivo','tarjeta','transferencia') DEFAULT 'efectivo',
  amount DECIMAL(12,2) NOT NULL,
  expense_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('registrado','anulado') DEFAULT 'registrado',
  notes TEXT,
  created_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_expense_date (expense_date),
  INDEX idx_expense_category (category),
  FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
