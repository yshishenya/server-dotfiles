# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting supervisor sudo z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ========================================
# 🚀 Расширенные настройки Zsh
# ========================================

# История команд
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Записывать timestamp команд
setopt HIST_EXPIRE_DUPS_FIRST    # Удалять дубликаты первыми при переполнении
setopt HIST_IGNORE_DUPS          # Не записывать дубликаты подряд
setopt HIST_IGNORE_ALL_DUPS      # Удалять старые дубликаты
setopt HIST_FIND_NO_DUPS         # Не показывать дубликаты при поиске
setopt HIST_IGNORE_SPACE         # Не записывать команды начинающиеся с пробела
setopt HIST_SAVE_NO_DUPS         # Не сохранять дубликаты
setopt HIST_REDUCE_BLANKS        # Убирать лишние пробелы
setopt SHARE_HISTORY             # Делить историю между сессиями
setopt INC_APPEND_HISTORY        # Добавлять в историю сразу

# Автодополнение
setopt ALWAYS_TO_END             # Курсор в конец слова после completion
setopt AUTO_MENU                 # Показывать меню completion после второго Tab
setopt AUTO_LIST                 # Автоматически показывать список вариантов
setopt COMPLETE_IN_WORD          # Completion в середине слова
unsetopt MENU_COMPLETE           # Не вставлять первый вариант автоматически

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colored completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Группировка completion
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# Навигация
setopt AUTO_CD                   # Переходить в директорию без cd
setopt AUTO_PUSHD                # Автоматический pushd
setopt PUSHD_IGNORE_DUPS         # Не дублировать директории в stack
setopt PUSHD_SILENT              # Не печатать stack после pushd/popd
setopt PUSHD_TO_HOME             # pushd без аргументов = pushd $HOME

# Исправление опечаток
setopt CORRECT                   # Исправлять опечатки в командах
setopt CORRECT_ALL               # Исправлять опечатки в аргументах

# Расширенный globbing
setopt EXTENDED_GLOB             # Расширенный glob (#, ~, ^)
setopt NOMATCH                   # Выдавать ошибку если glob не совпал
setopt GLOB_DOTS                 # Glob находит скрытые файлы

# Другое
setopt INTERACTIVE_COMMENTS      # Разрешить комментарии в интерактивной сессии
setopt NO_BEEP                   # Отключить beep
setopt MULTIOS                   # Множественные перенаправления

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"



# ========================================
# 🚀 Современные утилиты (замены старых команд)
# ========================================

# eza - замена ls (только если установлен)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons'
    alias ltree='eza --tree --icons'
    alias l='eza -lah --icons --group-directories-first --git'
fi

# bat - замена cat (только если установлен)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'  # с paging
    alias ccat='/usr/bin/cat'  # оригинальный cat если нужен
elif command -v batcat &> /dev/null; then
    alias bat='batcat'
    alias cat='batcat --paging=never'
    alias catp='batcat'
    alias ccat='/usr/bin/cat'
fi

# ripgrep - замена grep (только если установлен)
if command -v rg &> /dev/null; then
    alias grep='rg'
    alias oldgrep='/usr/bin/grep'  # оригинальный grep
fi

# fd - замена find (только если установлен)
if command -v fd &> /dev/null; then
    alias find='fd'
    alias oldfind='/usr/bin/find'  # оригинальный find
elif command -v fdfind &> /dev/null; then
    alias fd='fdfind'
    alias find='fdfind'
    alias oldfind='/usr/bin/find'
fi

# zoxide - умный cd (только если установлен)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias cdi='zi'  # интерактивный выбор
    alias oldcd='builtin cd'  # оригинальный cd
fi

# Git утилиты
if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi
alias gd='git diff'  # будет использовать delta автоматически
alias gl='git log --oneline --graph --decorate'

# Docker утилиты
if command -v lazydocker &> /dev/null; then
    alias ld='lazydocker'
fi
if command -v docker &> /dev/null; then
    alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    alias dcu='docker compose up -d'
    alias dcd='docker compose down'
    alias dcl='docker compose logs -f'
fi

# Системные утилиты
alias df='df -h'
if command -v ncdu &> /dev/null; then
    alias du='ncdu --color dark'
fi
alias free='free -h'
if command -v btop &> /dev/null; then
    alias top='btop'
    alias htop='btop'
fi

# Быстрые команды
alias c="clear"
alias x="exit"
alias n="nano"
alias v="vim"
alias mkd="mkdir -p"
alias rd="rmdir"

# Навигация
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Безопасность
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Полезные функции
alias ports='netstat -tulanp'
alias myip='curl ifconfig.me'
alias weather='curl wttr.in'

# fzf интеграция
alias preview='fzf --preview "bat --color=always {}"'
alias vf='vim $(fzf --preview "bat --color=always {}")'  # открыть файл через fzf в vim
# bun completions
[ -s "/home/yan/.bun/_bun" ] && source "/home/yan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export HIST_STAMPS="yyyy-mm-dd"

# ========================================
# 🎯 Полезные функции
# ========================================

# Создать директорию и перейти в нее
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Извлечь любой архив
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' не может быть извлечен" ;;
        esac
    else
        echo "'$1' не является файлом"
    fi
}

# Быстрый бэкап файла
backup() {
    cp "$1"{,.backup-$(date +%Y%m%d-%H%M%S)}
}

# Поиск процесса
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# Убить процесс по имени
killp() {
    ps aux | grep -v grep | grep "$1" | awk '{print $2}' | xargs kill -9
}

# Быстро открыть файл в vim через fzf
vif() {
    local file
    file=$(fzf --preview 'bat --color=always {}' --preview-window=right:60%)
    [ -n "$file" ] && vim "$file"
}

# Быстро перейти в директорию через fzf
cdf() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m)
    [ -n "$dir" ] && cd "$dir"
}

# Git: показать изменения в коммите
gdiff() {
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs git show --color=always' \
        --bind "enter:execute:grep -o '[a-f0-9]\{7,\}' <<< {} | head -1 | xargs git show | less -R"
}

# Docker: войти в контейнер
dexec() {
    local container
    container=$(docker ps --format '{{.Names}}' | fzf)
    [ -n "$container" ] && docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh
}

# Показать размер директорий в текущей папке
dirsize() {
    du -sh ${1:-.}/* 2>/dev/null | sort -hr
}

# Быстро найти и заменить в файлах
replace() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: replace 'old_text' 'new_text'"
        return 1
    fi
    rg "$1" --files-with-matches | xargs sed -i "s/$1/$2/g"
}

# ========================================
# 🔍 FZF интеграция
# ========================================

if command -v fzf &> /dev/null; then
    # Настройки fzf
    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --inline-info
        --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
        --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
        --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
        --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
    "

    # Использовать fd для fzf если доступен
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v fdfind &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
    fi

    # Интеграция с zsh
    if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
    if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi

    # Ctrl-R для истории с preview
    export FZF_CTRL_R_OPTS="
        --preview 'echo {}'
        --preview-window down:3:wrap
        --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort'
    "
fi

# ========================================
# 🎨 Цветные man страницы
# ========================================

export LESS_TERMCAP_mb=$'\e[1;32m'      # начало мигающего
export LESS_TERMCAP_md=$'\e[1;34m'      # начало жирного
export LESS_TERMCAP_me=$'\e[0m'         # конец режима
export LESS_TERMCAP_se=$'\e[0m'         # конец standout-mode
export LESS_TERMCAP_so=$'\e[01;44;33m'  # начало standout-mode
export LESS_TERMCAP_ue=$'\e[0m'         # конец подчеркивания
export LESS_TERMCAP_us=$'\e[1;32m'      # начало подчеркивания

# ========================================
# 💡 Система подсказок (Tips)
# ========================================

# Массив с подсказками
typeset -a TIPS
TIPS=(
    "💡 Нажми Ctrl+R для поиска в истории команд через fzf"
    "💡 Используй 'vif' чтобы открыть файл в vim через fzf с preview"
    "💡 Команда 'cdf' - выбрать директорию через fzf и перейти в нее"
    "💡 Просто введи имя папки без 'cd' для перехода (AUTO_CD включен)"
    "💡 Используй '..' для cd .. или '...' для cd ../.."
    "💡 Команда 'd' показывает stack директорий, 'cd -1' возвращает назад"
    "💡 'z projects' прыгнет в /opt/projects (zoxide запоминает куда ты ходишь)"
    "💡 'mkcd path/to/dir' создаст все папки и перейдет в них"
    "💡 'extract file.zip' распакует любой архив автоматически"
    "💡 'backup file.conf' создаст file.conf.backup-TIMESTAMP"
    "💡 'lg' запускает lazygit - визуальный TUI для Git"
    "💡 'ld' запускает lazydocker - визуальный TUI для Docker"
    "💡 'cat' теперь использует bat с подсветкой синтаксиса"
    "💡 'ls' теперь показывает иконки и Git статус (eza)"
    "💡 Ctrl+T - быстрый поиск файла, Alt+C - быстрый поиск директории"
    "💡 'gdiff' - интерактивный просмотр Git коммитов через fzf"
    "💡 'dexec' - выбрать Docker контейнер и войти в него"
    "💡 'psgrep node' найдет все процессы node"
    "💡 'dirsize' покажет размер всех директорий (отсортировано)"
    "💡 'preview' - fzf с bat preview для просмотра файлов"
    "�� Команды с пробелом в начале НЕ сохраняются в истории (для секретов)"
    "💡 История команд: 50,000 строк, без дубликатов, общая между сессиями"
    "💡 Автодополнение игнорирует регистр: 'Git' = 'git' = 'GIT'"
    "💡 'replace \"old\" \"new\"' найдет и заменит текст во всех файлах"
    "💡 'myip' покажет твой внешний IP адрес"
    "💡 'weather' покажет погоду в терминале"
    "💡 'ports' покажет все открытые порты"
    "💡 'tldr docker' - краткие примеры вместо длинного man"
    "💡 Опечатки исправляются: 'gti' → спросит 'git?'"
    "💡 'dps' - красивая таблица Docker контейнеров"
    "💡 'dcu' = docker compose up -d, 'dcd' = down, 'dcl' = logs -f"
    "💡 Ctrl+R и начни печатать для поиска команды в истории"
    "💡 'grep' теперь использует ripgrep (rg) - в 10x быстрее"
    "💡 'find' теперь использует fd - проще и быстрее"
    "💡 'top' теперь запускает btop - красивый мониторинг"
    "💡 man страницы теперь цветные!"
    "💡 'l' = 'eza -lah' - полный список с Git статусом и иконками"
    "💡 'lt' показывает дерево директорий (2 уровня)"
    "💡 rm/cp/mv теперь спрашивают подтверждение (безопасность)"
    "💡 Используй \\rm для оригинального rm без вопросов"
    "💡 'killp node' убьет все процессы node (осторожно!)"
    "💡 Набери 'tips' чтобы увидеть случайную подсказку"
    "💡 Набери 'tips-all' чтобы увидеть все подсказки"
    "💡 Документация: cat ~/dotfiles/ZSH-FEATURES.md"
    "💡 'vpn-on' включает VPN для доступа к Claude Code"
    "💡 'vpn-off' выключает VPN и переключает на прямое подключение"
    "💡 'vpn' или 'vpn-status' показывает статус VPN и текущий IP"
    "💡 'vpn-test' тестирует VPN подключение (4 проверки)"
    "💡 'novpn curl ...' выполнит команду БЕЗ VPN (временно)"
    "💡 'vpn-logs' показывает последние логи VPN"
)

# Функция показа случайной подсказки
show-tip() {
    local tip_index=$((RANDOM % ${#TIPS[@]} + 1))
    echo ""
    echo "${TIPS[$tip_index]}"
    echo ""
}

# Функция показа всех подсказок
show-all-tips() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  💡 Все доступные подсказки                                ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    for tip in "${TIPS[@]}"; do
        echo "  $tip"
    done
    echo ""
    echo "Используй 'tips' для случайной подсказки"
    echo "Документация: ~/dotfiles/ZSH-FEATURES.md"
    echo ""
}

# Алиасы
alias tips='show-tip'
alias tip='show-tip'
alias tips-all='show-all-tips'

# Показывать подсказку при запуске (не каждый раз, а случайно)
# Файл для отслеживания последней подсказки
TIP_COUNTER_FILE="${HOME}/.zsh_tip_counter"

# Создать файл если не существует
if [[ ! -f "$TIP_COUNTER_FILE" ]]; then
    echo "0" > "$TIP_COUNTER_FILE"
fi

# Прочитать счетчик
TIP_COUNTER=$(<"$TIP_COUNTER_FILE")
TIP_COUNTER=$((TIP_COUNTER + 1))

# Показывать подсказку каждые 5 запусков shell
if (( TIP_COUNTER >= 5 )); then
    show-tip
    echo "0" > "$TIP_COUNTER_FILE"
else
    echo "$TIP_COUNTER" > "$TIP_COUNTER_FILE"
fi

################################################################################
# VPN УПРАВЛЕНИЕ (Xray vless client)
################################################################################

# Быстрое включение VPN сервиса + переменных окружения
vpn-on() {
    echo "🔄 Запуск VPN..."
    sudo systemctl start xray

    # Подождать секунду для запуска
    sleep 1

    if systemctl is-active --quiet xray; then
        export http_proxy="http://127.0.0.1:1081"
        export https_proxy="http://127.0.0.1:1081"
        export all_proxy="socks5://127.0.0.1:1080"
        export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

        echo "✅ VPN включен"
        echo ""
        echo "🌍 Проверка внешнего IP..."
        local external_ip=$(curl -s --max-time 5 https://api.ipify.org?format=json 2>/dev/null | grep -o '"ip":"[^"]*"' | cut -d'"' -f4)
        if [[ -n "$external_ip" ]]; then
            echo "📍 Текущий IP: $external_ip"
        else
            echo "⚠️  Не удалось получить внешний IP"
        fi
    else
        echo "❌ Ошибка запуска VPN"
        echo "Проверьте логи: journalctl -u xray -n 20"
    fi
}

# Быстрое выключение VPN
vpn-off() {
    echo "🔄 Остановка VPN..."
    sudo systemctl stop xray

    unset http_proxy https_proxy all_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY

    echo "❌ VPN выключен"
    echo ""
    echo "🌍 Проверка внешнего IP..."
    local external_ip=$(curl -s --max-time 5 https://api.ipify.org?format=json 2>/dev/null | grep -o '"ip":"[^"]*"' | cut -d'"' -f4)
    if [[ -n "$external_ip" ]]; then
        echo "📍 Текущий IP: $external_ip"
    else
        echo "⚠️  Не удалось получить внешний IP"
    fi
}

# Перезапуск VPN
vpn-restart() {
    echo "🔄 Перезапуск VPN..."
    sudo systemctl restart xray
    sleep 1

    if systemctl is-active --quiet xray; then
        export http_proxy="http://127.0.0.1:1081"
        export https_proxy="http://127.0.0.1:1081"
        export all_proxy="socks5://127.0.0.1:1080"
        export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
        echo "✅ VPN перезапущен"
    else
        echo "❌ Ошибка перезапуска VPN"
    fi
}

# Статус VPN с деталями
vpn-status() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  🌐 Статус VPN (Xray vless client)                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Проверить статус сервиса
    if systemctl is-active --quiet xray; then
        echo "🟢 Сервис: РАБОТАЕТ"
    else
        echo "🔴 Сервис: ОСТАНОВЛЕН"
    fi

    # Проверить автозапуск
    if systemctl is-enabled --quiet xray 2>/dev/null; then
        echo "⚙️  Автозапуск: ВКЛЮЧЕН"
    else
        echo "⚙️  Автозапуск: ВЫКЛЮЧЕН"
    fi

    # Проверить порты
    echo ""
    if ss -tlnp 2>/dev/null | grep -q ":1080"; then
        echo "🔌 SOCKS5: 127.0.0.1:1080 ✅"
    else
        echo "🔌 SOCKS5: 127.0.0.1:1080 ❌"
    fi

    if ss -tlnp 2>/dev/null | grep -q ":1081"; then
        echo "🔌 HTTP:   127.0.0.1:1081 ✅"
    else
        echo "🔌 HTTP:   127.0.0.1:1081 ❌"
    fi

    # Проверить переменные окружения
    echo ""
    if [[ -n "$http_proxy" ]]; then
        echo "🌍 Прокси в ENV: $http_proxy ✅"
    else
        echo "🌍 Прокси в ENV: НЕ УСТАНОВЛЕН"
        echo "   Выполните: vpn-on (или source /etc/profile.d/xray-proxy.sh)"
    fi

    # Проверить внешний IP
    echo ""
    echo "📍 Проверка внешнего IP..."
    local external_ip=$(curl -s --max-time 5 https://api.ipify.org?format=json 2>/dev/null | grep -o '"ip":"[^"]*"' | cut -d'"' -f4)
    if [[ -n "$external_ip" ]]; then
        echo "   IP: $external_ip"

        # Определить через VPN или нет (примерно)
        if [[ "$external_ip" == "5.144.180.112" ]] || [[ "$external_ip" =~ ^5\.144\. ]]; then
            echo "   🇰🇬 Через VPN (Кыргызстан)"
        else
            echo "   🌍 Прямое подключение"
        fi
    else
        echo "   ⚠️  Не удалось получить IP"
    fi

    echo ""
    echo "Команды:"
    echo "  vpn-on       - Включить VPN"
    echo "  vpn-off      - Выключить VPN"
    echo "  vpn-restart  - Перезапустить VPN"
    echo "  vpn-logs     - Показать логи"
    echo "  novpn <cmd>  - Выполнить команду БЕЗ VPN"
    echo ""
}

# Показать логи VPN
vpn-logs() {
    local lines="${1:-50}"
    echo "📋 Последние $lines строк логов Xray:"
    echo ""
    journalctl -u xray -n "$lines" --no-pager
}

# Логи в реальном времени
vpn-logs-follow() {
    echo "📋 Логи Xray в реальном времени (Ctrl+C для выхода):"
    echo ""
    journalctl -u xray -f
}

# Выполнить команду БЕЗ прокси (временно)
novpn() {
    if [[ $# -eq 0 ]]; then
        echo "Использование: novpn <команда>"
        echo "Пример: novpn curl https://api.ipify.org"
        return 1
    fi

    (
        unset http_proxy https_proxy all_proxy no_proxy
        unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
        "$@"
    )
}

# Тест VPN подключения
vpn-test() {
    echo ""
    echo "🧪 Тестирование VPN подключения..."
    echo ""

    # Тест 1: Статус сервиса
    echo "1️⃣  Проверка сервиса Xray..."
    if systemctl is-active --quiet xray; then
        echo "   ✅ Сервис запущен"
    else
        echo "   ❌ Сервис не запущен"
        echo "   Запустите: vpn-on"
        return 1
    fi

    # Тест 2: Порты
    echo ""
    echo "2️⃣  Проверка портов прокси..."
    if ss -tlnp 2>/dev/null | grep -q ":1080" && ss -tlnp 2>/dev/null | grep -q ":1081"; then
        echo "   ✅ Порты 1080 и 1081 открыты"
    else
        echo "   ❌ Порты не открыты"
        return 1
    fi

    # Тест 3: Подключение через HTTP прокси
    echo ""
    echo "3️⃣  Тест подключения через HTTP прокси..."
    if curl -s --proxy http://127.0.0.1:1081 --max-time 10 https://api.ipify.org &>/dev/null; then
        echo "   ✅ HTTP прокси работает"
        local ip=$(curl -s --proxy http://127.0.0.1:1081 --max-time 5 https://api.ipify.org)
        echo "   IP через прокси: $ip"
    else
        echo "   ❌ HTTP прокси не работает"
        return 1
    fi

    # Тест 4: Подключение через SOCKS5
    echo ""
    echo "4️⃣  Тест подключения через SOCKS5..."
    if curl -s --socks5 127.0.0.1:1080 --max-time 10 https://api.ipify.org &>/dev/null; then
        echo "   ✅ SOCKS5 прокси работает"
    else
        echo "   ❌ SOCKS5 прокси не работает"
    fi

    echo ""
    echo "✅ Все тесты пройдены! VPN работает корректно."
}

# Алиасы для VPN
alias vpn='vpn-status'
alias vpnlogs='vpn-logs'
alias vpnlog='vpn-logs-follow'

