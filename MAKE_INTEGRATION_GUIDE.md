# Guía de Integración Norte ERP ↔ WooCommerce con Make

## Configuración de la API

### Variables de Entorno
Crea un archivo `.env` con las siguientes variables:

```env
# Base de datos
DB_HOST=localhost
DB_PORT=3306
DB_USER=tu_usuario
DB_PASSWORD=tu_password
DB_NAME=norte_erp_db

# API Keys para Make
API_KEY=norte-erp-api-key-2024
WEBHOOK_SECRET=norte-erp-webhook-secret-2024

# Servidor
PORT=8083
NODE_ENV=development
```

### Endpoints Disponibles

#### 1. Hola Mundo (Sin autenticación)
```
GET /api/integration/hello
```
**Descripción:** Endpoint básico para probar la conexión.

#### 2. Productos para WooCommerce (Con API Key)
```
GET /api/woocommerce/products?page=1&per_page=10
```
**Headers requeridos:**
- `x-api-key: norte-erp-api-key-2024`

**Parámetros:**
- `page` (opcional): Número de página (default: 1)
- `per_page` (opcional): Productos por página (default: 10)
- `search` (opcional): Búsqueda por nombre o código
- `category` (opcional): ID de categoría

#### 3. Sincronizar Productos desde WooCommerce (Con API Key)
```
POST /api/woocommerce/products/sync
```
**Headers requeridos:**
- `x-api-key: norte-erp-api-key-2024`
- `Content-Type: application/json`

**Body:**
```json
{
  "products": [
    {
      "sku": "ABAN-001",
      "name": "Abanico de Plástico",
      "price": 1500.00,
      "stock_quantity": 50,
      "status": "publish"
    }
  ]
}
```

#### 4. Actualizar Stock Específico (Con API Key)
```
PUT /api/woocommerce/products/:sku/stock
```
**Headers requeridos:**
- `x-api-key: norte-erp-api-key-2024`
- `Content-Type: application/json`

**Body:**
```json
{
  "stock_quantity": 45,
  "operation": "set"
}
```

#### 5. Webhook para WooCommerce (Con Webhook Secret)
```
POST /api/integration/webhook/woocommerce
```
**Headers requeridos:**
- `x-webhook-secret: norte-erp-webhook-secret-2024`
- `Content-Type: application/json`

## Configuración en Make (Integromat)

### Escenario 1: Sincronización de Productos (ERP → WooCommerce)

1. **Trigger:** Programado (cada hora)
2. **Módulo 1:** HTTP - Obtener productos del ERP
   - URL: `http://tu-servidor:8083/api/woocommerce/products`
   - Método: GET
   - Headers: `x-api-key: norte-erp-api-key-2024`
3. **Módulo 2:** WooCommerce - Crear/Actualizar productos
   - Usar los datos del módulo anterior

### Escenario 2: Sincronización de Stock (WooCommerce → ERP)

1. **Trigger:** Webhook de WooCommerce (cuando se actualiza stock)
2. **Módulo 1:** WooCommerce - Obtener producto actualizado
3. **Módulo 2:** HTTP - Actualizar stock en ERP
   - URL: `http://tu-servidor:8083/api/woocommerce/products/{{sku}}/stock`
   - Método: PUT
   - Headers: `x-api-key: norte-erp-api-key-2024`
   - Body: `{"stock_quantity": {{stock}}, "operation": "set"}`

### Escenario 3: Sincronización Bidireccional Completa

1. **Trigger:** Cron (cada 30 minutos)
2. **Módulo 1:** HTTP - Obtener productos del ERP
   - URL: `http://tu-servidor:8083/api/woocommerce/products`
   - Headers: `x-api-key: norte-erp-api-key-2024`
3. **Módulo 2:** WooCommerce - Actualizar productos
4. **Módulo 3:** WooCommerce - Obtener productos actualizados
5. **Módulo 4:** HTTP - Sincronizar stock en ERP
   - URL: `http://tu-servidor:8083/api/woocommerce/products/sync`
   - Headers: `x-api-key: norte-erp-api-key-2024`

## Configuración en N8N

### Workflow 1: Sincronización de Productos

1. **Trigger:** Cron (cada hora)
2. **Node 1:** HTTP Request - Obtener productos del ERP
   - URL: `http://localhost:8083/api/woocommerce/products`
   - Headers: `x-api-key: norte-erp-api-key-2024`
3. **Node 2:** WooCommerce - Actualizar productos

### Workflow 2: Webhook de Stock

1. **Trigger:** Webhook
2. **Node 1:** HTTP Request - Actualizar stock en ERP
   - URL: `http://localhost:8083/api/woocommerce/products/{{$json.sku}}/stock`
   - Method: PUT
   - Headers: `x-api-key: norte-erp-api-key-2024`
   - Body: `{"stock_quantity": {{$json.stock}}, "operation": "set"}`

## Pruebas de la API

### 1. Probar conexión básica
```bash
curl http://localhost:8083/api/integration/hello
```

### 2. Probar productos (con API Key)
```bash
curl -H "x-api-key: norte-erp-api-key-2024" \
     http://localhost:8083/api/woocommerce/products
```

### 3. Probar actualización de stock
```bash
curl -X PUT \
     -H "x-api-key: norte-erp-api-key-2024" \
     -H "Content-Type: application/json" \
     -d '{"stock_quantity": 25, "operation": "set"}' \
     http://localhost:8083/api/woocommerce/products/ABAN-001/stock
```

### 4. Probar webhook
```bash
curl -X POST \
     -H "x-webhook-secret: norte-erp-webhook-secret-2024" \
     -H "Content-Type: application/json" \
     -d '{"action": "product.updated", "product": {"sku": "ABAN-001", "stock_quantity": 30}}' \
     http://localhost:8083/api/integration/webhook/woocommerce
```

## Estructura de Respuestas

### Respuesta Exitosa
```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": { ... },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Respuesta de Error
```json
{
  "success": false,
  "message": "Descripción del error",
  "error": "Detalles del error",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Próximos Pasos

1. ✅ Endpoints de productos
2. ✅ Autenticación con API Key
3. ✅ Sincronización de stock
4. ✅ Webhooks
5. 🔄 Logs de sincronización
6. 🔄 Dashboard de integración
7. 🔄 Manejo de errores avanzado
8. 🔄 Rate limiting
9. 🔄 Documentación de API con Swagger
