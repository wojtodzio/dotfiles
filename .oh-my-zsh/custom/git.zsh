# Git related

## gco with fuzzy branch selector
alias gcof='gco $(_fgb)'

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

# Fuzzy status viewer with changes preview
_fgf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
    fzf-tmux -m --ansi --nth 2..,.. \
      --preview 'git diff --color=always -- {-1} | diff-so-fancy | head -500' | cut -c4- | sed 's/.* -> //'
}

# Fuzzy branch selector with commits logs
_fgb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf-tmux --ansi --multi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --color=always --date=short --pretty="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##'
}

# Fuzzy history viewer
_fgh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
    fzf-tmux --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'Press CTRL-S to toggle sort' \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | diff-so-fancy | head -'$LINES |
    grep -o "[a-f0-9]\{7,\}"
}

join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

# Bind _fg{f,b,h} to ^g^{f,b,h}
bind-git-helper() {
  for c in "$@"; do
    eval "fzf-g$c-widget() { local result=\$(_fg$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-g$c-widget"
    eval "bindkey '^g^$c' fzf-g$c-widget"
  done
}
bind-git-helper f b h
unset -f bind-git-helper
