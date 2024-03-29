#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

export LANG=en_US.UTF-8

export DOTFILES_DIR="${HOME}/.dotfiles"

if [ -d "/opt/homebrew/bin" ]; then
  export PATH=/opt/homebrew/bin:${PATH}
fi

if [ -d "/opt/homebrew/sbin" ]; then
  export PATH=/opt/homebrew/sbin:${PATH}
fi

if [ -d "${HOME}/.local/bin" ]; then
  export PATH=${HOME}/.local/bin:${PATH}
fi

if [ -d "${HOME}/.bin" ]; then
  export PATH=${HOME}/.bin:${PATH}
fi

if [ -f "${HOME}/.secret_env.sh" ]; then
  # shellcheck disable=1091
  source "${HOME}/.secret_env.sh"
fi

export MISE_USE_TOML=1
export MISE_EXPERIMENTAL=1

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
