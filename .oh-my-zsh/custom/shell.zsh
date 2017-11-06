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

expand-aliases() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]="$@"
  (($+functions[_expand-aliases]))
  echo "${functions[_expand-aliases]#$'\t'}"
}

# Use ripgrep as a pipe-grep
_post_load <<END
  alias -g G='| rg'
END
