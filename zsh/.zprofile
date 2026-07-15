# ~/.zprofile — sourced for LOGIN shells only, after .zshenv.
# Use this for login-time setup and guarded, machine-specific PATH appends.
# The canonical PATH is assembled once in .zshenv; this file may only APPEND
# guarded, machine-specific directories (per AGENTS.md rule 6).

# Homebrew shellenv fallback: some login contexts (e.g. a bare SSH login) may not
# have picked up the Homebrew PATH from .zshenv. Re-applying is idempotent and cheap.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Android SDK (React Native). Appended only when the SDK is actually present.
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  path+=(
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/platform-tools"
  )
fi
