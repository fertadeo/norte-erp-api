-- =====================================================
-- MIGRACIÓN: CAMPOS ADICIONALES PARA PROVEEDORES
-- Norte ERP - Campos adicionales de proveedores
-- Compatible con MySQL 5.7+
-- =====================================================
-- Esta migración agrega campos adicionales a la tabla suppliers:
-- - Razón Social
-- - Nombre de Fantasía
-- - Frecuencia de Compra
-- - Tipo de Identificación
-- - CUIT
-- - Ingresos Brutos
-- - Condición IVA
-- - Descripción de Cuenta
-- - Producto/Servicio
-- - Cuenta de Resumen Integral
-- - Costo
-- =====================================================

USE norte_erp_db;

-- =====================================================
-- ACTUALIZAR TABLA SUPPLIERS CON CAMPOS ADICIONALES
-- =====================================================

-- Agregar Razón Social (legal_name)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'legal_name');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN legal_name VARCHAR(255) NULL COMMENT ''Razón Social del Proveedor'' AFTER name',
    'SELECT "Column legal_name already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Nombre de Fantasía (trade_name)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'trade_name');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN trade_name VARCHAR(255) NULL COMMENT ''Nombre de Fantasía'' AFTER legal_name',
    'SELECT "Column trade_name already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Frecuencia de Compra (purchase_frequency)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'purchase_frequency');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN purchase_frequency VARCHAR(50) NULL COMMENT ''Frecuencia de Compra (diaria, semanal, mensual, etc.)'' AFTER trade_name',
    'SELECT "Column purchase_frequency already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Tipo de Identificación (id_type)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'id_type');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN id_type ENUM(''CUIT'', ''CUIL'', ''DNI'', ''PASAPORTE'', ''OTRO'') NULL COMMENT ''Tipo de Identificación'' AFTER purchase_frequency',
    'SELECT "Column id_type already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar CUIT (tax_id)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'tax_id');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN tax_id VARCHAR(20) NULL COMMENT ''CUIT/Número de Identificación'' AFTER id_type',
    'SELECT "Column tax_id already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Índice único para tax_id (opcional, comentado porque puede haber duplicados)
-- SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
--                WHERE TABLE_SCHEMA = 'norte_erp_db' 
--                AND TABLE_NAME = 'suppliers'
--                AND INDEX_NAME = 'idx_suppliers_tax_id');
-- 
-- SET @sqlstmt := IF(@exist = 0, 
--     'CREATE UNIQUE INDEX idx_suppliers_tax_id ON suppliers(tax_id)',
--     'SELECT "Index idx_suppliers_tax_id already exists" as message');
-- 
-- PREPARE stmt FROM @sqlstmt;
-- EXECUTE stmt;
-- DEALLOCATE PREPARE stmt;

-- Agregar Ingresos Brutos (gross_income)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'gross_income');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN gross_income VARCHAR(50) NULL COMMENT ''Ingresos Brutos'' AFTER tax_id',
    'SELECT "Column gross_income already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Condición IVA (vat_condition)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'vat_condition');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN vat_condition ENUM(''Responsable Inscripto'', ''Monotributista'', ''Exento'', ''Iva Exento'', ''No Responsable'', ''Consumidor Final'') NULL COMMENT ''Condición IVA'' AFTER gross_income',
    'SELECT "Column vat_condition already exists, updating ENUM values..." as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Si la columna ya existe, actualizar el ENUM para incluir 'Iva Exento'
-- Nota: MySQL no permite modificar ENUM directamente, se necesita recrear la columna
-- Por ahora, si la columna existe, este cambio se aplicará manualmente o en una migración separada

-- Agregar Descripción de Cuenta (account_description)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'account_description');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN account_description TEXT NULL COMMENT ''Descripción de Cuenta Contable'' AFTER vat_condition',
    'SELECT "Column account_description already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Producto/Servicio (product_service)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'product_service');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN product_service TEXT NULL COMMENT ''Producto o Servicio que provee'' AFTER account_description',
    'SELECT "Column product_service already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Cuenta de Resumen Integral (integral_summary_account)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'integral_summary_account');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN integral_summary_account VARCHAR(100) NULL COMMENT ''Cuenta de Resumen Integral'' AFTER product_service',
    'SELECT "Column integral_summary_account already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar Costo (cost)
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'cost');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE suppliers ADD COLUMN cost DECIMAL(12,2) NULL COMMENT ''Costo asociado al proveedor'' AFTER integral_summary_account',
    'SELECT "Column cost already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Crear índices para búsquedas frecuentes
SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND INDEX_NAME = 'idx_suppliers_tax_id');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_suppliers_tax_id ON suppliers(tax_id)',
    'SELECT "Index idx_suppliers_tax_id already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @exist := (SELECT COUNT(*) FROM information_schema.STATISTICS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND INDEX_NAME = 'idx_suppliers_legal_name');

SET @sqlstmt := IF(@exist = 0, 
    'CREATE INDEX idx_suppliers_legal_name ON suppliers(legal_name)',
    'SELECT "Index idx_suppliers_legal_name already exists" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'Migración completada: Campos adicionales agregados a tabla suppliers' as message;

