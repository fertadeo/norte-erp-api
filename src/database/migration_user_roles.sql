-- Migration to extend users.role ENUM with business-specific roles
ALTER TABLE users
  MODIFY COLUMN role ENUM(
    'admin',
    'manager',
    'employee',
    'viewer',
    'gerencia',
    'ventas',
    'logistica',
    'finanzas'
  ) DEFAULT 'employee';
