# download
echo "🚚download dotfiles"
git clone --depth 1 https://github.com/GossiperLoturot/dotfiles ~/.dotfiles

# create symbolic link
echo "🧵create symbolic link"
ln -s ~/.dotfiles/.zshrc ~/.zshrc

mkdir -p ~/.config/nvim
ln -s ~/.dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua

# message
echo "⚠️reload zsh. e.g. run \"source ~/.zshrc\""
