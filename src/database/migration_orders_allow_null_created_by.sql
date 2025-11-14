-- Migración para permitir NULL en created_by de orders
-- Esto permite crear pedidos desde sistemas externos (WooCommerce/N8N) sin usuario

USE norte_erp_db;

-- Eliminar la restricción de clave foránea existente
ALTER TABLE orders DROP FOREIGN KEY orders_ibfk_2;

-- Volver a crear la restricción pero permitiendo NULL
ALTER TABLE orders 
ADD CONSTRAINT orders_ibfk_2 
FOREIGN KEY (created_by) REFERENCES users(id) 
ON DELETE SET NULL;

