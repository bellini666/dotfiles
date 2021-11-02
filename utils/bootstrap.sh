#!/bin/bash

set -e

MY_DIR=$(dirname "${0}")
BASE_DIR=$(dirname "${MY_DIR}")
source "${MY_DIR}/funcs.sh"

LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
LOCAL_BUILD_DIR="${HOME}/.local_build"
NVIM_CONFIG="${HOME}/.config/nvim"
NVIM_BIN="${HOME}/.neovim/bin/nvim"
APT_PACKAGES=(
  bat
  build-essential
  cargo
  cpanminus
  fd-find
  fonts-inconsolata
  fonts-open-sans
  fonts-wine
  fzf
  git
  golang
  jq
  libtool-bin
  ninja-build
  pre-commit
  ripgrep
  ruby
  ruby-dev
  shellcheck
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
  cmake
  debugpy
  debugpy
  flake8
  ipython
  isort
  numpy
  pandas
  pip
  pynvim
  wheel
  yamllint
)
NODE_LIBS=(
  bash-language-server
  corepack
  create-react-native-app
  dockerfile-language-server-nodejs
  eslint
  expo-cli
  fixjson
  graphql
  graphql-language-service-cli
  gulp-cli
  localtunnel
  neovim
  npm
  opencollective
  patch-package
  prettier
  pyright
  react-native-cli
  rimraf
  tree-sitter
  tree-sitter-cli
  ts-server
  typescript
  typescript-language-server
  vim-language-server
  vscode-langservers-extracted
  yaml-language-server
  yarn
)
SYMLINKS=(
  config/efm-langserver
  config/nvim
  gitattributes
  gitconfig
  gitignore
  p10k.zsh
  tmux.conf
  zshrc
)

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"

function _system {
  EXTRA_OPTS="-t unstable"
  info "updating the system"
  sudo apt update --list-cleanup
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
}

function _symlinks {
  info "updating symlinks"
  for FILE in "${SYMLINKS[@]}"; do
    create_symlink "${BASE_DIR}/${FILE}" "${HOME}/.${FILE}"
  done
}

function _zsh {
  info "installing zsh plugins"
  zsh -i -c "antigen cleanup"
  zsh -i -c "antigen update"
}

function _poetry {
  info "installing poetry"
  if [ ! -f "${HOME}/.poetry/bin/poetry" ]; then
    curl -sSL -o- https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
    poetry config virtualenvs.create true
    poetry config virtualenvs.in-project true
  fi
  poetry self update
}

function _nvm {
  info "installing nvm"
  if [ ! -f "${HOME}/.nvm/nvm.sh" ]; then
    curl -ssL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    nvm install 16
    nvm use 16
    nvm alias default 16
  fi
  zsh -i -c "nvm upgrade"
}

function _neovim {
  info "installing neovim"
  git_clone_or_pull "${LOCAL_BUILD_DIR}/neovim" https://github.com/neovim/neovim master
  (
    cd "${LOCAL_BUILD_DIR}/neovim"
    # shellcheck disable=2015
    make CMAKE_INSTALL_PREFIX="${HOME}/.neovim" CMAKE_BUILD_TYPE=Release -j4 -Wno-dev &&
      make CMAKE_INSTALL_PREFIX="${HOME}/.neovim" CMAKE_BUILD_TYPE=Release install || true
  )
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

function _neovim-gtk {
  info "installing neovim-gtk"
  git_clone_or_pull "${LOCAL_BUILD_DIR}/neovim-gtk" https://github.com/Lyude/neovim-gtk main
  (
    cd "${LOCAL_BUILD_DIR}/neovim-gtk"
    make PREFIX="${LOCAL_DIR}" install
  )
}

function _language-servers {
  info "installing stylua"
  git_clone_or_pull "${LOCAL_BUILD_DIR}/stylua" https://github.com/JohnnyMorganz/StyLua master
  (
    cd "${LOCAL_BUILD_DIR}/stylua"
    git pull origin master
    cargo install --path . 2>/dev/null
  )
  # lua-ls
  info "installing lua-ls"
  git_clone_or_pull \
    "${LOCAL_BUILD_DIR}/lua-language-server" https://github.com/sumneko/lua-language-server master
  (
    cd "${LOCAL_BUILD_DIR}/lua-language-server"
    cd 3rd/luamake
    ./compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild
  )
}

function _python-libs {
  info "installing python libs"
  PIP_REQUIRE_VIRTUALENV=false pip install --progress-bar=ascii --user -U "${PYTHON_LIBS[@]}"
}

function _gem-libs {
  info "installing gem libs"
  gem install --user-install -u neovim
}

function _go-libs {
  info "installing go libs"
  go install github.com/mattn/efm-langserver@latest
  go install mvdan.cc/sh/v3/cmd/shfmt@latest
}

function _node-libs {
  info "installing node libs"
  set +x
  NODE_INSTALLED=$(
    npm list -g --depth=0 --parseable |
      sort | grep node_modules | grep -v npm | rev | cut -d'/' -f1 | rev
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

function _neovim-plugins {
  info "updating nvim plugins"
  ${NVIM_BIN} -c 'PackerSync'
  ${NVIM_BIN} --headless -c "TSUpdateSync" -c "sleep 100m | write! /tmp/ts.update.result | qall"
  cat /tmp/ts.update.result
}

function _ {
  _system "$@"
  _symlinks "$@"
  _zsh "$@"
  _poetry "$@"
  _nvm "$@"
  _nvm "$@"
  _neovim "$@"
  _neovim-gtk "$@"
  _language-servers "$@"
  _python-libs "$@"
  _gem-libs "$@"
  _go-libs "$@"
  _node-libs "$@"
  _neovim-plugins "$@"
}

echo
set -x
"_${1}" "$@"
