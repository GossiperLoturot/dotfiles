#!/bin/sh

cd $(dirname $0)
DOTFILES=$(pwd -P)

echo "🧵create symbolic link"

# zsh
if [ -f $HOME/.zshrc ]; then
    echo "⚠️ $HOME/.zshrc already exists."
    exit 1
fi
ln -s $DOTFILES/.zshrc $HOME/.zshrc

# neovim
if [ -d $HOME/.config/nvim ]; then
    echo "⚠️ $HOME/.config/nvim already exists."
    exit 1
fi
mkdir $HOME/.config
ln -s $DOTFILES/.config/nvim $HOME/.config/

# success
echo "💡run \"source ~/.zshrc\" to apply current zsh."
