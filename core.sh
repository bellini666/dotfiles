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

if [ -d "${HOME}/bin" ]; then
  export PATH=${HOME}/bin:${PATH}
fi

if [ -d "${HOME}/.rd/bin/" ]; then
  export PATH=${HOME}/.rd/bin/:${PATH}
fi

if [ -f "${HOME}/.secret_env.sh" ]; then
  # shellcheck disable=1091
  source "${HOME}/.secret_env.sh"
fi

export EDITOR=nvim
export GIT_SSH=ssh

# mise
export MISE_USE_TOML=1
export MISE_EXPERIMENTAL=1
export MISE_PIPX_UVX=1

# perl
export PERL_LOCAL_LIB_ROOT="${HOME}/.local/perl"

# pip
export PIP_REQUIRE_VIRTUALENV=true

# riggrep
export RIPGREP_CONFIG_PATH="${HOME}/.dotfiles/rg/ripgreprc"

# python
export PYTHON_CFLAGS="-march=native -mtune=native"
export PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-lto"

function bootstrap() { (
  set -e
  cd "${DOTFILES_DIR}"
  git pull origin master || true
  bash "${DOTFILES_DIR}/bootstrap.sh" "${@}" || return 1
); }

export _DEFAULTS_SOURCED="1"
