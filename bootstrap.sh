#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "${0}")" && pwd)"

UNAME_OUTPUT="$(uname -s)"
case "${UNAME_OUTPUT}" in
Linux*) MACHINE_OS=Linux ;;
Darwin*) MACHINE_OS=MacOS ;;
*)
  echo "Unknown OS: ${UNAME_OUTPUT}"
  exit 1
  ;;
esac

LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"

MISE_CONFIG_DIR="${HOME}/.config/mise"

if [ ${MACHINE_OS} = "MacOS" ]; then
  MISE_BINARY="/opt/homebrew/bin/mise"
  export MISE_ENV="macos"
else
  MISE_BINARY="${HOME}/.local/bin/mise"
  export MISE_ENV="linux"
fi

# Everything else mise creates itself: `[dotfiles]` targets get their parent
# dirs, and the mise config dir must exist before mise can read it.
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${MISE_CONFIG_DIR}"

function info {
  set +x
  echo
  echo "=== ${1} ==="
  echo
  set -x
}

function _system {
  info "updating the system"
  if [ ${MACHINE_OS} = "MacOS" ]; then
    if ! which brew >/dev/null 2>&1; then
      echo "brew not found"
      exit 1
    fi

    (
      # The repo config must be loaded for [bootstrap.packages].
      cd "${BASE_DIR}"

      # mise owns which formulae are needed (its closure plus `packages prune`).
      # Stop brew's autoremove — run by the `brew cleanup`/`brew uninstall` calls
      # below — from deleting closure deps mise still wants, e.g. a mid-transition
      # dep like openssl@4 that no installed formula records yet. Otherwise mise
      # repours it every run and cleanup deletes it again, an endless loop.
      export HOMEBREW_NO_AUTOREMOVE=1

      "${MISE_BINARY}" bootstrap packages apply --yes

      # mise's brew backend only overwrites links it created, so any formula not
      # installed by mise (a brew-installed dependency, or a half-linked leftover
      # from an earlier aborted run) fails `cannot link ...: files not created by
      # mise or brew` when mise upgrades it. Unlink everything this upgrade is
      # about to pour so mise relinks each fresh. Unconditional on purpose: a
      # record-less orphan conflicts just the same, and `brew unlink` clears it
      # regardless. Safe because the same run repours each formula (keg is kept).
      "${MISE_BINARY}" bootstrap packages upgrade --manager brew --dry-run --yes 2>/dev/null |
        sed -n 's#^pour \([^/]*\)/.*#\1#p' |
        while IFS= read -r formula; do
          brew unlink "${formula}" || true
        done

      "${MISE_BINARY}" bootstrap packages upgrade --yes
      "${MISE_BINARY}" bootstrap packages prune --manager brew --yes

      # mise prune only handles formulae; casks still need manual pruning
      # against the brew-cask entries declared in mise.macos.toml.
      DECLARED_CASKS=$("${MISE_BINARY}" bootstrap packages status --json |
        jq -r '.["brew-cask"].packages[].package' | sort)
      # A failure inside the process substitution below would go unnoticed
      # (`set -e` can't see it, and jq exits 0 on empty input), leaving `comm`
      # to report every installed cask as undeclared and uninstall the lot.
      # mise.macos.toml always declares some, so empty means something broke.
      if [ -z "${DECLARED_CASKS}" ]; then
        echo "no brew-cask entries reported; refusing to prune casks" >&2
        exit 1
      fi

      UNDECLARED_CASKS=$(comm -23 \
        <(brew list --cask 2>/dev/null | sort) \
        <(printf '%s\n' "${DECLARED_CASKS}"))
      if [ -n "${UNDECLARED_CASKS}" ]; then
        # --force also removes phantom Caskroom dirs (e.g. tmp leftovers from
        # a failed mise cask install), which plain uninstall errors on.
        # shellcheck disable=2086
        brew uninstall --cask --force ${UNDECLARED_CASKS}
      fi

      # mise prune removes undeclared formulae but leaves old keg versions and
      # the download cache behind (it pours new versions alongside old ones);
      # brew cleanup reclaims those, keeping only the currently-linked keg.
      brew cleanup
    )
  elif [ ${MACHINE_OS} = "Linux" ]; then
    (
      if ! locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
        sudo sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
        sudo locale-gen
        sudo update-locale LANG=en_US.UTF-8
      fi
      sudo apt update --list-cleanup
      sudo apt dist-upgrade --purge
      sudo apt build-dep python3
      sudo flatpak update || true
      sudo flatpak uninstall --unused || true
      sudo apt autoremove --purge
      sudo apt clean
    )
  else
    echo "Unknown OS: ${UNAME_OUTPUT}"
    exit 1
  fi
}

function _pre {
  info "preparing mise"

  if [ ${MACHINE_OS} = "MacOS" ] && [ ! -x "${MISE_BINARY}" ]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "brew not found; install Homebrew first" >&2
      exit 1
    fi
    brew install mise
  elif [ ${MACHINE_OS} = "Linux" ] && [ ! -f "${MISE_BINARY}" ]; then
    curl https://mise.run | sh
  fi

  # The global config must exist before mise can read [tools]; everything else
  # is symlinked declaratively from mise.toml's [dotfiles] during bootstrap.
  ln -sfn "${BASE_DIR}/mise/config.toml" "${MISE_CONFIG_DIR}/config.toml"
  "${MISE_BINARY}" trust "${BASE_DIR}/mise.toml"
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

  set +x
  eval "$("${MISE_BINARY}" activate bash)"
  set -x

  if [ ${MACHINE_OS} = "Linux" ]; then
    "${MISE_BINARY}" self-update || true
  fi

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
    _system
    _mise-bootstrap
    _mise
  )
}

echo
set -x
"_${1}" "$@"
