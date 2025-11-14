-- =====================================================
-- SCRIPT DE PRUEBA: CARGAR PEDIDO DE PRUEBA
-- =====================================================
-- Este script crea datos de prueba para el módulo de pedidos
-- Incluye: cliente, productos y un pedido completo
-- =====================================================

-- 1. INSERTAR CLIENTE DE PRUEBA
INSERT INTO clients (code, name, email, phone, address, city, country, is_active)
VALUES ('CLI-TEST-001', 'Cliente de Prueba SA', 'cliente.prueba@example.com', '+54 11 1234-5678', 
        'Av. Corrientes 1234', 'Buenos Aires', 'Argentina', TRUE)
ON DUPLICATE KEY UPDATE name = name; -- No actualiza si ya existe

-- Obtener el ID del cliente
SET @client_id = (SELECT id FROM clients WHERE code = 'CLI-TEST-001' LIMIT 1);

-- 2. INSERTAR CATEGORÍA DE PRUEBA
INSERT INTO categories (name, description, is_active)
VALUES ('Abanicos Industriales', 'Abanicos para uso industrial y comercial', TRUE)
ON DUPLICATE KEY UPDATE name = name;

-- Obtener el ID de la categoría
SET @category_id = (SELECT id FROM categories WHERE name = 'Abanicos Industriales' LIMIT 1);

-- 3. INSERTAR PRODUCTOS DE PRUEBA
INSERT INTO products (code, name, description, category_id, price, stock, min_stock, max_stock, is_active)
VALUES 
    ('PROD-001', 'Abanico Industrial 20"', 'Abanico industrial de 20 pulgadas, 3 velocidades', @category_id, 15500.00, 50, 5, 100, TRUE),
    ('PROD-002', 'Abanico Industrial 24"', 'Abanico industrial de 24 pulgadas, potencia alta', @category_id, 22800.00, 30, 5, 80, TRUE),
    ('PROD-003', 'Abanico de Piso 18"', 'Abanico de piso residencial 18 pulgadas', @category_id, 12300.00, 75, 10, 150, TRUE),
    ('PROD-004', 'Abanico de Pared 16"', 'Abanico de pared con control remoto', @category_id, 9800.00, 100, 15, 200, TRUE)
ON DUPLICATE KEY UPDATE name = name;

-- Obtener IDs de los productos
SET @product1_id = (SELECT id FROM products WHERE code = 'PROD-001' LIMIT 1);
SET @product2_id = (SELECT id FROM products WHERE code = 'PROD-002' LIMIT 1);
SET @product3_id = (SELECT id FROM products WHERE code = 'PROD-003' LIMIT 1);
SET @product4_id = (SELECT id FROM products WHERE code = 'PROD-004' LIMIT 1);

-- 4. OBTENER UN USUARIO EXISTENTE (el primero disponible)
SET @user_id = (SELECT id FROM users WHERE is_active = TRUE LIMIT 1);

-- 5. INSERTAR PEDIDO DE PRUEBA
INSERT INTO orders (
    order_number, 
    client_id, 
    status, 
    delivery_date,
    delivery_address,
    delivery_city,
    delivery_contact,
    delivery_phone,
    transport_company,
    transport_cost,
    notes,
    remito_status,
    stock_reserved,
    created_by
)
VALUES (
    CONCAT('ORD-', YEAR(NOW()), LPAD(MONTH(NOW()), 2, '0'), '-', LPAD(FLOOR(RAND() * 1000), 4, '0')),  -- Número de orden único
    @client_id,
    'pendiente_preparacion',
    DATE_ADD(NOW(), INTERVAL 7 DAY),  -- Entrega en 7 días
    'Av. Corrientes 1234, Piso 3',
    'Buenos Aires',
    'Juan Pérez',
    '+54 11 1234-5678',
    'OCA',
    2500.00,
    'Pedido de prueba - Entregar en horario de oficina (9-18hs)',
    'sin_remito',
    FALSE,
    @user_id
);

-- Obtener el ID del pedido recién creado
SET @order_id = LAST_INSERT_ID();

-- 6. INSERTAR ITEMS DEL PEDIDO
INSERT INTO order_items (order_id, product_id, quantity, unit_price, notes)
VALUES 
    (@order_id, @product1_id, 5, 15500.00, 'Color negro'),
    (@order_id, @product2_id, 3, 22800.00, 'Con garantía extendida'),
    (@order_id, @product3_id, 10, 12300.00, NULL),
    (@order_id, @product4_id, 8, 9800.00, 'Con control remoto incluido');

-- =====================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- =====================================================

-- Mostrar el pedido creado con sus detalles
SELECT 
    o.id,
    o.order_number,
    o.status,
    o.total_amount,
    c.name as cliente,
    c.email as email_cliente,
    o.delivery_city,
    o.transport_company,
    o.notes
FROM orders o
LEFT JOIN clients c ON o.client_id = c.id
WHERE o.id = @order_id;

-- Mostrar los items del pedido
SELECT 
    oi.id,
    p.code as codigo_producto,
    p.name as producto,
    oi.quantity as cantidad,
    oi.unit_price as precio_unitario,
    oi.total_price as total,
    oi.notes
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = @order_id;

-- Mostrar resumen del pedido
SELECT 
    'RESUMEN DEL PEDIDO' as titulo,
    @order_id as pedido_id,
    (SELECT order_number FROM orders WHERE id = @order_id) as numero_pedido,
    COUNT(*) as cantidad_items,
    SUM(oi.quantity) as unidades_totales,
    SUM(oi.total_price) as subtotal_productos,
    (SELECT transport_cost FROM orders WHERE id = @order_id) as costo_transporte,
    (SELECT total_amount FROM orders WHERE id = @order_id) as total_pedido
FROM order_items oi
WHERE oi.order_id = @order_id;

-- =====================================================
-- SCRIPT COMPLETADO
-- =====================================================
-- El pedido de prueba ha sido creado exitosamente
-- Puedes verificar los datos en la base de datos
-- =====================================================

