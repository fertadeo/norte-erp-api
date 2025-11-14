#!/bin/bash

# Script de despliegue para Norte ERP API
# Uso: ./scripts/deploy.sh

set -e  # Salir si algún comando falla

echo "🚀 Iniciando despliegue de Norte ERP API..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables
APP_NAME="norte-erp-api"
APP_DIR="/var/www/norte-erp-api"

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: No se encontró package.json. Ejecuta este script desde la raíz del proyecto.${NC}"
    exit 1
fi

# Verificar que existe el archivo .env
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Advertencia: No se encontró el archivo .env${NC}"
    echo -e "${YELLOW}   Asegúrate de crear el archivo .env con las variables de entorno necesarias.${NC}"
    echo -e "${YELLOW}   Puedes usar env.production.example como referencia.${NC}"
    read -p "¿Deseas continuar de todos modos? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

# Instalar dependencias
echo -e "${GREEN}📦 Instalando dependencias...${NC}"
npm install --production

# Compilar TypeScript
echo -e "${GREEN}🔨 Compilando TypeScript...${NC}"
npm run build

# Verificar que la compilación fue exitosa
if [ ! -d "dist" ] || [ ! -f "dist/index.js" ]; then
    echo -e "${RED}❌ Error: La compilación falló. No se encontró dist/index.js${NC}"
    exit 1
fi

# Crear directorio de logs si no existe
mkdir -p logs

# Verificar si PM2 está instalado
if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}❌ Error: PM2 no está instalado.${NC}"
    echo -e "${YELLOW}   Instala PM2 con: npm install -g pm2${NC}"
    exit 1
fi

# Detener la aplicación si está corriendo
echo -e "${GREEN}🛑 Deteniendo aplicación si está corriendo...${NC}"
pm2 delete $APP_NAME 2>/dev/null || true

# Iniciar aplicación con PM2
echo -e "${GREEN}▶️  Iniciando aplicación con PM2...${NC}"
pm2 start ecosystem.config.js

# Guardar configuración de PM2
pm2 save

# Mostrar estado
echo -e "${GREEN}📊 Estado de la aplicación:${NC}"
pm2 status

# Mostrar logs
echo -e "${GREEN}📋 Últimas líneas de los logs:${NC}"
pm2 logs $APP_NAME --lines 20 --nostream

echo -e "${GREEN}✅ Despliegue completado exitosamente!${NC}"
echo -e "${GREEN}   Verifica el estado con: pm2 status${NC}"
echo -e "${GREEN}   Ver logs en tiempo real con: pm2 logs $APP_NAME${NC}"

