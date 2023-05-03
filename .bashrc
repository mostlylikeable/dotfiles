#!/usr/bin/env bash

# shellcheck disable=SC1090
[ -n "$PS1" ] && source ~/.bash_profile

# Configure android sdk for react-native
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
if [ -d "$ANDROID_HOME" ]; then
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# Configure sdkman if installed
export SDKMAN_DIR="$HOME/.sdkman"
# shellcheck disable=SC1091
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Init rbenv if installed
# [[ -z "$(rbenv --version 2> /dev/null)" ]] && eval "$(rbenv init - zsh)"
command -v rbenv &> /dev/null && eval "$(rbenv init - zsh)"

# Configure nvm if installed
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# shellcheck disable=SC1091
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -f "$NVM_DIR/nvm.sh" ]; then
  # Add hook to auto switch node version based on .nvmrc
  # https://stackoverflow.com/a/39519460
  # https://stackoverflow.com/a/48322289
  nvm::nvmrc_hook() {
    local node_version
    local nvmrc_path

    node_version="$(nvm version)"
    nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version
      nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        echo "node version ${nvmrc_node_version} not found, installing..."
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      echo "Reverting to nvm default version"
      nvm use default
    fi
  }

  if ! [[ "${PROMPT_COMMAND:-}" =~ nvm::nvmrc_hook ]]; then
    PROMPT_COMMAND="nvm::nvmrc_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
fi

# Add node bin scripts to path
export PATH="./node_modules/.bin:$PATH"

