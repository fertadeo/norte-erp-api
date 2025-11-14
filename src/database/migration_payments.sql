-- Migration: Extended payments table for incomes and outflows
USE norte_erp_db;

-- Payments: soporta ingresos y egresos con referencias opcionales
-- type: 'income' (cobros) | 'outflow' (pagos)
-- method: 'efectivo' | 'tarjeta' | 'transferencia'
-- payee_type: 'supplier' | 'employee' | 'other' | 'client'
-- related_type: 'order' | 'purchase' | 'expense' | 'payroll' | NULL

CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('income','outflow') NOT NULL,
  method ENUM('efectivo','tarjeta','transferencia') NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'ARS',
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('draft','posted','void') NOT NULL DEFAULT 'posted',

  -- Contraparte (quien recibe o paga)
  payee_type ENUM('supplier','employee','other','client') NULL,
  payee_id INT NULL,
  payee_name VARCHAR(200) NULL,

  -- Relación contable opcional
  related_type ENUM('order','purchase','expense','payroll') NULL,
  related_id INT NULL,

  notes TEXT,
  created_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_payment_date (payment_date),
  INDEX idx_payment_method (method),
  INDEX idx_payment_type (type),
  INDEX idx_related (related_type, related_id),
  INDEX idx_payee (payee_type, payee_id),

  FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
