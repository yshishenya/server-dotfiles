#!/bin/bash

################################################################################
# Скрипт обновления dotfiles на существующем сервере
# Использование: ./update-dotfiles.sh
################################################################################

set -e

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔄 Обновление dotfiles                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Определить директорию репозитория
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}"

echo -e "${BLUE}ℹ${NC} Директория dotfiles: $DOTFILES_DIR"
echo ""

# Проверить что мы в git репозитории
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    echo -e "${YELLOW}⚠${NC} Это не git репозиторий!"
    echo "Склонируйте репозиторий:"
    echo "  cd ~"
    echo "  git clone https://github.com/yshishenya/server-dotfiles.git"
    exit 1
fi

# Перейти в директорию репозитория
cd "$DOTFILES_DIR"

# Сохранить текущие изменения если есть
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} У вас есть несохраненные изменения"
    echo "Сохраняем в stash..."
    git stash push -m "Auto-stash before update $(date +%Y%m%d-%H%M%S)"
fi

# Получить обновления
echo -e "${BLUE}ℹ${NC} Получение обновлений из GitHub..."
git fetch origin

# Проверить есть ли новые коммиты
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [[ "$LOCAL" == "$REMOTE" ]]; then
    echo -e "${GREEN}✓${NC} Вы уже используете последнюю версию!"
    echo ""
else
    # Показать что изменилось
    echo ""
    echo -e "${BLUE}Новые изменения:${NC}"
    git log --oneline --decorate --graph HEAD..@{u}
    echo ""

    # Обновить
    echo -e "${BLUE}ℹ${NC} Применение обновлений..."
    git pull origin main

    echo -e "${GREEN}✓${NC} Репозиторий обновлен!"
    echo ""
fi

# Применить конфигурацию
echo -e "${BLUE}ℹ${NC} Применение конфигурации..."

# Бэкап старых файлов
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

if [[ -f "$HOME/.zshrc" ]]; then
    echo -e "${BLUE}ℹ${NC} Создание бэкапа старого .zshrc..."
    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
fi

if [[ -f "$HOME/.p10k.zsh" ]]; then
    echo -e "${BLUE}ℹ${NC} Создание бэкапа старого .p10k.zsh..."
    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.p10k.zsh" "$BACKUP_DIR/.p10k.zsh"
fi

# Копировать новые файлы
echo -e "${BLUE}ℹ${NC} Копирование .zshrc..."
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo -e "${BLUE}ℹ${NC} Копирование .p10k.zsh..."
cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

echo -e "${GREEN}✓${NC} Конфигурация обновлена!"

if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${BLUE}ℹ${NC} Бэкап старых файлов: $BACKUP_DIR"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Обновление завершено!                                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Что дальше:"
echo ""
echo "1. Перезагрузите shell для применения изменений:"
echo "   ${BLUE}exec zsh${NC}"
echo ""
echo "2. Или перелогиньтесь в SSH сессию"
echo ""
echo "Новые возможности:"
echo "  - ${GREEN}vpn-on${NC}       - включить VPN"
echo "  - ${GREEN}vpn-off${NC}      - выключить VPN"
echo "  - ${GREEN}vpn${NC}          - статус VPN"
echo "  - ${GREEN}vpn-test${NC}     - тестировать VPN"
echo "  - ${GREEN}novpn <cmd>${NC}  - выполнить команду БЕЗ VPN"
echo "  - ${GREEN}tips${NC}         - случайная подсказка"
echo "  - ${GREEN}tips-all${NC}     - все подсказки"
echo ""
