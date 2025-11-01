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
PYTHON_VERSIONS=("3.11.9" "3.12.3")
NODE_VERSIONS=("18" "20")

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

# 3. Установка Docker
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

# 4. Установка Zsh
install_zsh() {
    print_section "Установка Zsh"

    # Установить Zsh
    log_info "Установка Zsh..."
    apt install -y zsh

    local zsh_version=$(zsh --version)
    log_success "Zsh установлен: $zsh_version"
}

# 5. Настройка текущего пользователя (кто запустил sudo)
setup_current_user() {
    # Определить пользователя, который запустил sudo
    local current_user="${SUDO_USER:-$(whoami)}"

    # Пропустить если это root
    if [ "$current_user" = "root" ]; then
        log_warning "Запуск от root - настройка пользователя пропущена"
        return
    fi

    print_section "Настройка текущего пользователя: $current_user"

    local home_dir="/home/$current_user"

    # Создать группу dev_team если не существует
    if ! getent group dev_team > /dev/null 2>&1; then
        log_info "Создание группы dev_team..."
        groupadd dev_team
        log_success "Группа dev_team создана"
    fi

    # Добавить в группы
    log_info "Добавление $current_user в группы..."
    usermod -aG sudo,docker,dev_team "$current_user" 2>/dev/null || true

    # Изменить shell на zsh
    log_info "Установка zsh для $current_user..."
    chsh -s $(which zsh) "$current_user" 2>/dev/null || true

    # Установить Oh My Zsh если еще не установлен
    if [ ! -d "$home_dir/.oh-my-zsh" ]; then
        log_info "Установка Oh My Zsh для $current_user..."
        sudo -u "$current_user" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Клонировать dotfiles
    log_info "Клонирование dotfiles для $current_user..."
    if [ -d "$home_dir/dotfiles" ]; then
        sudo -u "$current_user" bash -c "cd $home_dir/dotfiles && git pull"
    else
        sudo -u "$current_user" bash -c "cd $home_dir && git clone '$DOTFILES_REPO' dotfiles"
    fi

    # Установить плагины
    log_info "Установка плагинов Oh My Zsh для $current_user..."
    sudo -u "$current_user" bash "$home_dir/dotfiles/install-plugins.sh"

    # Скопировать конфиги
    log_info "Применение конфигурации для $current_user..."
    sudo -u "$current_user" cp "$home_dir/dotfiles/.zshrc" "$home_dir/.zshrc"
    sudo -u "$current_user" cp "$home_dir/dotfiles/.p10k.zsh" "$home_dir/.p10k.zsh"

    # Установить pyenv
    if [ ! -d "$home_dir/.pyenv" ]; then
        log_info "Установка pyenv для $current_user..."
        sudo -u "$current_user" bash -c "curl https://pyenv.run | bash"

        if ! sudo -u "$current_user" grep -q "PYENV_ROOT" "$home_dir/.zshrc"; then
            sudo -u "$current_user" bash -c "cat >> $home_dir/.zshrc <<'EOF'

# Pyenv configuration
export PYENV_ROOT=\"\$HOME/.pyenv\"
export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
eval \"\$(pyenv init -)\"
eval \"\$(pyenv virtualenv-init -)\"
EOF"
        fi

        # Установить Python версии
        for py_version in "${PYTHON_VERSIONS[@]}"; do
            log_info "Установка Python $py_version для $current_user..."
            sudo -u "$current_user" bash -c "export PYENV_ROOT=\"$home_dir/.pyenv\" && export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && pyenv install -s $py_version"
        done

        # Установить глобальную версию
        sudo -u "$current_user" bash -c "export PYENV_ROOT=\"$home_dir/.pyenv\" && export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && pyenv global ${PYTHON_VERSIONS[0]}"

        log_success "pyenv установлен для $current_user"
    else
        log_warning "pyenv уже установлен для $current_user"
    fi

    # Установить nvm
    if [ ! -d "$home_dir/.nvm" ]; then
        log_info "Установка nvm для $current_user..."
        sudo -u "$current_user" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"

        # Установить Node.js версии
        for node_version in "${NODE_VERSIONS[@]}"; do
            log_info "Установка Node.js $node_version для $current_user..."
            sudo -u "$current_user" bash -c "export NVM_DIR=\"$home_dir/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\" && nvm install $node_version"
        done

        # Установить дефолтную версию
        sudo -u "$current_user" bash -c "export NVM_DIR=\"$home_dir/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\" && nvm alias default ${NODE_VERSIONS[0]}"

        log_success "nvm установлен для $current_user"
    else
        log_warning "nvm уже установлен для $current_user"
    fi

    # Настроить git delta (если установлен)
    if command -v delta &> /dev/null; then
        log_info "Настройка git delta для $current_user..."
        sudo -u "$current_user" git config --global core.pager "delta"
        sudo -u "$current_user" git config --global interactive.diffFilter "delta --color-only"
        sudo -u "$current_user" git config --global delta.navigate true
        sudo -u "$current_user" git config --global delta.side-by-side true
        sudo -u "$current_user" git config --global delta.line-numbers true
        log_success "Git delta настроен"
    fi

    log_success "Полная настройка применена для $current_user"
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
    install_docker
    install_zsh
    install_nginx
    install_certbot
    install_fail2ban
    install_modern_utils
    setup_current_user
    setup_projects_structure
    create_utility_scripts
    configure_ssh
    final_checks
    print_summary
}

# 6. Установка Nginx
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
    if ! grep -q "gzip_vary on" /etc/nginx/nginx.conf; then
        sed -i 's/# gzip on;/gzip on;\n\tgzip_vary on;\n\tgzip_comp_level 6;\n\tgzip_types text\/plain text\/css text\/xml application\/json application\/javascript;/' /etc/nginx/nginx.conf
    fi

    if ! grep -q "client_max_body_size" /etc/nginx/nginx.conf; then
        sed -i '/http {/a \\tclient_max_body_size 100M;' /etc/nginx/nginx.conf
    fi

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

# 7. Финальные проверки
final_checks() {
    print_section "Финальные проверки"

    log_info "Проверка Docker..."
    docker --version && log_success "Docker: OK" || log_error "Docker: FAIL"

    log_info "Проверка Nginx..."
    nginx -t && log_success "Nginx: OK" || log_error "Nginx: FAIL"

    log_info "Проверка Fail2ban..."
    systemctl is-active fail2ban && log_success "Fail2ban: OK" || log_error "Fail2ban: FAIL"

    log_info "Проверка текущего пользователя..."
    local current_user="${SUDO_USER:-$(whoami)}"
    if [ "$current_user" != "root" ]; then
        id "$current_user" && log_success "Пользователь $current_user: OK" || log_error "Пользователь $current_user: FAIL"
        groups "$current_user" | grep -q "docker" && log_success "В группе docker: OK" || log_warning "В группе docker: FAIL"
    fi

    log_info "Проверка Zsh..."
    zsh --version && log_success "Zsh: OK" || log_error "Zsh: FAIL"
}

# 18. Итоговая информация
print_summary() {
    print_section "УСТАНОВКА ЗАВЕРШЕНА"

    local current_user="${SUDO_USER:-$(whoami)}"

    echo "✓ Система обновлена"
    echo "✓ Настроен пользователь: $current_user"
    echo "    - Группы: sudo, docker, dev_team"
    echo "    - Shell: Zsh + Oh My Zsh + Powerlevel10k"
    echo "    - Python: ${PYTHON_VERSIONS[*]} (через pyenv)"
    echo "    - Node.js: ${NODE_VERSIONS[*]} (через nvm)"
    echo ""
    echo "✓ Установлено ПО:"
    echo "    - Docker + Docker Compose"
    echo "    - Nginx"
    echo "    - Certbot (email: $CERTBOT_EMAIL)"
    echo "    - Fail2ban"
    echo "    - Современные утилиты: bat, eza, fzf, ripgrep, fd,"
    echo "      lazygit, lazydocker, delta, zoxide, btop, tldr, tmux"
    echo ""
    echo "✓ Структура:"
    echo "    - /opt/projects (проекты)"
    echo "    - /opt/backups (бэкапы)"
    echo ""
    echo "📝 ВАЖНО:"
    echo ""
    echo "1. Для применения настроек zsh:"
    echo "   exec zsh  (или перелогиниться)"
    echo ""
    echo "2. SSH настроен (только ключи, пароли отключены)"
    echo "   Перед перезапуском SSH:"
    echo "   - Проверьте что можете зайти по SSH ключу"
    echo "   - Сохраните текущую сессию открытой"
    echo "   - Затем: sudo systemctl restart sshd"
    echo ""
    echo "3. Настройте Git:"
    echo "   git config --global user.name \"Your Name\""
    echo "   git config --global user.email \"your@email.com\""
    echo ""
    echo "4. Полезные команды:"
    echo "   project-status         - статус проектов и Docker"
    echo "   backup-docker-volumes  - бэкап Docker volumes"
    echo "   backup-projects        - бэкап проектов"
    echo ""
    echo "═══════════════════════════════════════"
    echo "  🎉 Сервер готов к работе!"
    echo "═══════════════════════════════════════"
    echo ""
}

################################################################################
# ЗАПУСК
################################################################################

main "$@"
