import { Router } from 'express';
import { ProductController } from '../controllers/productController';
import { body, param, query } from 'express-validator';
import { validate } from '../middleware/validation';

const router = Router();
const productController = new ProductController();

// Validation rules
const createProductValidation = [
  body('code').notEmpty().withMessage('Código es requerido'),
  body('name').notEmpty().withMessage('Nombre es requerido'),
  body('price').isNumeric().withMessage('Precio debe ser numérico'),
  body('stock').optional().isInt({ min: 0 }).withMessage('Stock debe ser un número entero positivo'),
  body('min_stock').optional().isInt({ min: 0 }).withMessage('Stock mínimo debe ser un número entero positivo'),
  body('max_stock').optional().isInt({ min: 0 }).withMessage('Stock máximo debe ser un número entero positivo')
];

const updateProductValidation = [
  param('id').isInt().withMessage('ID debe ser un número entero'),
  body('code').optional().notEmpty().withMessage('Código no puede estar vacío'),
  body('name').optional().notEmpty().withMessage('Nombre no puede estar vacío'),
  body('price').optional().isNumeric().withMessage('Precio debe ser numérico'),
  body('stock').optional().isInt({ min: 0 }).withMessage('Stock debe ser un número entero positivo'),
  body('min_stock').optional().isInt({ min: 0 }).withMessage('Stock mínimo debe ser un número entero positivo'),
  body('max_stock').optional().isInt({ min: 0 }).withMessage('Stock máximo debe ser un número entero positivo')
];

const updateStockValidation = [
  param('id').isInt().withMessage('ID debe ser un número entero'),
  body('stock').isNumeric().withMessage('Stock debe ser numérico'),
  body('operation').optional().isIn(['set', 'add', 'subtract']).withMessage('Operación debe ser set, add o subtract')
];

// Routes
router.get('/', productController.getAllProducts.bind(productController));
router.get('/stats', productController.getProductStats.bind(productController));
router.get('/stock/low', productController.getLowStockProducts.bind(productController));
router.get('/:id', 
  param('id').isInt().withMessage('ID debe ser un número entero'),
  validate([param('id').isInt().withMessage('ID debe ser un número entero')]),
  productController.getProductById.bind(productController)
);
router.post('/', 
  createProductValidation,
  validate(createProductValidation),
  productController.createProduct.bind(productController)
);
router.put('/:id', 
  updateProductValidation,
  validate(updateProductValidation),
  productController.updateProduct.bind(productController)
);
router.put('/:id/stock', 
  updateStockValidation,
  validate(updateStockValidation),
  productController.updateStock.bind(productController)
);
router.delete('/:id', 
  param('id').isInt().withMessage('ID debe ser un número entero'),
  validate([param('id').isInt().withMessage('ID debe ser un número entero')]),
  productController.deleteProduct.bind(productController)
);
router.delete('/:id/permanent', 
  param('id').isInt().withMessage('ID debe ser un número entero'),
  validate([param('id').isInt().withMessage('ID debe ser un número entero')]),
  productController.permanentDeleteProduct.bind(productController)
);

export default router;