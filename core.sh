#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  exit 0
fi

BASE_DIR=$(dirname "${0}")
MYSELF=$(basename "${0}")

export EDITOR=nvim
export GIT_SSH=ssh

export NVIM_GTK_NO_HEADERBAR=1
export NVIM_GTK_PREFER_DARK_THEME=1

export PIP_REQUIRE_VIRTUALENV=true
export PROJECT_HOME=$HOME/dev
export WORKON_HOME=$HOME/.virtualenvs

export PERL_LOCAL_LIB_ROOT=$HOME/.local/perl

export GOBIN=$HOME/.local/bin
export GOPATH=$HOME/.go
export GOMODCACHE=$HOME/.go/pkg/mod

if which ruby >/dev/null && which gem >/dev/null; then
  PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$HOME/.neovim/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"
export PATH

function bootstrap() { (
  set -e
  cd "${BASE_DIR}"
  git pull origin master
  bash "${BASE_DIR}/utils/bootstrap.sh" "${BASE_DIR}" "${@}" || return 1
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

function dotfiles() { (
  set -e
  cd "${BASE_DIR}"
  echo "~ inside dotfiles ~"
); }

function edit-core() { (
  set -e

  CMD="nvim"
  if [ "${1}" = "-g" ]; then
    CMD="nvim-gtk"
  fi

  cd "${BASE_DIR}"
  ${CMD} . -c ":e ${MYSELF}"
); }

function edit-nvim() { (
  set -e

  CMD="nvim"
  if [ "${1}" = "-g" ]; then
    CMD="nvim-gtk"
  fi

  cd "${BASE_DIR}/config/nvim"
  ${CMD} . -c ":e init.lua"
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
