-- =====================================================
-- MIGRACIÓN: ACTUALIZAR ENUM DE VAT_CONDITION
-- Norte ERP - Agregar 'Iva Exento' al ENUM de vat_condition
-- =====================================================
-- Esta migración actualiza el ENUM de vat_condition para incluir 'Iva Exento'
-- Si la columna ya existe con el ENUM anterior, esta migración la actualiza
-- =====================================================

USE norte_erp_db;

-- Verificar si la columna existe y tiene el ENUM antiguo
SET @exist := (SELECT COUNT(*) FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = 'norte_erp_db' 
               AND TABLE_NAME = 'suppliers'
               AND COLUMN_NAME = 'vat_condition'
               AND COLUMN_TYPE NOT LIKE '%Iva Exento%');

-- Si existe pero no tiene 'Iva Exento', actualizar el ENUM
SET @sqlstmt := IF(@exist > 0, 
    'ALTER TABLE suppliers MODIFY COLUMN vat_condition ENUM(''Responsable Inscripto'', ''Monotributista'', ''Exento'', ''Iva Exento'', ''No Responsable'', ''Consumidor Final'') NULL COMMENT ''Condición IVA''',
    'SELECT "Column vat_condition already has Iva Exento or does not exist" as message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'Migración completada: ENUM de vat_condition actualizado para incluir Iva Exento' as message;

