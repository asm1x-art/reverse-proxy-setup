# 🚀 Автоматическая настройка сервера

Универсальный скрипт для быстрого развертывания веб-сервера с reverse proxy, API и мониторингом логов.

## 📋 Что делает скрипт

### 🔧 Основные компоненты

- **Nginx Reverse Proxy** с OpenResty и Lua скриптами
- **SSL сертификаты** через Let's Encrypt (обычные или wildcard)
- **ClickHouse** для хранения логов запросов
- **Redis** для кеширования и rate limiting
- **Node.js API** с автозапуском через PM2
- **Docker** с автоматической настройкой

### 📊 Система мониторинга

- **Логирование всех запросов** в ClickHouse
- **Rate limiting** (настраиваемый лимит RPS)
- **Blacklist/Whitelist** управление через Redis
- **Пакетная отправка логов** для оптимизации производительности

### 🛡️ Безопасность

- **Файрвол UFW** с базовой конфигурацией
- **SSL/TLS** шифрование
- **Контроль доступа** по IP и доменам
- **Автоматическое обновление** системы

## 🎯 Требования

- **Ubuntu 20.04+** или **Debian 11+**
- **Root доступ** для установки пакетов
- **Настроенные DNS записи** для вашего домена
- **Открытые порты** 80 и 443

## 📁 Структура проекта

Рядом со скриптом должны лежать директории:

```
├── server-setup.sh          # основной скрипт
├── nginx-reverse/           # конфигурация reverse proxy
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── nginx/
│       ├── conf.d/
│       └── lua/
└── nginx-api/              # ваш API проект
    ├── package.json
    ├── src/
    └── ...
```

## 🚀 Быстрый старт

### 1. Подготовка

```bash
# Клонируйте репозиторий
git clone <your-repo-url>
cd <project-folder>

# Убедитесь что DNS настроен
nslookup your-domain.com
```

### 2. Запуск с параметрами

```bash
# Базовый запуск (имя проекта будет запрошено)
sudo bash server-setup.sh your-domain.com admin@your-domain.com

# С указанием имени проекта
sudo bash server-setup.sh your-domain.com admin@your-domain.com myproject
```

### 3. Интерактивная настройка

Скрипт запросит:

- **Имя проекта** (если не указано в параметрах)
- **IP адрес основного сервера** (backend)
- **Порт основного сервера** (по умолчанию 80)
- **Протокол** (HTTP/HTTPS)
- **Тип SSL сертификата** (обычный/wildcard)

### 4. SSL сертификат

#### Обычный сертификат

- Автоматически получает сертификат для `domain.com` и `www.domain.com`
- Требует чтобы домен указывал на IP сервера

#### Wildcard сертификат

- Получает сертификат для `*.domain.com` (все поддомены)
- Требует ручного добавления TXT записи в DNS

## 🎮 Управление проектом

После установки доступны команды (где `PROJECT_NAME` - ваше имя проекта):

### Reverse Proxy

```bash
PROJECT_NAME start          # запустить nginx reverse proxy
PROJECT_NAME stop           # остановить nginx reverse proxy
PROJECT_NAME restart        # перезапустить nginx reverse proxy
PROJECT_NAME logs [service] # показать логи nginx
PROJECT_NAME status         # статус контейнеров
```

### API проект

```bash
PROJECT_NAME-api start      # запустить API
PROJECT_NAME-api stop       # остановить API
PROJECT_NAME-api restart    # перезапустить API
PROJECT_NAME-api logs       # показать логи API
PROJECT_NAME-api status     # статус PM2 процессов
PROJECT_NAME-api build      # пересобрать API
```

### База данных (ClickHouse)

```bash
PROJECT_NAME-db logs        # последние 100 запросов
PROJECT_NAME-db status      # количество запросов в базе
PROJECT_NAME-db shell       # подключиться к ClickHouse
PROJECT_NAME-db create-table # создать таблицу заново
```

## 📊 Примеры использования

### Просмотр логов

```bash
# Логи nginx
myproject logs openresty

# Логи API
myproject-api logs

# Последние запросы в базе
myproject-db logs
```

### Управление сервисами

```bash
# Перезапуск всего стека
myproject stop
myproject start

# Только API
myproject-api restart

# Пересборка API после изменений
myproject-api build
myproject-api restart
```

### Мониторинг

```bash
# Статус контейнеров
myproject status

# Статистика запросов
myproject-db status

# Веб-интерфейс ClickHouse
# http://YOUR_SERVER_IP:8123/play
```

## ⚙️ Конфигурация

### Основные пути

- **Проекты:** `/opt/PROJECT_NAME/` и `/opt/PROJECT_NAME-api/`
- **Сертификаты:** `/etc/letsencrypt/live/DOMAIN/`
- **Логи nginx:** `/opt/PROJECT_NAME/nginx/logs/`

### Порты по умолчанию

- **HTTP:** 80
- **HTTPS:** 443
- **API:** 127.0.0.1:15000
- **ClickHouse:** 8123, 9000
- **Redis:** 6379

### Environment переменные

В `docker-compose.yml` автоматически настраиваются:

- `BACKEND_HOST` - IP основного сервера
- `BACKEND_PORT` - порт основного сервера
- `BACKEND_SCHEME` - протокол (http/https)
- `BACKEND_SSL_NAME` - имя домена для SSL

<!-- ## ❗ Известные проблемы

> **TODO:** Заполните этот раздел на основе специфики вашего nginx-api проекта

### Проблема 1

**Описание:** Описание проблемы
**Решение:** Как исправить

### Проблема 2

**Описание:** Описание проблемы
**Решение:** Как исправить

### Проблема 3

**Описание:** Описание проблемы
**Решение:** Как исправить -->

## 🔒 Усиление безопасности

### 🔑 Настройка SSH ключей (обязательно перед отключением паролей!)

#### Windows (PowerShell/Command Prompt)

**Способ 1: Встроенный OpenSSH (Windows 10/11)**

```powershell
# Генерация ключа
ssh-keygen -t ed25519 -C "your-email@example.com"
# Нажмите Enter для сохранения в стандартном месте
# Установите passphrase для дополнительной безопасности

# Копирование ключа на сервер
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh user@your-server.com "cat >> ~/.ssh/authorized_keys"

# Или если уже настроен ssh-copy-id:
ssh-copy-id -i $env:USERPROFILE\.ssh\id_ed25519.pub user@your-server.com
```

**Способ 2: PuTTY**

```bash
# 1. Скачайте PuTTYgen с официального сайта
# 2. Откройте PuTTYgen
# 3. Выберите тип ключа: Ed25519 или RSA (4096 bits)
# 4. Нажмите "Generate" и двигайте мышью
# 5. Добавьте комментарий (ваш email)
# 6. Установите passphrase
# 7. Сохраните приватный ключ (.ppk файл)
# 8. Скопируйте публичный ключ из окна

# Добавление публичного ключа на сервер:
ssh user@your-server.com
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ВСТАВЬТЕ_ПУБЛИЧНЫЙ_КЛЮЧ_СЮДА" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

**Способ 3: Windows Subsystem for Linux (WSL)**

```bash
# В WSL терминале
ssh-keygen -t ed25519 -C "your-email@example.com"

# Копирование на сервер
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server.com
```

#### Linux/Ubuntu (хост машина)

```bash
# Генерация SSH ключа
ssh-keygen -t ed25519 -C "your-email@example.com"
# Или для старых систем:
# ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Добавление ключа в ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Копирование ключа на сервер
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server.com

# Или вручную:
cat ~/.ssh/id_ed25519.pub | ssh user@your-server.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

#### macOS

```bash
# Генерация SSH ключа
ssh-keygen -t ed25519 -C "your-email@example.com"

# Добавление в Keychain (для автоматической загрузки)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Настройка автозагрузки
echo "Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config

# Копирование на сервер
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server.com

# Или через pbcopy:
pbcopy < ~/.ssh/id_ed25519.pub
# Затем вставьте в ~/.ssh/authorized_keys на сервере
```

#### Android (Termux)

```bash
# Установка OpenSSH в Termux
pkg update && pkg install openssh

# Генерация ключа
ssh-keygen -t ed25519 -C "your-email@example.com"

# Показать публичный ключ для копирования
cat ~/.ssh/id_ed25519.pub

# Добавить на сервер вручную через веб-интерфейс или другое подключение
```

#### iOS (приложения Termius, Blink Shell)

**Termius:**

1. Откройте Termius
2. Settings → Keys → Add Key
3. Выберите "Generate Key"
4. Тип: Ed25519, добавьте комментарий
5. Сохраните и экспортируйте публичный ключ
6. Добавьте на сервер через веб-интерфейс

**Blink Shell:**

```bash
# В Blink Shell
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub

# Скопируйте и добавьте на сервер
```

### 🛡️ Проверка и тестирование SSH ключей

```bash
# Тест подключения с отладкой
ssh -v user@your-server.com

# Проверка каких ключей загружены в ssh-agent
ssh-add -l

# Тест конкретного ключа
ssh -i ~/.ssh/id_ed25519 user@your-server.com

# Проверка authorized_keys на сервере
cat ~/.ssh/authorized_keys
```

### 🔐 Настройка сервера для ключей

```bash
# На сервере: создание директории SSH (если не существует)
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Создание файла authorized_keys
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Проверка прав доступа
ls -la ~/.ssh/
# Должно быть:
# drwx------ 2 user user 4096 дата .
# -rw------- 1 user user  xxx дата authorized_keys
```

### 🚫 Отключение парольной аутентификации (только после настройки ключей!)

```bash
# ВАЖНО: Сначала убедитесь что можете подключиться по ключу!
ssh -i ~/.ssh/id_ed25519 user@your-server.com

# Только после успешного подключения выполняйте:
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Дополнительная безопасность
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config

# Перезапуск SSH
sudo systemctl restart sshd

# Тест подключения в новом терминале (НЕ закрывайте текущую сессию!)
ssh user@your-server.com
```

### ⚠️ Важные моменты безопасности

1. **Всегда тестируйте подключение по ключу ПЕРЕД отключением паролей**
2. **Держите открытой одну SSH сессию при изменении настроек**
3. **Используйте passphrase для дополнительной защиты ключей**
4. **Регулярно меняйте ключи (раз в год)**
5. **Не используйте один ключ для всех серверов**

### 📱 Управление ключами

```bash
# Генерация нового ключа для конкретного сервера
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_myserver -C "myserver-key"

# Настройка ~/.ssh/config для удобства
cat >> ~/.ssh/config << EOF
Host myserver
    HostName your-server.com
    User username
    IdentityFile ~/.ssh/id_ed25519_myserver
    IdentitiesOnly yes
EOF

# Подключение
ssh myserver
```

### 1. Настройка SSH (после настройки ключей)

```bash
# Отключить root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Отключить парольную аутентификацию (только ключи)
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Изменить порт SSH
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Применить изменения
sudo systemctl restart sshd

# Обновить файрвол для нового порта
sudo ufw delete allow ssh
sudo ufw allow 2222/tcp
```

### 2. Дополнительная защита файрвола

```bash
# Ограничить SSH подключения (максимум 6 попыток в 30 секунд)
sudo ufw limit ssh

# Заблокировать входящие пинги
sudo echo 'net.ipv4.icmp_echo_ignore_all = 1' >> /etc/sysctl.conf

# Защита от SYN flood атак
sudo echo 'net.ipv4.tcp_syncookies = 1' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_syn_retries = 2' >> /etc/sysctl.conf

# Применить настройки
sudo sysctl -p
```

### 3. Установка Fail2Ban

```bash
# Установка
sudo apt update
sudo apt install fail2ban -y

# Настройка для SSH
sudo tee /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /opt/*/nginx/logs/error.log
maxretry = 3
EOF

# Запуск
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Проверка статуса
sudo fail2ban-client status
```

### 4. Автоматические обновления безопасности

```bash
# Установка unattended-upgrades
sudo apt install unattended-upgrades -y

# Настройка автообновлений
echo 'Unattended-Upgrade::Automatic-Reboot "false";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades
echo 'Unattended-Upgrade::Mail "admin@your-domain.com";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades

# Включение
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 5. Мониторинг системы

```bash
# Установка системы мониторинга
sudo apt install htop iotop nethogs -y

# Настройка логирования подозрительной активности
sudo tee /etc/rsyslog.d/50-suspicious.conf << EOF
# Логирование подозрительной активности
auth,authpriv.*                 /var/log/auth.log
*.info;mail.none;authpriv.none;cron.none /var/log/messages
EOF

sudo systemctl restart rsyslog
```

### 6. Резервное копирование

```bash
# Создание скрипта бэкапа
sudo tee /usr/local/bin/backup-project << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
PROJECT_NAME="YOUR_PROJECT_NAME"

mkdir -p $BACKUP_DIR

# Бэкап конфигураций
tar -czf $BACKUP_DIR/configs_$DATE.tar.gz /opt/$PROJECT_NAME /opt/$PROJECT_NAME-api

# Бэкап SSL сертификатов
tar -czf $BACKUP_DIR/ssl_$DATE.tar.gz /etc/letsencrypt

# Бэкап базы данных ClickHouse
docker exec clickhouse-server clickhouse-client --query "BACKUP DATABASE logs_db TO File('/backups/clickhouse_$DATE.backup')"

# Удаление старых бэкапов (старше 30 дней)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
find $BACKUP_DIR -name "*.backup" -mtime +30 -delete

echo "Backup completed: $DATE"
EOF

sudo chmod +x /usr/local/bin/backup-project

# Добавление в cron (ежедневно в 3:00)
echo "0 3 * * * /usr/local/bin/backup-project" | sudo crontab -
```

### 7. Мониторинг сетевых подключений

```bash
# Установка netstat для мониторинга
sudo apt install net-tools -y

# Скрипт для мониторинга подозрительной активности
sudo tee /usr/local/bin/monitor-connections << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/connections.log"

# Логирование текущих подключений
echo "$(date): Active connections" >> $LOG_FILE
netstat -tuln >> $LOG_FILE
echo "---" >> $LOG_FILE

# Проверка на подозрительные порты
netstat -tuln | grep -E ":(1234|4444|5555|6666|7777|8888|9999)" && {
    echo "$(date): ALERT - Suspicious ports detected!" >> $LOG_FILE
    # Отправка уведомления (настройте под свою почту)
    # mail -s "Security Alert" admin@your-domain.com < $LOG_FILE
}
EOF

sudo chmod +x /usr/local/bin/monitor-connections

# Запуск каждые 15 минут
echo "*/15 * * * * /usr/local/bin/monitor-connections" | sudo crontab -
```

## 🗓️ Roadmap / Планы развития

### 🔥 В разработке

- [ ] **Автопродление SSL сертификатов** - настройка cron задач для Let's Encrypt
- [ ] **Web UI для управления** - веб-интерфейс для управления проектом
- [ ] **Интеграция с Telegram** - уведомления о статусе сервера
- [ ] **Docker Swarm поддержка** - масштабирование на несколько серверов

### 🎯 Запланировано

- [ ] **Автоматический бэкап в облако** (AWS S3, Google Cloud, Yandex Object Storage)
- [ ] **Мониторинг производительности** - Grafana + Prometheus интеграция
- [ ] **CI/CD pipeline** - автодеплой через GitHub Actions
- [ ] **Multi-domain поддержка** - несколько доменов на одном сервере
- [ ] **Load balancer** - распределение нагрузки между серверами
- [ ] **WAF (Web Application Firewall)** - дополнительная защита от атак
- [ ] **Rate limiting по пользователям** - гибкие лимиты на основе JWT токенов
- [ ] **Логирование в Elasticsearch** - продвинутая аналитика логов

### 🚀 Будущие возможности

<!-- - [ ] **Kubernetes манифесты** - развертывание в K8s кластере -->
<!-- - [ ] **Multi-cloud deployment** - поддержка разных облачных провайдеров -->
<!-- - [ ] **Автоматическое масштабирование** - horizontal pod autoscaling -->
<!-- - [ ] **Service mesh интеграция** (Istio/Linkerd) -->
<!-- - [ ] **AI-powered security** - машинное обучение для детекции атак -->

- [ ] **Global CDN интеграция** - автоматическая настройка CloudFlare/AWS CloudFront
- [ ] **Blue-green deployments** - безопасные обновления без простоя

### ✅ Выполнено

- [x] **Базовая установка сервера** - автоматическая настройка Ubuntu/Debian
- [x] **SSL сертификаты** - Let's Encrypt с поддержкой wildcard
- [x] **Docker контейнеризация** - OpenResty + ClickHouse + Redis
- [x] **Логирование запросов** - пакетная отправка в ClickHouse
- [x] **Rate limiting** - защита от DDoS атак
- [x] **PM2 для API** - автозапуск и мониторинг Node.js приложений
- [x] **Файрвол настройка** - базовая защита UFW
- [x] **SSH ключи поддержка** - безопасная аутентификация
- [x] **Интерактивная настройка** - удобный интерфейс установки

<!-- ### 🆘 Нужна помощь

- [ ] **Тестирование на CentOS/RHEL** - адаптация скрипта для Red Hat систем
- [ ] **ARM64 поддержка** - оптимизация для Apple Silicon и Raspberry Pi
- [ ] **Windows Server поддержка** - портирование на Windows контейнеры
- [ ] **Документация переводы** - локализация на другие языки -->

### 💡 Идеи от сообщества

> Есть идея? Создайте [Issue](https://github.com/your-repo/issues) или отправьте Pull Request!

---

### 🎮 Как помочь проекту

#### 🐛 Нашли баг?

1. Проверьте [существующие issues](https://github.com/your-repo/issues)
2. Создайте новый issue с:
   - Описанием проблемы
   - Шагами воспроизведения
   - Логами ошибок
   - Информацией о системе

#### 💻 Хотите добавить функцию?

1. Форкните репозиторий
2. Создайте feature branch: `git checkout -b feature/amazing-feature`
3. Внесите изменения и добавьте тесты
4. Отправьте Pull Request

#### 📖 Улучшение документации

- Исправления опечаток
- Добавление примеров
- Перевод на другие языки
- Создание туториалов

## 📞 Поддержка

При возникновении проблем:

1. **Проверьте логи:**

   ```bash
   PROJECT_NAME logs
   PROJECT_NAME-api logs
   sudo journalctl -u docker
   ```

2. **Проверьте статус сервисов:**

   ```bash
   PROJECT_NAME status
   sudo systemctl status docker
   ```

3. **Проверьте файрвол:**

   ```bash
   sudo ufw status verbose
   ```

4. **Проверьте сертификаты:**
   ```bash
   sudo certbot certificates
   ```

## 📄 Лицензия

Этот проект распространяется под лицензией **MIT License** - см. файл [LICENSE](LICENSE) для подробностей.

### 🆓 Что это означает:

- ✅ **Коммерческое использование** - можно использовать в коммерческих проектах
- ✅ **Модификация** - можно изменять код как угодно
- ✅ **Распространение** - можно делиться и копировать
- ✅ **Приватное использование** - можно использовать в закрытых проектах
- ⚠️ **Без гарантий** - автор не несет ответственности за возможные проблемы

**Простыми словами:** Делайте с кодом что хотите, только оставьте копирайт! 😊

## 🤝 Вклад в проект

Инструкции по внесению вклада в проект...

---

**⚡ Made by Nemcov aka asM1x для быстрого развертывания современных веб-приложений**
