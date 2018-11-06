# System related

alias battery_percentage='pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto \
                           | cut -f1 -d";"'
alias battery_time='pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto \
                     | cut -f3 -d";"'
alias current_finder_path='osascript -e "tell app \"Finder\" to \
                            POSIX path of (insertion location as alias)"'

# Fuzzy file finder with syntax-higlighted preview
pfzf() {
  fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                   echo {} is a binary file ||
                   (coderay {} ||
                    highlight -O ansi -l {} ||
                    rougify {} ||
                    cat {}) 2> /dev/null | head -500'
}

# Update (one or multiple) selected application(s)
# mnemonic [B]rew [U]pdate [P]lugin
bup() {
  local upd=$(brew leaves | fzf -m)

  if [[ $upd ]]; then
    for prog in $upd; do
      brew upgrade "$prog"
    done
  fi
}

# Delete (one or multiple) selected application(s)
# mnemonic [B]rew [C]lean [P]lugin (e.g. uninstall)
bcp() {
  local uninst=$(brew leaves | fzf -m)

  if [[ $uninst ]]; then
    for prog in $uninst; do
      brew uninstall "$prog"
    done
  fi
}

# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]lugin
bip() {
  local inst=$(brew search | fzf -m)

  if [[ $inst ]]; then
    for prog in $inst; do
      brew install "$prog"
    done
  fi
}

# Open Muse app for a better touch bar sound control
# and close cnnflicting NowPlayingTouchUI
muse() {
  open -a Muse
  (sleep 1 && killall NowPlayingTouchUI) &
}


# Sudo with TouchID support
# It does not allow for running interactive applications (e.g. VIM)
_t() {
  osascript -e "do shell script \"$*\" with administrator privileges"
}

alias restart_touchbar='((_t pkill "TouchBarServer" && sleep 0.5 && killall Muse && sleep 0.5 && muse) &) NUL'
alias fast_relog="_t killall -HUP WindowServer"

