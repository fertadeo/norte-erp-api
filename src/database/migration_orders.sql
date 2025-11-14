-- =====================================================
-- MIGRACIÓN: MÓDULO DE PEDIDOS (ORDERS)
-- =====================================================
-- Este script crea las tablas necesarias para el módulo de pedidos
-- Compatible con el módulo de logística (remitos)
-- =====================================================

-- Tabla principal de pedidos
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    client_id INT NOT NULL,
    status ENUM(
        'pendiente_preparacion',
        'listo_despacho',
        'pagado',
        'aprobado',
        'en_proceso',
        'completado',
        'cancelado'
    ) DEFAULT 'pendiente_preparacion',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date TIMESTAMP NULL,
    delivery_address TEXT,
    delivery_city VARCHAR(100),
    delivery_contact VARCHAR(100),
    delivery_phone VARCHAR(20),
    transport_company VARCHAR(100),
    transport_cost DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    
    -- Campos de control para remitos
    remito_status ENUM(
        'sin_remito',
        'remito_generado',
        'remito_despachado',
        'remito_entregado'
    ) DEFAULT 'sin_remito',
    stock_reserved BOOLEAN DEFAULT FALSE,
    
    -- Campos de auditoría
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Índices y restricciones
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_order_number (order_number),
    INDEX idx_client_id (client_id),
    INDEX idx_status (status),
    INDEX idx_remito_status (remito_status),
    INDEX idx_order_date (order_date),
    INDEX idx_stock_reserved (stock_reserved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de items de pedidos
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    batch_number VARCHAR(50),
    notes TEXT,
    stock_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices y restricciones
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- MIGRACIÓN: AGREGAR COLUMNAS FALTANTES A TABLAS EXISTENTES
-- =====================================================

-- Agregar columnas faltantes a order_items si no existen
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'order_items' 
     AND COLUMN_NAME = 'batch_number') = 0,
    'ALTER TABLE order_items ADD COLUMN batch_number VARCHAR(50)',
    'SELECT "Columna batch_number ya existe"'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'order_items' 
     AND COLUMN_NAME = 'notes') = 0,
    'ALTER TABLE order_items ADD COLUMN notes TEXT',
    'SELECT "Columna notes ya existe"'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'order_items' 
     AND COLUMN_NAME = 'stock_reserved') = 0,
    'ALTER TABLE order_items ADD COLUMN stock_reserved BOOLEAN DEFAULT FALSE',
    'SELECT "Columna stock_reserved ya existe"'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Tabla de historial de estados de pedidos
CREATE TABLE IF NOT EXISTS order_status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by INT,
    change_reason TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices y restricciones
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id),
    INDEX idx_order_id (order_id),
    INDEX idx_changed_at (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de configuración del módulo de pedidos
CREATE TABLE IF NOT EXISTS orders_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- DATOS INICIALES DE CONFIGURACIÓN
-- =====================================================

INSERT IGNORE INTO orders_config (config_key, config_value, config_type, description) VALUES
('auto_generate_order_number', 'true', 'boolean', 'Generar número de pedido automáticamente'),
('require_stock_before_approval', 'true', 'boolean', 'Requerir stock disponible antes de aprobar pedido'),
('auto_reserve_stock_on_approval', 'true', 'boolean', 'Reservar stock automáticamente al aprobar pedido'),
('auto_generate_remito_on_ready', 'true', 'boolean', 'Generar remito automáticamente cuando pedido está listo'),
('default_transport_company', 'OCA', 'string', 'Empresa de transporte predeterminada'),
('days_to_complete_order', '7', 'number', 'Días para completar un pedido'),
('notify_client_on_status_change', 'true', 'boolean', 'Notificar cliente al cambiar estado'),
('notify_logistics_on_ready', 'true', 'boolean', 'Notificar logística cuando pedido está listo');

-- =====================================================
-- TRIGGERS Y PROCEDIMIENTOS
-- =====================================================

-- Trigger para actualizar total_price en order_items
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS before_order_item_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END$$

CREATE TRIGGER IF NOT EXISTS before_order_item_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END$$

DELIMITER ;

-- Trigger para actualizar total_amount del pedido
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0) 
        FROM order_items 
        WHERE order_id = NEW.order_id
    )
    WHERE id = NEW.order_id;
END$$

CREATE TRIGGER IF NOT EXISTS after_order_item_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0) 
        FROM order_items 
        WHERE order_id = NEW.order_id
    )
    WHERE id = NEW.order_id;
END$$

CREATE TRIGGER IF NOT EXISTS after_order_item_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0) 
        FROM order_items 
        WHERE order_id = OLD.order_id
    )
    WHERE id = OLD.order_id;
END$$

DELIMITER ;

-- Trigger para registrar cambios de estado
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS after_order_status_change
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO order_status_history (order_id, previous_status, new_status, changed_by, change_reason)
        VALUES (NEW.id, OLD.status, NEW.status, NEW.created_by, 'Estado actualizado');
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Vista de pedidos con información de cliente
CREATE OR REPLACE VIEW v_orders_with_clients AS
SELECT 
    o.*,
    c.name as client_name,
    c.code as client_code,
    c.email as client_email,
    c.phone as client_phone,
    c.client_type as client_type,
    (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) as items_count
FROM orders o
LEFT JOIN clients c ON o.client_id = c.id
WHERE o.is_active = TRUE;

-- Vista de pedidos listos para generar remito
CREATE OR REPLACE VIEW v_orders_ready_for_remito AS
SELECT 
    o.*,
    c.name as client_name,
    c.email as client_email
FROM orders o
LEFT JOIN clients c ON o.client_id = c.id
WHERE o.is_active = TRUE
  AND o.status IN ('listo_despacho', 'pagado', 'aprobado')
  AND o.remito_status = 'sin_remito'
  AND o.stock_reserved = TRUE;

-- =====================================================
-- COMENTARIOS
-- =====================================================

-- Este script crea:
-- 1. Tabla de pedidos con control de remitos
-- 2. Tabla de items de pedidos
-- 3. Tabla de historial de estados
-- 4. Tabla de configuración
-- 5. Triggers para cálculos automáticos
-- 6. Vistas útiles para reportes

-- Estados del pedido:
-- - pendiente_preparacion: Pedido recibido, no preparado
-- - listo_despacho: Pedido listo para generar remito
-- - pagado: Pedido pagado (mayoristas con cuenta corriente)
-- - aprobado: Pedido aprobado administrativamente
-- - en_proceso: Pedido en fabricación/preparación
-- - completado: Pedido completado y entregado
-- - cancelado: Pedido cancelado

-- Estados de remito:
-- - sin_remito: No tiene remito generado
-- - remito_generado: Tiene remito pero no despachado
-- - remito_despachado: Remito en tránsito
-- - remito_entregado: Remito entregado al cliente

