import { Request, Response } from 'express';
import { ProductService } from '../services/ProductService';
import { ApiResponse } from '../types';

export class IntegrationController {
  private productService: ProductService;

  constructor() {
    this.productService = new ProductService();
  }

  // GET /api/integration/hello - Hola mundo endpoint para probar conexión
  public async helloWorld(req: Request, res: Response): Promise<void> {
    try {
      const response: ApiResponse = {
        success: true,
        message: '¡Hola Mundo! Conexión exitosa con Norte ERP API',
        data: {
          api_name: 'Norte ERP API',
          version: '1.0.0',
          status: 'active',
          timestamp: new Date().toISOString(),
          integration_ready: true,
          available_endpoints: {
            products: '/api/products',
            clients: '/api/clients',
            stock: '/api/products/stock',
            health: '/health'
          }
        },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Hello world error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error en endpoint hello world',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // GET /api/integration/products/woocommerce - Obtener productos formateados para WooCommerce
  public async getProductsForWooCommerce(req: Request, res: Response): Promise<void> {
    try {
      const { page = 1, per_page = 10 } = req.query;
      
      const pageNum = parseInt(String(page), 10) || 1;
      const perPageNum = parseInt(String(per_page), 10) || 10;
      
      const { products, total } = await this.productService.getAllProducts({
        page: pageNum,
        limit: perPageNum,
        active_only: true
      });
      
      // Formatear productos para WooCommerce
      const wooCommerceProducts = products.map((product) => ({
        id: product.id,
        name: product.name,
        slug: product.name.toLowerCase().replace(/\s+/g, '-'),
        permalink: `https://tu-tienda.com/producto/${product.name.toLowerCase().replace(/\s+/g, '-')}`,
        sku: product.code,
        price: product.price.toString(),
        regular_price: product.price.toString(),
        sale_price: '',
        on_sale: false,
        status: product.is_active ? 'publish' : 'draft',
        purchasable: product.stock > 0,
        stock_quantity: product.stock,
        stock_status: product.stock > 0 ? 'instock' : 'outofstock',
        manage_stock: true,
        backorders: 'no',
        categories: product.category_name ? [{ name: product.category_name }] : [],
        description: product.description || '',
        short_description: product.description ? product.description.substring(0, 160) + '...' : '',
        date_created: product.created_at,
        date_modified: product.updated_at,
        meta_data: [
          {
            key: '_norte_erp_id',
            value: product.id.toString()
          },
          {
            key: '_norte_erp_code',
            value: product.code
          }
        ]
      }));
      
      const response: ApiResponse = {
        success: true,
        message: 'Productos formateados para WooCommerce obtenidos exitosamente',
        data: {
          products: wooCommerceProducts,
          pagination: {
            page: pageNum,
            per_page: perPageNum,
            total,
            total_pages: Math.ceil(total / perPageNum)
          }
        },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Get products for WooCommerce error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error obteniendo productos para WooCommerce',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // POST /api/integration/products/sync - Sincronizar stock desde WooCommerce
  public async syncStockFromWooCommerce(req: Request, res: Response): Promise<void> {
    try {
      const { products } = req.body; // Array de productos con { sku, stock_quantity }
      
      if (!Array.isArray(products)) {
        const response: ApiResponse = {
          success: false,
          message: 'Formato inválido. Se espera un array de productos.',
          timestamp: new Date().toISOString()
        };
        res.status(400).json(response);
        return;
      }
      
      const results = [];
      
      for (const product of products) {
        const { sku, stock_quantity } = product;
        
        if (!sku || typeof stock_quantity !== 'number') {
          results.push({
            sku,
            success: false,
            error: 'SKU o stock_quantity inválido'
          });
          continue;
        }
        
         try {
           // Buscar producto por código (SKU)
           const existingProduct = await this.productService.getProductByCode(sku);
          
          if (!existingProduct) {
            results.push({
              sku,
              success: false,
              error: 'Producto no encontrado'
            });
            continue;
          }
          
          // Actualizar stock
          await this.productService.updateStock(existingProduct.id, stock_quantity, 'set');
          
          results.push({
            sku,
            success: true,
            old_stock: existingProduct.stock,
            new_stock: stock_quantity
          });
          
        } catch (error) {
          results.push({
            sku,
            success: false,
            error: error instanceof Error ? error.message : 'Error desconocido'
          });
        }
      }
      
      const successCount = results.filter((r: any) => r.success).length;
      const errorCount = results.filter((r: any) => !r.success).length;
      
      const response: ApiResponse = {
        success: true,
        message: `Sincronización completada. ${successCount} exitosos, ${errorCount} errores.`,
        data: {
          results,
          summary: {
            total: products.length,
            successful: successCount,
            errors: errorCount
          }
        },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Sync stock from WooCommerce error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error sincronizando stock desde WooCommerce',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // GET /api/integration/stock/summary - Resumen de stock para sincronización
  public async getStockSummary(req: Request, res: Response): Promise<void> {
    try {
      const { products } = await this.productService.getAllProducts({ active_only: true });
      
      const summary = {
        total_products: products.length,
        instock: products.filter(p => p.stock > p.min_stock).length,
        lowstock: products.filter(p => p.stock <= p.min_stock && p.stock > 0).length,
        outofstock: products.filter(p => p.stock === 0).length,
        total_stock_value: products.reduce((sum, p) => sum + (p.stock * p.price), 0)
      };
      
      const response: ApiResponse = {
        success: true,
        message: 'Resumen de stock obtenido exitosamente',
        data: {
          summary,
          products: products.map(p => ({
            sku: p.code,
            name: p.name,
            stock: p.stock,
            min_stock: p.min_stock,
            max_stock: p.max_stock,
            is_active: p.is_active,
            stock_status: p.stock === 0 ? 'outofstock' : p.stock <= p.min_stock ? 'lowstock' : 'instock'
          }))
        },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Get stock summary error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error obteniendo resumen de stock',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // POST /api/integration/webhook/woocommerce - Webhook para recibir actualizaciones de WooCommerce
  public async wooCommerceWebhook(req: Request, res: Response): Promise<void> {
    try {
      const { action, product } = req.body;
      
      console.log('Webhook recibido de WooCommerce:', { action, product });
      
      if (action === 'product.updated' && product) {
        const { sku, stock_quantity } = product;
        
         if (sku && typeof stock_quantity === 'number') {
           // Buscar producto por código
           const existingProduct = await this.productService.getProductByCode(sku);
           console.log('Producto encontrado:', existingProduct);
          if (existingProduct) {
            // Actualizar stock en ERP
            await this.productService.updateStock(existingProduct.id, stock_quantity, 'set');
            console.log(`Stock actualizado para SKU ${sku}: ${stock_quantity}`);
          }
        }
      }
      
      const response: ApiResponse = {
        success: true,
        message: 'Webhook procesado exitosamente',
        data: { action, processed: true },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('WooCommerce webhook error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error procesando webhook de WooCommerce',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }
}

