import { Router } from 'express';
import dashboardRoutes from './dashboard';
import clientRoutes from './clients';
import productRoutes from './products';
import integrationRoutes from './integration';
import wooCommerceRoutes from './woocommerce';
import authRoutes from './auth';

const router = Router();

// Mount all route modules
router.use('/dashboard', dashboardRoutes);
router.use('/clients', clientRoutes);
router.use('/products', productRoutes);
router.use('/integration', integrationRoutes);
router.use('/woocommerce', wooCommerceRoutes);
router.use('/auth', authRoutes);

// Health check for API routes
router.get('/', (req, res) => {
  res.json({
    message: 'Norte ERP API Routes',
    version: '1.0.0',
    availableRoutes: {
      dashboard: '/api/dashboard',
      clients: '/api/clients',
      products: '/api/products',
      integration: '/api/integration',
      woocommerce: '/api/woocommerce',
      auth: '/api/auth',
      // Future routes will be added here
      stock: '/api/products/stock (available)',
      orders: '/api/orders (coming soon)',
      production: '/api/production (coming soon)',
      personnel: '/api/personnel (coming soon)',
      purchases: '/api/purchases (coming soon)',
      budgets: '/api/budgets (coming soon)',
      store: '/api/store (coming soon)',
      billing: '/api/billing (coming soon)'
    },
    products: {
      list: 'GET /api/products',
      get_by_id: 'GET /api/products/:id',
      create: 'POST /api/products',
      update: 'PUT /api/products/:id',
      delete: 'DELETE /api/products/:id (soft delete)',
      permanent_delete: 'DELETE /api/products/:id/permanent',
      update_stock: 'PUT /api/products/:id/stock',
      low_stock: 'GET /api/products/stock/low',
      stats: 'GET /api/products/stats'
    },
    integration: {
      hello_world: '/api/integration/hello',
      woo_commerce_products: '/api/integration/products/woocommerce',
      stock_sync: '/api/integration/products/sync',
      stock_summary: '/api/integration/stock/summary',
      webhook: '/api/integration/webhook/woocommerce'
    },
    woocommerce: {
      products: '/api/woocommerce/products',
      sync_products: '/api/woocommerce/products/sync',
      update_stock: '/api/woocommerce/products/:sku/stock'
    }
  });
});

export default router;
