# for interactive shell user

# load features
autoload -Uz compinit && compinit
autoload -Uz colors && colors

# define functions wheather command exists or not.
exists () { (( $+commands[$1] )) }

# key binding
bindkey -e

# history
export HISTFILE="$HOME/.zhistfile"
export HISTSIZE=1000
export SAVEHIST=1000000
setopt share_history

# set alias
exists nvim && alias vi="nvim" && vim="nvim"
exists eza && alias ls="eza"
exists bat && alias cat="bat"
exists difft && alias diff="difft"

# set env
export PROMPT="%F{cyan}%n@%m:%~ %# %f"
export PAGER="less"
if exists nvim; then
  export EDITOR="nvim"
  export VISUAL="nvim"
fi

# gnupg
gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# bootstrap zinit
if [ ! -r "$HOME/.zinit/zinit.zsh" ]; then
  git clone "https://github.com/zdharma-continuum/zinit" "$HOME/.zinit" --depth=1
fi

# zinit
if [ -r "$HOME/.zinit/zinit.zsh" ]; then
  source "$HOME/.zinit/zinit.zsh"

  zinit light "zsh-users/zsh-syntax-highlighting"

  if exists fzf; then
    zinit light "Aloxaf/fzf-tab"
    zstyle ":completion:*:descriptions" format "[%d]"
    zstyle ":fzf-tab:*" fzf-flags "--border" "--color=dark"
    zstyle ":fzf-tab:*" single-group color header
    zstyle ":fzf-tab:*" default-color ""
    zstyle ":fzf-tab:*" fzf-pad 4
  fi
fi

# user binaries
if [ -r "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
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
  source "/home/main/.bun/_bun"
fi

