module.exports = {
  apps: [
    {
      name: 'norte-erp-api',
      script: './dist/index.js',
      instances: 2, // Número de instancias (puedes usar 'max' para usar todos los CPUs)
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 8083
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

