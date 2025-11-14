-- =====================================================
-- MIGRACIÓN: MÓDULO DE PROVEEDORES EXTENDIDO
-- Norte ERP - Extensión del módulo de proveedores
-- Compatible con MySQL 5.7+
-- =====================================================
-- Esta migración extiende el módulo de proveedores con:
-- - Tipos de proveedores (productivo, no_productivo, otro_pasivo)
-- - Compromiso vs Deuda en OC
-- - Facturas de proveedores
-- - Remitos de entrega
-- - Cuenta corriente de proveedores
-- =====================================================

USE norte_erp_db;

-- =====================================================
-- 1. ACTUALIZAR TABLA SUPPLIERS
-- =====================================================

-- Agregar campos para tipo de proveedor y cuenta corriente
-- Nota: Si las columnas ya existen, se mostrará un error que se puede ignorar

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'supplier_type');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN supplier_type ENUM(''productivo'', ''no_productivo'', ''otro_pasivo'') DEFAULT ''no_productivo'' AFTER code',
    'SELECT "Column supplier_type already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'has_account');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN has_account BOOLEAN DEFAULT TRUE AFTER country',
    'SELECT "Column has_account already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'payment_terms');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN payment_terms INT DEFAULT 30 COMMENT ''Términos de pago en días'' AFTER has_account',
    'SELECT "Column payment_terms already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Crear índice para supplier_type (si no existe)
SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND INDEX_NAME = 'idx_suppliers_type');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_suppliers_type ON suppliers(supplier_type)',
    'SELECT "Index idx_suppliers_type already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 2. ACTUALIZAR TABLA PURCHASES (OC)
-- =====================================================

-- Agregar campos para compromiso vs deuda
-- Nota: Si las columnas ya existen, se mostrará un error que se puede ignorar

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND COLUMN_NAME = 'debt_type');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchases ADD COLUMN debt_type ENUM(''compromiso'', ''deuda_directa'') DEFAULT ''compromiso'' AFTER status',
    'SELECT "Column debt_type already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND COLUMN_NAME = 'commitment_amount');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchases ADD COLUMN commitment_amount DECIMAL(12,2) DEFAULT 0.00 COMMENT ''Monto en compromiso'' AFTER total_amount',
    'SELECT "Column commitment_amount already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND COLUMN_NAME = 'debt_amount');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchases ADD COLUMN debt_amount DECIMAL(12,2) DEFAULT 0.00 COMMENT ''Monto en deuda real'' AFTER commitment_amount',
    'SELECT "Column debt_amount already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND COLUMN_NAME = 'allows_partial_delivery');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchases ADD COLUMN allows_partial_delivery BOOLEAN DEFAULT TRUE AFTER debt_amount',
    'SELECT "Column allows_partial_delivery already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND COLUMN_NAME = 'confirmed_at');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchases ADD COLUMN confirmed_at TIMESTAMP NULL COMMENT ''Fecha de confirmación de la OC'' AFTER purchase_date',
    'SELECT "Column confirmed_at already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Actualizar total_amount para permitir valores más grandes
ALTER TABLE purchases MODIFY COLUMN total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00;

-- Crear índices (si no existen)
SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND INDEX_NAME = 'idx_purchases_debt_type');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_purchases_debt_type ON purchases(debt_type)',
    'SELECT "Index idx_purchases_debt_type already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchases'
               AND INDEX_NAME = 'idx_purchases_confirmed');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_purchases_confirmed ON purchases(confirmed_at)',
    'SELECT "Index idx_purchases_confirmed already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 3. ACTUALIZAR TABLA PURCHASE_ITEMS
-- =====================================================

-- Agregar campos para códigos de materiales y control de recepción
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchase_items'
               AND COLUMN_NAME = 'material_code');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchase_items ADD COLUMN material_code VARCHAR(50) NULL COMMENT ''Código del material (clave para costos)'' AFTER product_id',
    'SELECT "Column material_code already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchase_items'
               AND COLUMN_NAME = 'received_quantity');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchase_items ADD COLUMN received_quantity INT DEFAULT 0 COMMENT ''Cantidad recibida'' AFTER quantity',
    'SELECT "Column received_quantity already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchase_items'
               AND COLUMN_NAME = 'unit_cost');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE purchase_items ADD COLUMN unit_cost DECIMAL(10,2) NULL COMMENT ''Costo unitario para producción'' AFTER unit_price',
    'SELECT "Column unit_cost already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Actualizar total_price para permitir valores más grandes
ALTER TABLE purchase_items MODIFY COLUMN total_price DECIMAL(12,2) NOT NULL;

-- Crear índice para material_code
SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'purchase_items'
               AND INDEX_NAME = 'idx_purchase_items_material');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_purchase_items_material ON purchase_items(material_code)',
    'SELECT "Index idx_purchase_items_material already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 4. CREAR TABLA SUPPLIER_INVOICES (Facturas)
-- =====================================================

CREATE TABLE IF NOT EXISTS supplier_invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Número de factura del proveedor',
    supplier_id INT NOT NULL,
    purchase_id INT NULL COMMENT 'OC relacionada (opcional al inicio)',
    invoice_date DATE NOT NULL,
    due_date DATE NULL COMMENT 'Fecha de vencimiento',
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    
    -- Estados
    status ENUM('draft', 'received', 'partial_paid', 'paid', 'cancelled') DEFAULT 'received',
    payment_status ENUM('pending', 'partial', 'paid', 'overdue') DEFAULT 'pending',
    
    -- Vinculaciones
    delivery_note_id INT NULL COMMENT 'Remito relacionado',
    
    -- Control
    notes TEXT,
    file_url VARCHAR(255) COMMENT 'URL del PDF de la factura',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (purchase_id) REFERENCES purchases(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_invoices_supplier (supplier_id),
    INDEX idx_invoices_purchase (purchase_id),
    INDEX idx_invoices_number (invoice_number),
    INDEX idx_invoices_date (invoice_date),
    INDEX idx_invoices_status (status),
    INDEX idx_invoices_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 5. CREAR TABLA SUPPLIER_INVOICE_ITEMS
-- =====================================================

CREATE TABLE IF NOT EXISTS supplier_invoice_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    material_code VARCHAR(50) NOT NULL COMMENT 'CÓDIGO DEL MATERIAL (CLAVE)',
    product_id INT NULL COMMENT 'Opcional, vinculación con producto',
    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    
    -- Para cálculo de costos
    unit_cost DECIMAL(10,2) COMMENT 'Costo unitario para producción',
    affects_production_cost BOOLEAN DEFAULT TRUE COMMENT 'Si afecta costo de producción',
    
    -- Vinculación con OC
    purchase_item_id INT NULL COMMENT 'Item de OC relacionado',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (invoice_id) REFERENCES supplier_invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (purchase_item_id) REFERENCES purchase_items(id),
    
    INDEX idx_invoice_items_invoice (invoice_id),
    INDEX idx_invoice_items_material (material_code),
    INDEX idx_invoice_items_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 6. CREAR TABLA SUPPLIER_DELIVERY_NOTES (Remitos)
-- =====================================================

CREATE TABLE IF NOT EXISTS supplier_delivery_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    delivery_note_number VARCHAR(50) UNIQUE NOT NULL,
    supplier_id INT NOT NULL,
    purchase_id INT NOT NULL COMMENT 'OC relacionada',
    invoice_id INT NULL COMMENT 'Factura relacionada (puede ser NULL si se recibe antes)',
    
    -- Fechas
    delivery_date DATE NOT NULL,
    received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Estados
    status ENUM('pending', 'partial', 'complete', 'cancelled') DEFAULT 'pending',
    matches_invoice BOOLEAN DEFAULT FALSE COMMENT 'Si coincide con factura',
    
    -- Control
    notes TEXT,
    received_by INT COMMENT 'Usuario que recibió',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (purchase_id) REFERENCES purchases(id),
    FOREIGN KEY (invoice_id) REFERENCES supplier_invoices(id),
    FOREIGN KEY (received_by) REFERENCES users(id),
    
    INDEX idx_delivery_notes_supplier (supplier_id),
    INDEX idx_delivery_notes_purchase (purchase_id),
    INDEX idx_delivery_notes_invoice (invoice_id),
    INDEX idx_delivery_notes_number (delivery_note_number),
    INDEX idx_delivery_notes_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 7. CREAR TABLA SUPPLIER_DELIVERY_NOTE_ITEMS
-- =====================================================

CREATE TABLE IF NOT EXISTS supplier_delivery_note_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    delivery_note_id INT NOT NULL,
    material_code VARCHAR(50) NOT NULL,
    product_id INT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    
    -- Vinculaciones
    purchase_item_id INT NULL COMMENT 'Item de OC',
    invoice_item_id INT NULL COMMENT 'Item de factura',
    
    -- Control de calidad
    quality_check BOOLEAN DEFAULT FALSE,
    quality_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (delivery_note_id) REFERENCES supplier_delivery_notes(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (purchase_item_id) REFERENCES purchase_items(id),
    FOREIGN KEY (invoice_item_id) REFERENCES supplier_invoice_items(id),
    
    INDEX idx_delivery_note_items_delivery (delivery_note_id),
    INDEX idx_delivery_note_items_material (material_code),
    INDEX idx_delivery_note_items_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 8. CREAR TABLA SUPPLIER_ACCOUNTS (Cuenta Corriente)
-- =====================================================

CREATE TABLE IF NOT EXISTS supplier_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT UNIQUE NOT NULL,
    
    -- Balances
    commitment_balance DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Compromisos',
    debt_balance DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Deuda real',
    total_balance DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Total (commitment + debt)',
    
    -- Límites
    credit_limit DECIMAL(12,2) DEFAULT 0.00,
    
    -- Estado
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    
    INDEX idx_supplier_accounts_supplier (supplier_id),
    INDEX idx_supplier_accounts_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 9. CREAR TABLA SUPPLIER_ACCOUNT_MOVEMENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS supplier_account_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_account_id INT NOT NULL,
    
    -- Tipo de movimiento
    movement_type ENUM('commitment', 'debt', 'payment', 'adjustment') NOT NULL,
    type ENUM('debit', 'credit') NOT NULL COMMENT 'Débito = aumenta deuda, Crédito = pago',
    
    -- Montos
    amount DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL COMMENT 'Balance después del movimiento',
    
    -- Referencias
    reference_type ENUM('purchase', 'invoice', 'payment', 'delivery_note', 'adjustment') NULL,
    reference_id INT NULL,
    
    -- Control
    description VARCHAR(255),
    due_date DATE NULL COMMENT 'Fecha de vencimiento (para deudas)',
    payment_date DATE NULL COMMENT 'Fecha de pago (si aplica)',
    status ENUM('pending', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_account_id) REFERENCES supplier_accounts(id),
    
    INDEX idx_movements_account (supplier_account_id),
    INDEX idx_movements_type (movement_type),
    INDEX idx_movements_reference (reference_type, reference_id),
    INDEX idx_movements_status (status),
    INDEX idx_movements_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 10. ACTUALIZAR TABLA PAYMENTS
-- =====================================================

-- Agregar campos para vinculación directa con facturas
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'payments'
               AND COLUMN_NAME = 'invoice_id');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE payments ADD COLUMN invoice_id INT NULL COMMENT ''Vinculación directa a factura de proveedor'' AFTER related_id',
    'SELECT "Column invoice_id already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'payments'
               AND COLUMN_NAME = 'is_partial_payment');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE payments ADD COLUMN is_partial_payment BOOLEAN DEFAULT FALSE AFTER invoice_id',
    'SELECT "Column is_partial_payment already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'payments'
               AND COLUMN_NAME = 'remaining_amount');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE payments ADD COLUMN remaining_amount DECIMAL(12,2) NULL COMMENT ''Monto restante de la factura'' AFTER is_partial_payment',
    'SELECT "Column remaining_amount already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Crear índice para invoice_id
SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'payments'
               AND INDEX_NAME = 'idx_payments_invoice');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_payments_invoice ON payments(invoice_id)',
    'SELECT "Index idx_payments_invoice already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar foreign key si la tabla supplier_invoices existe
-- (se agregará después de crear la tabla)
-- ALTER TABLE payments ADD FOREIGN KEY (invoice_id) REFERENCES supplier_invoices(id);

-- =====================================================
-- 11. CREAR CUENTAS CORRIENTES PARA PROVEEDORES EXISTENTES
-- =====================================================

-- Insertar cuenta corriente para todos los proveedores activos que no tengan una
INSERT INTO supplier_accounts (supplier_id, commitment_balance, debt_balance, total_balance, credit_limit, is_active)
SELECT 
    s.id,
    0.00,
    0.00,
    0.00,
    100000.00, -- Límite por defecto
    s.is_active
FROM suppliers s
LEFT JOIN supplier_accounts sa ON s.id = sa.supplier_id
WHERE sa.id IS NULL;

-- =====================================================
-- 12. ACTUALIZAR FOREIGN KEY DE PAYMENTS
-- =====================================================

-- Agregar foreign key para invoice_id después de crear la tabla supplier_invoices
-- Nota: Si la tabla payments ya existe y tiene datos, verificar antes de agregar la FK
SET @exist := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
               WHERE CONSTRAINT_SCHEMA = 'norte_erp_db' 
               AND CONSTRAINT_NAME = 'payments_ibfk_invoice'
               AND TABLE_NAME = 'payments');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE payments ADD CONSTRAINT payments_ibfk_invoice FOREIGN KEY (invoice_id) REFERENCES supplier_invoices(id) ON DELETE SET NULL',
    'SELECT "Foreign key payments_ibfk_invoice already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 13. ACTUALIZAR FOREIGN KEY DE SUPPLIER_INVOICES
-- =====================================================

-- Agregar foreign key para delivery_note_id después de crear la tabla supplier_delivery_notes
SET @exist := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
               WHERE CONSTRAINT_SCHEMA = 'norte_erp_db' 
               AND CONSTRAINT_NAME = 'supplier_invoices_ibfk_delivery'
               AND TABLE_NAME = 'supplier_invoices');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE supplier_invoices ADD CONSTRAINT supplier_invoices_ibfk_delivery FOREIGN KEY (delivery_note_id) REFERENCES supplier_delivery_notes(id) ON DELETE SET NULL',
    'SELECT "Foreign key supplier_invoices_ibfk_delivery already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 14. MODIFICAR SUPPLIER_INVOICE_ITEMS PARA PERMITIR MATERIAL_CODE NULL
-- =====================================================

-- Hacer material_code opcional (NULL permitido) para proveedores no productivos
-- Si material_code es NULL, no afecta costo de producción
ALTER TABLE supplier_invoice_items MODIFY COLUMN material_code VARCHAR(50) NULL;

-- =====================================================
-- 15. CREAR TABLA ACCRUED_EXPENSES (Egresos sin factura / Devengamientos)
-- =====================================================

CREATE TABLE IF NOT EXISTS accrued_expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Número de egreso devengado',
    supplier_id INT NULL COMMENT 'Proveedor relacionado (opcional)',
    expense_type ENUM('compromise', 'accrual') NOT NULL COMMENT 'compromise = compromiso, accrual = devengado',
    
    -- Información del egreso
    concept VARCHAR(255) NOT NULL COMMENT 'Concepto del egreso',
    category ENUM('seguro', 'impuesto', 'alquiler', 'servicio', 'otro') DEFAULT 'otro',
    amount DECIMAL(12,2) NOT NULL,
    
    -- Fechas
    accrual_date DATE NOT NULL COMMENT 'Fecha de devengamiento',
    due_date DATE NULL COMMENT 'Fecha de vencimiento',
    payment_date DATE NULL COMMENT 'Fecha de pago efectivo',
    
    -- Estados
    status ENUM('pending', 'paid', 'cancelled') DEFAULT 'pending',
    has_invoice BOOLEAN DEFAULT FALSE COMMENT 'Si tiene factura asociada',
    invoice_id INT NULL COMMENT 'Factura asociada (si existe)',
    
    -- Control
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL,
    FOREIGN KEY (invoice_id) REFERENCES supplier_invoices(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_accrued_expenses_supplier (supplier_id),
    INDEX idx_accrued_expenses_type (expense_type),
    INDEX idx_accrued_expenses_category (category),
    INDEX idx_accrued_expenses_status (status),
    INDEX idx_accrued_expenses_date (accrual_date),
    INDEX idx_accrued_expenses_due (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 16. CREAR TABLA ACCRUED_LIABILITIES (Pasivos Devengados)
-- =====================================================

CREATE TABLE IF NOT EXISTS accrued_liabilities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    liability_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Número de pasivo',
    liability_type ENUM('impuesto', 'alquiler', 'seguro', 'servicio', 'prestamo', 'otro') NOT NULL,
    
    -- Información del pasivo
    description VARCHAR(255) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    
    -- Fechas
    accrual_date DATE NOT NULL COMMENT 'Fecha de devengamiento',
    due_date DATE NOT NULL COMMENT 'Fecha de vencimiento',
    payment_date DATE NULL COMMENT 'Fecha de pago',
    
    -- Estados
    status ENUM('pending', 'partial_paid', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    paid_amount DECIMAL(12,2) DEFAULT 0.00,
    remaining_amount DECIMAL(12,2) NOT NULL COMMENT 'Monto pendiente',
    
    -- Vinculación con tesorería
    treasury_account_id INT NULL COMMENT 'Cuenta de tesorería relacionada',
    payment_id INT NULL COMMENT 'Pago relacionado (si se pagó desde tesorería)',
    
    -- Control
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_accrued_liabilities_type (liability_type),
    INDEX idx_accrued_liabilities_status (status),
    INDEX idx_accrued_liabilities_accrual_date (accrual_date),
    INDEX idx_accrued_liabilities_due_date (due_date),
    INDEX idx_accrued_liabilities_payment (payment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 17. CREAR TABLA ACCRUED_LIABILITY_PAYMENTS (Vinculación Pasivos-Pagos)
-- =====================================================

CREATE TABLE IF NOT EXISTS accrued_liability_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    liability_id INT NOT NULL,
    payment_id INT NOT NULL COMMENT 'Pago desde tesorería',
    amount DECIMAL(12,2) NOT NULL COMMENT 'Monto del pago aplicado',
    payment_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (liability_id) REFERENCES accrued_liabilities(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments(id),
    
    INDEX idx_liability_payments_liability (liability_id),
    INDEX idx_liability_payments_payment (payment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 18. AGREGAR CAMPO PARA VINCULAR ACCRUED_EXPENSES CON PAYMENTS
-- =====================================================

-- Agregar campo en payments para vincular con accrued_expenses
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'payments'
               AND COLUMN_NAME = 'accrued_expense_id');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE payments ADD COLUMN accrued_expense_id INT NULL COMMENT ''Egreso devengado relacionado'' AFTER invoice_id',
    'SELECT "Column accrued_expense_id already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar foreign key
SET @exist := (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
               WHERE CONSTRAINT_SCHEMA = 'norte_erp_db' 
               AND CONSTRAINT_NAME = 'payments_ibfk_accrued_expense'
               AND TABLE_NAME = 'payments');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE payments ADD CONSTRAINT payments_ibfk_accrued_expense FOREIGN KEY (accrued_expense_id) REFERENCES accrued_expenses(id) ON DELETE SET NULL',
    'SELECT "Foreign key payments_ibfk_accrued_expense already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 19. ACTUALIZAR RELATED_TYPE EN PAYMENTS
-- =====================================================

-- Agregar 'accrued_expense' y 'accrued_liability' a related_type
-- Nota: Esto requiere recrear la columna ENUM, lo cual es complejo
-- Se puede manejar en la aplicación o crear una migración separada si es necesario
-- Por ahora, se puede usar 'expense' para accrued_expenses y 'other' para accrued_liabilities

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Verificar que las tablas se crearon correctamente
SELECT 'Tabla supplier_invoices' as tabla, COUNT(*) as registros FROM supplier_invoices
UNION ALL
SELECT 'Tabla supplier_invoice_items', COUNT(*) FROM supplier_invoice_items
UNION ALL
SELECT 'Tabla supplier_delivery_notes', COUNT(*) FROM supplier_delivery_notes
UNION ALL
SELECT 'Tabla supplier_delivery_note_items', COUNT(*) FROM supplier_delivery_note_items
UNION ALL
SELECT 'Tabla supplier_accounts', COUNT(*) FROM supplier_accounts
UNION ALL
SELECT 'Tabla supplier_account_movements', COUNT(*) FROM supplier_account_movements
UNION ALL
SELECT 'Tabla accrued_expenses', COUNT(*) FROM accrued_expenses
UNION ALL
SELECT 'Tabla accrued_liabilities', COUNT(*) FROM accrued_liabilities
UNION ALL
SELECT 'Tabla accrued_liability_payments', COUNT(*) FROM accrued_liability_payments;

-- Verificar campos agregados
SELECT 
    'suppliers' as tabla,
    COUNT(*) as campos_agregados
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'norte_erp_db' 
AND TABLE_NAME = 'suppliers'
AND COLUMN_NAME IN ('supplier_type', 'has_account', 'payment_terms')
UNION ALL
SELECT 
    'purchases',
    COUNT(*)
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'norte_erp_db' 
AND TABLE_NAME = 'purchases'
AND COLUMN_NAME IN ('debt_type', 'commitment_amount', 'debt_amount', 'allows_partial_delivery', 'confirmed_at')
UNION ALL
SELECT 
    'purchase_items',
    COUNT(*)
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'norte_erp_db' 
AND TABLE_NAME = 'purchase_items'
AND COLUMN_NAME IN ('material_code', 'received_quantity', 'unit_cost');

-- =====================================================
-- MIGRACIÓN COMPLETADA
-- =====================================================

SELECT 'Migración de proveedores extendido completada exitosamente' as resultado;

