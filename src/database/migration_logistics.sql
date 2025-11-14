-- Migration: Logistics Module - Sistema de Remitos y Trazabilidad
-- Este archivo crea todas las tablas necesarias para el módulo de logística

USE norte_erp_db;

-- =====================================================
-- 1. REMITOS - Documentos de entrega física
-- =====================================================
CREATE TABLE IF NOT EXISTS remitos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    remito_number VARCHAR(20) UNIQUE NOT NULL,
    order_id INT NOT NULL,
    client_id INT NOT NULL,
    remito_type ENUM('entrega_cliente', 'traslado_interno', 'devolucion', 'consignacion') DEFAULT 'entrega_cliente',
    status ENUM('generado', 'preparando', 'listo_despacho', 'en_transito', 'entregado', 'devuelto', 'cancelado') DEFAULT 'generado',
    
    -- Fechas del proceso logístico
    generation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    preparation_date TIMESTAMP NULL,
    dispatch_date TIMESTAMP NULL,
    delivery_date TIMESTAMP NULL,
    
    -- Información de entrega
    delivery_address TEXT,
    delivery_city VARCHAR(50),
    delivery_contact VARCHAR(100),
    delivery_phone VARCHAR(20),
    
    -- Información de transporte
    transport_company VARCHAR(100),
    tracking_number VARCHAR(50),
    transport_cost DECIMAL(10,2) DEFAULT 0.00,
    
    -- Totales
    total_products INT DEFAULT 0,
    total_quantity INT DEFAULT 0,
    total_value DECIMAL(10,2) DEFAULT 0.00,
    
    -- Observaciones
    preparation_notes TEXT,
    delivery_notes TEXT,
    signature_data TEXT, -- Para firma digital
    delivery_photo VARCHAR(255), -- URL de foto de entrega
    
    -- Control
    created_by INT,
    delivered_by INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (delivered_by) REFERENCES users(id)
);

-- =====================================================
-- 2. REMITO_ITEMS - Productos incluidos en cada remito
-- =====================================================
CREATE TABLE IF NOT EXISTS remito_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    remito_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    
    -- Estado del item en el remito
    status ENUM('preparado', 'parcial', 'completo', 'devuelto') DEFAULT 'preparado',
    prepared_quantity INT DEFAULT 0,
    delivered_quantity INT DEFAULT 0,
    returned_quantity INT DEFAULT 0,
    
    -- Información adicional
    batch_number VARCHAR(50), -- Lote del producto
    serial_numbers TEXT, -- Números de serie (JSON array)
    expiration_date DATE,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (remito_id) REFERENCES remitos(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- =====================================================
-- 3. TRAZABILIDAD - Seguimiento completo del producto
-- =====================================================
CREATE TABLE IF NOT EXISTS trazabilidad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    remito_id INT NOT NULL,
    product_id INT NOT NULL,
    
    -- Etapa del proceso
    stage ENUM('fabricacion', 'control_calidad', 'almacenamiento', 'preparacion', 'despacho', 'transito', 'entrega', 'devuelto') NOT NULL,
    
    -- Ubicación y responsable
    location VARCHAR(100),
    location_details TEXT,
    responsible_person VARCHAR(100),
    responsible_user_id INT,
    
    -- Información de la etapa
    stage_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    stage_end TIMESTAMP NULL,
    duration_minutes INT,
    
    -- Datos específicos de la etapa
    temperature DECIMAL(5,2), -- Para productos sensibles
    humidity DECIMAL(5,2),
    quality_check BOOLEAN DEFAULT FALSE,
    quality_notes TEXT,
    
    -- Información de transporte (si aplica)
    vehicle_plate VARCHAR(20),
    driver_name VARCHAR(100),
    driver_phone VARCHAR(20),
    
    -- Observaciones y evidencia
    notes TEXT,
    photos JSON, -- Array de URLs de fotos
    documents JSON, -- Array de URLs de documentos
    
    -- Control
    is_automatic BOOLEAN DEFAULT FALSE, -- Si fue registrado automáticamente
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (remito_id) REFERENCES remitos(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (responsible_user_id) REFERENCES users(id)
);

-- =====================================================
-- 4. STOCK_MOVEMENTS - Movimientos de stock por logística
-- =====================================================
CREATE TABLE IF NOT EXISTS stock_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    movement_type ENUM('salida_remito', 'entrada_devolucion', 'traslado_interno', 'ajuste_inventario') NOT NULL,
    
    -- Referencia al remito o documento origen
    remito_id INT NULL,
    reference_number VARCHAR(50),
    reference_type ENUM('remito', 'devolucion', 'traslado', 'ajuste') NOT NULL,
    
    -- Cantidades
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2),
    total_cost DECIMAL(10,2),
    
    -- Ubicaciones
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    
    -- Información adicional
    batch_number VARCHAR(50),
    notes TEXT,
    
    -- Control
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (remito_id) REFERENCES remitos(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- =====================================================
-- 5. DELIVERY_ZONES - Zonas de entrega para optimización
-- =====================================================
CREATE TABLE IF NOT EXISTS delivery_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    city VARCHAR(50),
    province VARCHAR(50),
    postal_codes JSON, -- Array de códigos postales
    
    -- Configuración de entrega
    delivery_time_days INT DEFAULT 1,
    delivery_cost DECIMAL(10,2) DEFAULT 0.00,
    free_delivery_minimum DECIMAL(10,2),
    
    -- Estado
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- 6. TRANSPORT_COMPANIES - Empresas de transporte
-- =====================================================
CREATE TABLE IF NOT EXISTS transport_companies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    
    -- Configuración de servicios
    services JSON, -- Array de servicios ofrecidos
    coverage_zones JSON, -- Zonas que cubre
    rates JSON, -- Tarifas por zona/tipo
    
    -- Estado
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- 7. LOGISTICS_CONFIG - Configuración del módulo
-- =====================================================
CREATE TABLE IF NOT EXISTS logistics_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para remitos
CREATE INDEX idx_remitos_order ON remitos(order_id);
CREATE INDEX idx_remitos_client ON remitos(client_id);
CREATE INDEX idx_remitos_status ON remitos(status);
CREATE INDEX idx_remitos_date ON remitos(generation_date);
CREATE INDEX idx_remitos_number ON remitos(remito_number);

-- Índices para remito_items
CREATE INDEX idx_remito_items_remito ON remito_items(remito_id);
CREATE INDEX idx_remito_items_product ON remito_items(product_id);
CREATE INDEX idx_remito_items_status ON remito_items(status);

-- Índices para trazabilidad
CREATE INDEX idx_trazabilidad_remito ON trazabilidad(remito_id);
CREATE INDEX idx_trazabilidad_product ON trazabilidad(product_id);
CREATE INDEX idx_trazabilidad_stage ON trazabilidad(stage);
CREATE INDEX idx_trazabilidad_date ON trazabilidad(stage_start);

-- Índices para stock_movements
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_remito ON stock_movements(remito_id);
CREATE INDEX idx_stock_movements_type ON stock_movements(movement_type);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at);

-- =====================================================
-- DATOS INICIALES
-- =====================================================

-- Zonas de entrega por defecto
INSERT INTO delivery_zones (name, description, city, province, postal_codes, delivery_time_days, delivery_cost, free_delivery_minimum) VALUES
('Capital Federal', 'Ciudad Autónoma de Buenos Aires', 'CABA', 'CABA', '["1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800", "1900"]', 1, 500.00, 5000.00),
('GBA Norte', 'Gran Buenos Aires - Zona Norte', 'San Isidro', 'Buenos Aires', '["1600", "1610", "1615", "1620", "1625", "1630", "1635", "1640"]', 2, 800.00, 8000.00),
('GBA Sur', 'Gran Buenos Aires - Zona Sur', 'Avellaneda', 'Buenos Aires', '["1870", "1875", "1880", "1885", "1890", "1895", "1900"]', 2, 800.00, 8000.00),
('GBA Oeste', 'Gran Buenos Aires - Zona Oeste', 'La Matanza', 'Buenos Aires', '["1700", "1702", "1704", "1706", "1708", "1710"]', 2, 800.00, 8000.00);

-- Empresas de transporte por defecto
INSERT INTO transport_companies (name, contact_person, email, phone, services, coverage_zones) VALUES
('OCA', 'Contacto OCA', 'contacto@oca.com.ar', '0810-888-6222', '["envio_estandar", "envio_express", "envio_express_24hs"]', '["capital_federal", "gba", "interior"]'),
('Correo Argentino', 'Contacto Correo', 'contacto@correoargentino.com.ar', '0810-222-2276', '["envio_estandar", "envio_certificado"]', '["nacional"]'),
('Andreani', 'Contacto Andreani', 'contacto@andreani.com.ar', '0810-777-2627', '["envio_estandar", "envio_express"]', '["capital_federal", "gba", "interior"]');

-- Configuración inicial del módulo
INSERT INTO logistics_config (config_key, config_value, config_type, description) VALUES
('auto_generate_remito', 'true', 'boolean', 'Generar remitos automáticamente al aprobar pedidos'),
('require_signature', 'true', 'boolean', 'Requerir firma digital en entregas'),
('tracking_enabled', 'true', 'boolean', 'Habilitar seguimiento GPS de entregas'),
('auto_update_stock', 'true', 'boolean', 'Actualizar stock automáticamente con remitos'),
('default_transport_company', '1', 'number', 'Empresa de transporte por defecto'),
('remito_number_prefix', 'REM', 'string', 'Prefijo para numeración de remitos'),
('max_delivery_days', '7', 'number', 'Máximo días para entrega antes de alerta'),
('quality_check_required', 'true', 'boolean', 'Requerir control de calidad antes del despacho');

-- =====================================================
-- TRIGGERS PARA AUTOMATIZACIÓN
-- =====================================================

-- Trigger para actualizar stock automáticamente al crear remito
DELIMITER //
CREATE TRIGGER tr_remito_stock_update
AFTER INSERT ON remito_items
FOR EACH ROW
BEGIN
    -- Actualizar stock del producto
    UPDATE products 
    SET stock = stock - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.product_id;
    
    -- Registrar movimiento de stock
    INSERT INTO stock_movements (
        product_id, 
        movement_type, 
        remito_id, 
        reference_number, 
        reference_type, 
        quantity, 
        unit_cost, 
        total_cost,
        notes
    ) VALUES (
        NEW.product_id,
        'salida_remito',
        NEW.remito_id,
        (SELECT remito_number FROM remitos WHERE id = NEW.remito_id),
        'remito',
        NEW.quantity,
        NEW.unit_price,
        NEW.total_price,
        CONCAT('Salida por remito ', (SELECT remito_number FROM remitos WHERE id = NEW.remito_id))
    );
END//
DELIMITER ;

-- Trigger para actualizar totales del remito
DELIMITER //
CREATE TRIGGER tr_remito_totals_update
AFTER INSERT ON remito_items
FOR EACH ROW
BEGIN
    UPDATE remitos 
    SET total_products = (
            SELECT COUNT(*) FROM remito_items WHERE remito_id = NEW.remito_id
        ),
        total_quantity = (
            SELECT SUM(quantity) FROM remito_items WHERE remito_id = NEW.remito_id
        ),
        total_value = (
            SELECT SUM(total_price) FROM remito_items WHERE remito_id = NEW.remito_id
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.remito_id;
END//
DELIMITER ;
