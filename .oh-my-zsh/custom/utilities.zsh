# Utilities

weather() {
  local city="${1:-'Bielsko'}"
  curl -4 http://wttr.in/"$city"
}

# Figlet fuzzy font selector with preview => copy to clipboard
fgl() (
  [ $# -eq 0 ] && return
  cd /usr/local/Cellar/figlet/*/share/figlet/fonts
  local font=$(ls *.flf | sort | fzf --no-multi --reverse --preview "figlet -f {} $@") &&
  figlet -f "$font" "$@" | pbcopy
)

# Fuzzy pass selector => copy to clipboard
fp() {
  local key=$(for i in ~/.password-store/*; do basename "${i%%.gpg}"; done | fzf)
  [ -n "$key" ] && pass -c "$key"
}

# Fuzzy pass selector => show full info
fpf() {
  local key=$(for i in ~/.password-store/*; do basename "${i%%.gpg}"; done | fzf)
  [ -n "$key" ] && pass "$key"
}
