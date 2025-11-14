module.exports = {
  apps: [
    {
      name: 'norte-erp-api',
      script: './dist/index.js',
      instances: 2, // Número de instancias (puedes usar 'max' para usar todos los CPUs)
      exec_mode: 'cluster',
      env_production: {
        NODE_ENV: 'production',
        PORT: 8083,
        // Las variables de entorno sensibles (DB_PASSWORD, JWT_SECRET, etc.) 
        // se leerán del archivo .env automáticamente gracias a dotenv.config()
        // Si prefieres incluirlas aquí, descomenta y completa:
        // DB_HOST: '149.50.139.91',
        // DB_PORT: 3306,
        // DB_USER: 'fenecstudio-remote',
        // DB_PASSWORD: 'tu_password_aqui',
        // DB_NAME: 'norte_erp_db',
        // JWT_SECRET: 'tu_jwt_secret_aqui',
        // CORS_ORIGIN: 'http://149.50.139.91,https://tu-dominio.com'
      },
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      log_file: './logs/pm2-combined.log',
      time: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      merge_logs: true,
      instance_var: 'INSTANCE_ID'
    }
  ]
};

