# Completion

# Enable zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)


# Use fd in fzf for rast dir/path completion
# https://github.com/sharkdp/fd
_fzf_compgen_path() {
  echo "$1"
  /usr/local/bin/fd --hidden --no-ignore '' "$1" 2>/dev/null
}

_fzf_compgen_dir() {
  /usr/local/bin/fd --hidden --no-ignore --type d '' "$1" 2>/dev/null
}

# Pass completion
_fzf_complete_pass() {
  _fzf_complete '+m' "$@" < <(
    pwdir=${PASSWORD_STORE_DIR-~/.password-store/}
    stringsize="${#pwdir}"
    find "$pwdir" -name "*.gpg" -print |
        cut -c "$((stringsize + 1))"-  |
        sed -e 's/\(.*\)\.gpg/\1/'
  )
}

# gco completion
_fzf_complete_gco() {
    local branches
    branches=$(git branch -vv --all)
    _fzf_complete "--reverse --multi" "$@" < <(
        echo "$branches"
    )
}

_fzf_complete_gco_post() {
    awk '{print $1}'
}

# FZF completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# asdf version manager
_post_load <<END
. $HOME/.asdf/completions/asdf.bash
END
