scriptencoding utf-8

"  General

"    No compatible always
set nocp

"    Set Unicode and Unix LF by default
set enc=utf-8
set ff=unix
set ffs=unix,dos

"    Wildmenu options
set wildmenu
set wildmode=list:longest,full
set wildignore+=*.DS_Store
set wildignore+=*.bak
set wildignore+=*.class
set wildignore+=*.gif
set wildignore+=*.jpeg
set wildignore+=*.jpg
set wildignore+=*.min.js
set wildignore+=*.o
set wildignore+=*.obj
set wildignore+=*.out
set wildignore+=*.png
set wildignore+=*.pyc
set wildignore+=*.so
set wildignore+=*.swp
set wildignore+=*.zip
set wildignore+=*/*-egg-info/*
set wildignore+=*/.egg-info/*
set wildignore+=*/.expo/*
set wildignore+=*/.git/*
set wildignore+=*/.hg/*
set wildignore+=*/.mypy_cache/*
set wildignore+=*/.next/*
set wildignore+=*/.pnp/*
set wildignore+=*/.pytest_cache/*
set wildignore+=*/.repo/*
set wildignore+=*/.sass-cache/*
set wildignore+=*/.svn/*
set wildignore+=*/.venv/*
set wildignore+=*/.yarn/*
set wildignore+=*/.yarn/*
set wildignore+=*/__pycache__/*
set wildignore+=*/bower_modules/*
set wildignore+=*/build/*
set wildignore+=*/dist/*
set wildignore+=*/node_modules/*
set wildignore+=*/target/*
set wildignore+=*/venv/*
set wildignore+=*~

"    Search options
set ignorecase
set hlsearch
set incsearch
set smartcase

"    TAB options
set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

"    Programming options
set mouse=nv
set textwidth=99
set autoindent
set nosmartindent
set showmatch
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable
set synmaxcol=2500
set formatoptions+=1
set formatoptions-=t
set formatoptions-=o
if has('patch-7.3.541')
  set formatoptions+=j
endif

"    Dictionary and Spell Options
set spelllang=en_us,pt_br
if filereadable("/usr/share/dict/words")
  set dictionary+=/usr/share/dict/words
endif
if filereadable("/usr/share/dict/brazilian")
  set dictionary+=/usr/share/dict/brazilian
endif
if filereadable("/usr/share/dict/american-english")
  set dictionary+=/usr/share/dict/american-english
endif

"    Show Tabs names
set gtl=%t
set gtt=%F

"    Visual options
set ruler
set number
set showcmd
set cursorline
set linebreak
set breakat=\ \	;:,!?
set cc=100

"    Vim Misc
set updatetime=300
set hidden
set autoread
set noswapfile
set nomodeline
set history=4000
set laststatus=2
set whichwrap+=h,l,<,>,[,],~
set backspace=indent,eol,start
set complete=".,w,b,k"
" set completeopt=longest,menu,preview
set completeopt=menu,menuone,noselect
set shortmess+=c
if has("nvim-0.5.0") || has("patch-8.1.1564")
  set signcolumn=number
else
  set signcolumn=yes
endif

"    Show trailing spaces and tabs
set list
set listchars=tab:»·,trail:·,nbsp:·,extends:→,precedes:←
set showbreak=↪\ 

" This needs to be set before plugins are loaded
let g:ale_disable_lsp = 1

"  Plugins

filetype off
call plug#begin('~/.vim/plugged')

Plug 'SmiteshP/nvim-gps'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/nvim-cmp'
Plug 'inkarkat/vcscommand.vim'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lewis6991/spellsitter.nvim'
Plug 'mbbill/undotree'
Plug 'metalelf0/jellybeans-nvim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'mg979/vim-xtabline'
Plug 'mhinz/vim-grepper'
Plug 'nanotech/jellybeans.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'numToStr/Comment.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'ojroques/nvim-hardline'
Plug 'rktjmp/lush.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'wakatime/vim-wakatime'

call plug#end()

"  Appearance

"    Default background/colorscheme
set background=dark
if has('nvim-0.5')
  set termguicolors
  colorscheme jellybeans-nvim
else
  colorscheme jellybeans
endif
if has("gui_running")
  set gfn=Inconsolata\ Medium\ 12,Monospace\ 11
  set guioptions-=T
  set guioptions-=m
  set guioptions+=d
  set mousehide
  set anti
else
  if $TERM == 'xterm-256color'
    set t_Co=256
  endif
endif

"  Maps

"    <Leader>
let mapleader = ','
let g:mapleader = ','

"    Clear highlight when refreshing.
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"    Make Y compatible with D
nnoremap Y y$
nnoremap Q gq

"    Shift + Insert
nnoremap <S-Insert> "+p
inoremap <S-Insert> <C-O>"+p
noremap! <S-Insert> <MiddleMouse>

"    Continous visual indenting
vnoremap < <gv
vnoremap > >gv

"    Togglers
nnoremap <Leader>tl :set list!<CR>:set list?<CR>
nnoremap <Leader>tn :set number!<CR>:set number?<CR>
nnoremap <Leader>tp :set paste!<CR>:set paste?<CR>
nnoremap <Leader>ts :set spell!<CR>:set spell?<CR>

"    Undotree
nnoremap <F2> :UndotreeToggle<CR>

"    Nvim-Tree
nnoremap <silent> <F4> :NvimTreeToggle<CR>

"    Telescope
nnoremap z= <cmd>Telescope spell_suggest theme=get_dropdown<CR>
nnoremap <C-P> <cmd>Telescope find_files<cr>
nnoremap <C-F> <cmd>Telescope live_grep<cr>
nnoremap <C-B> <cmd>Telescope buffers<cr>

nnoremap <silent> <Leader>gr :call <SID>my_run_grep()<CR>

"  General

let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'


"  Plugins options

"    XTabline
let g:xtabline_settings = {
      \ 'tab_number_in_left_corner': 0,
      \ 'theme': 'slate',
      \ }

"    Undotree
let g:undotree_SetFocusWhenToggle = 1

"    VCSCommand
let g:VCSCommandMapPrefix='<Leader>v'
let g:VCSCommandDeleteOnHide=1

"    Nvim-Tree
let g:nvim_tree_quit_on_open = 1


"  Syntax

if has('syntax') && !(exists('syntax_on') && syntax_on)
  syntax on
endif
filetype on
filetype plugin on
filetype indent on


"  Autocmds for filetypes

augroup vimrc_autocmds
  "  Bash
  autocmd FileType sh,bash,zsh setlocal shiftwidth=2 softtabstop=2 expandtab

  "  Vim
  autocmd FileType vim setlocal shiftwidth=2 softtabstop=2 expandtab

  "  Javascript
  autocmd FileType javascript,javascript.jsx,typescript,typescript.tsx,typescriptreact setlocal shiftwidth=2 softtabstop=2 expandtab

  "  CSS
  autocmd FileType css,scss setlocal shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType scss setl iskeyword+=@-@

  "  HTML/XML
  autocmd FileType html,xml setlocal shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType html,xml syn spell toplevel

  "  Docbook
  autocmd FileType docbk,docbkxml setlocal shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType docbk,docbkxml syn spell toplevel

  "  Mail
  autocmd FileType mail setlocal spell
  autocmd FileType mail setlocal textwidth=74

  "  PO
  autocmd FileType po setlocal spell

  "  Misc
  autocmd FileType help,tags setlocal nospell
  autocmd FileType text,bzr,git,gitcommit setlocal spell

  "  Jump to the last position when the file was last opened..
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END


"  Functions

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! s:my_run_grep()
    let l:pattern = trim(input('Search for pattern: ', expand('<cword>')))
    if l:pattern == ''
      return
    endif
    let l:pattern = '"' . substitute(l:pattern, '"', '\"', "g") . '"'
    echo "\r"

    let l:dirs = trim(input('Limit for directory: ', './', 'dir'))
    if l:dirs != ''
      let l:dirs = '"' . l:dirs . '"'
    endif
    echo "\r"

    let l:files = trim(input('Limit for files pattern: ', '*'))
    if l:files == '*'
      let l:files = ''
    else
      let l:files = '-g "' . l:files . '"'
    endif
    echo "\r"

    :echo "GrepperRg " . l:pattern . " " . l:dirs . " " . l:files
    :execute "GrepperRg " . l:pattern . " " . l:dirs . " " . l:files
endfunction

"  LUA config

if has('nvim-0.5')
lua << EOF
local nvim_lsp = require('lspconfig')
local cmp = require('cmp')
local util = require('lspconfig/util')
local path = util.path

-- treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  incremental_selection = {
    enable = true,
  },
}

-- devicons
require'nvim-web-devicons'.setup {
  opt = true,
}

-- nvim-tree
require'nvim-tree'.setup{
  auto_close = true,
}

-- telescope
require'telescope'.setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}
require'telescope'.load_extension('fzf')

-- spellsitter
require'spellsitter'.setup {
  hl = 'SpellBad',
  -- captures = {'comment'},
  captures = {},
  spellchecker = 'vimfn',
}

-- nvim-gps
require'nvim-gps'.setup()

-- hardline
require'hardline'.setup {
  bufferline = false,
  theme = 'jellybeans',
  sections = {         -- define sections
    {class = 'mode', item = require('hardline.parts.mode').get_item},
    {class = 'med', item = require('hardline.parts.filename').get_item},
    {class = 'high', item = require('hardline.parts.git').get_item, hide = 100},
    {class = 'high', item = require('hardline.parts.treesitter-context').get_item, hide = 100},
    '%<',
    {class = 'med', item = '%='},
    {class = 'low', item = require('hardline.parts.wordcount').get_item, hide = 100},
    {class = 'error', item = require('hardline.parts.lsp').get_error},
    {class = 'warning', item = require('hardline.parts.lsp').get_warning},
    {class = 'warning', item = require('hardline.parts.whitespace').get_item},
    {class = 'high', item = require('hardline.parts.filetype').get_item, hide = 80},
    {class = 'mode', item = require('hardline.parts.line').get_item},
  },
}

-- Comment
require'Comment'.setup()

-- LSP
local on_attach = function(client, bufnr)
  vim.cmd [[augroup Format]]
  vim.cmd [[autocmd! * <buffer>]]
  if client.resolved_capabilities.document_formatting then
    vim.cmd [[autocmd BufWritePost <buffer> lua vim.lsp.buf.formatting()]]
  end
  vim.cmd [[ autocmd CursorHold * lua print_diagnostics() ]]
  vim.cmd [[augroup END]]

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
end

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({'./', '*/.'}) do
    local match = vim.fn.glob(path.join(workspace, pattern, 'poetry.lock'))
    if match ~= '' then
      local dir = path.dirname(match)
      local venv = vim.fn.trim(vim.fn.system('cd '..dir..' && poetry env info -p'))
      return path.join(venv, 'bin', 'python')
    end
    local vmatch = vim.fn.glob(path.join(workspace, pattern, '.venv'))
    if vmatch ~= '' then
      return path.join(venv, vmatch, 'python')
    end
  end

  -- Fallback to system Python.
  return "python3"
end

function print_diagnostics(opts, bufnr, line_nr, client_id)
  opts = opts or {}

  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts, client_id)
  if vim.tbl_isempty(line_diagnostics) then return end

  local diagnostic_message = ""
  for i, diagnostic in ipairs(line_diagnostics) do
    diagnostic_message = diagnostic_message .. string.format("%d: %s", i, diagnostic.message or "")
    if i ~= #line_diagnostics then
      diagnostic_message = diagnostic_message .. "\n"
    end
  end
  --print only shows a single line, echo blocks requiring enter, pick your poison
  print(diagnostic_message)
end

-- Setup lspconfig.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup { on_attach = on_attach }

-- https://github.com/microsoft/pyright
nvim_lsp.pyright.setup({
  -- handlers = {
  --   ["textDocument/publishDiagnostics"] = vim.lsp.with(
  --     vim.lsp.diagnostic.on_publish_diagnostics, {
  --       -- Disable virtual_text
  --       virtual_text = false
  --     }
  --   ),
  -- },
  capabilities = capabilities,
  on_attach = on_attach,
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path(config.root_dir)
  end
})

-- https://github.com/theia-ide/typescript-language-server
nvim_lsp.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end,
}

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup { on_attach = on_attach }

-- https://github.com/vscode-langservers/vscode-json-languageserver
nvim_lsp.jsonls.setup {
  on_attach = on_attach,
  cmd = { "json-languageserver", "--stdio" },
}

-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
nvim_lsp.cssls.setup { on_attach = on_attach }

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
nvim_lsp.html.setup { on_attach = on_attach }

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup { on_attach = on_attach }

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end,
}

-- Linting
local black = {
  formatCommand = [[eval "$(run-findlinter black ${INPUT}) --fast -"]],
  formatStdin = true,
}
local isort = {
  formatCommand = [[eval "$(run-findlinter isort ${INPUT}) --stdout -"]],
  formatStdin = true,
}
local flake8 = {
  lintCommand = [[eval "$(run-findlinter flake8 ${INPUT}) --format '%(path)s:%(row)d:%(col)d: %(code)s %(code)s %(text)s' --stdin-display-name ${INPUT} -"]],
  lintStdin = true,
  lintIgnoreExitCode = true,
  lintFormats = { "%f:%l:%c: %t%n%n%n %m" },
  lintSource = "flake8",
}
local prettier = {
  lintCommand = [[eval "$(run-findlinter prettier ${INPUT}) --stdin-filepath ${INPUT}"]],
  formatStdin = true,
}
local eslint = {
  lintCommand = [[eval "$(run-findlinter eslint ${INPUT}) --stdin --stdin-filename ${INPUT}"]],
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {
      "%f(%l,%c): %tarning %m",
      "%f(%l,%c): %rror %m",
  },
  lintSource = "eslint",
}
nvim_lsp.efm.setup {
  on_attach = on_attach,
  init_options = {documentFormatting = true},
  filetypes = {
    "vim",
    "python",
    "typescript",
    "typescript.tsx",
    "javascript",
    "javascript.jsx",
    "typescriptreact",
    "javascriptreact",
  },
  settings = {
    rootMarkers = {".git/"},
    languages = {
      python = { black, isort, flake8 },
      typescript = { prettier, eslint },
      ["typescript.tsx"] = { prettier, eslint },
      javascript = { prettier, eslint },
      ["javascript.jsx"] = { prettier, eslint },
      typescriptreact = { prettier, eslint },
      javascriptreact = { prettier, eslint },
      yaml = { prettier },
      json = { prettier },
      html = { prettier },
      scss = { prettier },
      css = { prettier },
      markdown = { prettier },
    }
  },
}

-- Completion
cmp.setup({
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  })
})

EOF
endif
