#!/bin/bash

# Скрипт установки плагинов Oh My Zsh
# Использование: ./install-plugins.sh

set -e

echo "========================================="
echo "  Установка плагинов Oh My Zsh"
echo "========================================="
echo ""

# Проверка наличия Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "✗ Oh My Zsh не установлен!"
    echo "Сначала установите Oh My Zsh:"
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    exit 1
fi

CUSTOM_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
CUSTOM_THEMES="$HOME/.oh-my-zsh/custom/themes"

# Установка zsh-autosuggestions
echo "[1/3] Установка zsh-autosuggestions..."
if [ -d "$CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
    echo "  ℹ Уже установлен, обновление..."
    cd "$CUSTOM_PLUGINS/zsh-autosuggestions" && git pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_PLUGINS/zsh-autosuggestions"
    echo "  ✓ Установлен"
fi

echo ""

# Установка zsh-syntax-highlighting
echo "[2/3] Установка zsh-syntax-highlighting..."
if [ -d "$CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
    echo "  ℹ Уже установлен, обновление..."
    cd "$CUSTOM_PLUGINS/zsh-syntax-highlighting" && git pull
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_PLUGINS/zsh-syntax-highlighting"
    echo "  ✓ Установлен"
fi

echo ""

# Установка Powerlevel10k
echo "[3/3] Установка темы Powerlevel10k..."
if [ -d "$CUSTOM_THEMES/powerlevel10k" ]; then
    echo "  ℹ Уже установлена, обновление..."
    cd "$CUSTOM_THEMES/powerlevel10k" && git pull
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$CUSTOM_THEMES/powerlevel10k"
    echo "  ✓ Установлена"
fi

echo ""
echo "========================================="
echo "  ✓ Все плагины установлены!"
echo "========================================="
echo ""
echo "Примените изменения:"
echo "  source ~/.zshrc"
echo ""
