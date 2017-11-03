# Shell related

alias cd..='cd ..'
alias zsh_reload='source ~/.zshrc'

# Explain command or function
'$'() {
  if [[ $(type -a "$@") =~ 'function' ]]; then
    declare -f "$@"
  else
    command -v "$@"
  fi
}

# Use ripgrep as a pipe-grep
_post_load <<END
  alias -g G='| rg'
END
