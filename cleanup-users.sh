#!/bin/bash

################################################################################
# Cleanup Users Script
#
# Удаление пользователей созданных старой версией setup-production-server.sh
# Использование: sudo bash cleanup-users.sh
################################################################################

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  Очистка созданных пользователей"
echo "========================================="
echo ""

# Проверка root прав
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✗ Этот скрипт должен быть запущен с правами root (sudo)${NC}"
    exit 1
fi

# Функция удаления пользователя
remove_user() {
    local username=$1

    if id "$username" &>/dev/null; then
        echo -e "${YELLOW}[INFO]${NC} Удаление пользователя: $username"

        # Завершить все процессы пользователя
        pkill -u "$username" 2>/dev/null || true
        sleep 1

        # Удалить пользователя и его домашнюю директорию
        userdel -r "$username" 2>/dev/null || userdel "$username" 2>/dev/null || true

        # Проверить что удален
        if ! id "$username" &>/dev/null; then
            echo -e "${GREEN}✓${NC} Пользователь $username удален"
        else
            echo -e "${RED}✗${NC} Ошибка удаления $username"
        fi
    else
        echo -e "${YELLOW}[INFO]${NC} Пользователь $username не найден (возможно уже удален)"
    fi
}

# Удалить пользователей
echo "Удаление пользователей созданных скриптом..."
echo ""

remove_user "yan"
remove_user "alex"
remove_user "deploy"

echo ""

# Удалить группу dev_team
if getent group dev_team > /dev/null 2>&1; then
    echo -e "${YELLOW}[INFO]${NC} Удаление группы: dev_team"
    groupdel dev_team 2>/dev/null || true

    if ! getent group dev_team > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Группа dev_team удалена"
    else
        echo -e "${RED}✗${NC} Ошибка удаления группы dev_team"
    fi
else
    echo -e "${YELLOW}[INFO]${NC} Группа dev_team не найдена (возможно уже удалена)"
fi

echo ""
echo "========================================="
echo -e "${GREEN}✓ Очистка завершена${NC}"
echo "========================================="
echo ""
echo "Теперь можно запустить обновленный setup-production-server.sh"
echo "который настроит только текущего пользователя."
echo ""
