# download zsh plugin manager
git clone --depth 1 https://github.com/zplug/zplug ~/.zplug

# download neovim plugin manager
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# download dotfiles
git clone --depth 1 https://github.com/GossiperLoturot/dotfiles ~/.dotfiles

# create symbolic link
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.p10k ~/.p10k

mkdir -p ~/.config/nvim
ln -s ~/.dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua

# init zsh
source ~/.zshrc

# init neovim
neovim +PackerSync +qall
