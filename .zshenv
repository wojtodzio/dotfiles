# PATH
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"

# Language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Use vim as default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# Use libc++ (llvm) from brew
## /usr/local/opt/llvm = brew --prefix llvm
## I'm using a hardcoded value here to speed up shell start
export LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
export CFLAGS="-I/usr/local/opt/llvm/include"

# Add OpenSSL PKG_CONFIG path (required by Crystal's Lucky framework)
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

# GPG
export GPG_TTY=$(tty)

# Setup lesspipe for better less for binary files
export LESSOPEN="|/usr/local/bin/lesspipe.sh %s" LESS_ADVANCED_PREPROCESSOR=1

# Homebrew
## I'm using hardcoded value to speed up shell start
export HOMEBREW_PREFIX="/usr/local"

# FZF
## Show certain number of lines in preview window
export FZF_PREVIEW_LINES=1000

## Use fd for rast dir/path traversal
export FZF_DEFAULT_COMMAND="/usr/local/bin/fd --hidden --no-ignore '' 2>/dev/null"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="/usr/local/bin/fd --hidden --no-ignore --type d '' 2>/dev/null"

## Preview dir tree on alt-c
export FZF_ALT_C_OPTS="--no-height --preview 'tree -C {} | head -'$FZF_PREVIEW_LINES"

## Press ? to toggle preview for too long commands
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

## Preview files with syntax highlight on ctrl-t
export FZF_CTRL_T_OPTS="--no-height
                        --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'
                        --preview 'file --mime {} | grep \"binary\" | grep -qv \"directory\" &&
                                   echo {} is a binary file ||
                                   (bat {} --color=always ||
                                    cat {} ||
                                    tree -C {}) 2> /dev/null | head -'$FZF_PREVIEW_LINES"

# Usage in scripts: eval $DEBUGGER
export DEBUGGER='while IFS="\n" read -erp "[$(basename ${BASH_SOURCE[0]}):$LINENO]> " command_to_execute; do
                   eval "$command_to_execute";
                 done;
                 echo'

# Enable history in iex
export ERL_AFLAGS="-kernel shell_history enabled"

source ~/.secrets

