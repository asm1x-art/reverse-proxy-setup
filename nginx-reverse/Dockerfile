# --------------------------------------------------------------------------------
# 1. Базовый образ: OpenResty на Alpine (минимальный и производительный)
# --------------------------------------------------------------------------------
FROM openresty/openresty:1.21.4.1-0-alpine

# --------------------------------------------------------------------------------
# 2. Устанавливаем только необходимое для lua модулей
# --------------------------------------------------------------------------------
RUN apk add --no-cache \
        gettext \
        git \
    && mkdir -p /tmp/lua-libs \
    \
    && git clone --depth=1 https://github.com/ledgetech/lua-resty-http.git /tmp/lua-libs/lua-resty-http \
    && git clone --depth=1 https://github.com/openresty/lua-resty-redis.git /tmp/lua-libs/lua-resty-redis \
    \
    && mkdir -p /usr/local/openresty/lualib/resty \
    \
    && find /tmp/lua-libs/lua-resty-http/lib -name "*.lua" -exec cp {} /usr/local/openresty/lualib/resty/ \; \
    && cp /tmp/lua-libs/lua-resty-redis/lib/resty/redis.lua /usr/local/openresty/lualib/resty/ \
    \
    && rm -rf /tmp/lua-libs \
    && apk del git

# --------------------------------------------------------------------------------
# Убираем сложности с entrypoint - будем использовать только volumes
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# 5. Оптимальные переменные окружения для OpenResty под высокую нагрузку
# --------------------------------------------------------------------------------
# Позволяем Nginx автоматически настроить число воркеров под количество CPU
ENV WORKER_PROCESSES auto

# --------------------------------------------------------------------------------
# 6. Экспонируем стандартные HTTP/HTTPS (если вы работаете не в host-режиме)
# --------------------------------------------------------------------------------
EXPOSE 80 443

# --------------------------------------------------------------------------------
# 7. Просто запускаем openresty без entrypoint
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# 8. Команда по умолчанию
# --------------------------------------------------------------------------------
CMD ["openresty", "-g", "daemon off;"]