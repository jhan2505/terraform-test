#!/bin/bash
# Script para verificar conexión real a MySQL RDS

# Las variables de entorno ya están disponibles desde Docker
# No necesitamos cargar archivos adicionales

# Verificar que todas las variables estén definidas
if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "Content-Type: application/json"
    echo ""
    cat << EOF
{
    "status": "error",
    "message": "Variables de entorno de base de datos no configuradas correctamente",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    exit 1
fi

# Separar host y puerto si vienen juntos
if [[ $DB_HOST == *":"* ]]; then
    IFS=':' read -r DB_HOST DB_PORT <<< "$DB_HOST"
fi

echo "Content-Type: application/json"
echo ""

# Intentar conexión a MySQL
if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1 as test;" >/dev/null 2>&1; then
    # Conexión exitosa - obtener datos
    TEST_RESULT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1 as test;" 2>/dev/null | tail -n +2)
    TIME_RESULT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT NOW() as current_time;" 2>/dev/null | tail -n +2)
    VERSION_RESULT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT VERSION() as mysql_version;" 2>/dev/null | tail -n +2)
    
    TEST=$(echo "$TEST_RESULT" | awk '{print $1}')
    CURRENT_TIME=$(echo "$TIME_RESULT" | awk '{print $1, $2}')
    MYSQL_VERSION=$(echo "$VERSION_RESULT" | awk '{print $1}')
    
    cat << EOF
{
    "status": "connected",
    "message": "Conexión exitosa a MySQL RDS",
    "database_info": {
        "host": "$DB_HOST",
        "port": "$DB_PORT",
        "database": "$DB_NAME",
        "user": "$DB_USER",
        "mysql_version": "$MYSQL_VERSION",
        "server_time": "$CURRENT_TIME"
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
else
    # Error de conexión
    cat << EOF
{
    "status": "error",
    "message": "Error de conexión a MySQL RDS",
    "database_info": {
        "host": "$DB_HOST",
        "port": "$DB_PORT",
        "database": "$DB_NAME",
        "user": "$DB_USER"
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
fi
