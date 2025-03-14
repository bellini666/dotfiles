#!/bin/bash

set -e

BASE_DIR=$(dirname "${0}")
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

NVIM_CONFIG_DIR="${HOME}/.config/nvim"

MISE_CONFIG_DIR="${HOME}/.config/mise"

SYMLINKS=(
  "${BASE_DIR}/git/gitattributes ${HOME}/.gitattributes"
  "${BASE_DIR}/git/gitconfig ${HOME}/.gitconfig"
  "${BASE_DIR}/git/gitignore ${HOME}/.gitignore"
  "${BASE_DIR}/mise/config.toml ${HOME}/.config/mise/config.toml"
  "${BASE_DIR}/python/pdbrc.py ${HOME}/.pdbrc.py"
  "${BASE_DIR}/tmux/tmux.conf ${HOME}/.tmux.conf"
  "${BASE_DIR}/vim ${HOME}/.config/nvim"
  "${BASE_DIR}/kitty ${HOME}/.config/kitty"
  "${BASE_DIR}/ghostty ${HOME}/.config/ghostty"
  "${BASE_DIR}/zsh/zshrc ${HOME}/.zshrc"
  "${BASE_DIR}/zsh/zsh_plugins.txt ${HOME}/.zsh_plugins.txt"
)

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${BIN_DIR}"
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${FONTS_DIR}"
mkdir -p "${MISE_CONFIG_DIR}"
mkdir -p "${BUILD_DIR}"

function _system {
  info "updating the system"
  if [ ${MACHINE_OS} = "MacOS" ]; then
    if ! which brew >/dev/null 2>&1; then
      echo "brew not found"
      exit 1
    fi

    BREW_PACKAGES=$(tr '\n' ' ' <"${BASE_DIR}/packages/brew-packages")
    # shellcheck disable=2086
    brew install ${BREW_PACKAGES}
    brew update
    brew upgrade
    brew autoremove
    brew cleanup
  elif [ ${MACHINE_OS} = "Linux" ]; then
    (
      APT_PACKAGES=$(tr '\n' ' ' <"${BASE_DIR}/packages/apt-packages")
      EXTRA_OPTS="-t unstable"
      sudo apt update --list-cleanup
      sudo apt dist-upgrade --purge
      # shellcheck disable=2086
      sudo apt dist-upgrade --purge ${EXTRA_OPTS}
      # shellcheck disable=2086
      sudo apt build-dep python3 ${EXTRA_OPTS}
      # shellcheck disable=2086
      sudo apt install --purge ${EXTRA_OPTS} ${APT_PACKAGES}
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
    if ! grep "force-dark-mode" /usr/share/applications/google-chrome.desktop; then
      sudo sed -i \
        's;/usr/bin/google-chrome-stable;/usr/bin/google-chrome-stable --force-dark-mode;g' \
        /usr/share/applications/google-chrome.desktop
    fi
  else
    echo "Unknown OS: ${UNAME_OUTPUT}"
    exit 1
  fi
}

function _symlinks {
  info "updating symlinks"
  for FILE in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${FILE}
  done
}

function _mise {
  info "installing mise"

  if [ ${MACHINE_OS} = "MacOS" ]; then
    MISE_BINARY="/opt/homebrew/bin/mise"
  elif [ ${MACHINE_OS} = "Linux" ]; then
    MISE_BINARY="${HOME}/.local/bin/mise"
    if [ ! -f "${MISE_BINARY}" ]; then
      curl https://mise.run | sh
    fi
  else
    echo "Unknown OS: ${UNAME_OUTPUT}"
    exit 1
  fi

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

  "${MISE_BINARY}" plugins update -y || true
  "${MISE_BINARY}" install -y || true
  "${MISE_BINARY}" upgrade -y || true
  "${MISE_BINARY}" prune -y
}

function _fonts {
  info "installing fonts"

  download_file \
    "${FONTS_DIR}/codicon.ttf" \
    https://github.com/microsoft/vscode-codicons/blob/main/dist/codicon.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Hack Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Inconsolata Nerd Font Complete.otf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/InconsolataNerdFont-Regular.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf?raw=true
  download_file \
    "${FONTS_DIR}/JetBrains Mono Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf?raw=true

  if [ ${MACHINE_OS} = "Linux" ]; then
    if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 11'" ]; then
      gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
    fi
  fi
}

function _gh {
  gh extension install github/gh-copilot
  gh extension upgrade --all
}

function _zsh {
  info "installing zsh plugins"
  zsh -i -c "antidote update"
}

function _neovim {
  info "installing neovim"

  if [ ${MACHINE_OS} = "MacOS" ]; then
    local file=${BUILD_DIR}/nvim.tar.gz
    local url=https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz

    if [ "$(download_file ${file} ${url})" == "1" ]; then
      rm -rf ${BUILD_DIR}/nvim-macos-arm64
      tar xzf ${file} -C ${BUILD_DIR}
      ln -sf ${BUILD_DIR}/nvim-macos-arm64/bin/nvim ${BIN_DIR}/nvim
    fi
  elif [ ${MACHINE_OS} = "Linux" ]; then
    download_executable \
      "${BIN_DIR}/nvim" \
      https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage
  else
    echo "Unknown OS: ${UNAME_OUTPUT}"
    exit 1
  fi

  info "installing vim-spell"
  if [ ! -f "${NVIM_CONFIG_DIR}/spell/.done" ]; then
    (
      cd "${NVIM_CONFIG_DIR}/spell"
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/en.* --timeout=5 || exit 1
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/pt.* --timeout=5 || exit 1
      touch .done
    )
  fi
}

function _mise-reshim {
  info "reshimming mise"

  if [ ${MACHINE_OS} = "MacOS" ]; then
    MISE_BINARY="/opt/homebrew/bin/mise"
  elif [ ${MACHINE_OS} = "Linux" ]; then
    MISE_BINARY="${HOME}/.local/bin/mise"
  else
    echo "Unknown OS: ${UNAME_OUTPUT}"
    exit 1
  fi

  "${MISE_BINARY}" reshim
}

function _ {
  (
    cd "${HOME}"
    _system
    _patches
    _neovim
    _symlinks
    _fonts
    _zsh
    _mise
    _gh
    _mise-reshim
  )
}

echo
set -x
"_${1}" "$@"
