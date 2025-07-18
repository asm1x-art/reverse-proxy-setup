#!/bin/bash

# Использование: bash server-setup.sh your-domain.com your-email@example.com [project_name]

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Функции для красивого вывода
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

log_cmd() {
    echo -e "${CYAN}[RUN]${NC} $1"
}

log_skip() {
    echo -e "${CYAN}[SKIP]${NC} $1"
}

# Проверяем параметры
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    log_error "Использование: $0 <domain> <email> [project_name]"
    log_error "Пример: $0 astrum.ac admin@astrum.ac astrum"
    log_error "Если project_name не указан, будет запрошен интерактивно"
    exit 1
fi

DOMAIN=$1
EMAIL=$2
PROJECT_NAME=$3

# Проверяем, что скрипт запущен от root
if [ "$EUID" -ne 0 ]; then
    log_error "Скрипт должен быть запущен от root"
    log_info "Запустите: sudo bash $0 $DOMAIN $EMAIL"
    exit 1
fi

# Определяем пользователя
REAL_USER=${SUDO_USER:-$(who am i | awk '{print $1}')}
if [ -z "$REAL_USER" ]; then
    log_error "Не удалось определить пользователя"
    exit 1
fi

REAL_HOME=$(eval echo ~$REAL_USER)

# Если имя проекта не передано, запрашиваем его
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${CYAN}Введите имя проекта (будет использоваться в командах и директориях):${NC}"
    read -p "Имя проекта [astrum]: " PROJECT_NAME
    PROJECT_NAME=${PROJECT_NAME:-astrum}
fi

# Проверяем, что имя проекта содержит только допустимые символы
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_error "Имя проекта может содержать только буквы, цифры, дефисы и подчеркивания"
    exit 1
fi

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    🚀 НАСТРОЙКА СЕРВЕРА                     ║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC} Проект: ${CYAN}$PROJECT_NAME${NC}"
echo -e "${PURPLE}║${NC} Домен: ${CYAN}$DOMAIN${NC}"
echo -e "${PURPLE}║${NC} Email: ${CYAN}$EMAIL${NC}"
echo -e "${PURPLE}║${NC} Пользователь: ${CYAN}$REAL_USER${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Функция проверки версии пакета
check_version() {
    local package=$1
    local required_version=$2
    local current_version=""
    
    case $package in
        "docker")
            if command -v docker &> /dev/null; then
                current_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1)
            fi
            ;;
        "node")
            if command -v node &> /dev/null; then
                current_version=$(node --version 2>/dev/null | sed 's/v//')
            fi
            ;;
        "nvm")
            if [ -s "$REAL_HOME/.nvm/nvm.sh" ]; then
                current_version="installed"
            fi
            ;;
        "pm2")
            if sudo -u $REAL_USER bash -c "export NVM_DIR=\"$REAL_HOME/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; command -v pm2" &> /dev/null; then
                current_version="installed"
            fi
            ;;
        "yarn")
            if sudo -u $REAL_USER bash -c "export NVM_DIR=\"$REAL_HOME/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; command -v yarn" &> /dev/null; then
                current_version="installed"
            fi
            ;;
        "certbot")
            if command -v certbot &> /dev/null; then
                current_version="installed"
            fi
            ;;
    esac
    
    if [ "$current_version" = "$required_version" ] || ([ "$required_version" = "installed" ] && [ -n "$current_version" ]); then
        return 0
    else
        return 1
    fi
}

# Опрос пользователя для настройки бэкенда
log_step "Настройка параметров бэкенда"
echo
echo -e "${CYAN}Введите параметры основного сервера:${NC}"

read -p "IP адрес основного сервера: " BACKEND_HOST
read -p "Порт основного сервера [80]: " BACKEND_PORT
BACKEND_PORT=${BACKEND_PORT:-80}

echo -e "${CYAN}Выберите протокол для подключения к основному серверу:${NC}"
echo -e "  ${YELLOW}1.${NC} HTTP"
echo -e "  ${YELLOW}2.${NC} HTTPS"
read -p "Введите номер (1 или 2) [1]: " BACKEND_SCHEME_CHOICE
BACKEND_SCHEME_CHOICE=${BACKEND_SCHEME_CHOICE:-1}

case $BACKEND_SCHEME_CHOICE in
    2)
        BACKEND_SCHEME="https"
        ;;
    *)
        BACKEND_SCHEME="http"
        ;;
esac

log_info "Настройки бэкенда:"
log_info "  Хост: $BACKEND_HOST"
log_info "  Порт: $BACKEND_PORT"  
log_info "  Протокол: $BACKEND_SCHEME"
log_info "  SSL Name: $DOMAIN"
echo

# 1. Обновляем систему
log_step "Обновление системы"
log_cmd "apt update && apt upgrade -y"
apt update && apt upgrade -y > /dev/null 2>&1
log_success "Система обновлена"

# 2. Устанавливаем базовые пакеты
log_step "Установка базовых пакетов"
log_cmd "apt install базовые утилиты..."
apt install -y \
    curl \
    wget \
    git \
    htop \
    nano \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    build-essential > /dev/null 2>&1

log_success "Базовые пакеты установлены"

# 3. Настройка файрвола
log_step "Настройка файрвола"
log_cmd "ufw настройка портов..."
ufw --force reset > /dev/null 2>&1
ufw default deny incoming > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1
ufw allow ssh > /dev/null 2>&1
ufw allow 80/tcp > /dev/null 2>&1
ufw allow 443/tcp > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
log_success "Файрвол настроен (SSH, HTTP, HTTPS)"

# 4. Устанавливаем Docker
log_step "Проверка и установка Docker"
if check_version "docker" "installed"; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    log_skip "Docker уже установлен (версия: $DOCKER_VERSION)"
else
    log_cmd "Удаление старых версий..."
    apt remove -y docker docker-engine docker.io containerd runc > /dev/null 2>&1 || true

    log_cmd "Добавление Docker GPG ключа..."
    # Всегда обновляем ключ для актуальности
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    log_cmd "Добавление Docker репозитория..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    log_cmd "Установка Docker..."
    apt update > /dev/null 2>&1
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

    log_cmd "Запуск Docker..."
    systemctl enable docker > /dev/null 2>&1
    systemctl start docker > /dev/null 2>&1

    log_success "Docker установлен и запущен"
fi

# Добавляем пользователя в группу docker
usermod -aG docker $REAL_USER
log_info "Пользователь $REAL_USER добавлен в группу docker"

# Проверяем версии
DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
log_info "Docker: $DOCKER_VERSION, Compose: $COMPOSE_VERSION"

# 5. Устанавливаем NVM и Node.js
log_step "Проверка и установка NVM и Node.js"
TARGET_NODE_VERSION="22.17.0"

if check_version "nvm" "installed" && check_version "node" "$TARGET_NODE_VERSION"; then
    log_skip "NVM и Node.js $TARGET_NODE_VERSION уже установлены"
else
    if ! check_version "nvm" "installed"; then
        log_cmd "Установка NVM..."
        sudo -u $REAL_USER bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
        sleep 2
    else
        log_skip "NVM уже установлен"
    fi

    if ! check_version "node" "$TARGET_NODE_VERSION"; then
        log_cmd "Установка Node.js $TARGET_NODE_VERSION..."
        sudo -u $REAL_USER bash -c "
        export NVM_DIR=\"$REAL_HOME/.nvm\"
        [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
        nvm install $TARGET_NODE_VERSION
        nvm use $TARGET_NODE_VERSION
        nvm alias default $TARGET_NODE_VERSION
        "
    else
        log_skip "Node.js $TARGET_NODE_VERSION уже установлен"
    fi
fi

# Проверяем и устанавливаем глобальные пакеты
PACKAGES_TO_INSTALL=()

if ! check_version "pm2" "installed"; then
    PACKAGES_TO_INSTALL+=("pm2")
fi

if ! check_version "yarn" "installed"; then
    PACKAGES_TO_INSTALL+=("yarn")
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    log_cmd "Установка глобальных пакетов: ${PACKAGES_TO_INSTALL[*]}"
    sudo -u $REAL_USER bash -c "
    export NVM_DIR=\"$REAL_HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
    npm install -g ${PACKAGES_TO_INSTALL[*]}
    "
else
    log_skip "PM2 и Yarn уже установлены"
fi

log_success "NVM, Node.js $TARGET_NODE_VERSION, PM2 и Yarn готовы к работе"

# 6. Устанавливаем Certbot
log_step "Проверка и установка Certbot"
if check_version "certbot" "installed"; then
    log_skip "Certbot уже установлен"
else
    log_cmd "snap install certbot..."
    snap install core > /dev/null 2>&1
    snap refresh core > /dev/null 2>&1
    snap install --classic certbot > /dev/null 2>&1
    ln -sf /snap/bin/certbot /usr/bin/certbot
    log_success "Certbot установлен"
fi

# 7. Получаем SSL сертификат
log_step "Получение SSL сертификата"

# Проверяем существование сертификата
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
if [ -d "$CERT_PATH" ] && [ -f "$CERT_PATH/fullchain.pem" ] && [ -f "$CERT_PATH/privkey.pem" ]; then
    # Проверяем срок действия сертификата
    CERT_EXPIRY=$(openssl x509 -enddate -noout -in "$CERT_PATH/fullchain.pem" | cut -d= -f2)
    CERT_EXPIRY_TIMESTAMP=$(date -d "$CERT_EXPIRY" +%s)
    CURRENT_TIMESTAMP=$(date +%s)
    DAYS_UNTIL_EXPIRY=$(( (CERT_EXPIRY_TIMESTAMP - CURRENT_TIMESTAMP) / 86400 ))
    
    if [ $DAYS_UNTIL_EXPIRY -gt 30 ]; then
        log_skip "SSL сертификат для $DOMAIN уже существует и действителен еще $DAYS_UNTIL_EXPIRY дней"
        CERT_EXISTS=true
    else
        log_warning "SSL сертификат истекает через $DAYS_UNTIL_EXPIRY дней, получаем новый"
        CERT_EXISTS=false
    fi
else
    CERT_EXISTS=false
fi

if [ "$CERT_EXISTS" = false ]; then
    echo -e "${CYAN}Выберите тип сертификата:${NC}"
    echo -e "  ${YELLOW}1.${NC} Обычный сертификат (только $DOMAIN и www.$DOMAIN)"
    echo -e "  ${YELLOW}2.${NC} Wildcard сертификат (*.$DOMAIN - все поддомены)"
    echo

    read -p "Введите номер (1 или 2): " CERT_TYPE

    case $CERT_TYPE in
        1)
            log_info "Получаем обычный сертификат для $DOMAIN"
            
            # Показываем текущий IP сервера
            SERVER_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || echo "не удалось определить")
            log_info "IP этого сервера: $SERVER_IP"
            echo
            
            log_warning "Убедитесь что $DOMAIN указывает на IP $SERVER_IP"
            read -p "Нажмите Enter если DNS настроен, или Ctrl+C для отмены..."
            
            log_cmd "certbot standalone для $DOMAIN..."
            
            # Останавливаем процессы на портах 80/443
            fuser -k 80/tcp > /dev/null 2>&1 || true
            fuser -k 443/tcp > /dev/null 2>&1 || true
            
            certbot certonly \
                --standalone \
                --email $EMAIL \
                --agree-tos \
                --no-eff-email \
                -d $DOMAIN \
                -d www.$DOMAIN
            ;;
            
        2)
            log_info "Получаем wildcard сертификат для *.$DOMAIN"
            log_warning "Потребуется добавить TXT записи в DNS!"
            echo
            
            log_info "Процесс:"
            log_info "1. Certbot покажет TXT запись для добавления в DNS"
            log_info "2. Добавьте запись _acme-challenge.$DOMAIN в вашей DNS панели"
            log_info "3. Подождите распространения DNS (до 10 минут)"
            log_info "4. Нажмите Enter в certbot для проверки"
            echo
            
            read -p "Готовы продолжить? (y/N): " READY
            if [[ ! $READY =~ ^[Yy]$ ]]; then
                log_warning "Отменено пользователем"
                log_info "Можете запустить позже: certbot certonly --manual --preferred-challenges dns -d $DOMAIN -d '*.$DOMAIN'"
                exit 0
            fi
            
            log_cmd "certbot DNS challenge для *.$DOMAIN..."
            
            certbot certonly \
                --manual \
                --preferred-challenges dns \
                --email $EMAIL \
                --agree-tos \
                --no-eff-email \
                -d $DOMAIN \
                -d "*.$DOMAIN"
            ;;
            
        *)
            log_error "Неверный выбор. Запустите скрипт заново."
            exit 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        log_success "SSL сертификат получен для $DOMAIN"
        
        # Показываем что получили
        if [ "$CERT_TYPE" = "1" ]; then
            log_info "Сертификат работает для: $DOMAIN, www.$DOMAIN"
        else
            log_info "Сертификат работает для: $DOMAIN, *.$DOMAIN (все поддомены)"
        fi
    else
        log_error "Не удалось получить SSL сертификат"
        
        if [ "$CERT_TYPE" = "1" ]; then
            log_warning "Проверьте что $DOMAIN указывает на этот сервер"
        else
            log_warning "Проверьте что DNS TXT записи добавлены правильно"
            log_info "Запись должна быть: _acme-challenge.$DOMAIN"
        fi
        
        log_info "Можете попробовать получить сертификат позже вручную"
        exit 1
    fi
fi

# 8. Создаем директории для проектов
log_step "Создание директорий проектов"
log_cmd "mkdir -p /opt/$PROJECT_NAME /opt/$PROJECT_NAME-api"
mkdir -p "/opt/$PROJECT_NAME" "/opt/$PROJECT_NAME-api"
chown -R $REAL_USER:$REAL_USER "/opt/$PROJECT_NAME" "/opt/$PROJECT_NAME-api"
log_success "Директории /opt/$PROJECT_NAME и /opt/$PROJECT_NAME-api созданы"

# 9. Копируем проекты и настраиваем их
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Nginx reverse proxy
if [ -d "$SCRIPT_DIR/nginx-reverse" ]; then
    log_step "Настройка Nginx reverse proxy"
    log_cmd "Копирование nginx-reverse в /opt/$PROJECT_NAME"
    
    # Очищаем директорию если она не пустая
    if [ "$(ls -A /opt/$PROJECT_NAME 2>/dev/null)" ]; then
        log_cmd "Очистка существующих файлов в /opt/$PROJECT_NAME"
        rm -rf "/opt/$PROJECT_NAME/"*
    fi
    
    # Копируем файлы
    cp -r "$SCRIPT_DIR/nginx-reverse/"* "/opt/$PROJECT_NAME/"
    chown -R $REAL_USER:$REAL_USER "/opt/$PROJECT_NAME"
    
    # Проверяем наличие docker-compose файлов и обновляем их
    log_cmd "Обновление конфигурации docker-compose"
    cd "/opt/$PROJECT_NAME"
    
    # Ищем файл docker-compose
    COMPOSE_FILE=""
    if [ -f "docker-compose.yml" ]; then
        COMPOSE_FILE="docker-compose.yml"
    elif [ -f "docker-compose.yaml" ]; then
        COMPOSE_FILE="docker-compose.yaml"
    else
        log_error "Файл docker-compose.yml или docker-compose.yaml не найден в nginx-reverse"
        log_warning "Пропускаем настройку reverse proxy"
    fi
    
    if [ -n "$COMPOSE_FILE" ]; then
        # Создаем резервную копию
        cp "$COMPOSE_FILE" "$COMPOSE_FILE.backup"
        
        # Обновляем конфигурацию
        sed -e "s|BACKEND_HOST=.*|BACKEND_HOST=$BACKEND_HOST|" \
            -e "s|BACKEND_PORT=.*|BACKEND_PORT=$BACKEND_PORT|" \
            -e "s|BACKEND_SCHEME=.*|BACKEND_SCHEME=$BACKEND_SCHEME|" \
            -e "s|BACKEND_SSL_NAME=.*|BACKEND_SSL_NAME=$DOMAIN|" \
            -e "s|/etc/letsencrypt/live/[^/]*/|/etc/letsencrypt/live/$DOMAIN/|g" \
            "$COMPOSE_FILE" > "$COMPOSE_FILE.tmp" && mv "$COMPOSE_FILE.tmp" "$COMPOSE_FILE"
        
        log_cmd "Запуск $PROJECT_NAME start..."
        if sudo -u $REAL_USER bash -c "cd /opt/$PROJECT_NAME && docker compose up -d"; then
            log_success "Nginx reverse proxy запущен"
            
            # Ждем запуска ClickHouse
            log_cmd "Ожидание запуска ClickHouse..."
            sleep 10
            
            # Создаем базу и таблицу в ClickHouse
            log_cmd "Создание базы и таблицы в ClickHouse..."
            if docker exec -i clickhouse-server clickhouse-client --query "
            CREATE DATABASE IF NOT EXISTS logs_db;

            CREATE TABLE IF NOT EXISTS logs_db.request_logs
            (
                request_id String,
                user String,
                ip String,
                host String,
                uri String,
                method String,
                args String,
                body Nullable(String),
                time DateTime
            ) 
            ENGINE = MergeTree()
            ORDER BY (time, ip, host)
            PARTITION BY toYYYYMM(time)
            TTL time + INTERVAL 30 DAY;
            " 2>/dev/null; then
                log_success "ClickHouse база и таблица созданы"
            else
                log_warning "Не удалось создать таблицу ClickHouse сейчас, попробуйте позже командой:"
                log_info "$PROJECT_NAME-db create-table"
            fi
        else
            log_error "Не удалось запустить nginx reverse proxy"
            log_warning "Проверьте логи: docker compose logs -f"
        fi
    fi
else
    log_warning "Директория nginx-reverse не найдена рядом со скриптом"
fi

# API проект
if [ -d "$SCRIPT_DIR/nginx-api" ]; then
    log_step "Настройка API проекта"
    log_cmd "Копирование nginx-api в /opt/$PROJECT_NAME-api"
    
    # Очищаем директорию если она не пустая (кроме node_modules и dist)
    if [ "$(ls -A /opt/$PROJECT_NAME-api 2>/dev/null)" ]; then
        log_cmd "Очистка существующих файлов в /opt/$PROJECT_NAME-api (сохраняем node_modules и dist)"
        find "/opt/$PROJECT_NAME-api" -mindepth 1 -maxdepth 1 ! -name 'node_modules' ! -name 'dist' ! -name '.yarn' -exec rm -rf {} + 2>/dev/null || true
    fi
    
    # Копируем файлы
    cp -r "$SCRIPT_DIR/nginx-api/"* "/opt/$PROJECT_NAME-api/"
    chown -R $REAL_USER:$REAL_USER "/opt/$PROJECT_NAME-api"
    
    # Устанавливаем зависимости с обработкой ошибок
    log_cmd "Установка зависимостей..."
    if sudo -u $REAL_USER bash -c "
    export NVM_DIR=\"$REAL_HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
    cd /opt/$PROJECT_NAME-api
    yarn install
    " 2>/dev/null; then
        log_success "Зависимости установлены"
        
        # Сборка проекта с обработкой ошибок
        log_cmd "Сборка проекта..."
        if sudo -u $REAL_USER bash -c "
        export NVM_DIR=\"$REAL_HOME/.nvm\"
        [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
        cd /opt/$PROJECT_NAME-api
        yarn build
        " 2>/dev/null; then
            log_success "Проект собран"
            
            # Запуск API через PM2 с обработкой ошибок
            log_cmd "Запуск API через PM2..."
            if sudo -u $REAL_USER bash -c "
            export NVM_DIR=\"$REAL_HOME/.nvm\"
            [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
            cd /opt/$PROJECT_NAME-api
            pm2 start ecosystem.config.js 2>/dev/null || pm2 start --name $PROJECT_NAME-api yarn -- start --host 127.0.0.1 --port 15000
            pm2 save
            " 2>/dev/null; then
                log_success "API запущен через PM2"
                
                # Настраиваем автозапуск PM2
                sudo -u $REAL_USER bash -c "
                export NVM_DIR=\"$REAL_HOME/.nvm\"
                [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
                pm2 startup
                " 2>/dev/null || log_warning "Не удалось настроить автозапуск PM2"
                
                log_success "API проект настроен и запущен на 127.0.0.1:15000"
            else
                log_error "Не удалось запустить API через PM2"
                log_warning "API сервис не критичен, продолжаем установку"
                log_info "Можете запустить API позже командой: $PROJECT_NAME-api start"
            fi
        else
            log_error "Ошибка при сборке API проекта"
            log_warning "API сервис не критичен, продолжаем установку"
            log_info "Проверьте код в /opt/$PROJECT_NAME-api и соберите вручную: $PROJECT_NAME-api build"
        fi
    else
        log_error "Ошибка при установке зависимостей API"
        log_warning "API сервис не критичен, продолжаем установку"
        log_info "Проверьте package.json в /opt/$PROJECT_NAME-api"
    fi
else
    log_warning "Директория nginx-api не найдена рядом со скриптом"
fi

# 10. Создаем полезные команды
log_step "Создание полезных команд"

# Команда для управления проектом
cat > /usr/local/bin/$PROJECT_NAME << EOF
#!/bin/bash
cd /opt/$PROJECT_NAME
case "\$1" in
    start)   docker compose up -d ;;
    stop)    docker compose down ;;
    restart) docker compose restart ;;
    logs)    docker compose logs -f \${2:-} ;;
    status)  docker compose ps ;;
    *)       echo "Использование: $PROJECT_NAME {start|stop|restart|logs|status}" ;;
esac
EOF

chmod +x /usr/local/bin/$PROJECT_NAME

# Команда для управления API
cat > /usr/local/bin/$PROJECT_NAME-api << EOF
#!/bin/bash
export NVM_DIR="$REAL_HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
cd /opt/$PROJECT_NAME-api
case "\$1" in
    start)   sudo -u $REAL_USER pm2 start $PROJECT_NAME-api ;;
    stop)    sudo -u $REAL_USER pm2 stop $PROJECT_NAME-api ;;
    restart) sudo -u $REAL_USER pm2 restart $PROJECT_NAME-api ;;
    logs)    sudo -u $REAL_USER pm2 logs $PROJECT_NAME-api ;;
    status)  sudo -u $REAL_USER pm2 status ;;
    build)   sudo -u $REAL_USER bash -c "cd /opt/$PROJECT_NAME-api && yarn build" ;;
    *)       echo "Использование: $PROJECT_NAME-api {start|stop|restart|logs|status|build}" ;;
esac
EOF

chmod +x /usr/local/bin/$PROJECT_NAME-api

# Команда для управления ClickHouse
cat > /usr/local/bin/$PROJECT_NAME-db << 'EOF'
#!/bin/bash
case "$1" in
    logs)    docker exec -it clickhouse-server clickhouse-client --query "SELECT * FROM logs_db.request_logs ORDER BY time DESC LIMIT 100" ;;
    status)  docker exec -it clickhouse-server clickhouse-client --query "SELECT count() as total_requests FROM logs_db.request_logs" ;;
    shell)   docker exec -it clickhouse-server clickhouse-client ;;
    create-table) 
        docker exec -i clickhouse-server clickhouse-client --query "
        CREATE DATABASE IF NOT EXISTS logs_db;
        CREATE TABLE IF NOT EXISTS logs_db.request_logs
        (
            request_id String,
            user String,
            ip String,
            host String,
            uri String,
            method String,
            args String,
            body Nullable(String),
            time DateTime
        ) 
        ENGINE = MergeTree()
        ORDER BY (time, ip, host)
        PARTITION BY toYYYYMM(time)
        TTL time + INTERVAL 30 DAY;"
        echo "База и таблица созданы"
        ;;
    *)       echo "Использование: $PROJECT_NAME-db {logs|status|shell|create-table}" ;;
esac
EOF

chmod +x /usr/local/bin/$PROJECT_NAME-db

log_success "Команды '$PROJECT_NAME', '$PROJECT_NAME-api' и '$PROJECT_NAME-db' созданы"

# Финальный вывод
echo
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ НАСТРОЙКА ЗАВЕРШЕНА                   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

log_success "Система обновлена"
log_success "Docker установлен ($DOCKER_VERSION)"
log_success "NVM, Node.js $TARGET_NODE_VERSION, PM2 и Yarn установлены"
log_success "Certbot установлен"
log_success "SSL сертификат получен для $DOMAIN"
log_success "Файрвол настроен"

# Проверяем статус компонентов
if [ -d "/opt/$PROJECT_NAME" ] && [ -n "$(docker ps -q)" ]; then
    log_success "Nginx reverse proxy настроен и запущен"
else
    log_warning "Nginx reverse proxy настроен, но возможны проблемы с запуском"
fi

if pgrep -f "$PROJECT_NAME-api" > /dev/null 2>&1; then
    log_success "API проект настроен и запущен на 127.0.0.1:15000"
else
    log_warning "API проект настроен, но не запущен (не критично)"
fi

if docker ps | grep -q clickhouse; then
    log_success "ClickHouse настроен с базой logs_db"
else
    log_warning "ClickHouse настроен, но возможны проблемы с подключением"
fi

echo
echo -e "${CYAN}🔧 Полезные команды:${NC}"
echo -e "  ${YELLOW}$PROJECT_NAME start${NC}       - запустить nginx reverse proxy"
echo -e "  ${YELLOW}$PROJECT_NAME stop${NC}        - остановить nginx reverse proxy"
echo -e "  ${YELLOW}$PROJECT_NAME restart${NC}     - перезапустить nginx reverse proxy"
echo -e "  ${YELLOW}$PROJECT_NAME logs${NC}        - показать логи nginx"
echo -e "  ${YELLOW}$PROJECT_NAME status${NC}      - статус контейнеров"
echo
echo -e "  ${YELLOW}$PROJECT_NAME-api start${NC}   - запустить API"
echo -e "  ${YELLOW}$PROJECT_NAME-api stop${NC}    - остановить API"
echo -e "  ${YELLOW}$PROJECT_NAME-api restart${NC} - перезапустить API"
echo -e "  ${YELLOW}$PROJECT_NAME-api logs${NC}    - показать логи API"
echo -e "  ${YELLOW}$PROJECT_NAME-api status${NC}  - статус PM2 процессов"
echo -e "  ${YELLOW}$PROJECT_NAME-api build${NC}   - пересобрать API"
echo
echo -e "  ${YELLOW}$PROJECT_NAME-db logs${NC}     - последние 100 запросов"
echo -e "  ${YELLOW}$PROJECT_NAME-db status${NC}   - количество запросов в базе"
echo -e "  ${YELLOW}$PROJECT_NAME-db shell${NC}    - подключиться к ClickHouse"
echo -e "  ${YELLOW}$PROJECT_NAME-db create-table${NC} - создать таблицу заново"

echo
echo -e "${CYAN}📝 Конфигурация:${NC}"
echo -e "  ${BLUE}Бэкенд:${NC} $BACKEND_SCHEME://$BACKEND_HOST:$BACKEND_PORT"
echo -e "  ${BLUE}SSL Name:${NC} $DOMAIN"
echo -e "  ${BLUE}API:${NC} http://127.0.0.1:15000"
echo -e "  ${BLUE}Сертификаты:${NC} /etc/letsencrypt/live/$DOMAIN/"
echo -e "  ${BLUE}Проекты:${NC} /opt/$PROJECT_NAME (nginx), /opt/$PROJECT_NAME-api (API)"

echo
echo -e "${CYAN}📝 Следующие шаги:${NC}"
if [ "$CERT_TYPE" = "1" ]; then
    echo -e "  ${BLUE}1.${NC} Проверьте: ${CYAN}https://$DOMAIN${NC} и ${CYAN}https://www.$DOMAIN${NC}"
else
    echo -e "  ${BLUE}1.${NC} Проверьте: ${CYAN}https://$DOMAIN${NC}, ${CYAN}https://api.$DOMAIN${NC}, ${CYAN}https://dev.$DOMAIN${NC}"
fi
echo -e "  ${BLUE}2.${NC} API доступен на ${CYAN}http://127.0.0.1:15000${NC}"
echo -e "  ${BLUE}3.${NC} ClickHouse веб-интерфейс: ${CYAN}http://$(curl -s ifconfig.me):8123/play${NC}"

echo
echo -e "${CYAN}🚨 Диагностика проблем:${NC}"
echo -e "  ${BLUE}Проверить статус контейнеров:${NC} docker ps"
echo -e "  ${BLUE}Проверить логи nginx:${NC} $PROJECT_NAME logs nginx"
echo -e "  ${BLUE}Проверить логи API:${NC} $PROJECT_NAME-api logs"
echo -e "  ${BLUE}Проверить процессы PM2:${NC} $PROJECT_NAME-api status"
echo -e "  ${BLUE}Пересобрать API:${NC} $PROJECT_NAME-api build && $PROJECT_NAME-api restart"

echo
log_warning "Перелогиньтесь для применения группы docker"

echo
echo -e "${GREEN}🎉 Сервер готов к работе!${NC}"