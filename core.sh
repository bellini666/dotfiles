#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

export LANG=en_US.UTF-8

export DOTFILES_DIR="${HOME}/.dotfiles"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
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

# go
export GOPATH="${HOME}/.go"

# perl
export PERL_LOCAL_LIB_ROOT="${HOME}/.local/perl"

# pip
export PIP_REQUIRE_VIRTUALENV=true

# ripgrep
export RIPGREP_CONFIG_PATH="${DOTFILES_DIR}/rg/ripgreprc"

# python
export PYTHON_CFLAGS="-march=native -mtune=native"
export PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-lto"

function bootstrap() { (
  set -e
  cd "${DOTFILES_DIR}"
  git pull origin master || true
  bash "${DOTFILES_DIR}/bootstrap.sh" "${@}" || return 1
); }

function vi() {
  local activate_path
  local current_dir

  # Check for existing virtual environment that matches current directory
  if [ -n "${VIRTUAL_ENV}" ] && [ -d "${VIRTUAL_ENV}" ] && [ -f "${VIRTUAL_ENV}/bin/activate" ]; then
    activate_path="${VIRTUAL_ENV}/bin/activate"
  fi

  # Search for venv in current and parent directories
  if [ -z "${activate_path}" ]; then
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      # Check common venv directory names
      for venv_dir in ".venv" "venv"; do
        if [ -f "$current_dir/$venv_dir/bin/activate" ]; then
          activate_path="$current_dir/$venv_dir/bin/activate"
          break 2
        fi
      done
      current_dir="$(dirname "$current_dir")"
    done
  fi

  # Check for Poetry environment (only if pyproject.toml exists to avoid slow calls)
  if [ -z "${activate_path}" ]; then
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      if [ -f "$current_dir/pyproject.toml" ]; then
        if command -v poetry &>/dev/null && grep -q '\[tool\.poetry\]' "$current_dir/pyproject.toml" 2>/dev/null; then
          local poetry_venv
          poetry_venv=$(poetry env info --path -C "$current_dir" 2>/dev/null)
          if [ -n "${poetry_venv}" ] && [ -f "${poetry_venv}/bin/activate" ]; then
            activate_path="${poetry_venv}/bin/activate"
          fi
        fi
        break
      fi
      current_dir="$(dirname "$current_dir")"
    done
  fi

  if [ -n "${activate_path}" ] && [ -f "${activate_path}" ]; then
    # shellcheck disable=1090
    source "${activate_path}"
  fi

  nvim "${@}"
}

function opencode() {
  XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}${XDG_DATA_EXTRA:-}" npx opencode-ai@latest "${@}"
}

export _DEFAULTS_SOURCED="1"
