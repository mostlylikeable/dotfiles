# dotfile randomness

## setup
* symlink to dotfiles
  - `ln -s $<PROJECT_DIR>/dotfiles $HOME/.dotfiles`
* configure custom .sh file dir, if you need one
  - set env variable `DOTFILES_CUSTOM_DIR`
  - *all .sh files in this dir will be sourced*
* symlink to zshrc (or copy init lines from zshrc to yours)
  - `ln -s $<PROJECT_DIR>/dotfiles/sh/zshrc $HOME/.zshrc`
* _NOTE: you can override `$HOME/.dotfiles` dirname with env var `DOTFILES_DIR_OVERRIDE`_
