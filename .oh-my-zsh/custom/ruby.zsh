# Ruby related

alias re='pry-remote'

rspec() {
  if [ -e "bin/rspec" ]; then
    bin/rspec $@
  elif type bundle &> /dev/null && [ -e "Gemfile" ]; then
    bundle exec rspec $@
  else
    command rspec $@
  fi
}

# Eval passed commands (inside HEREDOC) with global version of Ruby
inline_global_ruby() {
  export ASDF_RUBY_VERSION="$(cat ~/.tool-versions | grep ruby | cut -d ' ' -f 2)"

  while IFS="\n" read -r read_heredoc_line; do
    eval "$read_heredoc_line"
  done

  unset ASDF_RUBY_VERSION;
}
