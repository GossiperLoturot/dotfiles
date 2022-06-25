# history
HISTFILE="~/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000000
setopt share_history

# set alias and default editor, zsh keybind
alias ls="exa --icons"
alias l="exa -al --icons"
alias cat="bat"
alias vi="nvim"
alias vim="nvim"
export BAT_THEME="OneHalfDark"
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"
bindkey -e

# zplug
if [[ -r "~/.zplug/init.zsh" ]]; then
	source "~/.zplug/init.zsh"

	zplug "Aloxaf/fzf-tab"
	zplug "romkatv/powerlevel10k", as:theme
	zplug "zsh-users/zsh-syntax-highlighting"
	zplug "zplug/zplug", hook-build:"zplug --self-manage"

	zplug load --verbose
fi

# completion
zstyle ":completion:*:descriptions" format "[%d]"
zstyle ":fzf-tab:*" fzf-flags "--border" "--color=dark"
zstyle ':fzf-tab:*' single-group color header
zstyle ":fzf-tab:*" default-color ""
zstyle ":fzf-tab:*" fzf-pad 4

# powerlevel10k
if [[ -r "~/.p10k.zsh" ]]; then
	source "~/.p10k.zsh"
fi

clear
