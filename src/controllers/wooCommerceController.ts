import { Request, Response } from 'express';
import { ProductService } from '../services/ProductService';
import { ApiResponse } from '../types';

export class WooCommerceController {
  private productService: ProductService;

  constructor() {
    this.productService = new ProductService();
  }

  // GET /api/woocommerce/products - Obtener productos para WooCommerce
  public async getProducts(req: Request, res: Response): Promise<void> {
    try {
      const { page = 1, per_page = 10, search, category } = req.query;
      
      const pageNum = parseInt(String(page), 10) || 1;
      const perPageNum = parseInt(String(per_page), 10) || 10;
      
      const { products, total } = await this.productService.getAllProducts({
        page: pageNum,
        limit: perPageNum,
        search: search as string,
        category_id: category ? parseInt(String(category), 10) : undefined,
        active_only: true
      });
      
      // Formatear para WooCommerce
      const wooProducts = products.map(product => ({
        id: product.id,
        name: product.name,
        slug: product.name.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
        permalink: `https://tu-tienda.com/producto/${product.name.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`,
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
          { key: '_norte_erp_id', value: product.id.toString() },
          { key: '_norte_erp_code', value: product.code }
        ]
      }));
      
      const response: ApiResponse = {
        success: true,
        message: 'Productos obtenidos exitosamente',
        data: {
          products: wooProducts,
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
      console.error('Get WooCommerce products error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error obteniendo productos',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // POST /api/woocommerce/products/sync - Sincronizar productos desde WooCommerce
  public async syncProducts(req: Request, res: Response): Promise<void> {
    try {
      const { products } = req.body;
      
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
        const { sku, stock_quantity, price, name, status } = product;
        
        try {
          // Buscar producto existente
          const existingProduct = await this.productService.getProductByCode(sku);
          
          if (existingProduct) {
            // Actualizar producto existente
            await this.productService.updateProduct(existingProduct.id, {
              name: name || existingProduct.name,
              price: price || existingProduct.price,
              stock: stock_quantity || existingProduct.stock,
              is_active: status === 'publish'
            });
            
            results.push({
              sku,
              action: 'updated',
              success: true,
              message: 'Producto actualizado exitosamente'
            });
          } else {
            // Crear nuevo producto
            await this.productService.createProduct({
              code: sku,
              name: name || `Producto ${sku}`,
              price: price || 0,
              stock: stock_quantity || 0
            });
            
            results.push({
              sku,
              action: 'created',
              success: true,
              message: 'Producto creado exitosamente'
            });
          }
        } catch (error) {
          results.push({
            sku,
            action: 'error',
            success: false,
            error: error instanceof Error ? error.message : 'Error desconocido'
          });
        }
      }
      
      const successCount = results.filter(r => r.success).length;
      const errorCount = results.filter(r => !r.success).length;
      
      const response: ApiResponse = {
        success: true,
        message: `Sincronización completada. ${successCount} exitosos, ${errorCount} errores.`,
        data: { results },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Sync WooCommerce products error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error sincronizando productos',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // PUT /api/woocommerce/products/:sku/stock - Actualizar stock específico
  public async updateStock(req: Request, res: Response): Promise<void> {
    try {
      const { sku } = req.params;
      const { stock_quantity, operation = 'set' } = req.body;
      
      if (typeof stock_quantity !== 'number' || stock_quantity < 0) {
        const response: ApiResponse = {
          success: false,
          message: 'stock_quantity debe ser un número positivo',
          timestamp: new Date().toISOString()
        };
        res.status(400).json(response);
        return;
      }
      
      const product = await this.productService.getProductByCode(sku);
      
      if (!product) {
        const response: ApiResponse = {
          success: false,
          message: 'Producto no encontrado',
          timestamp: new Date().toISOString()
        };
        res.status(404).json(response);
        return;
      }
      
      const updatedProduct = await this.productService.updateStock(
        product.id, 
        stock_quantity, 
        operation as 'set' | 'add' | 'subtract'
      );
      
      const response: ApiResponse = {
        success: true,
        message: 'Stock actualizado exitosamente',
        data: {
          sku: updatedProduct.code,
          old_stock: product.stock,
          new_stock: updatedProduct.stock,
          operation
        },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Update stock error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error actualizando stock',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }
}
