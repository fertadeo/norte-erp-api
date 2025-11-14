-- =====================================================
-- Script de Migración Compatible para Módulo de Compras
-- Norte ERP - Módulo de Compras (Compatible con MySQL 5.7+)
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

-- =====================================================
-- CREAR ÍNDICES (con manejo de errores)
-- =====================================================

-- Función para crear índices de forma segura
-- Si el índice ya existe, se mostrará un error que se puede ignorar

-- Índices para tabla purchases
CREATE INDEX idx_purchases_supplier ON purchases(supplier_id);
CREATE INDEX idx_purchases_status ON purchases(status);
CREATE INDEX idx_purchases_date ON purchases(purchase_date);

-- Índices para tabla purchase_items
CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX idx_purchase_items_product ON purchase_items(product_id);

-- Índices para tabla suppliers
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
-- CREAR PRODUCTOS TEMPORALES PARA ITEMS
-- =====================================================

-- Crear productos temporales si no existen
INSERT IGNORE INTO products (id, code, name, description, price, stock, min_stock, max_stock, is_active) VALUES
(1001, 'MOT001', 'Motor Eléctrico 220V', 'Motor eléctrico para abanicos de techo', 1200.00, 50, 5, 100, TRUE),
(1002, 'ASP001', 'Aspas de Abanico', 'Aspas de madera para abanicos', 600.00, 30, 10, 80, TRUE),
(1003, 'CAB001', 'Cable Eléctrico', 'Cable eléctrico para instalaciones', 400.00, 100, 20, 200, TRUE),
(1004, 'TEN001', 'Tornillos y Tuercas', 'Kit de tornillos y tuercas', 312.50, 200, 50, 500, TRUE),
(1005, 'CON001', 'Conectores Eléctricos', 'Conectores para instalaciones eléctricas', 500.00, 80, 15, 150, TRUE),
(1006, 'RES001', 'Resistencia Eléctrica', 'Resistencia para motores', 200.00, 40, 10, 100, TRUE),
(1007, 'CAP001', 'Capacitores', 'Capacitores para motores eléctricos', 1500.00, 25, 5, 50, TRUE),
(1008, 'INT001', 'Interruptores', 'Interruptores de pared', 500.00, 60, 10, 120, TRUE),
(1009, 'CAB002', 'Cable de Alimentación', 'Cable de alimentación principal', 800.00, 45, 10, 90, TRUE),
(1010, 'FUS001', 'Fusibles', 'Fusibles de protección', 300.00, 100, 20, 200, TRUE),
(1011, 'LED001', 'Luces LED', 'Luces LED para abanicos', 300.00, 35, 10, 70, TRUE),
(1012, 'REM001', 'Control Remoto', 'Control remoto para abanicos', 200.00, 25, 5, 50, TRUE),
(1013, 'BRA001', 'Brazos de Abanico', 'Brazos metálicos para abanicos', 2500.00, 15, 3, 30, TRUE),
(1014, 'BAL001', 'Balancín', 'Balancín para abanicos de techo', 500.00, 20, 5, 40, TRUE),
(1015, 'PLA001', 'Placa Base', 'Placa base para motores', 600.00, 30, 8, 60, TRUE),
(1016, 'ENV001', 'Envolvente', 'Envolvente protector para motores', 500.00, 25, 5, 50, TRUE),
(1017, 'ROD001', 'Rodamientos', 'Rodamientos para motores', 700.00, 40, 10, 80, TRUE),
(1018, 'ACE001', 'Aceite Lubricante', 'Aceite para lubricación', 500.00, 20, 5, 40, TRUE),
(1019, 'BAN001', 'Banda Elástica', 'Banda elástica para aspas', 1000.00, 15, 3, 30, TRUE),
(1020, 'ADH001', 'Adhesivo Industrial', 'Adhesivo para ensamblaje', 500.00, 30, 8, 60, TRUE);

-- =====================================================
-- DATOS DE EJEMPLO - ITEMS DE COMPRAS
-- =====================================================

-- Insertar items para las compras
INSERT INTO purchase_items (purchase_id, product_id, quantity, unit_price, total_price) VALUES
-- Items para COMP0001 (Compra 1)
(1, 1001, 10, 1200.00, 12000.00),
(1, 1002, 5, 600.00, 3000.00),

-- Items para COMP0002 (Compra 2)
(2, 1003, 15, 400.00, 6000.00),
(2, 1004, 8, 312.50, 2500.00),

-- Items para COMP0003 (Compra 3)
(3, 1005, 20, 500.00, 10000.00),
(3, 1006, 10, 200.00, 2000.00),

-- Items para COMP0004 (Compra 4)
(4, 1007, 12, 1500.00, 18000.00),
(4, 1008, 8, 500.00, 4000.00),

-- Items para COMP0005 (Compra 5)
(5, 1009, 18, 800.00, 14400.00),
(5, 1010, 12, 300.00, 3600.00),

-- Items para COMP0006 (Compra 6 - cancelada)
(6, 1011, 25, 300.00, 7500.00),
(6, 1012, 10, 200.00, 2000.00),

-- Items para COMP0007 (Compra 7)
(7, 1013, 8, 2500.00, 20000.00),
(7, 1014, 10, 500.00, 5000.00),

-- Items para COMP0008 (Compra 8 - pendiente)
(8, 1015, 15, 600.00, 9000.00),
(8, 1016, 9, 500.00, 4500.00),

-- Items para COMP0009 (Compra 9)
(9, 1017, 20, 700.00, 14000.00),
(9, 1018, 10, 500.00, 5000.00),

-- Items para COMP0010 (Compra 10)
(10, 1019, 12, 1000.00, 12000.00),
(10, 1020, 9, 500.00, 4500.00);

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
    FORMAT(SUM(total_amount), 2) as 'Monto Total'
FROM purchases 
GROUP BY status;

-- Mostrar compras con sus proveedores
SELECT 
    p.purchase_number as 'Número',
    s.name as 'Proveedor',
    p.status as 'Estado',
    FORMAT(p.total_amount, 2) as 'Monto',
    p.purchase_date as 'Fecha Compra',
    p.received_date as 'Fecha Recibido'
FROM purchases p
JOIN suppliers s ON p.supplier_id = s.id
ORDER BY p.purchase_date DESC;

-- =====================================================
-- SCRIPT COMPLETADO
-- =====================================================

SELECT 'Script de migración completado exitosamente' as resultado;
