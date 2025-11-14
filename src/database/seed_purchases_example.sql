-- =====================================================
-- Script de Datos de Ejemplo para Módulo de Compras
-- Norte ERP - Compras de Ejemplo
-- =====================================================

-- Asegurar que las tablas existan (ejecutar primero migration_purchases_complete.sql)
-- Este script solo inserta datos de ejemplo

-- =====================================================
-- LIMPIAR DATOS EXISTENTES (OPCIONAL)
-- =====================================================
-- Descomentar las siguientes líneas si quieres limpiar datos existentes
-- DELETE FROM purchase_items;
-- DELETE FROM purchases;
-- DELETE FROM suppliers;

-- =====================================================
-- PROVEEDORES DE EJEMPLO
-- =====================================================

INSERT IGNORE INTO suppliers (code, name, contact_name, email, phone, address, city, country, is_active) VALUES
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
-- COMPRAS DE EJEMPLO
-- =====================================================

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
-- ITEMS DE COMPRA DE EJEMPLO (SIN DEPENDENCIA DE PRODUCTOS)
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

-- Insertar items de compra
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
-- VERIFICACIÓN Y REPORTES
-- =====================================================

-- Mostrar resumen de datos insertados
SELECT 'Proveedores insertados:' as info, COUNT(*) as cantidad FROM suppliers;
SELECT 'Compras insertadas:' as info, COUNT(*) as cantidad FROM purchases;
SELECT 'Items de compra insertados:' as info, COUNT(*) as cantidad FROM purchase_items;

-- Resumen de compras por estado
SELECT 
    status as 'Estado',
    COUNT(*) as 'Cantidad',
    FORMAT(SUM(total_amount), 2) as 'Monto Total'
FROM purchases 
GROUP BY status;

-- Compras con sus proveedores
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

-- Items de compra con productos
SELECT 
    p.purchase_number as 'Compra',
    pr.name as 'Producto',
    pi.quantity as 'Cantidad',
    FORMAT(pi.unit_price, 2) as 'Precio Unitario',
    FORMAT(pi.total_price, 2) as 'Total'
FROM purchase_items pi
JOIN purchases p ON pi.purchase_id = p.id
JOIN products pr ON pi.product_id = pr.id
ORDER BY p.purchase_number, pi.id;

-- =====================================================
-- SCRIPT COMPLETADO
-- =====================================================

SELECT 'Datos de ejemplo insertados exitosamente' as resultado;
