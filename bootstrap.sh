#!/bin/bash

set -e

BASE_DIR=$(dirname "${0}")
# shellcheck source=/home/bellini/.dotfiles/utils.sh
source "${BASE_DIR}/utils.sh"
if [ -f "${HOME}/.secret_env.sh" ]; then
  # shellcheck source=/home/bellini/.secret_env.sh
  source "${HOME}/.secret_env.sh"
fi

LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
LOCAL_BUILD_DIR="${HOME}/.local_build"
FONTS_DIR="${HOME}/.local/share/fonts"
NVIM_CONFIG="${HOME}/.config/nvim"
RTX_CONFIG="${HOME}/.config/rtx/"
APT_PACKAGES=(
  build-essential
  cpanminus
  fonts-hack-ttf
  fonts-inconsolata
  fonts-open-sans
  fonts-wine
  git
  htop
  kubetail
  libtool-bin
  ncdu
  ninja-build
  pipx
  pre-commit
  python3-debugpy
  python3-numpy
  python3-pandas
  python3-pip
  python3-pynvim
  ruby
  ruby-dev
  sqlformat
  universal-ctags
  wamerican
  watchman
  wbrazilian
  zsh
  zsh-antigen
)
PYTHON_LIBS=(
  black
  codespell
  djlint
  docker-compose
  flake8
  ipython
  isort
  pipx
  ruff
  ruff-lsp
  textLSP
  yamllint
)
NODE_LIBS=(
  bash-language-server
  cloc
  corepack
  cspell
  diff-so-fancy
  dockerfile-language-server-nodejs
  eslint
  eslint_d
  fixjson
  graphql
  graphql-language-service-cli
  markdownlint-cli
  neovim
  npm
  opencollective
  patch-package
  prettier
  pyright
  stylelint
  tree-sitter-cli
  ts-server
  typescript
  typescript-language-server
  vscode-langservers-extracted
  yaml-language-server
)
SYMLINKS=(
  "${BASE_DIR}/git/gitattributes ${HOME}/.gitattributes"
  "${BASE_DIR}/git/gitconfig ${HOME}/.gitconfig"
  "${BASE_DIR}/git/gitignore ${HOME}/.gitignore"
  "${BASE_DIR}/git/gitignore ${HOME}/.gitignore"
  "${BASE_DIR}/rtx/rtxtool-versions ${HOME}/.tool-versions"
  "${BASE_DIR}/rtx/config.toml ${HOME}/.config/rtx/config.toml"
  "${BASE_DIR}/tmux/tmux.conf ${HOME}/.tmux.conf"
  "${BASE_DIR}/vim ${HOME}/.config/nvim"
  "${BASE_DIR}/zsh/zshrc ${HOME}/.zshrc"
  "${BASE_DIR}/zsh/zshrc ${HOME}/.zshrc"
)

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"
mkdir -p "${FONTS_DIR}"
mkdir -p "${RTX_CONFIG}"

function _system {
  info "updating the system"
  (
    EXTRA_OPTS="-t unstable"
    sudo apt update --list-cleanup
    sudo apt dist-upgrade --purge "$@"
    # shellcheck disable=2086
    sudo apt dist-upgrade --purge ${EXTRA_OPTS} "$@"
    # shellcheck disable=2086
    sudo apt build-dep neovim ${EXTRA_OPTS} "$@"
    # shellcheck disable=2086
    sudo apt install --purge "${APT_PACKAGES[@]}" ${EXTRA_OPTS} "${@}"
    sudo flatpak update
    sudo flatpak uninstall --unused
    sudo apt autoremove --purge
    sudo apt clean
  ) || true
}

function _patches {
  info "patching files"
  if ! grep "force-dark-mode" /usr/share/applications/google-chrome.desktop; then
    sudo sed -i \
      's;/usr/bin/google-chrome-stable;/usr/bin/google-chrome-stable --force-dark-mode;g' \
      /usr/share/applications/google-chrome.desktop
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

  "${HOME}/.local/share/rtx/bin/rtx" self-update
  "${HOME}/.local/share/rtx/bin/rtx" plugins update -a --install-missing
  "${HOME}/.local/share/rtx/bin/rtx" install -a
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
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Inconsolata Nerd Font Complete.otf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf?raw=true
  download_file \
    "${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf?raw=true

  if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Regular 10'" ]; then
    gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Regular 10'
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
  download_executable \
    "${LOCAL_BIN_DIR}/nvim" \
    https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage

  info "installing vim-spell"
  if [ ! -f "${NVIM_CONFIG}/spell/.done" ]; then
    (
      cd "${NVIM_CONFIG}/spell"
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/en.* --timeout=5 || exit 1
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/pt.* --timeout=5 || exit 1
      touch .done
    )
  fi
}

function _language-servers {
  # lua-ls
  info "installing lua-ls"
  git_clone_or_pull \
    "${LOCAL_BUILD_DIR}/lua-ls" https://github.com/LuaLS/lua-language-server.git master
  (
    cd "${LOCAL_BUILD_DIR}/lua-ls"
    ./make.sh
  ) || true
}

function _rust-libs {
  info "installing rust libs"
  cargo install cargo-update
  cargo install --features lsp taplo-cli
  cargo install-update -a
}

function _python-libs {
  info "installing python libs"
  PP="${PYTHON_LIBS[*]}"
  for P in ${PP}; do
    pipx install "${P}"
  done
  pipx upgrade-all -f

  info "installing debugpy latest version"
  if [ ! -f "${HOME}/.debugpy/bin/poetry" ]; then
    python3 -m venv "${HOME}/.debugpy"
  fi
  "${HOME}/.debugpy/bin/pip" install -U pip
  "${HOME}/.debugpy/bin/pip" install -U git+https://github.com/microsoft/debugpy.git@main
}

function _gem-libs {
  info "installing gem libs"
  gem install --user-install -u neovim
}

function _node-libs {
  info "installing node libs"
  set +x
  NODE_INSTALLED=$(
    npm list -g --depth=0 --parseable |
      grep node_modules | grep -v npm | sed 's/.*\/node_modules\///' | sort
  )
  NP="${NODE_LIBS[*]}"
  for P in ${NP}; do
    if [ "${P}" = "npm" ]; then
      continue
    fi
    if [[ "$NODE_INSTALLED" != *"$P"* ]]; then
      set -x
      debug "${P} is missing, installing it..."
      npm -g i "$P"
      set +x
    fi
  done
  for I in $NODE_INSTALLED; do
    if [[ "${NP}" != *"$I"* ]]; then
      set -x
      debug "${I} should not be installed, uninstalling it..."
      npm -g uninstall "$I"
      set +x
    fi
  done
  set -x
  npm update -g
}

function _ {
  _system "$@"
  _patches "$@"
  _symlinks "$@"
  _rtx "$@"
  _fonts "$@"
  _zsh "$@"
  _neovim "$@"
  _language-servers "$@"
  _python-libs "$@"
  _rust-libs "$@"
  _gem-libs "$@"
  _node-libs "$@"
}

echo
set -x
"_${1}" "$@"
