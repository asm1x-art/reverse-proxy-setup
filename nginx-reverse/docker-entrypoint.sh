#!/bin/bash
set -e

echo "=== Ultimate OpenResty Entrypoint ==="

# Проверяем что все обязательные переменные заданы
echo "🔍 Checking required environment variables..."

check_var() {
    local var_name="$1"
    local var_value=$(eval echo \$$var_name)
    
    if [ -z "$var_value" ]; then
        echo "   ❌ ERROR: Environment variable $var_name is not set!"
        exit 1
    fi
    echo "   ✓ $var_name=$var_value"
}

check_var "BACKEND_HOST"
check_var "BACKEND_PORT"
check_var "BACKEND_SCHEME"
check_var "BACKEND_SSL_NAME"
check_var "TECH_API_HOST"
check_var "TECH_API_PORT"
check_var "REDIS_HOST"
check_var "REDIS_PORT"
check_var "CLICKHOUSE_HOST"
check_var "CLICKHOUSE_PORT"
check_var "CLICKHOUSE_USER"
check_var "CLICKHOUSE_PASSWORD"
check_var "CLICKHOUSE_DATABASE"
check_var "CLICKHOUSE_TABLE"
check_var "BATCH_SIZE"
check_var "BATCH_INTERVAL"
check_var "RPS_LIMIT"

echo "✅ All required variables are set"

# Генерируем конфиги из templates
echo "📝 Processing templates..."

if [ -f "/etc/nginx/conf.d/openresty_proxy.conf.template" ]; then
    echo "   ✓ Processing nginx template..."
    envsubst '${BACKEND_HOST} ${BACKEND_PORT} ${BACKEND_SCHEME} ${BACKEND_SSL_NAME} ${TECH_API_HOST} ${TECH_API_PORT}' < /etc/nginx/conf.d/openresty_proxy.conf.template > /etc/nginx/conf.d/openresty_proxy.conf
    echo "   ✓ Nginx config generated"
else
    echo "   ⚠ No nginx template found, using existing config"
fi

if [ -f "/etc/nginx/lua/access_control.lua.template" ]; then
    echo "   ✓ Processing lua template..."
    envsubst '${REDIS_HOST} ${REDIS_PORT} ${CLICKHOUSE_HOST} ${CLICKHOUSE_PORT} ${CLICKHOUSE_USER} ${CLICKHOUSE_PASSWORD} ${CLICKHOUSE_DATABASE} ${CLICKHOUSE_TABLE} ${BATCH_SIZE} ${BATCH_INTERVAL} ${RPS_LIMIT}' < /etc/nginx/lua/access_control.lua.template > /etc/nginx/lua/access_control.lua
    echo "   ✓ Lua script generated"
else
    echo "   ⚠ No lua template found, using existing script"
fi

# Проверяем что все файлы на месте
echo "🔍 Checking files..."

if [ ! -f "/etc/nginx/conf.d/openresty_proxy.conf" ]; then
    echo "   ❌ ERROR: nginx config not found"
    exit 1
fi

if [ ! -f "/etc/nginx/lua/access_control.lua" ]; then
    echo "   ❌ ERROR: lua script not found"
    exit 1
fi

if [ ! -f "/etc/nginx/certs/fullchain.pem" ]; then
    echo "   ❌ ERROR: SSL certificate not found"
    exit 1
fi

echo "   ✅ All files found"

# Проверяем синтаксис nginx
echo "🧪 Testing nginx configuration..."
openresty -t

echo "✅ Configuration is valid"
echo "🚀 Starting OpenResty..."
exec "$@"