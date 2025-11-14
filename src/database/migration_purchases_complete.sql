-- =====================================================
-- Script de Migración Completo para Módulo de Compras
-- Norte ERP - Módulo de Compras
-- =====================================================

-- Crear tabla de proveedores si no existe
CREATE TABLE IF NOT EXISTS suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50) DEFAULT 'Argentina',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Crear tabla de compras si no existe
CREATE TABLE IF NOT EXISTS purchases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_number VARCHAR(20) UNIQUE NOT NULL,
    supplier_id INT NOT NULL,
    status ENUM('pending', 'received', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    received_date TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Crear tabla de items de compra si no existe
CREATE TABLE IF NOT EXISTS purchase_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Crear índices para mejor rendimiento
-- Nota: IF NOT EXISTS no es compatible con todas las versiones de MySQL
-- Si los índices ya existen, se mostrará un error que se puede ignorar

CREATE INDEX idx_purchases_supplier ON purchases(supplier_id);
CREATE INDEX idx_purchases_status ON purchases(status);
CREATE INDEX idx_purchases_date ON purchases(purchase_date);
CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX idx_purchase_items_product ON purchase_items(product_id);
CREATE INDEX idx_suppliers_code ON suppliers(code);
CREATE INDEX idx_suppliers_active ON suppliers(is_active);

-- =====================================================
-- DATOS DE EJEMPLO - PROVEEDORES
-- =====================================================

-- Insertar proveedores de ejemplo
INSERT INTO suppliers (code, name, contact_name, email, phone, address, city, country, is_active) VALUES
('PROV001', 'Proveedor ABC S.A.', 'Juan Pérez', 'juan@proveedorabc.com', '+54 11 1234-5678', 'Av. Corrientes 1234', 'Buenos Aires', 'Argentina', TRUE),
('PROV002', 'Materiales del Norte SRL', 'María González', 'maria@materialesnorte.com', '+54 11 2345-6789', 'Av. Santa Fe 5678', 'Buenos Aires', 'Argentina', TRUE),
('PROV003', 'Componentes Eléctricos S.A.', 'Carlos Rodríguez', 'carlos@componentes.com', '+54 11 3456-7890', 'Av. Rivadavia 9012', 'Córdoba', 'Argentina', TRUE),
('PROV004', 'Repuestos Industriales Ltda.', 'Ana Martínez', 'ana@repuestos.com', '+54 11 4567-8901', 'Av. Córdoba 3456', 'Rosario', 'Argentina', TRUE),
('PROV005', 'Suministros Técnicos S.A.', 'Roberto Silva', 'roberto@suministros.com', '+54 11 5678-9012', 'Av. 9 de Julio 7890', 'Buenos Aires', 'Argentina', TRUE),
('PROV006', 'Herramientas del Sur', 'Laura Fernández', 'laura@herramientas.com', '+54 11 6789-0123', 'Av. San Martín 1234', 'Mendoza', 'Argentina', TRUE),
('PROV007', 'Equipos Industriales SRL', 'Diego López', 'diego@equipos.com', '+54 11 7890-1234', 'Av. Belgrano 5678', 'Tucumán', 'Argentina', TRUE),
('PROV008', 'Materiales Especializados', 'Patricia García', 'patricia@materiales.com', '+54 11 8901-2345', 'Av. Libertador 9012', 'Buenos Aires', 'Argentina', TRUE),
('PROV009', 'Componentes del Litoral', 'Miguel Torres', 'miguel@litoral.com', '+54 11 9012-3456', 'Av. Entre Ríos 3456', 'Paraná', 'Argentina', TRUE),
('PROV010', 'Suministros del Interior', 'Sandra Morales', 'sandra@interior.com', '+54 11 0123-4567', 'Av. Sarmiento 7890', 'Salta', 'Argentina', TRUE);

-- =====================================================
-- DATOS DE EJEMPLO - COMPRAS
-- =====================================================

-- Insertar 10 compras de ejemplo
INSERT INTO purchases (purchase_number, supplier_id, status, total_amount, purchase_date, received_date, notes) VALUES
('COMP0001', 1, 'received', 15000.00, '2024-01-15 10:30:00', '2024-01-16 14:30:00', 'Compra de motores eléctricos para producción'),
('COMP0002', 2, 'received', 8500.00, '2024-01-18 09:15:00', '2024-01-19 11:45:00', 'Materiales de construcción para abanicos'),
('COMP0003', 3, 'pending', 12000.00, '2024-01-20 14:20:00', NULL, 'Componentes eléctricos pendientes de entrega'),
('COMP0004', 4, 'received', 22000.00, '2024-01-22 08:45:00', '2024-01-23 16:20:00', 'Repuestos industriales para mantenimiento'),
('COMP0005', 5, 'received', 18000.00, '2024-01-25 11:30:00', '2024-01-26 09:15:00', 'Suministros técnicos para línea de producción'),
('COMP0006', 6, 'cancelled', 9500.00, '2024-01-28 13:10:00', NULL, 'Compra cancelada por problemas de calidad'),
('COMP0007', 7, 'received', 25000.00, '2024-01-30 16:45:00', '2024-01-31 10:30:00', 'Equipos industriales para nueva línea'),
('COMP0008', 8, 'pending', 13500.00, '2024-02-02 12:20:00', NULL, 'Materiales especializados en proceso'),
('COMP0009', 9, 'received', 19000.00, '2024-02-05 15:30:00', '2024-02-06 13:45:00', 'Componentes del litoral para exportación'),
('COMP0010', 10, 'received', 16500.00, '2024-02-08 10:15:00', '2024-02-09 14:20:00', 'Suministros del interior para distribución');

-- =====================================================
-- DATOS DE EJEMPLO - ITEMS DE COMPRAS
-- =====================================================

-- Insertar items para las compras (asumiendo que existen productos con IDs 1-20)
INSERT INTO purchase_items (purchase_id, product_id, quantity, unit_price, total_price) VALUES
-- Items para COMP0001 (Compra 1)
(1, 1, 10, 1200.00, 12000.00),
(1, 2, 5, 600.00, 3000.00),

-- Items para COMP0002 (Compra 2)
(2, 3, 15, 400.00, 6000.00),
(2, 4, 8, 312.50, 2500.00),

-- Items para COMP0003 (Compra 3)
(3, 5, 20, 500.00, 10000.00),
(3, 6, 10, 200.00, 2000.00),

-- Items para COMP0004 (Compra 4)
(4, 7, 12, 1500.00, 18000.00),
(4, 8, 8, 500.00, 4000.00),

-- Items para COMP0005 (Compra 5)
(5, 9, 18, 800.00, 14400.00),
(5, 10, 12, 300.00, 3600.00),

-- Items para COMP0006 (Compra 6 - cancelada)
(6, 11, 25, 300.00, 7500.00),
(6, 12, 10, 200.00, 2000.00),

-- Items para COMP0007 (Compra 7)
(7, 13, 8, 2500.00, 20000.00),
(7, 14, 10, 500.00, 5000.00),

-- Items para COMP0008 (Compra 8 - pendiente)
(8, 15, 15, 600.00, 9000.00),
(8, 16, 9, 500.00, 4500.00),

-- Items para COMP0009 (Compra 9)
(9, 17, 20, 700.00, 14000.00),
(9, 18, 10, 500.00, 5000.00),

-- Items para COMP0010 (Compra 10)
(10, 19, 12, 1000.00, 12000.00),
(10, 20, 9, 500.00, 4500.00);

-- =====================================================
-- VERIFICACIÓN DE DATOS
-- =====================================================

-- Verificar que se insertaron correctamente
SELECT 'Proveedores insertados:' as info, COUNT(*) as cantidad FROM suppliers;
SELECT 'Compras insertadas:' as info, COUNT(*) as cantidad FROM purchases;
SELECT 'Items de compra insertados:' as info, COUNT(*) as cantidad FROM purchase_items;

-- Mostrar resumen de compras por estado
SELECT 
    status as 'Estado',
    COUNT(*) as 'Cantidad',
    SUM(total_amount) as 'Monto Total'
FROM purchases 
GROUP BY status;

-- Mostrar compras con sus proveedores
SELECT 
    p.purchase_number as 'Número',
    s.name as 'Proveedor',
    p.status as 'Estado',
    p.total_amount as 'Monto',
    p.purchase_date as 'Fecha Compra',
    p.received_date as 'Fecha Recibido'
FROM purchases p
JOIN suppliers s ON p.supplier_id = s.id
ORDER BY p.purchase_date DESC;

-- Mostrar items de compra con productos
SELECT 
    p.purchase_number as 'Compra',
    pr.name as 'Producto',
    pi.quantity as 'Cantidad',
    pi.unit_price as 'Precio Unitario',
    pi.total_price as 'Total'
FROM purchase_items pi
JOIN purchases p ON pi.purchase_id = p.id
JOIN products pr ON pi.product_id = pr.id
ORDER BY p.purchase_number, pi.id;

-- =====================================================
-- SCRIPT COMPLETADO
-- =====================================================

SELECT 'Script de migración completado exitosamente' as resultado;
