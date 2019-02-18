# Use HEREDOC to Pass commands which should be loaded last
_POST_LOAD=""
_post_load() {
  while IFS="\n" read -r read_heredoc_line; do
    _POST_LOAD+="\n$read_heredoc_line"
  done
}

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

# Remove unwanted aliases from plugins
unalias fd
unalias rg
unalias 'G'

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

# Load asdf version manager
# https://github.com/asdf-vm/asdf
. "$HOME/.asdf/asdf.sh"

# Allow setting tab title from terminal in ITerm
if [ $ITERM_SESSION_ID ]; then
  DISABLE_AUTO_TITLE="true"
fi

# Set tab title to the current directory name after executing a command
precmd() {
  echo -ne "\033];${PWD##*/}\007"
}

# Load commands which were marked to be loaded last
while read -r i; do
  eval "$i"
done < <(echo "$_POST_LOAD")

