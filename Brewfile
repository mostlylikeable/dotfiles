# Base Brewfile — the minimal set every preset gets, composed first by
# install.sh (module fragments in brew/Brewfile.<module> are appended after).
# Keep this lean: GNU coreutils + the handful of tools the installer and shell
# assume exist. Everything opinionated lives in a module fragment.

# GNU userland (put on PATH ahead of BSD tools via gnubin in .zshenv).
brew "coreutils"
brew "findutils"
brew "gnu-sed"
brew "grep"
brew "moreutils"

# Modern shells / transfer / crypto basics.
brew "bash"
brew "curl"
brew "wget"
brew "openssh"

# Data wrangling used across scripts.
brew "jq"
brew "yq"

# Version control + the dotfiles symlink farmer itself.
brew "git"
brew "stow"
