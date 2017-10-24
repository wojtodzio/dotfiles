# Ruby related

alias re='pry-remote'

## Eval passed commands (inside HEREDOC) with global version of Ruby
inline_global_ruby() {
  rbenv shell $(rbenv global)

  while IFS="\n" read -r read_heredoc_line; do
    eval "$read_heredoc_line"
  done

  rbenv shell --unset
}
