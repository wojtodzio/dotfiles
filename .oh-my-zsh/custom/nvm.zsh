# NVM
## Node and npm loading is super slow, so I'm lazy-loading it
## https://github.com/creationix/nvm/issues/539#issuecomment-245791291

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" --no-use # This setups nvm to be lazy-loaded
 
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

# Alias node, npm, and yarn to access node lazily. We reset the alias on cd to ensure we always use
# the right nvm version when in a new folder (respecting the nvmrc if possible).
alias node='unalias node ; unalias npm ; unalias yarn ; export NVM_LOADED_FOR_PATH=1 ; load-nvmrc ; node $@';
alias npm='unalias node ; unalias npm ; unalias yarn ; export NVM_LOADED_FOR_PATH=1 ; load-nvmrc ; npm $@';
alias yarn='unalias node ; unalias npm ; unalias yarn ; export NVM_LOADED_FOR_PATH=1 ; load-nvmrc ; yarn $@';

unset_nvm() {
  if [[ "$NVM_LOADED_FOR_PATH" -eq 1 ]]; then
    export NVM_LOADED_FOR_PATH=0
    alias node='unalias node ; unalias npm ; unalias yarn ; export NVM_LOADED_FOR_PATH=1 ; load-nvmrc ; node $@';
    alias npm='unalias node ; unalias npm ; unalias yarn ; export NVM_LOADED_FOR_PATH=1 ; load-nvmrc ; npm $@';
    alias yarn='unalias node ; unalias npm ; unalias yarn ; export NVM_LOADED_FOR_PATH=1 ; load-nvmrc ; yarn $@';
  fi
}

add-zsh-hook chpwd unset_nvm
