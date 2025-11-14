-- =====================================================
-- Script de Instalación: Sistema de Roles y Permisos
-- Norte ERP - Crear tablas y permisos iniciales
-- =====================================================
-- Ejecutar este script en MySQL Workbench o línea de comandos
-- mysql -u root -p norte_erp_db < install_roles_permissions.sql
-- =====================================================

USE norte_erp_db;

-- =====================================================
-- CREAR TABLAS
-- =====================================================

-- Tabla de permisos
CREATE TABLE IF NOT EXISTS permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(100) UNIQUE NOT NULL COMMENT 'Código único del permiso (ej: products.create, orders.view)',
    module VARCHAR(50) NOT NULL COMMENT 'Módulo al que pertenece (products, orders, purchases, etc)',
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_module (module),
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de asignación de permisos a roles
CREATE TABLE IF NOT EXISTS role_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role VARCHAR(50) NOT NULL COMMENT 'Rol del usuario (admin, manager, gerencia, ventas, etc)',
    permission_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_role_permission (role, permission_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    INDEX idx_role (role),
    INDEX idx_permission (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de asignación de permisos directos a usuarios
CREATE TABLE IF NOT EXISTS user_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    granted_by INT COMMENT 'ID del usuario que otorgó el permiso',
    expires_at TIMESTAMP NULL COMMENT 'Fecha de expiración del permiso (NULL = permanente)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_permission (user_id, permission_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_permission (permission_id),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERTAR PERMISOS (solo si no existen)
-- =====================================================

-- Módulo: Products
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver productos', 'products.view', 'products', 'Permite ver el listado y detalles de productos'),
('Crear productos', 'products.create', 'products', 'Permite crear nuevos productos'),
('Actualizar productos', 'products.update', 'products', 'Permite modificar productos existentes'),
('Eliminar productos', 'products.delete', 'products', 'Permite eliminar productos (soft delete)'),
('Eliminación permanente de productos', 'products.delete_permanent', 'products', 'Permite eliminar productos permanentemente de la base de datos'),
('Gestionar stock', 'products.manage_stock', 'products', 'Permite actualizar el stock de productos'),
('Ver estadísticas de productos', 'products.view_stats', 'products', 'Permite ver estadísticas del módulo de productos');

-- Módulo: Orders
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver pedidos', 'orders.view', 'orders', 'Permite ver el listado y detalles de pedidos'),
('Crear pedidos', 'orders.create', 'orders', 'Permite crear nuevos pedidos'),
('Actualizar pedidos', 'orders.update', 'orders', 'Permite modificar pedidos existentes'),
('Eliminar pedidos', 'orders.delete', 'orders', 'Permite eliminar pedidos'),
('Ver estadísticas de pedidos', 'orders.view_stats', 'orders', 'Permite ver estadísticas del módulo de pedidos'),
('Reservar stock', 'orders.reserve_stock', 'orders', 'Permite reservar stock para pedidos'),
('Actualizar estado de remito', 'orders.update_remito_status', 'orders', 'Permite actualizar el estado de remito de pedidos');

-- Módulo: Purchases
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver compras', 'purchases.view', 'purchases', 'Permite ver el listado y detalles de compras'),
('Crear compras', 'purchases.create', 'purchases', 'Permite crear nuevas compras'),
('Actualizar compras', 'purchases.update', 'purchases', 'Permite modificar compras existentes'),
('Eliminar compras', 'purchases.delete', 'purchases', 'Permite eliminar compras'),
('Ver estadísticas de compras', 'purchases.view_stats', 'purchases', 'Permite ver estadísticas del módulo de compras'),
('Gestionar items de compra', 'purchases.manage_items', 'purchases', 'Permite gestionar items de compras'),
('Gestionar proveedores', 'purchases.manage_suppliers', 'purchases', 'Permite gestionar proveedores');

-- Módulo: Clients
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver clientes', 'clients.view', 'clients', 'Permite ver el listado y detalles de clientes'),
('Crear clientes', 'clients.create', 'clients', 'Permite crear nuevos clientes'),
('Actualizar clientes', 'clients.update', 'clients', 'Permite modificar clientes existentes'),
('Eliminar clientes', 'clients.delete', 'clients', 'Permite eliminar clientes'),
('Ver estadísticas de clientes', 'clients.view_stats', 'clients', 'Permite ver estadísticas del módulo de clientes');

-- Módulo: Cash
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver resumen de caja', 'cash.view', 'cash', 'Permite ver resúmenes de caja (día, período, mensual)'),
('Gestionar gastos', 'cash.manage_expenses', 'cash', 'Permite crear y gestionar gastos operativos'),
('Exportar movimientos', 'cash.export', 'cash', 'Permite exportar movimientos de caja');

-- Módulo: Payments
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver pagos', 'payments.view', 'payments', 'Permite ver el listado y detalles de pagos'),
('Crear pagos', 'payments.create', 'payments', 'Permite crear nuevos pagos'),
('Actualizar pagos', 'payments.update', 'payments', 'Permite modificar pagos existentes'),
('Eliminar pagos', 'payments.delete', 'payments', 'Permite eliminar pagos');

-- Módulo: Dashboard
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver dashboard', 'dashboard.view', 'dashboard', 'Permite acceder al dashboard principal'),
('Ver estadísticas del dashboard', 'dashboard.view_stats', 'dashboard', 'Permite ver estadísticas en el dashboard'),
('Ver actividades recientes', 'dashboard.view_activities', 'dashboard', 'Permite ver actividades recientes en el dashboard');

-- Módulo: Logistics
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver remitos', 'logistics.view_remitos', 'logistics', 'Permite ver remitos de logística'),
('Crear remitos', 'logistics.create_remitos', 'logistics', 'Permite crear nuevos remitos'),
('Actualizar remitos', 'logistics.update_remitos', 'logistics', 'Permite modificar remitos'),
('Eliminar remitos', 'logistics.delete_remitos', 'logistics', 'Permite eliminar remitos'),
('Gestionar estados de remitos', 'logistics.manage_remito_status', 'logistics', 'Permite cambiar estados de remitos (preparar, despachar, entregar)'),
('Ver trazabilidad', 'logistics.view_trazabilidad', 'logistics', 'Permite ver trazabilidad de remitos'),
('Gestionar trazabilidad', 'logistics.manage_trazabilidad', 'logistics', 'Permite crear y actualizar trazabilidad');

-- Módulo: Users
INSERT IGNORE INTO permissions (name, code, module, description) VALUES
('Ver usuarios', 'users.view', 'users', 'Permite ver el listado de usuarios'),
('Crear usuarios', 'users.create', 'users', 'Permite crear nuevos usuarios'),
('Actualizar usuarios', 'users.update', 'users', 'Permite modificar usuarios existentes'),
('Eliminar usuarios', 'users.delete', 'users', 'Permite eliminar usuarios'),
('Gestionar roles', 'users.manage_roles', 'users', 'Permite gestionar roles del sistema'),
('Gestionar permisos', 'users.manage_permissions', 'users', 'Permite gestionar permisos del sistema'),
('Asignar permisos', 'users.assign_permissions', 'users', 'Permite asignar permisos a roles y usuarios');

-- =====================================================
-- ASIGNAR PERMISOS A ROLES (eliminar duplicados primero)
-- =====================================================

-- Eliminar asignaciones existentes para evitar duplicados
DELETE FROM role_permissions;

-- ADMIN: Todos los permisos
INSERT INTO role_permissions (role, permission_id)
SELECT 'admin', id FROM permissions;

-- GERENCIA: Permisos de visualización y gestión general
INSERT INTO role_permissions (role, permission_id)
SELECT 'gerencia', id FROM permissions 
WHERE code IN (
    'products.view', 'products.view_stats', 'products.create', 'products.update', 'products.manage_stock',
    'orders.view', 'orders.view_stats', 'orders.create', 'orders.update', 'orders.reserve_stock', 'orders.update_remito_status',
    'purchases.view', 'purchases.view_stats', 'purchases.create', 'purchases.update', 'purchases.manage_items', 'purchases.manage_suppliers',
    'clients.view', 'clients.view_stats', 'clients.create', 'clients.update', 'clients.delete',
    'cash.view', 'cash.manage_expenses', 'cash.export',
    'payments.view', 'payments.create', 'payments.update', 'payments.delete',
    'dashboard.view', 'dashboard.view_stats', 'dashboard.view_activities',
    'logistics.view_remitos', 'logistics.create_remitos', 'logistics.update_remitos', 'logistics.manage_remito_status', 'logistics.view_trazabilidad', 'logistics.manage_trazabilidad',
    'users.view', 'users.create', 'users.update'
);

-- VENTAS: Permisos relacionados con ventas
INSERT INTO role_permissions (role, permission_id)
SELECT 'ventas', id FROM permissions 
WHERE code IN (
    'products.view', 'products.view_stats',
    'orders.view', 'orders.view_stats', 'orders.create', 'orders.update', 'orders.reserve_stock',
    'clients.view', 'clients.view_stats', 'clients.create', 'clients.update',
    'dashboard.view', 'dashboard.view_stats',
    'payments.view', 'payments.create'
);

-- LOGISTICA: Permisos relacionados con logística y stock
INSERT INTO role_permissions (role, permission_id)
SELECT 'logistica', id FROM permissions 
WHERE code IN (
    'products.view', 'products.view_stats', 'products.manage_stock',
    'orders.view', 'orders.view_stats', 'orders.update_remito_status',
    'purchases.view', 'purchases.manage_items',
    'logistics.view_remitos', 'logistics.create_remitos', 'logistics.update_remitos', 'logistics.manage_remito_status', 'logistics.view_trazabilidad', 'logistics.manage_trazabilidad',
    'dashboard.view'
);

-- FINANZAS: Permisos relacionados con finanzas y compras
INSERT INTO role_permissions (role, permission_id)
SELECT 'finanzas', id FROM permissions 
WHERE code IN (
    'products.view', 'products.view_stats',
    'orders.view', 'orders.view_stats',
    'purchases.view', 'purchases.view_stats', 'purchases.create', 'purchases.update', 'purchases.manage_items', 'purchases.manage_suppliers',
    'clients.view', 'clients.view_stats',
    'cash.view', 'cash.manage_expenses', 'cash.export',
    'payments.view', 'payments.create', 'payments.update', 'payments.delete',
    'dashboard.view', 'dashboard.view_stats'
);

-- MANAGER: Similar a gerencia pero sin gestión de usuarios
INSERT INTO role_permissions (role, permission_id)
SELECT 'manager', id FROM permissions 
WHERE code IN (
    'products.view', 'products.view_stats', 'products.create', 'products.update', 'products.manage_stock',
    'orders.view', 'orders.view_stats', 'orders.create', 'orders.update', 'orders.reserve_stock', 'orders.update_remito_status',
    'purchases.view', 'purchases.view_stats', 'purchases.create', 'purchases.update', 'purchases.manage_items', 'purchases.manage_suppliers',
    'clients.view', 'clients.view_stats', 'clients.create', 'clients.update', 'clients.delete',
    'cash.view', 'cash.manage_expenses', 'cash.export',
    'payments.view', 'payments.create', 'payments.update', 'payments.delete',
    'dashboard.view', 'dashboard.view_stats', 'dashboard.view_activities',
    'logistics.view_remitos', 'logistics.create_remitos', 'logistics.update_remitos', 'logistics.manage_remito_status', 'logistics.view_trazabilidad', 'logistics.manage_trazabilidad',
    'users.view'
);

-- EMPLOYEE: Permisos básicos de visualización y operación
INSERT INTO role_permissions (role, permission_id)
SELECT 'employee', id FROM permissions 
WHERE code IN (
    'products.view',
    'orders.view', 'orders.create',
    'clients.view',
    'dashboard.view'
);

-- VIEWER: Solo lectura
INSERT INTO role_permissions (role, permission_id)
SELECT 'viewer', id FROM permissions 
WHERE code LIKE '%.view' OR code LIKE '%.view_stats' OR code LIKE '%.view_activities';

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

SELECT '✅ Tablas creadas exitosamente' AS status;
SELECT COUNT(*) AS total_permisos FROM permissions;
SELECT COUNT(*) AS total_asignaciones_roles FROM role_permissions;
SELECT role, COUNT(*) AS permisos FROM role_permissions GROUP BY role;

