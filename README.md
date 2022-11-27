# dotfiles

> My `dotfiles`. _Probably won't work for you._ :)

_I use `zsh`, so not everything will play nice with other shells most likely._

_Inspired by `dotfiles` by
[mathiasbynens](https://github.com/mathiasbynens) and various other things.
I've tried to give credit where appropriate, but definitely check me on that
if I've missed a spot._

---
## Prerequisites

```shell
# install homebrew
sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
brew update

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Apps

Optionally install these apps:

- [XCode](https://developer.apple.com/xcode/) (download from website for less flakiness)
- [Android Studio](https://developer.android.com/studio)
- [VSCode](https://code.visualstudio.com/docs/setup/mac)
- [Sublime Text](https://www.sublimetext.com/3)
- Firefox/Chrome
- [Notion](https://www.notion.so/desktop)

#### VSCode Extensions

_Common_

- _EditorConfig_

_JS/TS_

- _JavaScript and TypeScript_
- _React Native Tools_
- _ESLint_

_Python_

- _Python_

---
## Install

_**WARNING**: You'll be prompted but be warned that bootstrapping will overwrite
various files in `$HOME`, like `.zsh_profile`, `.gitconfig`, etc._

### Custom dotfiles

Custom dotfile config can be added in `~/.dotfiles-custom`, and will be applied
via bootstrap / sourcing.

### Bootstrap

Clone the repo and bootstrap your env, which will copy various config files
to `$HOME`, as well as source the files from the repo.

```shell
git clone https://github.com/mostlylikeable/dotfiles && cd dotfiles && source bootstrap.sh
```

This will create a `~/.dotfiles` symlink to the repo, and will copy the
configuration files to `$HOME`.

Configure your git info

```shell
git config --global user.name "<your name>"
git config --global user.email "<your email>"
```

### Install Homebrew Formulae

```shell
# install homebrew
sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# update brew and install various formulas (requires repo to be cloned)
source ./brew.sh
```

### Install Ruby

For react-native development, install [the correct version](https://github.com/facebook/react-native/blob/main/template/_ruby-version) of ruby.

```shell
# rbenv install 2.7.6
rbenv install <version>
```

### Install Volta

For Node version management, install [Volta](https://docs.volta.sh).

```shell
# volta setup is already added to .zshrc
curl https://get.volta.sh | bash -s -- --skip-setup
```
