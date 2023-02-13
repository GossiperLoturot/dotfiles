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
exists exa && alias ls="exa"
exists bat && alias cat="bat --theme=OneHalfDark"

# set env
export PROMPT="$fg[cyan]%n@%m:%~ %# $reset_color"
export PAGER="less"
if exists nvim; then
  export EDITOR="nvim"
  export VISUAL="nvim"
fi

# bootstrap antigen
if [ ! -r "$HOME/.antigen/antigen.zsh" ]; then
  git clone "https://github.com/zsh-users/antigen" "$HOME/.antigen"
fi

# antigen
if [ -r "$HOME/.antigen/antigen.zsh" ]; then
  source "$HOME/.antigen/antigen.zsh"

  antigen bundle "zsh-users/zsh-syntax-highlighting"
  if exists fzf; then
    antigen bundle "Aloxaf/fzf-tab"
    zstyle ":completion:*:descriptions" format "[%d]"
    zstyle ":fzf-tab:*" fzf-flags "--border" "--color=dark"
    zstyle ":fzf-tab:*" single-group color header
    zstyle ":fzf-tab:*" default-color ""
    zstyle ":fzf-tab:*" fzf-pad 4
  fi

  antigen apply
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
