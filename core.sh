#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

if [ -d "/opt/homebrew/bin" ]; then
  export PATH=/opt/homebrew/bin:${PATH}
fi

export RTX_USE_TOML=1
export DOTFILES_DIR="${HOME}/.dotfiles"
if [ -f "${HOME}/.secret_env.sh" ]; then
  # shellcheck source=/home/bellini/.secret_env.sh
  source "${HOME}/.secret_env.sh"
fi

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
