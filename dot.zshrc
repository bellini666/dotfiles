source /usr/share/zsh-antigen/antigen.zsh

if [ -f "$HOME/.sharedrc" ]; then
  source "$HOME/.sharedrc"
fi

# oh-my-zsh config
CASE_SENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

DISABLE_VENV_CD=1
SPACESHIP_TIME_SHOW=true
SPACESHIP_DOCKER_SHOW=false

antigen use oh-my-zsh

antigen bundle colored-man-pages
antigen bundle colorize
antigen bundle common-aliases
antigen bundle django
antigen bundle docker
antigen bundle encode64
antigen bundle extract
antigen bundle fzf
antigen bundle gitfast
antigen bundle npm
antigen bundle pip
antigen bundle python
antigen bundle screen
antigen bundle supervisor
antigen bundle systemd
antigen bundle virtualenvwrapper

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle jocelynmallon/zshmarks
antigen bundle wbingli/zsh-wakatime
antigen bundle lukechilds/zsh-nvm

antigen theme denysdovhan/spaceship-prompt

antigen apply

alias g="jump"
alias s="bookmark"
alias d="deletemark"
alias p="showmarks"

autoload -U compinit && compinit
