#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "${0}")" && pwd)"

UNAME_OUTPUT="$(uname -s)"
case "${UNAME_OUTPUT}" in
Linux*) export MISE_ENV="linux" ;;
Darwin*) export MISE_ENV="macos" ;;
*)
  echo "Unknown OS: ${UNAME_OUTPUT}"
  exit 1
  ;;
esac

LOCAL_BIN_DIR="${HOME}/.local/bin"
MISE_CONFIG_DIR="${HOME}/.config/mise"
MISE_BINARY="${LOCAL_BIN_DIR}/mise"

# Everything else mise creates itself: `[dotfiles]` targets get their parent
# dirs, and the mise config dir must exist before mise can read it.
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${MISE_CONFIG_DIR}"

# `[bootstrap.hooks]` run in this process's environment, so they need mise on
# PATH even on a machine whose shell predates the install below.
export PATH="${LOCAL_BIN_DIR}:${PATH}"

function info {
  set +x
  echo
  echo "=== ${1} ==="
  echo
  set -x
}

function _pre {
  info "preparing mise"

  # Deliberately not brew on macOS: the brew backend unlinks formulae it is
  # about to repour, and a brew-owned mise would delete its own binary
  # mid-run whenever a new mise is released.
  [ -x "${MISE_BINARY}" ] || curl https://mise.run | sh
  "${MISE_BINARY}" self-update -y || true

  # The global config must exist before mise can read [tools]; everything else
  # is symlinked declaratively from mise.toml's [dotfiles] during bootstrap.
  ln -sfn "${BASE_DIR}/mise/config.toml" "${MISE_CONFIG_DIR}/config.toml"
}

function _mise-bootstrap {
  info "running mise bootstrap"
  (
    cd "${BASE_DIR}"
    "${MISE_BINARY}" bootstrap --yes --force-dotfiles --update
  )
}

function _mise {
  info "updating mise"

  (
    if [ -f "${HOME}/.mise_secret_env.sh" ]; then
      set +x
      # shellcheck disable=1091
      source "${HOME}/.mise_secret_env.sh"
      set -x
    fi
    "${MISE_BINARY}" plugins update -y || true
    "${MISE_BINARY}" upgrade -y || true
    "${MISE_BINARY}" prune -y
  )
}

function _ {
  (
    cd "${HOME}"
    _pre
    _mise-bootstrap
    _mise
  )
}

echo
set -x
"_${1}" "$@"
