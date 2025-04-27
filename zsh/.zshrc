# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use powerline
USE_POWERLINE="true"

ZVM_INIT_MODE=sourcing

zstyle ':completion:*' cache-path ~/.config/zsh/cache
HISTFILE=~/.config/zsh/.zhistory

source /usr/share/nvm/init-nvm.sh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

bindkey '^J' autosuggest-accept

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

export PATH=$PATH:~/.cargo/bin

HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(/usr/bin/code --locate-shell-integration-path zsh)"

alias rm="trash"
