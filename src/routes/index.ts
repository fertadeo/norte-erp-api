import { Router } from 'express';
import dashboardRoutes from './dashboard';

const router = Router();

// Mount all route modules
router.use('/dashboard', dashboardRoutes);

// Health check for API routes
router.get('/', (req, res) => {
  res.json({
    message: 'Norte ERP API Routes',
    version: '1.0.0',
    availableRoutes: {
      dashboard: '/api/dashboard',
      // Future routes will be added here
      stock: '/api/stock (coming soon)',
      clients: '/api/clients (coming soon)',
      orders: '/api/orders (coming soon)',
      production: '/api/production (coming soon)',
      personnel: '/api/personnel (coming soon)',
      purchases: '/api/purchases (coming soon)',
      budgets: '/api/budgets (coming soon)',
      store: '/api/store (coming soon)',
      billing: '/api/billing (coming soon)'
    }
  });
});

export default router;
