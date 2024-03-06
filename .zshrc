# for interactive shell user

# load features
autoload -Uz compinit && compinit
autoload -Uz colors && colors
exists() { (( $+commands[$1] )) }

# key binding
bindkey -e

# history
export HISTFILE="$HOME/.zhistfile"
export HISTSIZE=1000
export SAVEHIST=1000000
setopt share_history

# set alias
exists eza && alias ls="eza"
exists bat && alias cat="bat --theme=OneHalfDark"
exists difft && alias diff="difft"

# set env
# export PROMPT="$fg[cyan]%n@%m:%~ %# $reset_color"
export PROMPT="%F{cyan}%n@%m:%~ %# %F"
export PAGER="less"
if exists nvim; then
  export EDITOR="nvim"
  export VISUAL="nvim"
fi
export GPG_TTY="$(tty)"

# bootstrap antigen
if [ ! -r "$HOME/.zplug/init.zsh" ]; then
  git clone "https://github.com/zplug/zplug" "$HOME/.zplug"
fi

# antigen
if [ -r "$HOME/.zplug/init.zsh" ]; then
  source "$HOME/.zplug/init.zsh"

  zplug "zsh-users/zsh-syntax-highlighting"
  if exists fzf; then
    zplug "Aloxaf/fzf-tab"
    zstyle ":completion:*:descriptions" format "[%d]"
    zstyle ":fzf-tab:*" fzf-flags "--border" "--color=dark"
    zstyle ":fzf-tab:*" single-group color header
    zstyle ":fzf-tab:*" default-color ""
    zstyle ":fzf-tab:*" fzf-pad 4
  fi

  if ! zplug check; then
    zplug install
  fi

  zplug load
fi

# cargo
if [ -r "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"

	# sccache
	if exists sccache; then
		export RUSTC_WRAPPER="sccache"
	fi

	# mold
	if exists mold; then
		export RUSTFLAGS="-C link-arg=-fuse-ld=mold"
	fi
fi

# bun
if [ -r "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# ghc
if [ -f "/home/main/.ghcup/env" ]; then
    source "/home/main/.ghcup/env"
fi

