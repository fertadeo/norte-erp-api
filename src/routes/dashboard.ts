import { Router } from 'express';
import { DashboardController } from '../controllers/dashboardController';
import { authenticateToken } from '../middleware/auth';

const router = Router();
const dashboardController = new DashboardController();

// All dashboard routes require authentication
router.use(authenticateToken);

// GET /api/dashboard/stats - Get dashboard statistics
router.get('/stats', dashboardController.getDashboardStats.bind(dashboardController));

// GET /api/dashboard/activities - Get recent activities
router.get('/activities', dashboardController.getRecentActivities.bind(dashboardController));

export default router;
