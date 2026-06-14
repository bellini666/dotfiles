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

BUILD_DIR="${HOME}/.build"

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
else
  MISE_BINARY="${HOME}/.local/bin/mise"
fi

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${BIN_DIR}"
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${FONTS_DIR}"
mkdir -p "${MISE_CONFIG_DIR}"
mkdir -p "${BUILD_DIR}"
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
    brew update
    brew upgrade
    brew autoremove
    brew cleanup
  elif [ ${MACHINE_OS} = "Linux" ]; then
    (
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

function _patches {
  info "patching files"
  if [ ${MACHINE_OS} = "MacOS" ]; then
    :
  elif [ ${MACHINE_OS} = "Linux" ]; then
    if [ -f /usr/share/applications/google-chrome.desktop ] && ! grep -q "force-dark-mode" /usr/share/applications/google-chrome.desktop; then
      sudo sed -i \
        's;/usr/bin/google-chrome-stable;/usr/bin/google-chrome-stable --force-dark-mode;g' \
        /usr/share/applications/google-chrome.desktop
    fi
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
    "${MISE_BINARY}" bootstrap --yes
  )
}

function _agents {
  info "updating agents"
  (
    claude update || true
    claude plugin list --json | jq -r '.[] | select(.enabled) | .id' | xargs -I {} claude plugin update {}
  ) || true

  rtk init -g --hook-only --auto-patch || true
  rtk init -g --hook-only --auto-patch --opencode || true
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

function _zsh {
  info "installing zsh plugins"
  zsh -i -c "antidote update -b"
}

function _neovim {
  info "installing neovim"

  if [ ${MACHINE_OS} = "MacOS" ]; then
    local file=${BUILD_DIR}/nvim.tar.gz
    local url=https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz

    if [ "$(download_file "${file}" "${url}")" == "1" ]; then
      rm -rf "${BUILD_DIR}/nvim-macos-arm64"
      tar xzf "${file}" -C "${BUILD_DIR}"
      ln -sf "${BUILD_DIR}/nvim-macos-arm64/bin/nvim" "${BIN_DIR}/nvim"
    fi
  elif [ ${MACHINE_OS} = "Linux" ]; then
    local arch
    arch="$(uname -m)"
    if [ "${arch}" = "aarch64" ] || [ "${arch}" = "arm64" ]; then
      arch="arm64"
    else
      arch="x86_64"
    fi
    download_executable \
      "${BIN_DIR}/nvim" \
      "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-${arch}.appimage"
  else
    echo "Unknown OS: ${UNAME_OUTPUT}"
    exit 1
  fi
}

function _mise-reshim {
  info "reshimming mise"
  "${MISE_BINARY}" reshim
}

function _ {
  (
    cd "${HOME}"
    _pre
    _mise-bootstrap
    _system
    _patches
    _neovim
    _agents
    _fonts
    _zsh
    _mise
    _mise-reshim
  )
}

echo
set -x
"_${1}" "$@"
