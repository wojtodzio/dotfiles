# Path to my oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
ZSH_THEME="robbyrussell"

# Red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Custom ZSH plugins ~/.oh-my-zsh/custom/plugins/
plugins=(alias-tips)

# Oh My Zsh plugins
plugins+=(git common-aliases gem git-extras osx rails sprunge web-search docker docker-compose)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Aliases and custom function are located within ZSH_CUSTOM folder

# Prevent enter from producing ^M
stty sane

# Load iTerm2 shell integration
source "${HOME}/.iterm2_shell_integration.zsh"

# Load fzf
source ~/.fzf.zsh

# Load standalone ZSH plugins
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
## Suggests commands as you type based on your commands history
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Load rbenv
eval "$(rbenv init -)"
