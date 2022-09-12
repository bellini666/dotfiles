#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

export DOTFILES_DIR="${HOME}/.dotfiles"

export EDITOR=nvim
export GIT_SSH=ssh

export PIP_REQUIRE_VIRTUALENV=true
export PROJECT_HOME=$HOME/dev
export WORKON_HOME=$HOME/.virtualenvs

export PERL_LOCAL_LIB_ROOT=$HOME/.local/perl

export GOBIN=$HOME/.local/bin
export GOPATH=$HOME/.go
export GOMODCACHE=$HOME/.go/pkg/mod

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

if which ruby >/dev/null && which gem >/dev/null; then
  PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$HOME/.local_build/lua-language-server/bin:$PATH"
PATH="$HOME/.neovim/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"
export PATH

# https://gitlab.gnome.org/GNOME/console/-/issues/124
source /etc/profile.d/vte-2.91.sh

function bootstrap() { (
  set -e
  cd "${DOTFILES_DIR}"
  git pull origin master || true
  bash "${DOTFILES_DIR}/bootstrap.sh" "${@}" || return 1
); }

function swap2ram() { (
  set -e
  MEM=$(free | awk '/Mem:/ {print $4}')
  SWAP=$(free | awk '/Swap:/ {print $3}')

  if [ "${MEM}" -lt "${SWAP}" ]; then
    echo "ERROR: Not enough RAM to write swap back... Nothing done." >&2
    exit 1
  fi

  sudo swapoff -a || return 1
  sudo swapon -a || return 1
); }

function run-bb() { (
  set -e
  docker run \
    -it \
    --rm \
    --shm-size 2g \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "${HOME}/Downloads:/home/bank/Downloads" \
    -e DISPLAY="unix${DISPLAY}" \
    --name warsaw-browser \
    lichti/warsaw-browser bb
); }

export _DEFAULTS_SOURCED="1"
