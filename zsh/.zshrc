# Use powerline
USE_POWERLINE="true"

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

ZVM_INIT_MODE=sourcing
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

zstyle ':completion:*' cache-path ~/.config/zsh/cache
HISTFILE=~/.config/zsh/.zhistory

source /usr/share/nvm/init-nvm.sh

bindkey '^J' autosuggest-accept
