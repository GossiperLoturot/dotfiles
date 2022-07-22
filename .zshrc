# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000
export SAVEHIST=1000000
setopt share_history

# set alias and default editor, zsh keybind
alias ls="exa --icons"
alias cat="bat --theme=OneHalfDark"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
bindkey -e

# bootstraps zplug
if [ ! -r "$HOME/.zplug/init.zsh" ]; then
	git clone "https://github.com/zplug/zplug" "$HOME/.zplug"
fi

# zplug
if [ -r "$HOME/.zplug/init.zsh" ]; then
	source "$HOME/.zplug/init.zsh"

	zplug "Aloxaf/fzf-tab"
	zplug "zsh-users/zsh-syntax-highlighting"
	zplug "zplug/zplug", hook-build:"zplug --self-manage"

	if ! zplug check; then
		zplug install
	fi

	zplug load
fi

# prompt
export PROMPT="$fg[cyan]%n@%m:%~ %# $reset_color"

# completion
zstyle ":completion:*:descriptions" format "[%d]"
zstyle ":fzf-tab:*" fzf-flags "--border" "--color=dark"
zstyle ":fzf-tab:*" single-group color header
zstyle ":fzf-tab:*" default-color ""
zstyle ":fzf-tab:*" fzf-pad 4
