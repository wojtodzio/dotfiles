# Shell related

alias cd..='cd ..'
alias zsh_reload='exec zsh'
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

only_files() {
  for i in $@; do
    [ -f "$i" ] && echo "$i"
  done
}

setTabTitle() {
  echo -ne "\033];$1\007"
}

setTabTitlePernamently() {
  echo -n "$1" > .tab-title
}

setTabTitleFromPath() {
  if [ -e "$1/.tab-title" ]; then
    setTabTitle "$(cat $1/.tab-title)"
  else
    setTabTitle "${1##*/}"
  fi
}

setTabTitleFromContext() {
  local git_toplevel_path="$(git rev-parse --show-toplevel 2> /dev/null)"
  if [ -n "$git_toplevel_path" ]; then
    setTabTitleFromPath "$git_toplevel_path"
  else
    setTabTitleFromPath "$PWD"
  fi
}

# Use ripgrep as a pipe-grep
_post_load <<END
  alias -g G='| rg'
END
