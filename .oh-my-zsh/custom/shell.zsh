# Shell related

alias cd..='cd ..'
alias zsh_reload='source ~/.zshrc'
alias path='tr ":" "\n" <<< "$PATH"'

# Explain command or function
'$'() {
  if [[ $(type -a "$@") =~ 'function' ]]; then
    declare -f "$@"
  else
    command -v "$@"
  fi
}

# expand aliases
ea() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]="$@"
  (($+functions[_expand-aliases]))
  echo "${functions[_expand-aliases]#$'\t'}" | sed 's/_rails_command/rails/'
}

# Open a man page in Preview
pman () {
    man -t "${1}" | open -f -a /Applications/Preview.app
}

# Use ripgrep as a pipe-grep
_post_load <<END
  alias -g G='| rg'
END
