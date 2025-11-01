#!/bin/bash

################################################################################
# Скрипт установки и настройки Xray vless-клиента для VPN доступа
# Использование: sudo ./setup-vless-client.sh
################################################################################

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Конфигурация vless-сервера (из ключа)
VLESS_UUID="7babc4dc-697b-447d-9f44-4a576a3f8afd"
VLESS_SERVER="5.144.180.112"
VLESS_PORT="433"
VLESS_SNI="house.kg"
VLESS_PUBLIC_KEY="Lhq3BYT2D91lPnXpsn98c6NNO-JUN1dQKZhh1zZ6AFI"
VLESS_SHORT_ID="9b87f99955b077a3"
VLESS_SPIDER_X="/"
VLESS_FLOW="xtls-rprx-vision"
VLESS_FINGERPRINT="chrome"

# Локальные порты для прокси
SOCKS_PORT="1080"
HTTP_PORT="1081"

################################################################################
# Функции вывода
################################################################################

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

################################################################################
# Проверки
################################################################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен быть запущен с правами root (sudo)"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Не удалось определить операционную систему"
        exit 1
    fi

    . /etc/os-release

    if [[ "$ID" != "ubuntu" ]] && [[ "$ID" != "debian" ]]; then
        log_warning "Скрипт тестировался на Ubuntu/Debian, ваша ОС: $ID"
    fi
}

################################################################################
# Установка Xray-core
################################################################################

install_xray() {
    print_section "Установка Xray-core"

    # Проверка установлен ли уже
    if command -v xray &> /dev/null; then
        local version=$(xray version 2>/dev/null | head -n1 || echo "unknown")
        log_warning "Xray уже установлен: $version"
        read -p "Переустановить? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Пропуск установки Xray"
            return 0
        fi
    fi

    log_info "Скачивание и установка Xray-core..."

    # Установка через официальный скрипт
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

    if command -v xray &> /dev/null; then
        log_success "Xray-core установлен: $(xray version 2>/dev/null | head -n1)"
    else
        log_error "Не удалось установить Xray-core"
        exit 1
    fi
}

################################################################################
# Создание конфигурации
################################################################################

create_config() {
    print_section "Создание конфигурации Xray"

    local config_dir="/usr/local/etc/xray"
    local config_file="$config_dir/config.json"

    # Создать директорию если не существует
    mkdir -p "$config_dir"

    # Создать резервную копию если конфиг уже существует
    if [[ -f "$config_file" ]]; then
        local backup_file="$config_file.backup.$(date +%Y%m%d-%H%M%S)"
        log_info "Создание резервной копии: $backup_file"
        cp "$config_file" "$backup_file"
    fi

    log_info "Создание конфигурации клиента..."

    # Создать конфиг для vless + reality
    cat > "$config_file" <<EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "tag": "socks-in",
      "port": $SOCKS_PORT,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true,
        "ip": "127.0.0.1"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    },
    {
      "tag": "http-in",
      "port": $HTTP_PORT,
      "listen": "127.0.0.1",
      "protocol": "http",
      "settings": {
        "allowTransparent": false
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "$VLESS_SERVER",
            "port": $VLESS_PORT,
            "users": [
              {
                "id": "$VLESS_UUID",
                "encryption": "none",
                "flow": "$VLESS_FLOW"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "serverName": "$VLESS_SNI",
          "fingerprint": "$VLESS_FINGERPRINT",
          "show": false,
          "publicKey": "$VLESS_PUBLIC_KEY",
          "shortId": "$VLESS_SHORT_ID",
          "spiderX": "$VLESS_SPIDER_X"
        }
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "block",
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "direct"
      },
      {
        "type": "field",
        "domain": [
          "geosite:category-ads-all"
        ],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "outboundTag": "proxy",
        "network": "tcp,udp"
      }
    ]
  }
}
EOF

    # Создать директорию для логов
    mkdir -p /var/log/xray

    log_success "Конфигурация создана: $config_file"
    log_info "SOCKS5 прокси: 127.0.0.1:$SOCKS_PORT"
    log_info "HTTP прокси: 127.0.0.1:$HTTP_PORT"
}

################################################################################
# Настройка systemd
################################################################################

setup_systemd() {
    print_section "Настройка systemd сервиса"

    local service_file="/etc/systemd/system/xray.service"

    log_info "Создание systemd сервиса..."

    cat > "$service_file" <<'EOF'
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
Type=simple
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

    log_success "Systemd сервис создан"

    # Перезагрузить systemd
    systemctl daemon-reload

    # Включить автозапуск
    systemctl enable xray

    # Запустить сервис
    log_info "Запуск Xray сервиса..."
    systemctl restart xray

    # Проверить статус
    sleep 2
    if systemctl is-active --quiet xray; then
        log_success "Xray сервис запущен и работает"
    else
        log_error "Ошибка запуска Xray сервиса"
        log_info "Проверьте логи: journalctl -u xray -n 50"
        exit 1
    fi
}

################################################################################
# Настройка переменных окружения для прокси
################################################################################

setup_proxy_env() {
    print_section "Настройка переменных окружения"

    local proxy_script="/etc/profile.d/xray-proxy.sh"

    log_info "Создание скрипта настройки прокси..."

    cat > "$proxy_script" <<EOF
# Xray VPN Proxy Settings
export http_proxy="http://127.0.0.1:$HTTP_PORT"
export https_proxy="http://127.0.0.1:$HTTP_PORT"
export HTTP_PROXY="http://127.0.0.1:$HTTP_PORT"
export HTTPS_PROXY="http://127.0.0.1:$HTTP_PORT"
export all_proxy="socks5://127.0.0.1:$SOCKS_PORT"
export ALL_PROXY="socks5://127.0.0.1:$SOCKS_PORT"

# No proxy для локальных адресов
export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
export NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
EOF

    chmod +x "$proxy_script"

    log_success "Скрипт создан: $proxy_script"
    log_info "Переменные окружения будут применены при следующем входе"

    # Создать также файл для текущего пользователя
    local current_user="${SUDO_USER:-$(whoami)}"
    if [[ "$current_user" != "root" ]]; then
        local user_home="/home/$current_user"
        if [[ -d "$user_home" ]]; then
            log_info "Добавление настроек прокси в .zshrc пользователя $current_user..."

            # Проверить есть ли уже настройки
            if [[ -f "$user_home/.zshrc" ]]; then
                if ! grep -q "Xray VPN Proxy" "$user_home/.zshrc"; then
                    cat >> "$user_home/.zshrc" <<EOF

# Xray VPN Proxy Settings
export http_proxy="http://127.0.0.1:$HTTP_PORT"
export https_proxy="http://127.0.0.1:$HTTP_PORT"
export all_proxy="socks5://127.0.0.1:$SOCKS_PORT"
export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
EOF
                    chown "$current_user:$current_user" "$user_home/.zshrc"
                    log_success "Настройки прокси добавлены в .zshrc"
                else
                    log_warning "Настройки прокси уже есть в .zshrc"
                fi
            fi
        fi
    fi
}

################################################################################
# Настройка git для работы через прокси
################################################################################

setup_git_proxy() {
    print_section "Настройка git для работы через прокси"

    local current_user="${SUDO_USER:-$(whoami)}"
    if [[ "$current_user" != "root" ]]; then
        log_info "Настройка git прокси для пользователя $current_user..."

        # Настроить git для использования прокси
        sudo -u "$current_user" git config --global http.proxy "http://127.0.0.1:$HTTP_PORT"
        sudo -u "$current_user" git config --global https.proxy "http://127.0.0.1:$HTTP_PORT"

        log_success "Git настроен для работы через прокси"
        log_info "Чтобы отключить: git config --global --unset http.proxy"
    fi
}

################################################################################
# Тестирование подключения
################################################################################

test_connection() {
    print_section "Тестирование подключения"

    log_info "Проверка статуса Xray..."
    systemctl status xray --no-pager | head -n 10

    log_info ""
    log_info "Проверка портов..."
    if ss -tlnp | grep -E "(:$SOCKS_PORT|:$HTTP_PORT)" > /dev/null 2>&1; then
        log_success "Прокси порты открыты"
        ss -tlnp | grep -E "(:$SOCKS_PORT|:$HTTP_PORT)"
    else
        log_warning "Прокси порты не найдены"
    fi

    log_info ""
    log_info "Тестирование подключения через прокси..."

    # Тест через HTTP прокси
    if curl -s --proxy "http://127.0.0.1:$HTTP_PORT" --max-time 10 https://api.ipify.org?format=json > /dev/null 2>&1; then
        local external_ip=$(curl -s --proxy "http://127.0.0.1:$HTTP_PORT" --max-time 10 https://api.ipify.org?format=json 2>/dev/null | grep -o '"ip":"[^"]*"' | cut -d'"' -f4)
        log_success "Подключение через прокси работает!"
        log_success "Внешний IP через VPN: $external_ip"
    else
        log_warning "Не удалось протестировать подключение"
        log_info "Возможно, VPN сервер недоступен или есть проблемы с сетью"
    fi
}

################################################################################
# Информация после установки
################################################################################

print_info() {
    print_section "Установка завершена"

    cat <<EOF
${GREEN}✓${NC} Xray vless-клиент успешно установлен и настроен!

${BLUE}Информация о прокси:${NC}
  SOCKS5: 127.0.0.1:$SOCKS_PORT
  HTTP:   127.0.0.1:$HTTP_PORT

${BLUE}Управление сервисом:${NC}
  Статус:      systemctl status xray
  Запустить:   systemctl start xray
  Остановить:  systemctl stop xray
  Перезапуск:  systemctl restart xray
  Логи:        journalctl -u xray -f

${BLUE}Использование:${NC}
  1. Переменные окружения применятся после выхода и входа
  2. Или сейчас: source /etc/profile.d/xray-proxy.sh
  3. Git уже настроен для работы через прокси
  4. Для Claude Code и других приложений прокси будет работать автоматически

${BLUE}Проверка IP адреса:${NC}
  curl https://api.ipify.org?format=json

${BLUE}Проверка через прокси:${NC}
  curl --proxy http://127.0.0.1:$HTTP_PORT https://api.ipify.org?format=json

${BLUE}Конфигурация:${NC}
  Config:  /usr/local/etc/xray/config.json
  Логи:    /var/log/xray/

${BLUE}Отключение прокси (временно):${NC}
  unset http_proxy https_proxy all_proxy

${YELLOW}⚠ Важно:${NC}
  - Прокси работает только для исходящих подключений
  - Локальные адреса (192.168.x.x, 10.x.x.x) идут напрямую
  - Проверьте что VPN сервер ($VLESS_SERVER) доступен

EOF
}

################################################################################
# Главная функция
################################################################################

main() {
    check_root
    check_os

    install_xray
    create_config
    setup_systemd
    setup_proxy_env
    setup_git_proxy
    test_connection
    print_info

    log_success "Готово! Выйдите и войдите снова для применения настроек прокси."
}

################################################################################
# ЗАПУСК
################################################################################

main "$@"
