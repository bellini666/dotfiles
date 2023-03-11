#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

export DOTFILES_DIR="${HOME}/.dotfiles"

export EDITOR=nvim
export GIT_SSH=ssh

export PIP_REQUIRE_VIRTUALENV=true
export PERL_LOCAL_LIB_ROOT=$HOME/.local/perl

PATH="$HOME/.local_build/lua-ls/bin:$PATH"
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:${PATH}"
[[ ":$PATH:" != *":$HOME/bin:"* ]] && PATH="$HOME/bin:${PATH}"
export PATH

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

export _DEFAULTS_SOURCED="1"
