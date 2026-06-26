#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "${0}")" && pwd)"
source "${BASE_DIR}/utils.sh"

UNAME_OUTPUT="$(uname -s)"
case "${UNAME_OUTPUT}" in
Linux*) MACHINE_OS=Linux ;;
Darwin*) MACHINE_OS=MacOS ;;
*)
  echo "Unknown OS: ${UNAME_OUTPUT}"
  exit 1
  ;;
esac

BIN_DIR="${HOME}/bin"
LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"

if [ ${MACHINE_OS} = "MacOS" ]; then
  FONTS_DIR="${HOME}/Library/Fonts"
elif [ ${MACHINE_OS} = "Linux" ]; then
  FONTS_DIR="${HOME}/.local/share/fonts"
else
  echo "Unknown OS: ${UNAME_OUTPUT}"
  exit 1
fi

MISE_CONFIG_DIR="${HOME}/.config/mise"

if [ ${MACHINE_OS} = "MacOS" ]; then
  MISE_BINARY="/opt/homebrew/bin/mise"
  export MISE_ENV="macos"
else
  MISE_BINARY="${HOME}/.local/bin/mise"
  export MISE_ENV="linux"
fi

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${BIN_DIR}"
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${FONTS_DIR}"
mkdir -p "${MISE_CONFIG_DIR}"
mkdir -p "${HOME}/.config/opencode"
mkdir -p "${HOME}/.claude"
mkdir -p "${HOME}/.codex"

function _system {
  info "updating the system"
  if [ ${MACHINE_OS} = "MacOS" ]; then
    if ! which brew >/dev/null 2>&1; then
      echo "brew not found"
      exit 1
    fi

    BREW_CASKS=$(tr '\n' ' ' <"${BASE_DIR}/packages/brew-casks")
    # shellcheck disable=2086
    brew install --cask ${BREW_CASKS}

    # Drop casks no longer declared in packages/brew-casks (mirrors `mise prune` for formulae).
    UNDECLARED_CASKS=$(comm -23 \
      <(brew list --cask 2>/dev/null | sort) \
      <(sort "${BASE_DIR}/packages/brew-casks"))
    if [ -n "${UNDECLARED_CASKS}" ]; then
      # shellcheck disable=2086
      brew uninstall --cask ${UNDECLARED_CASKS}
    fi

    brew update
    brew upgrade
    brew autoremove
    brew cleanup
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
      sudo flatpak update
      sudo flatpak uninstall --unused
      sudo apt autoremove --purge
      sudo apt clean
    ) || true
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
  create_symlink "${BASE_DIR}/mise/config.toml" "${MISE_CONFIG_DIR}/config.toml"
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

  eval "$("${MISE_BINARY}" activate bash)"

  today=$(date +%Y-%m-%d)
  marker_file="${HOME}/.cache/mise-last-cache-clear"
  if [ -f "$marker_file" ]; then
    last_run_date=$(cat "$marker_file")
    if [ "$last_run_date" == "$today" ]; then
      echo "Mise cache already cleared today. Skipping..."
    else
      "${MISE_BINARY}" cache clear
      echo "$today" >"$marker_file"
    fi
  else
    "${MISE_BINARY}" cache clear
    echo "$today" >"$marker_file"
  fi

  if [ ${MACHINE_OS} = "Linux" ]; then
    "${MISE_BINARY}" self-update || true
  fi

  (
    if [ -f "${HOME}/.mise_secret_env.sh" ]; then
      # shellcheck disable=1091
      source "${HOME}/.mise_secret_env.sh"
    fi
    "${MISE_BINARY}" plugins update -y || true
    "${MISE_BINARY}" upgrade -y || true
    "${MISE_BINARY}" prune -y
  )
}

function _fonts {
  info "installing fonts"

  download_file \
    "${FONTS_DIR}/codicon.ttf" \
    https://unpkg.com/@vscode/codicons/dist/codicon.ttf
  download_file \
    "${FONTS_DIR}/Hack Regular Nerd Font Complete.ttf" \
    https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf
  download_file \
    "${FONTS_DIR}/Inconsolata Nerd Font Complete.ttf" \
    https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Inconsolata/InconsolataNerdFont-Regular.ttf
  download_file \
    "${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf" \
    https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
  download_file \
    "${FONTS_DIR}/JetBrains Mono Nerd Font Complete.ttf" \
    https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf

  if [ ${MACHINE_OS} = "Linux" ]; then
    if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 11'" ]; then
      gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
    fi
  fi
}

function _ {
  (
    cd "${HOME}"
    _pre
    _mise-bootstrap
    _system
    _fonts
    _mise
  )
}

echo
set -x
"_${1}" "$@"
