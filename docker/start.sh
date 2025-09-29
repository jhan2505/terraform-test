#!/bin/bash
set -e

echo "🚀 Iniciando Hola Mundo desde AWS..."

# Iniciar Apache en background
/usr/sbin/httpd -D FOREGROUND &

# Iniciar VS Code Server en background
nohup code-server --bind-addr 0.0.0.0:8080 --auth none /home/developer/app &

echo "✅ Servicios iniciados:"
echo "   - Apache HTTP Server (Puerto 80)"
echo "   - VS Code Server (Puerto 8080)"
echo "   - Base de datos: MySQL RDS"
echo ""
echo "🌐 Aplicación disponible en: http://localhost"
echo "📊 Health check: http://localhost/db_check.sh"
echo ""
echo "¡Hola Mundo desde AWS está funcionando!"

# Mantener el contenedor en ejecución
echo "🔄 Manteniendo contenedor activo..."
while true; do
    sleep 30
    echo "💓 Contenedor activo - $(date)"
done