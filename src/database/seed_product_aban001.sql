-- Script para crear el producto ABAN-001 (EcoFan FullBlack)
-- Este producto se usa para pruebas de pedidos mayoristas desde WooCommerce

USE norte_erp_db;

-- Verificar si el producto ya existe
SET @product_exists = (SELECT COUNT(*) FROM products WHERE code = 'ABAN-001');

-- Si no existe, crear el producto
INSERT INTO products (code, name, description, category_id, price, stock, min_stock, max_stock, is_active)
SELECT 
  'ABAN-001',
  'EcoFan FullBlack',
  'Abanico de plástico de 20cm, ideal para uso personal.',
  (SELECT id FROM categories WHERE name = 'Abanicos' LIMIT 1), -- Buscar categoría de Abanicos
  1500.00, -- Precio
  100, -- Stock inicial
  10, -- Stock mínimo
  1000, -- Stock máximo
  1 -- Activo
WHERE @product_exists = 0;

-- Verificar que el producto se creó correctamente
SELECT * FROM products WHERE code = 'ABAN-001';

