# Server Dotfiles

Общие настройки для production серверов команды разработки.

## Содержимое

- `.zshrc` - основная конфигурация Zsh
- `.p10k.zsh` - настройки темы Powerlevel10k
- `install-plugins.sh` - скрипт установки плагинов Oh My Zsh

## Что включено

### Тема
- **Powerlevel10k** - современная и быстрая тема

### Плагины
- **git** - Git интеграция и алиасы
- **zsh-autosuggestions** - автодополнение на основе истории
- **zsh-syntax-highlighting** - подсветка синтаксиса команд
- **supervisor** - интеграция с Supervisor
- **sudo** - быстрое добавление sudo (ESC ESC)
- **z** - быстрая навигация по директориям

### Алиасы
```bash
ls='exa'           # современная замена ls
ll='exa -l'        # длинный формат
la='exa -la'       # все файлы
ltree='exa -T'     # древовидный вид
fd='fdfind'        # быстрый поиск
c="clear"          # очистка
x="exit"           # выход
n="nano"           # редактор
```

### Интеграции
- **pyenv** - менеджер версий Python
- **nvm** - менеджер версий Node.js
- **bun** - быстрый JavaScript runtime

## Установка

### Автоматическая (через главный скрипт)
```bash
curl -fsSL https://raw.githubusercontent.com/yshishenya/server-dotfiles/main/install.sh | bash
```

### Ручная
```bash
# Клонировать репозиторий
git clone https://github.com/yshishenya/server-dotfiles.git ~/dotfiles

# Установить Oh My Zsh (если еще не установлен)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Установить плагины
~/dotfiles/install-plugins.sh

# Скопировать конфиги
cp ~/dotfiles/.zshrc ~/.zshrc
cp ~/dotfiles/.p10k.zsh ~/.p10k.zsh

# Применить изменения
source ~/.zshrc
```

## Индивидуальные настройки

### Git конфигурация
Git конфигурация (.gitconfig) **НЕ** хранится в этом репозитории - каждый пользователь настраивает свою:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Дополнительные алиасы
Если хотите добавить свои алиасы, создайте файл `~/.zshrc.local`:

```bash
# ~/.zshrc.local
alias myalias='my command'
```

И добавьте в конец `~/.zshrc`:
```bash
# Load local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

## Требования

- Ubuntu 22.04+ / Debian 11+
- Zsh 5.8+
- Git
- Curl

## Обновление

```bash
cd ~/dotfiles
git pull
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh
source ~/.zshrc
```

## Поддержка

При возникновении проблем создайте issue в репозитории.

---

**Автор:** Yan Shishenya
**Лицензия:** MIT
