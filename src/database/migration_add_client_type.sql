-- Migration: Add client_type field to clients table
-- This migration adds support for different client types with auto-incremental codes

USE norte_erp_db;

-- Add client_type field to clients table
ALTER TABLE clients 
ADD COLUMN client_type ENUM('mayorista', 'minorista', 'personalizado') DEFAULT 'minorista' 
AFTER code;

-- Update existing clients to have a default type (optional)
-- UPDATE clients SET client_type = 'minorista' WHERE client_type IS NULL;

-- Add index for better performance on client_type queries
CREATE INDEX idx_clients_type ON clients(client_type);

-- Add composite index for code generation queries
CREATE INDEX idx_clients_type_code ON clients(client_type, code);

-- Insert some example data with different types (optional)
-- INSERT INTO clients (code, client_type, name, email) VALUES 
-- ('MAY001', 'mayorista', 'Distribuidora Mayorista S.A.', 'ventas@mayorista.com'),
-- ('MIN001', 'minorista', 'Tienda Minorista', 'info@tienda.com'),
-- ('PER001', 'personalizado', 'Cliente Personalizado', 'cliente@personalizado.com');
