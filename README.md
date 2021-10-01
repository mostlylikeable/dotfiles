# dotfile randomness

## _**prerequisites**_

```bash
# make dev/project dir
mkdir $HOME/dev

# install homebrew
sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
brew update

# install bash 5
brew install bash
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# change default shell to zsh (already is in osx)
chsh -s $(which zsh)

# install sdkman
curl -s "https://get.sdkman.io" | bash
```

## _**setup**_

```bash
# clone repo
git clone git@github.com:mostlylikeable/dotfiles.git

# symlink dotfiles
ln -s $HOME/dev/dotfiles $HOME/.dotfiles

# set custom dotfiles dir var
export DOTFILES_CUSTOM_DIR=<custom_dotfiles_dir>

# replace .zshrc with symlink to this one
rm $HOME/.zshrc
ln -s $HOME/dev/dotfiles/sh/zshrc $HOME/.zshrc

# NOTE: $HOME/.dotfiles dir can be overridden via
# -- OPTIONAL --
export DOTFILES_DIR_OVERRIDE=<dotfiles_dir>
```

## _**testing**_

```bash
# install bats https://bats-core.readthedocs.io/en/stable/index.html
brew install bats-core

# run tests
bats test
```
