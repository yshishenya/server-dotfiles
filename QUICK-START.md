# Быстрый старт - Установка production сервера

## Подготовка

### 1. Создайте GitHub репозиторий для dotfiles

```bash
# На текущем сервере (где вы сейчас)
cd /home/yan/dotfiles-repo
git init
git add .
git commit -m "Initial commit: server dotfiles"
git remote add origin https://github.com/yshishenya/server-dotfiles.git
git branch -M main
git push -u origin main
```

### 2. Скопируйте скрипт на новый сервер

```bash
# С текущего сервера скопируйте на новый
scp /home/yan/setup-production-server.sh root@NEW_SERVER_IP:/root/
```

## Установка на новом сервере

### 1. Подключитесь к новому серверу

```bash
ssh root@NEW_SERVER_IP
```

### 2. Запустите скрипт установки

```bash
cd /root
chmod +x setup-production-server.sh
sudo ./setup-production-server.sh
```

**Важно:** Скрипт должен быть запущен от root или с sudo!

### 3. Процесс установки

Скрипт автоматически:
- Обновит систему
- Установит все необходимые пакеты
- Создаст пользователей: yan, alex, deploy
- Настроит SSH ключи
- Установит Docker, Nginx, Certbot, Fail2ban
- Установит Zsh с Oh My Zsh и плагинами
- Применит dotfiles из вашего репозитория
- Установит pyenv с Python 3.11.9 и 3.12.3
- Установит nvm с Node.js 18 и 20
- Установит современные утилиты (bat, eza, fzf, lazygit, и т.д.)
- Создаст структуру каталогов для проектов
- Создаст утилиты для управления сервером

**Время выполнения:** 20-30 минут

## После установки

### 1. Протестируйте SSH доступ

**Не закрывайте текущую root сессию!**

Откройте новое терминальное окно и попробуйте:

```bash
ssh yan@NEW_SERVER_IP
ssh alex@NEW_SERVER_IP
```

Если вход работает, можно перезапустить SSH:

```bash
sudo systemctl restart sshd
```

### 2. Активируйте Zsh

```bash
exec zsh
```

или перелогинтесь

### 3. Проверьте установленные инструменты

```bash
# Python версии
pyenv versions

# Node.js версии
nvm list

# Docker
docker --version
docker compose version

# Современные утилиты
bat --version
eza --version
fzf --version
lazygit --version
```

### 4. Настройте проекты

Создайте каталоги для ваших проектов:

```bash
cd /opt/projects
sudo mkdir project-name
sudo chown $USER:dev_team project-name
cd project-name
git clone ...
```

### 5. Настройте Nginx и SSL

Для каждого проекта:

```bash
# Создайте конфигурацию Nginx
sudo nano /etc/nginx/sites-available/yourdomain.com

# Включите сайт
sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/

# Проверьте конфигурацию
sudo nginx -t

# Перезагрузите Nginx
sudo systemctl reload nginx

# Получите SSL сертификат
sudo certbot --nginx -d yourdomain.com
```

## Полезные команды

```bash
# Статус всех проектов и Docker контейнеров
project-status

# Бэкап Docker volumes
backup-docker-volumes

# Бэкап всех проектов
backup-projects
```

## Структура сервера

```
/opt/
├── projects/          # Все ваши проекты здесь
│   ├── project1/
│   ├── project2/
│   └── ...
└── backups/           # Автоматические бэкапы

/home/
├── yan/               # Пользователь yan
├── alex/              # Пользователь alex
└── deploy/            # CI/CD пользователь
```

## Устранение проблем

### SSH доступ не работает

1. Проверьте что SSH ключ добавлен правильно
2. Проверьте права на .ssh директорию (должно быть 700)
3. Проверьте права на authorized_keys (должно быть 600)

### Git коммиты идут не от того пользователя

Каждый пользователь имеет свой .gitconfig:

```bash
cat ~/.gitconfig

# Если нужно изменить:
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Zsh плагины не работают

Переустановите плагины:

```bash
~/dotfiles/install-plugins.sh
exec zsh
```

## Документация

Полная документация доступна в файле:
```bash
cat ~/production-server-setup-guide.md
```

## Поддержка

При возникновении проблем:
1. Проверьте логи: `journalctl -xe`
2. Проверьте статус сервисов: `systemctl status docker nginx fail2ban`
3. Создайте issue в репозитории dotfiles

---

**Автор:** Yan Shishenya
**Версия:** 1.0
**Дата:** 2025-11-02
