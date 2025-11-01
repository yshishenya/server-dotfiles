#!/bin/bash

################################################################################
# Production Server Setup Script
#
# Автоматическая настройка Ubuntu 24.04 production сервера
# Для команды разработчиков: yan, alex, deploy
#
# Использование: sudo bash setup-production-server.sh
#
# Автор: Yan Shishenya
# Версия: 1.0
################################################################################

set -e  # Остановка при ошибке

################################################################################
# КОНФИГУРАЦИЯ
################################################################################

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Общие параметры
DOTFILES_REPO="https://github.com/yshishenya/server-dotfiles.git"
CERTBOT_EMAIL="yshishenya@gmail.com"
DEFAULT_PASSWORD="Pr0ffes4.0"
PYTHON_VERSIONS=("3.11.9" "3.12.3")
NODE_VERSIONS=("18" "20")

# Пользователь 1: yan (yshishenya)
USER1_NAME="yan"
USER1_GIT_NAME="yshishenya"
USER1_GIT_EMAIL="yshishenya@gmail.com"
USER1_SSH_KEYS=(
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjiKHD49QR2mDa8sgHiioThO0nAhGZ5/jGIREpflUShyz3WHawabWzIaaixypHpg14YrLJgCYF2q4FcCFoTvjyjtnfxxx00F/JilTcV6QQxztupeJkAO0PkMACxi7z01PovQevVCkoRXVDnh+Yjnu0KXBQKVseR/P1+Zall5jhCofyZJdNWeyS5zgW4NGVMG8N1U9cOuNuX9ye3PAKlwYNPQB266Qf13H+ymtCxnfeZMmCgopwYGTWCHcVAwu9QoNNaGi2xx9rrOuYg9rNCmCh0DTuqTdku3GXC2eqenlzlJAvWAytwGkjS53PM+Fji3x0WoxCrUEuXHc5bAWqwlQ9jUAk9yVP0I/kfkGyjP+Hdubdruld0LSKv8nsgUg16mWHga8OBW9YY++YqKNYQjaSK4eHRpXDQEyBvJQwMuI+yznnjVFb3phuf00ezVfBwujc84uQCQYNp9KC/eqAy+uEILdImOD3/h+oaDpUyOWGjJgLk8IobRbSvYPQm+pnDwk= evgeny@Evgenys-MacBook-Pro.local"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1kHs1bfMW/x59ZNqNtirIX4VrCnr8xEHDYCo/424D2cuiEk/IFWwX6/M/shhuGrFZZ04ZSRE8ZmzkJdOWOyaGfJqUusLHqkTMjgXWOs3CLJ41Tf/av7DuRJKd98OfTcsgKovNC74uyfuRVxNGPJeXLSWxhuNhpeWFoiLGMWEgYt3T3eCVoDm/PVaMF8nhxPERmhWJvkjiygGm1gZ1e+cO1v0Eqg5QXIToqTuBDOKlBMrx2UTggVkNVH66MSOMvHr1Z2kGLn3w2BHRjibgsB/lKL6UulakhIaIC/CunR5+XTwWBnWR/qQqWIu6uc3k7lwVifxpt/W9yTgkD35bvnWAGMGz0fBYHuaUhq9deZ2k85sbYZDfCiOpOAAD7xewdvlG/hWt517tLW+cB1Lj3bJHB9tDDgJAXQyhYbTMvhYKLAO1t3FaBi1j8YnLDTwocTpJaHhZMYY9yg+B7aF0UQ0gdI86CRq897zXPALgMnrKDRiz+oYWkGHgYpNKIXYqfO8= yshishenya@MacBook-Pro-Yan.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1zvD/lJmRT536AL1iCDLVeSzQlBMIBReP5XQqTf1kx y.shishenya@gmail.com"
)

# Пользователь 2: alex (Alexey Fedushin)
USER2_NAME="alex"
USER2_GIT_NAME="Alexey Fedushin"
USER2_GIT_EMAIL="alexeyfedyshinural@gmail.com"
USER2_SSH_KEYS=(
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNFi2fM4oIuzsvDuQYkf4MbRfpltv22P7SpWgmqLpqYG3iWL4OfntBbN76T6sIYhfnO8VQTCGsjMznot5dq4trHjjBTku0AMRhXMala8ZPNdqVAGcilq55ujjWLMQJsyRHzW0onea0CwfUHMwDD+e/iqke2QA/MH6+mN92xaaTYevCJLCdzePQutmdrTPKeCxwvLSX+p/bbXqXahDJp/HoXu9WbXda5xm1000GpC3Wal2mTs/971xmad09VgFr4cdy6jlrDl3hPJA+YKZlX7sis0sNxlYLwR7Fuorl69dA8cXfce50Q9ucXLMIJgwi1MfRxTK5iJt3UWuQw/dx8gtbKqWGut4fuQf/tIMi2Q98sLPR5DksItkU6ypVI9gy5j0400owR4rRNxRewi+MDpL2A1k+wiFrY3suFjO4BEUQjDg0n7cwrZ0fjchgxnPxXwfPc2XHSEdblCGd8aN1QRZ/8ds2CRLgjPTtiK2myPusT4A0DnPqS5psi5OibuaTP7c= naladhiki@DESKTOP-I27VA2G"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEGvkRXgwFZgkgGRy4eOVE6IoDR4jhl7gCjcu6b2C373MYI5bzB1SDUEgI6yVYaGSl+ckL8/qWeb3+9594Sr0t0tcFjECbqdjle7A7sTSer/+wIy+P5ZRukCoFfs/wIPftHq0ZkQxe2d/jwIedEiFw/x0cuLHn1XYYLOQx7o/zZZCy6Vy8SvJwbn2fe04gqsaBhZb+0ihYGl7+qnR7jGtTVjiWxduqAURnbvDdXJmvIaRaMIkvUNKv7c1rRTaTIVgIwuq6JOoyTSwfpiSYog85XxLlqC8ibJhV4KtsPuwmIJzPWL6CGbQPsMILjOfyK8YAblHNYQKCXh9xL1dB1RThXhU2MDthWRdf14nVY+g4drUYozECEUDJ0uNNMzNLbg8eT28ZwNNbtSw2kRzwaItOrPSs8UtwqgNUqMFoFobTKroR55pzXW78/eJUKBnLnEpX03UOUXX8bvuSWwvOnK0VByXUdJLZo3OKjwkdXF3CwHgcOVIrKtZempqo4sqB1AU= alexe@DESKTOP-RUOC6JI"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGfMKWiT3QfmngmCp9+D31ZEbRYGTIYiLKEdwIi174KQXr0HYemKnwozwiy0zUjSzU0gs33fq/H4Xd/m0YiYPYsWhs62BfgVfjrN0/7Xg+vKGg7U6eS8QP1uewGGWLitZbFvuVi2SikrCqRSs7bVpIiQht0wApuYO8SN3o7W0cVQTxAmaRQyS0PShc9Y8vL0fmIfOiM22/l822xHdTShC0ggSZq8SlD3GnPrDaeEsZaGgf5Q1ALe25zwfb9YvA1Y5a7Nr547lJ7aB+SYmAEUTyq6fhWvb1+ojt1KUGS8FkBhDI5ToIk/Y2WwrrHYJkLdt0kzEUFPPXU6dDhDJNeNEFzvNNQSNH6sI5k4Ro5IOIXI19NoI12ntSLTmwdQml/7EyhZbsWEBBIpXUsn9ooyvOecwI5Xee/GVNdz/fJ/ftZKIMnhKwJ2VsmtVcN9TfzVS8aUeRvuQq6eot/l0cjsHF5f/XFW2mD4RRJ8II5h9v3tJPkeQUB4CLyKDQggB7zOTB+o2IOOCZSE3WqVCd87M6SAuTjqg0r65v4WCgrS9tsUO1YNRzUm8KOeLS794dXz4bxMPc6Qddu9aer0L9z8NcK5MY4/aHIL2Bh5mBsyqzJNFaTGpqvQFtfG13xFpBZuqIIG9IEpUlNlmdUXdNsDZL2E7lpvm9i2jq+stSmEuwvw== alexeyfedyshinural@gmail.com"
)

# Пользователь 3: deploy (для CI/CD)
USER3_NAME="deploy"
USER3_GIT_NAME="Deploy Bot"
USER3_GIT_EMAIL="yshishenya@gmail.com"
# SSH ключ для deploy будет сгенерирован автоматически

################################################################################
# ФУНКЦИИ
################################################################################

# Логирование
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Заголовок секции
print_section() {
    echo ""
    echo "========================================="
    echo "  $1"
    echo "========================================="
    echo ""
}

# Проверка что скрипт запущен с sudo
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен быть запущен с sudo"
        echo "Использование: sudo bash $0"
        exit 1
    fi
}

# Проверка Ubuntu версии
check_ubuntu() {
    if [ ! -f /etc/lsb-release ]; then
        log_error "Этот скрипт предназначен для Ubuntu"
        exit 1
    fi

    source /etc/lsb-release
    log_info "Обнаружен: $DISTRIB_DESCRIPTION"

    if [[ "$DISTRIB_ID" != "Ubuntu" ]]; then
        log_error "Этот скрипт предназначен для Ubuntu"
        exit 1
    fi
}

# Получить реального пользователя (если скрипт запущен через sudo)
get_real_user() {
    if [ -n "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

################################################################################
# ОСНОВНЫЕ ФУНКЦИИ УСТАНОВКИ
################################################################################

# 1. Обновление системы
update_system() {
    print_section "Обновление системы"

    log_info "Обновление списка пакетов..."
    apt update

    log_info "Обновление установленных пакетов..."
    DEBIAN_FRONTEND=noninteractive apt upgrade -y

    log_success "Система обновлена"
}

# 2. Установка базовых пакетов
install_base_packages() {
    print_section "Установка базовых пакетов"

    local packages=(
        curl wget git vim nano htop unzip zip tree
        build-essential software-properties-common
        apt-transport-https ca-certificates gnupg lsb-release
        # Для pyenv
        make libssl-dev zlib1g-dev libbz2-dev libreadline-dev
        libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    )

    log_info "Установка пакетов: ${packages[*]}"
    DEBIAN_FRONTEND=noninteractive apt install -y "${packages[@]}"

    log_success "Базовые пакеты установлены"
}

# 3. Создание пользователей
create_users() {
    print_section "Создание пользователей"

    # Создать группу dev_team если не существует
    if ! getent group dev_team > /dev/null 2>&1; then
        log_info "Создание группы dev_team..."
        groupadd dev_team
        log_success "Группа dev_team создана"
    fi

    # Пользователь 1: yan
    create_user "$USER1_NAME" "$USER1_GIT_NAME" "$USER1_GIT_EMAIL" "sudo,docker,dev_team" USER1_SSH_KEYS[@]

    # Пользователь 2: alex
    create_user "$USER2_NAME" "$USER2_GIT_NAME" "$USER2_GIT_EMAIL" "sudo,docker,dev_team" USER2_SSH_KEYS[@]

    # Пользователь 3: deploy (без sudo)
    create_user "$USER3_NAME" "$USER3_GIT_NAME" "$USER3_GIT_EMAIL" "docker,dev_team"
}

# Функция создания пользователя
create_user() {
    local username=$1
    local git_name=$2
    local git_email=$3
    local groups=$4
    local -n ssh_keys=$5

    log_info "Создание пользователя: $username"

    # Создать пользователя если не существует
    if id "$username" &>/dev/null; then
        log_warning "Пользователь $username уже существует"
    else
        useradd -m -s /bin/zsh -G "$groups" "$username"
        log_success "Пользователь $username создан"
    fi

    # Установить пароль
    echo "$username:$DEFAULT_PASSWORD" | chpasswd
    log_success "Пароль установлен: $DEFAULT_PASSWORD"

    # Настроить SSH
    local ssh_dir="/home/$username/.ssh"
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    # Добавить SSH ключи
    if [ -n "$ssh_keys" ] && [ ${#ssh_keys[@]} -gt 0 ]; then
        local auth_keys="$ssh_dir/authorized_keys"
        touch "$auth_keys"
        chmod 600 "$auth_keys"

        for key in "${ssh_keys[@]}"; do
            echo "$key" >> "$auth_keys"
        done

        log_success "Добавлено ${#ssh_keys[@]} SSH ключ(ей)"
    fi

    # Если это deploy - сгенерировать ключ
    if [ "$username" == "$USER3_NAME" ]; then
        log_info "Генерация SSH ключа для $username..."
        sudo -u "$username" ssh-keygen -t ed25519 -f "$ssh_dir/id_ed25519" -N "" -C "$git_email"
        log_success "SSH ключ сгенерирован: $ssh_dir/id_ed25519.pub"
    fi

    # Установить владельца
    chown -R "$username:$username" "$ssh_dir"

    # Настроить Git
    sudo -u "$username" git config --global user.name "$git_name"
    sudo -u "$username" git config --global user.email "$git_email"
    log_success "Git настроен: $git_name <$git_email>"
}

# 4. Установка Docker
install_docker() {
    print_section "Установка Docker"

    # Удалить старые версии
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # Добавить GPG ключ
    log_info "Добавление GPG ключа Docker..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Добавить репозиторий
    log_info "Добавление репозитория Docker..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Обновить и установить
    apt update
    log_info "Установка Docker..."
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Настроить логирование
    log_info "Настройка логирования Docker..."
    cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

    # Запустить и включить
    systemctl enable docker
    systemctl start docker
    systemctl restart docker

    # Проверить версию
    local docker_version=$(docker --version)
    log_success "Docker установлен: $docker_version"
}

# 5. Установка Zsh и Oh My Zsh для всех пользователей
install_zsh() {
    print_section "Установка Zsh и Oh My Zsh"

    # Установить Zsh
    log_info "Установка Zsh..."
    apt install -y zsh

    local zsh_version=$(zsh --version)
    log_success "Zsh установлен: $zsh_version"

    # Установить для каждого пользователя
    for username in "$USER1_NAME" "$USER2_NAME" "$USER3_NAME"; do
        log_info "Установка Oh My Zsh для $username..."

        # Изменить shell
        chsh -s $(which zsh) "$username"

        # Установить Oh My Zsh
        sudo -u "$username" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        log_success "Oh My Zsh установлен для $username"
    done
}

# 6. Применить dotfiles
apply_dotfiles() {
    print_section "Применение dotfiles"

    for username in "$USER1_NAME" "$USER2_NAME" "$USER3_NAME"; do
        local home_dir="/home/$username"

        log_info "Клонирование dotfiles для $username..."

        # Клонировать dotfiles
        if [ -d "$home_dir/dotfiles" ]; then
            log_warning "Директория $home_dir/dotfiles уже существует"
            sudo -u "$username" bash -c "cd $home_dir/dotfiles && git pull"
        else
            sudo -u "$username" git clone "$DOTFILES_REPO" "$home_dir/dotfiles"
        fi

        # Установить плагины
        log_info "Установка плагинов Oh My Zsh для $username..."
        sudo -u "$username" bash "$home_dir/dotfiles/install-plugins.sh"

        # Скопировать конфиги
        log_info "Применение конфигурации для $username..."
        sudo -u "$username" cp "$home_dir/dotfiles/.zshrc" "$home_dir/.zshrc"
        sudo -u "$username" cp "$home_dir/dotfiles/.p10k.zsh" "$home_dir/.p10k.zsh"

        log_success "Dotfiles применены для $username"
    done
}

# Продолжение в следующем сообщении (файл слишком большой)...

################################################################################
# ГЛАВНАЯ ФУНКЦИЯ
################################################################################

main() {
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║  Production Server Setup Script       ║"
    echo "║  Version 1.0                           ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    # Проверки
    check_root
    check_ubuntu

    log_info "Начало установки..."
    log_warning "Это займет 20-30 минут"
    echo ""

    # Выполнение шагов
    update_system
    install_base_packages
    create_users
    install_docker
    install_zsh
    apply_dotfiles
    install_pyenv
    install_nvm
    install_nginx
    install_certbot
    install_fail2ban
    install_modern_utils
    setup_projects_structure
    create_utility_scripts
    configure_git
    configure_ssh
    final_checks
    print_summary
}

# Запуск
main "$@"

# 7. Установка pyenv и Python
install_pyenv() {
    print_section "Установка pyenv и Python"

    for username in "$USER1_NAME" "$USER2_NAME" "$USER3_NAME"; do
        local home_dir="/home/$username"

        log_info "Установка pyenv для $username..."

        # Установить pyenv
        sudo -u "$username" bash -c "curl https://pyenv.run | bash"

        # Добавить в .zshrc если еще не добавлено
        if ! sudo -u "$username" grep -q "PYENV_ROOT" "$home_dir/.zshrc"; then
            sudo -u "$username" bash -c "cat >> $home_dir/.zshrc <<'EOF'

# Pyenv configuration
export PYENV_ROOT=\"\$HOME/.pyenv\"
export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
eval \"\$(pyenv init -)\"
eval \"\$(pyenv virtualenv-init -)\"
EOF"
        fi

        # Установить Python версии
        for py_version in "${PYTHON_VERSIONS[@]}"; do
            log_info "Установка Python $py_version для $username..."
            sudo -u "$username" bash -c "export PYENV_ROOT=\"$home_dir/.pyenv\" && export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && pyenv install -s $py_version"
        done

        # Установить глобальную версию
        sudo -u "$username" bash -c "export PYENV_ROOT=\"$home_dir/.pyenv\" && export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && pyenv global ${PYTHON_VERSIONS[-1]}"

        log_success "pyenv и Python установлены для $username"
    done
}

# 8. Установка nvm и Node.js
install_nvm() {
    print_section "Установка nvm и Node.js"

    for username in "$USER1_NAME" "$USER2_NAME" "$USER3_NAME"; do
        local home_dir="/home/$username"

        log_info "Установка nvm для $username..."

        # Установить nvm
        sudo -u "$username" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"

        # Установить Node.js версии
        for node_version in "${NODE_VERSIONS[@]}"; do
            log_info "Установка Node.js $node_version для $username..."
            sudo -u "$username" bash -c "export NVM_DIR=\"$home_dir/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\" && nvm install $node_version"
        done

        # Установить версию по умолчанию
        sudo -u "$username" bash -c "export NVM_DIR=\"$home_dir/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\" && nvm alias default ${NODE_VERSIONS[0]}"

        log_success "nvm и Node.js установлены для $username"
    done
}

# 9. Установка Nginx
install_nginx() {
    print_section "Установка Nginx"

    log_info "Установка Nginx..."
    apt install -y nginx

    # Удалить дефолтный конфиг
    rm -f /etc/nginx/sites-enabled/default

    # Создать шаблон
    cat > /etc/nginx/sites-available/template <<'EOF'
# Шаблон конфига для проекта
server {
    listen 80;
    server_name DOMAIN www.DOMAIN;

    access_log /var/log/nginx/PROJECT_NAME_access.log;
    error_log /var/log/nginx/PROJECT_NAME_error.log;

    location / {
        proxy_pass http://localhost:PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

    # Оптимизация
    sed -i 's/# gzip on;/gzip on;\n\tgzip_vary on;\n\tgzip_comp_level 6;\n\tgzip_types text\/plain text\/css text\/xml application\/json application\/javascript;/' /etc/nginx/nginx.conf
    sed -i '/http {/a \\tclient_max_body_size 100M;' /etc/nginx/nginx.conf

    # Запустить
    systemctl enable nginx
    systemctl start nginx

    log_success "Nginx установлен и запущен"
}

# 10. Установка Certbot
install_certbot() {
    print_section "Установка Certbot"

    log_info "Установка Certbot..."
    apt install -y certbot python3-certbot-nginx

    log_success "Certbot установлен (email: $CERTBOT_EMAIL)"
}

# 11. Установка Fail2ban
install_fail2ban() {
    print_section "Установка Fail2ban"

    log_info "Установка Fail2ban..."
    apt install -y fail2ban

    # Конфигурация
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
EOF

    systemctl enable fail2ban
    systemctl start fail2ban

    log_success "Fail2ban установлен и запущен"
}

# 12. Установка современных утилит
install_modern_utils() {
    print_section "Установка современных утилит"

    log_info "Установка bat, fzf, ripgrep, fd, jq, httpie, ncdu, tree, btop, tldr..."
    apt install -y bat fzf ripgrep fd-find jq httpie ncdu tree btop tldr

    # Установка eza
    log_info "Установка eza..."
    mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    apt update
    apt install -y eza

    # Установка zoxide
    log_info "Установка zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

    # Установка delta
    log_info "Установка delta..."
    wget -q https://github.com/dandavison/delta/releases/download/0.17.0/git-delta_0.17.0_amd64.deb
    dpkg -i git-delta_0.17.0_amd64.deb || apt install -f -y
    rm git-delta_0.17.0_amd64.deb

    # Установка lazygit
    log_info "Установка lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz

    # Установка lazydocker
    log_info "Установка lazydocker..."
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

    # Установка tmux
    log_info "Установка tmux..."
    apt install -y tmux

    # Создать симлинки для bat и fd
    mkdir -p /usr/local/bin
    ln -sf /usr/bin/batcat /usr/local/bin/bat
    ln -sf /usr/bin/fdfind /usr/local/bin/fd

    log_success "Современные утилиты установлены"
}

# 13. Настройка структуры проектов
setup_projects_structure() {
    print_section "Настройка структуры проектов"

    log_info "Создание /opt/projects..."
    mkdir -p /opt/projects
    chown -R root:dev_team /opt/projects
    chmod -R 775 /opt/projects
    chmod g+s /opt/projects

    log_info "Создание /opt/backups..."
    mkdir -p /opt/backups
    chown -R root:dev_team /opt/backups
    chmod -R 775 /opt/backups

    log_success "Структура проектов создана"
}

# 14. Настройка SSH
configure_ssh() {
    print_section "Настройка SSH"

    log_warning "Настройка SSH (отключение паролей, root логина)..."

    # Бэкап оригинального конфига
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

    # Настройки безопасности
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config

    # НЕ перезапускаем SSH сейчас (безопасность)
    log_warning "SSH настроен, но НЕ перезапущен"
    log_warning "Перезапустите SSH вручную после проверки: sudo systemctl restart sshd"
}

# 15. Создание полезных скриптов
create_utility_scripts() {
    print_section "Создание полезных скриптов"

    # project-status
    cat > /usr/local/bin/project-status <<'EOF'
#!/bin/bash
echo "========================================="
echo "  Docker Containers Status"
echo "========================================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "========================================="
echo "  Disk Usage: /opt/projects"
echo "========================================="
du -sh /opt/projects/* 2>/dev/null || echo "No projects yet"
echo ""
echo "========================================="
echo "  Nginx Status"
echo "========================================="
systemctl status nginx --no-pager -l
EOF

    chmod +x /usr/local/bin/project-status

    # backup-docker-volumes
    cat > /usr/local/bin/backup-docker-volumes <<'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
mkdir -p "$BACKUP_DIR/$DATE"
VOLUMES=$(docker volume ls -q)
for VOLUME in $VOLUMES; do
    echo "Backing up: $VOLUME"
    docker run --rm -v "$VOLUME":/volume -v "$BACKUP_DIR/$DATE":/backup alpine tar czf "/backup/${VOLUME}.tar.gz" -C /volume .
done
find "$BACKUP_DIR" -type d -mtime +7 -exec rm -rf {} +
EOF

    chmod +x /usr/local/bin/backup-docker-volumes

    # backup-projects
    cat > /usr/local/bin/backup-projects <<'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/projects"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
mkdir -p "$BACKUP_DIR"
tar czf "$BACKUP_DIR/projects_$DATE.tar.gz" --exclude='node_modules' --exclude='__pycache__' --exclude='.git' --exclude='venv' -C /opt/projects .
find "$BACKUP_DIR" -name "projects_*.tar.gz" -mtime +14 -delete
EOF

    chmod +x /usr/local/bin/backup-projects

    log_success "Утилиты созданы: project-status, backup-docker-volumes, backup-projects"
}

# 16. Настройка Git для пользователей
configure_git() {
    print_section "Дополнительная настройка Git"

    for username in "$USER1_NAME" "$USER2_NAME" "$USER3_NAME"; do
        local home_dir="/home/$username"

        # Настроить delta как pager
        sudo -u "$username" git config --global core.pager "delta"
        sudo -u "$username" git config --global interactive.diffFilter "delta --color-only"
        sudo -u "$username" git config --global delta.navigate true
        sudo -u "$username" git config --global delta.side-by-side true
        sudo -u "$username" git config --global delta.line-numbers true

        log_success "Git delta настроен для $username"
    done
}

# 17. Финальные проверки
final_checks() {
    print_section "Финальные проверки"

    log_info "Проверка Docker..."
    docker --version && log_success "Docker: OK" || log_error "Docker: FAIL"

    log_info "Проверка Nginx..."
    nginx -t && log_success "Nginx: OK" || log_error "Nginx: FAIL"

    log_info "Проверка Fail2ban..."
    systemctl is-active fail2ban && log_success "Fail2ban: OK" || log_error "Fail2ban: FAIL"

    log_info "Проверка пользователей..."
    for username in "$USER1_NAME" "$USER2_NAME" "$USER3_NAME"; do
        id "$username" && log_success "Пользователь $username: OK" || log_error "Пользователь $username: FAIL"
    done

    log_info "Проверка Zsh..."
    zsh --version && log_success "Zsh: OK" || log_error "Zsh: FAIL"
}

# 18. Итоговая информация
print_summary() {
    print_section "УСТАНОВКА ЗАВЕРШЕНА"

    echo "✓ Система обновлена"
    echo "✓ Созданы пользователи:"
    echo "    - $USER1_NAME (sudo, docker, dev_team)"
    echo "    - $USER2_NAME (sudo, docker, dev_team)"
    echo "    - $USER3_NAME (docker, dev_team)"
    echo ""
    echo "✓ Установлено ПО:"
    echo "    - Docker + Docker Compose"
    echo "    - Zsh + Oh My Zsh + Powerlevel10k"
    echo "    - pyenv + Python ${PYTHON_VERSIONS[*]}"
    echo "    - nvm + Node.js ${NODE_VERSIONS[*]}"
    echo "    - Nginx"
    echo "    - Certbot (email: $CERTBOT_EMAIL)"
    echo "    - Fail2ban"
    echo "    - Современные утилиты (bat, eza, fzf, lazygit, и др.)"
    echo ""
    echo "✓ Структура:"
    echo "    - /opt/projects (проекты)"
    echo "    - /opt/backups (бэкапы)"
    echo ""
    echo "📝 ВАЖНО:"
    echo ""
    echo "1. Пароль для всех пользователей: $DEFAULT_PASSWORD"
    echo "   Измените пароли: passwd"
    echo ""
    echo "2. SSH настроен, но НЕ перезапущен!"
    echo "   Перед перезапуском SSH:"
    echo "   - Проверьте что можете зайти по SSH ключу"
    echo "   - Сохраните текущую сессию открытой"
    echo "   - Затем: sudo systemctl restart sshd"
    echo ""
    echo "3. Публичный ключ для deploy пользователя:"
    echo "   cat /home/$USER3_NAME/.ssh/id_ed25519.pub"
    echo "   Добавьте этот ключ в GitHub/GitLab для CI/CD"
    echo ""
    echo "4. Для применения настроек zsh:"
    echo "   exec zsh  (или перелогиниться)"
    echo ""
    echo "5. Полезные команды:"
    echo "   project-status     - статус проектов и Docker"
    echo "   backup-docker-volumes - бэкап Docker volumes"
    echo "   backup-projects    - бэкап проектов"
    echo ""
    echo "6. Документация:"
    echo "   ~/production-server-setup-guide.md"
    echo ""
    echo "═══════════════════════════════════════"
    echo "  🎉 Сервер готов к работе!"
    echo "═══════════════════════════════════════"
    echo ""
}
