-- Migration: Add sales_channel field to clients table
-- This migration adds support for tracking where clients come from (sales channel)

USE norte_erp_db;

-- Add sales_channel field to clients table
ALTER TABLE clients 
ADD COLUMN sales_channel ENUM(
    'woocommerce_minorista',
    'woocommerce_mayorista', 
    'mercadolibre',
    'sistema_norte',
    'manual',
    'otro'
) DEFAULT 'manual' 
AFTER client_type;

-- Add index for better performance on sales_channel queries
CREATE INDEX idx_clients_sales_channel ON clients(sales_channel);

-- Add comment to describe the field
ALTER TABLE clients 
MODIFY COLUMN sales_channel ENUM(
    'woocommerce_minorista',
    'woocommerce_mayorista', 
    'mercadolibre',
    'sistema_norte',
    'manual',
    'otro'
) DEFAULT 'manual' 
COMMENT 'Canal de venta del que proviene el cliente';

-- Update existing clients to have 'manual' as default (already handled by DEFAULT)
-- This is just for documentation purposes
-- Clients created manually through the system will have 'manual'
-- Clients synced from WooCommerce will have 'woocommerce_minorista' or 'woocommerce_mayorista'
-- Clients from MercadoLibre will have 'mercadolibre'
-- Clients from Sistema Norte will have 'sistema_norte'
-- Other sources will have 'otro'

