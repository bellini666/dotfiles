#!/bin/bash

function bootstrap() { (
  # mise reads .miserc.toml before it applies -C, so this has to cd.
  cd "${DOTFILES_DIR}" || exit 1
  git pull origin master || true
  mise self-update -y || true
  mise bootstrap --yes --force-dotfiles --update --upgrade "${@}"
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

# safehouse aborts on a grant whose path doesn't exist.
function _existing_paths() {
  local p joined=""
  for p in "${@}"; do
    [ -e "${p}" ] && joined+=":${p}"
  done
  printf '%s' "${joined#:}"
}

SAFEHOUSE_ADD_DIRS="$(_existing_paths \
  "${HOME}/.cache/prek" "${HOME}/.cache/ty" "${HOME}/.cache/pnpm" "${HOME}/.cache/helm" \
  "${HOME}/.cache/huggingface" "${HOME}/.cache/rtk-hook-version-ok" \
  "${HOME}/Library/Application Support/rtk" "${HOME}/.local/state/herdr" \
  "${HOME}/.wakatime" "${HOME}/.wakatime.cfg" "${HOME}/dev/_tmp")"
export SAFEHOUSE_ADD_DIRS
SAFEHOUSE_ADD_DIRS_RO="$(_existing_paths \
  "${HOME}/Library/Caches/Homebrew" \
  "${HOME}/.gitconfig" "${HOME}/.gitignore" "${HOME}/.gitattributes" \
  "${HOME}/.npmrc" "${HOME}/.dotfiles" "/Applications/Ghostty.app" \
  "${HOME}/dev" "${HOME}/Downloads" "${HOME}/.config/ponytail")"
export SAFEHOUSE_ADD_DIRS_RO

SAFEHOUSE_ENV_PASS="CLAUDE_CONFIG_DIR,CLAUDE_CODE_NO_FLICKER,CLAUDE_CODE_SUBAGENT_MODEL"
SAFEHOUSE_ENV_PASS+=",DOTFILES_DIR,GIT_SSH,GIT_EDITOR,RIPGREP_CONFIG_PATH,LESS,PAGER,PIP_REQUIRE_VIRTUALENV"
SAFEHOUSE_ENV_PASS+=",GOPATH,GOBIN,GOROOT,CARGO_HOME,RUSTUP_HOME,RUSTUP_TOOLCHAIN"
SAFEHOUSE_ENV_PASS+=",DENO_INSTALL_ROOT,PERL_LOCAL_LIB_ROOT,COREPACK_ENABLE_AUTO_PIN"
SAFEHOUSE_ENV_PASS+=",XDG_DATA_DIRS,TERMINFO,GHOSTTY_RESOURCES_DIR,SENTRY_ACCESS_TOKEN,SENTRY_HOST"
SAFEHOUSE_ENV_PASS+=",HERDR_ENV,HERDR_PANE_ID,HERDR_SOCKET_PATH"
# Project mise configs extend these with templates that fail on an undefined var.
SAFEHOUSE_ENV_PASS+=",SAFEHOUSE_ADD_DIRS,SAFEHOUSE_ADD_DIRS_RO,SAFEHOUSE_ENV_PASS"
export SAFEHOUSE_ENV_PASS

SAFEHOUSE_ENABLE="docker,playwright-chrome,ssh,shell-init,herdr"

if [ "$(uname -s)" = "Darwin" ]; then
  function safe() {
    local args=()
    local rest="${SAFE_PROFILES:-}"

    # zsh doesn't word-split unquoted variables, so walk the colons by hand.
    while [ -n "${rest}" ]; do
      args+=(--append-profile="${rest%%:*}")
      case "${rest}" in
      *:*) rest="${rest#*:}" ;;
      *) rest="" ;;
      esac
    done

    # Last so a project profile can't override it. Opening on ~ means full access.
    if [ "$(pwd -P)" != "${HOME}" ]; then
      args+=(--append-profile="${DOTFILES_DIR}/safehouse/deny.sb")
    fi

    local child_env=()
    if [ -n "${SAFE_CHILD_ENV:-}" ]; then
      child_env=("${SAFE_CHILD_ENV}")
    fi

    env "${child_env[@]}" safehouse --enable="${SAFEHOUSE_ENABLE}${SAFE_ENABLE:+,${SAFE_ENABLE}}" \
      --append-profile="${DOTFILES_DIR}/safehouse/extra.sb" \
      "${args[@]}" -- "${@}"
  }
else
  # safehouse wraps sandbox-exec, which only exists on macOS.
  function safe() {
    command "${@}"
  }
fi

function claude() {
  safe claude --permission-mode "${CLAUDE_PERMISSION_MODE:-bypassPermissions}" --plugin-dir "${DOTFILES_DIR}/agents" "${@}"
}

function opencode() {
  # Safehouse can't match opencode's profile through `npx opencode-ai`.
  SAFEHOUSE_ADD_DIRS="${SAFEHOUSE_ADD_DIRS}:$(_existing_paths \
    "${HOME}/.config/opencode" "${HOME}/.local/share/opencode" \
    "${HOME}/.cache/opencode" "${HOME}/.opencode")" \
    safe npx opencode-ai@latest "${@}"
}

function codex() {
  safe codex --ask-for-approval never --sandbox danger-full-access "${@}"
}

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
elif [ -d "/opt/homebrew/bin" ]; then
  # mise pours formulae into this prefix without installing Homebrew itself.
  export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:${PATH}
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

# less: keep colors (R) and leave output in scrollback instead of the
# alternate screen (X). No F: it skips paging on some long outputs.
export LESS=-RX

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

export _DEFAULTS_SOURCED="1"
