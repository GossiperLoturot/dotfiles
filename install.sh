#!/bin/sh

cd $(dirname $0)
DOTFILES=$(pwd -P)

echo "🧵create symbolic link"

# zsh
ln -s $DOTFILES/.zshrc $HOME/.zshrc

# neovim
mkdir -p $HOME/.config/nvim
ln -s $DOTFILES/.config/nvim/init.lua $HOME/.config/nvim/init.lua

echo "💡run \"source ~/.zshrc\" to apply current zsh."
