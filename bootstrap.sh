#!/bin/bash

set -e

BASE_DIR=$(dirname "${0}")
source "${BASE_DIR}/utils.sh"
if [ -f "${HOME}/.secret_env.sh" ]; then
  # shellcheck disable=1091
  source "${HOME}/.secret_env.sh"
fi

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
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
RTX_CONFIG_DIR="${HOME}/.config/rtx"
APT_PACKAGES=(
  bat
  btop
  build-essential
  cpanminus
  curl
  docker-compose
  exa
  fonts-open-sans
  fonts-wine
  fzf
  git
  htop
  jq
  kubetail
  libbz2-dev
  libffi-dev
  liblzma-dev
  libncurses-dev
  libreadline-dev
  libsqlite3-dev
  libssl-dev
  libtool-bin
  libwebkit2gtk-4.0-dev
  libxml2-dev
  libxmlsec1-dev
  ncdu
  neovim
  ninja-build
  pipx
  python3-dev
  python3-pip
  python3-pynvim
  tk-dev
  universal-ctags
  wamerican
  watchman
  wbrazilian
  xz-utils
  zlib1g-dev
  zsh
  zsh-antigen
)
BREW_PACKAGES=(
  antigen
  bat
  btop
  cpanminus
  curl
  exa
  fzf
  git
  gnu-sed
  htop
  jq
  libffi
  libtool
  md5sha1sum
  ninja
  openssl
  orbstack
  pipx
  readline
  rtx
  sqlite
  universal-ctags
  watchman
  wget
  xmlsectool
  xz
  zlib
  zsh
)
PYTHON_LIBS=(
  black
  codespell
  djlint
  flake8
  ipdb
  ipython
  isort
  mypy
  pdm
  pipx
  poetry
  pre-commit
  ruff
  ruff-lsp
  tox
  yamlfix
  yamllint
)
PYTHON_INJECTIONS=(
  "poetry poetry-plugin-up"
  "ipython numpy pandas requests httpx openpyxl xlsxwriter"
)
SYMLINKS=(
  "${BASE_DIR}/git/gitattributes ${HOME}/.gitattributes"
  "${BASE_DIR}/git/gitconfig ${HOME}/.gitconfig"
  "${BASE_DIR}/git/gitignore ${HOME}/.gitignore"
  "${BASE_DIR}/rtx/config.toml ${HOME}/.config/rtx/config.toml"
  "${BASE_DIR}/rtx/node-packages ${HOME}/.default-nodejs-packages"
  "${BASE_DIR}/rtx/rust-packages ${HOME}/.default-cargo-crates"
  "${BASE_DIR}/rtx/gcloud-components ${HOME}/.default-cloud-sdk-components"
  "${BASE_DIR}/tmux/tmux.conf ${HOME}/.tmux.conf"
  "${BASE_DIR}/vim ${HOME}/.config/nvim"
  "${BASE_DIR}/zsh/zshrc ${HOME}/.zshrc"
)

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${BIN_DIR}"
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${FONTS_DIR}"
mkdir -p "${RTX_CONFIG_DIR}"

function _system {
  info "updating the system"
  if [ ${MACHINE_OS} = "MacOS" ]; then
    if ! which brew >/dev/null 2>&1; then
      echo "brew not found"
      exit 1
    fi

    brew install "${BREW_PACKAGES[@]}"
    brew update
    brew upgrade
    brew autoremove
    brew cleanup
  elif [ ${MACHINE_OS} = "Linux" ]; then
    (
      EXTRA_OPTS="-t unstable"
      sudo apt update --list-cleanup
      sudo apt dist-upgrade --purge
      # shellcheck disable=2086
      sudo apt dist-upgrade --purge ${EXTRA_OPTS}
      # shellcheck disable=2086
      sudo apt build-dep python3 ${EXTRA_OPTS}
      # shellcheck disable=2086
      sudo apt install --purge "${APT_PACKAGES[@]}" ${EXTRA_OPTS}
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

function _rtx {
  info "installing rtx"
  RTX_BINARY="${HOME}/.local/share/rtx/bin/rtx"
  if [ ! -f "${RTX_BINARY}" ]; then
    curl https://rtx.pub/install.sh | sh
  fi

  eval "$("${HOME}/.local/share/rtx/bin/rtx" activate bash)"
  "${HOME}/.local/share/rtx/bin/rtx" self-update || true
  "${HOME}/.local/share/rtx/bin/rtx" plugins update -y || true
  "${HOME}/.local/share/rtx/bin/rtx" install
  "${HOME}/.local/share/rtx/bin/rtx" prune

  mkdir -p "${HOME}/.local/share/zsh/site-functions"
  "${HOME}/.local/share/rtx/bin/rtx" complete -s zsh >"${HOME}/.local/share/zsh/site-functions/_rtx"
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

function _zsh {
  info "installing zsh plugins"
  if which antigen >/dev/null 2>&1; then
    antigen cleanup
    antigen update
    antigen cache-gen
  else
    zsh -i -c "antigen cleanup"
    zsh -i -c "antigen update"
    zsh -i -c "antigen cache-gen"
  fi
}

function _neovim {
  info "installing neovim"

  if [ ${MACHINE_OS} = "MacOS" ]; then
    brew install --HEAD neovim
    brew upgrade neovim --fetch-HEAD
  elif [ ${MACHINE_OS} = "Linux" ]; then
    download_executable \
      "${BIN_DIR}/nvim" \
      https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
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

function _rust-libs {
  info "installing/updating rust libs"
  cargo install-update -a
}

function _python-libs {
  info "installing/updating python libs"
  PP="${PYTHON_LIBS[*]}"
  for P in ${PP}; do
    pipx install "${P}"
  done

  for P in "${PYTHON_INJECTIONS[@]}"; do
    # shellcheck disable=2086
    pipx inject ${P}
  done

  pipx upgrade-all -f --include-injected

  info "installing debugpy latest version"
  if [ ! -f "${HOME}/.debugpy/bin/python3" ]; then
    python3 -m venv "${HOME}/.debugpy"
  fi
  "${HOME}/.debugpy/bin/pip" install -U pip
  "${HOME}/.debugpy/bin/pip" install -U git+https://github.com/microsoft/debugpy.git@main
}

function _node-libs {
  info "updating/updating node libs"
  npm update -g
}

function _rtx-reshim {
  info "reshimming rtx"
  "${HOME}/.local/share/rtx/bin/rtx" reshim
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
    _rtx
    _python-libs
    _rust-libs
    _node-libs
    _rtx-reshim
  )
}

echo
set -x
"_${1}" "$@"
