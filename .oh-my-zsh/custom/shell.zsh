# Shell related

alias cd..='cd ..'
alias zsh_reload='source ~/.zshrc'

# Explain command
alias '$'='command -v'

# Explain function
alias '$f'='declare -f'

# Use ripgrep as a pipe-grep
_post_load <<END
  alias -g G='| rg'
END
