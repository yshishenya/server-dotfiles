# Настройка VPN (vless/Xray) для доступа к Claude Code

## Описание

Этот скрипт устанавливает и настраивает Xray vless-клиент для подключения к VPN серверу. После установки все приложения (включая Claude Code) автоматически будут работать через VPN.

## Что устанавливается

- **Xray-core** - современный VPN клиент с поддержкой протокола vless + REALITY
- **SOCKS5 прокси** на порту 1080
- **HTTP прокси** на порту 1081
- **Переменные окружения** для автоматического использования прокси
- **systemd сервис** для автозапуска VPN при загрузке системы

## Быстрый старт

### 1. Скачать репозиторий на новый сервер

```bash
cd ~
git clone https://github.com/yshishenya/server-dotfiles.git
cd server-dotfiles
```

### 2. Запустить установку VPN

```bash
sudo ./setup-vless-client.sh
```

### 3. Применить настройки

После установки нужно либо:

**Вариант А:** Выйти и войти заново
```bash
exit
# Войти снова по SSH
```

**Вариант Б:** Применить настройки в текущей сессии
```bash
source /etc/profile.d/xray-proxy.sh
```

### 4. Проверить работу

```bash
# Проверить статус VPN
systemctl status xray

# Проверить ваш IP адрес (должен быть IP VPN сервера)
curl https://api.ipify.org?format=json

# Должен показать IP: примерно 5.144.180.112 (Кыргызстан)
```

## Что настраивается автоматически

### 1. Переменные окружения

Скрипт создает `/etc/profile.d/xray-proxy.sh` с настройками:

```bash
export http_proxy="http://127.0.0.1:1081"
export https_proxy="http://127.0.0.1:1081"
export all_proxy="socks5://127.0.0.1:1080"
```

Эти переменные применяются автоматически для всех пользователей при входе.

### 2. Git через прокси

Git автоматически настраивается для работы через VPN:

```bash
git config --global http.proxy "http://127.0.0.1:1081"
git config --global https.proxy "http://127.0.0.1:1081"
```

### 3. Claude Code и другие приложения

Большинство современных приложений автоматически используют переменные окружения `http_proxy` и `https_proxy`. Claude Code будет работать через VPN без дополнительных настроек.

## Управление VPN

### Основные команды

```bash
# Проверить статус
systemctl status xray

# Остановить VPN
sudo systemctl stop xray

# Запустить VPN
sudo systemctl start xray

# Перезапустить VPN
sudo systemctl restart xray

# Посмотреть логи
journalctl -u xray -f

# Посмотреть последние 50 строк логов
journalctl -u xray -n 50
```

### Отключить автозапуск

```bash
sudo systemctl disable xray
```

### Включить автозапуск

```bash
sudo systemctl enable xray
```

## Временное отключение прокси

Если нужно временно отключить прокси для текущей сессии:

```bash
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
```

Или добавить в .zshrc функцию:

```bash
# Отключить прокси
proxy-off() {
    unset http_proxy https_proxy all_proxy
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
    echo "Proxy disabled"
}

# Включить прокси
proxy-on() {
    export http_proxy="http://127.0.0.1:1081"
    export https_proxy="http://127.0.0.1:1081"
    export all_proxy="socks5://127.0.0.1:1080"
    echo "Proxy enabled"
}
```

## Проверка подключения

### Проверить статус сервиса

```bash
systemctl status xray
```

Должно показать: `Active: active (running)`

### Проверить что порты открыты

```bash
ss -tlnp | grep -E ':(1080|1081)'
```

Должны быть видны порты 1080 и 1081.

### Проверить внешний IP

```bash
# Без прокси (если временно отключили)
curl https://api.ipify.org?format=json

# Через прокси (должен показать IP VPN сервера)
curl --proxy http://127.0.0.1:1081 https://api.ipify.org?format=json
```

### Тест скорости через VPN

```bash
curl -o /dev/null -s -w 'Total: %{time_total}s\n' https://www.google.com
```

## Конфигурация

### Файлы конфигурации

- **Конфиг Xray:** `/usr/local/etc/xray/config.json`
- **Systemd сервис:** `/etc/systemd/system/xray.service`
- **Переменные окружения:** `/etc/profile.d/xray-proxy.sh`
- **Логи:** `/var/log/xray/access.log` и `/var/log/xray/error.log`

### Параметры VPN сервера

Текущие настройки (из ключа `vless://...`):

```
Сервер:     5.144.180.112
Порт:       433
Протокол:   vless + REALITY
SNI:        house.kg
Fingerprint: chrome
Flow:       xtls-rprx-vision
```

### Изменение конфигурации

Если нужно изменить настройки VPN сервера:

1. Отредактировать `/usr/local/etc/xray/config.json`
2. Перезапустить сервис: `sudo systemctl restart xray`

## Маршрутизация трафика

Скрипт настраивает умную маршрутизацию:

### Через VPN идет:
- Весь интернет трафик (кроме исключений)
- Все HTTPS запросы
- Git операции

### Напрямую (без VPN) идет:
- Локальные адреса (`192.168.x.x`, `10.x.x.x`, `172.16.x.x`)
- localhost (`127.0.0.1`)
- Приватные сети (определяются автоматически)

### Блокируется:
- Рекламные домены (geosite:category-ads-all)

## Решение проблем

### VPN не запускается

```bash
# Проверить логи
journalctl -u xray -n 100

# Проверить конфигурацию
xray -test -config /usr/local/etc/xray/config.json
```

### Проблемы с подключением

```bash
# Проверить доступность VPN сервера
ping 5.144.180.112

# Проверить порт VPN сервера
nc -zv 5.144.180.112 433
```

### Git не работает через прокси

```bash
# Проверить настройки git
git config --global --get http.proxy
git config --global --get https.proxy

# Переустановить настройки
git config --global http.proxy "http://127.0.0.1:1081"
git config --global https.proxy "http://127.0.0.1:1081"
```

### Claude Code не работает

1. Проверить что переменные окружения установлены:
```bash
echo $http_proxy
echo $https_proxy
```

2. Если пусто, применить:
```bash
source /etc/profile.d/xray-proxy.sh
```

3. Проверить что VPN работает:
```bash
systemctl status xray
curl https://api.ipify.org?format=json
```

### Переустановка

```bash
# Остановить и удалить сервис
sudo systemctl stop xray
sudo systemctl disable xray

# Удалить Xray
sudo bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove

# Установить заново
sudo ./setup-vless-client.sh
```

## Безопасность

### Что нужно знать

- VPN использует протокол REALITY - современная обфускация трафика
- Трафик шифруется и выглядит как обычный HTTPS (house.kg)
- Fingerprint = chrome (трафик маскируется под браузер Chrome)
- Short ID и Public Key обеспечивают аутентификацию

### Смена VPN ключа

Если получили новый vless ключ:

1. Открыть скрипт: `nano /home/yan/server-dotfiles/setup-vless-client.sh`
2. Изменить переменные в начале файла:
   - `VLESS_UUID`
   - `VLESS_SERVER`
   - `VLESS_PORT`
   - и т.д.
3. Запустить заново: `sudo ./setup-vless-client.sh`

## FAQ

**Q: Нужно ли открывать порты в файрволе?**
A: Нет, клиент использует только исходящие подключения к VPN серверу.

**Q: Какая скорость VPN?**
A: Зависит от VPN сервера и канала. Обычно 50-100 Мбит/с достаточно для работы.

**Q: Работает ли VPN после перезагрузки сервера?**
A: Да, сервис автоматически запускается при загрузке системы.

**Q: Можно ли использовать несколько VPN серверов?**
A: Да, можно настроить балансировку или fallback. Нужно отредактировать config.json.

**Q: Как посмотреть статистику трафика?**
A: Через логи Xray: `journalctl -u xray | grep -E '(upload|download)'`

**Q: Влияет ли VPN на производительность?**
A: Минимально. Основное влияние - это задержка (ping) до VPN сервера.

## Дополнительные ресурсы

- [Документация Xray](https://xtls.github.io/)
- [GitHub Xray-core](https://github.com/XTLS/Xray-core)
- [REALITY протокол](https://github.com/XTLS/REALITY)

## Поддержка

При проблемах проверьте:
1. Логи сервиса: `journalctl -u xray -n 100`
2. Конфигурацию: `/usr/local/etc/xray/config.json`
3. Доступность VPN сервера: `ping 5.144.180.112`
4. Переменные окружения: `env | grep -i proxy`
