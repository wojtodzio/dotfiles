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

source ~/.secrets

