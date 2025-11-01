#!/bin/bash

# Быстрая установка dotfiles
# Использование: curl -fsSL https://raw.githubusercontent.com/yshishenya/server-dotfiles/main/install.sh | bash

set -e

echo "========================================="
echo "  Установка Server Dotfiles"
echo "========================================="
echo ""

# Проверка Zsh
if ! command -v zsh &> /dev/null; then
    echo "✗ Zsh не установлен!"
    echo "Установите Zsh:"
    echo "  sudo apt install -y zsh"
    exit 1
fi

# Клонирование репозитория
echo "[1/4] Клонирование dotfiles..."
if [ -d "$HOME/dotfiles" ]; then
    echo "  ℹ Директория уже существует, обновление..."
    cd "$HOME/dotfiles" && git pull
else
    git clone https://github.com/yshishenya/server-dotfiles.git "$HOME/dotfiles"
    echo "  ✓ Склонировано"
fi

echo ""

# Установка Oh My Zsh
echo "[2/4] Установка Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  ℹ Oh My Zsh уже установлен"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "  ✓ Установлен"
fi

echo ""

# Установка плагинов
echo "[3/4] Установка плагинов..."
bash "$HOME/dotfiles/install-plugins.sh"

echo ""

# Копирование конфигов
echo "[4/4] Применение конфигурации..."
cp "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
cp "$HOME/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
echo "  ✓ Конфигурация применена"

echo ""
echo "========================================="
echo "  ✓ Установка завершена!"
echo "========================================="
echo ""
echo "Выполните для применения изменений:"
echo "  exec zsh"
echo ""
