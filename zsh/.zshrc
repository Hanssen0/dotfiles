ZVM_INIT_MODE=sourcing

zstyle ':completion:*' cache-path ~/.config/zsh/cache
HISTFILE=~/.config/zsh/.zhistory

source /usr/share/nvm/init-nvm.sh
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

bindkey '^J' autosuggest-accept

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto --hyperlink=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

export PATH=$PATH:~/.cargo/bin
export GOOGLE_CLOUD_PROJECT=gemini-code-469321

HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(/usr/bin/code --locate-shell-integration-path zsh)"

alias rm="trash"
alias icat="kitty +kitten icat"
alias vim="nvim"

eval "$(starship init zsh)"
