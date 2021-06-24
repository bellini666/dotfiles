scriptencoding utf-8

"  General

"    Set Unicode and Unix LF by default
set enc=utf-8
set ff=unix
set ffs=unix,dos

"    Wildmenu options
set wildmenu
set wildmode=list:longest,full
set wildignore+=*.bak
set wildignore+=*.class
set wildignore+=*.min.js
set wildignore+=*.next
set wildignore+=*.o
set wildignore+=*.obj
set wildignore+=*.pyc
set wildignore+=*.so
set wildignore+=*.swp
set wildignore+=*.zip
set wildignore+=*/*-egg-info/*
set wildignore+=*/.git/*
set wildignore+=*/.pytest_cache/*
set wildignore+=*/.expo/*
set wildignore+=*/.hg/*
set wildignore+=*/.next/*
set wildignore+=*/.repo/*
set wildignore+=*/.svn/*
set wildignore+=*/.venv/*
set wildignore+=*/.yarn/*
set wildignore+=*/__pycache__/*
set wildignore+=*/build/*
set wildignore+=*/dist/*
set wildignore+=*/node_modules/*
set wildignore+=*/target/*
set wildignore+=*/venv/*
set wildignore+=*/wine-prefix/*
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
set textwidth=79
set linebreak
set autoindent
set nosmartindent
set showmatch
set foldmethod=indent
set nofoldenable

"    Dictionary and Spell Options
set spelllang=en,pt
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

"    Vim Misc
set updatetime=300
set nocp
set hidden
set autoread
set noswapfile
set nomodeline
set history=4000
set laststatus=2
set switchbuf=usetab
set backspace=indent,eol,start
set complete=".,w,b,t"
set completeopt=longest,menu,preview
if has("patch-8.1.1564")
  set signcolumn=number
else
  set signcolumn=yes
endif

"    Status line options
set noshowmode
set statusline=%<%f
set statusline+=%#warningmsg#%{&ff!='unix'?'[ff='.&ff.']':''}%*
set statusline+=%#warningmsg#%{(&fenc!='utf-8'&&&fenc!='')?'[fenc='.&fenc.']':''}%*
set statusline+=%h%y%r%m
set statusline+=%#error#%{StatuslineTabWarning()}%*
set statusline+=%#error#%{StatuslineTrailingSpaceWarning()}%*
set statusline+=%#error#%{&paste?'[paste]':''}%*
set statusline+=%=
set statusline+=\ (%l,%c/%L)\ %P


"  Plugins

filetype off
call plug#begin('~/.vim/plugged')

Plug 'dense-analysis/ale'
Plug 'deoplete-plugins/deoplete-jedi'
Plug 'dsummersl/gundo.vim'
Plug 'inkarkat/vcscommand.vim'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'nanotech/jellybeans.vim'
Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'scrooloose/nerdcommenter'
Plug 'sheerun/vim-polyglot'
Plug 'shougo/deoplete.nvim'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'wakatime/vim-wakatime'
Plug 'yegappan/grep'

call plug#end()

"  Appearance

"    Default background/colorscheme
set background=dark
if has("gui_running")
  colorscheme jellybeans
  set gfn=Inconsolata\ Medium\ 12,Monospace\ 11
  set mouse=a
  set lines=26 columns=92
  set guioptions-=T
  set guioptions-=m
  set mousehide
  set anti
else
  if $TERM == 'xterm-256color'
    set t_Co=256
    colorscheme jellybeans
  else
    colorscheme desert
  endif
endif

if has('gui_gtk3')
  set guioptions+=d
endif

"    Show trailing spaces and tabs
set list
set listchars=tab:»⋅,trail:⋅,nbsp:⋅,extends:→,precedes:←
set showbreak=↪\ 


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

"    Grep plugin
nnoremap <silent> <Leader>gg :Gitgrep<CR>
nnoremap <silent> <Leader>gr :Rgrep<CR>
"nnoremap <silent> <Leader>gr :call MyRunGrep()<CR>

"    Gundo plugin
nnoremap <F2> :MundoToggle<CR>

"    NerdTree
nmap <silent> <F7> :NERDTreeToggle<CR>

"    FZF
nmap <C-P> :FZF<CR>

"    ale
nmap <silent> [g <Plug>(ale_previous_wrap)
nmap <silent> ]g <Plug>(ale_next_wrap)
nmap <silent> gd <Plug>(ale_go_to_definition)
nmap <silent> gy <Plug>(ale_go_to_type_definition)
nmap <silent> gr <Plug>(ale_find_references)


"  General

let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'


"  Plugins options

"    VCSCommand
let g:VCSCommandMapPrefix='<Leader>v'
let g:VCSCommandDeleteOnHide=1

"    Buff Explorer
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=0

"    Grep
let g:Grep_Skip_Files='
      \ *.bak
      \ *.class
      \ *.jpeg
      \ *.jpg
      \ *.min.js
      \ *.o
      \ *.obj
      \ *.pdf
      \ *.png
      \ *.pyc
      \ *.pyc
      \ *.so
      \ *.svg
      \ *.swp
      \ *.uitest
      \ *.zip
      \ *~
      \ .noseids
      \ nosetests.xml
      \ package-lock.json'
let g:Grep_Skip_Dirs='
      \ *.egg-info
      \ .bzr
      \ .git
      \ .expo
      \ .hg
      \ .next
      \ .repo
      \ .svn
      \ .venv
      \ .yarn
      \ .pytest_cache
      \ __pycache__
      \ build
      \ dist
      \ node_modules
      \ target
      \ venv
      \ wine-prefix'


"    FZF
let g:fzf_layout = { 'up': '40%' }


"    Lightline
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }

"    Ale
let g:ale_linters = {
\   'python': ['flake8'],
\}
let g:ale_fixers = {
\   'javascript': ['prettier', 'eslint'],
\   'javascript.jsx': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'typescript.tsx': ['prettier', 'eslint'],
\   'typescriptreact': ['prettier', 'eslint'],
\   'python': ['black'],
\}
let g:ale_fix_on_save = 1
let g:deoplete#enable_at_startup = 1
let g:ale_completion_enabled = 0
call deoplete#custom#option('sources', {
\ '_': ['ale', 'jedi'],
\})

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

  "  Python
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab

  "  Vim
  autocmd FileType vim setlocal shiftwidth=2 softtabstop=2 expandtab

  "  Javascript
  autocmd FileType javascript,javascript.jsx,typescript,typescript.tsx,typescriptreact setlocal shiftwidth=2 softtabstop=2 expandtab

  "  CSS
  autocmd FileType css,scss setlocal shiftwidth=2 softtabstop=2 expandtab

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
  autocmd FileType help,tags,taglist setlocal nospell
  autocmd FileType text,bzr,git,gitcommit setlocal spell
  autocmd FileType taglist setlocal statusline=%<%f

  "  Help keep text on 79 columns
  autocmd BufEnter * set cc=80,100

  "  Jump to the last position when the file was last opened..
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

  "  Autocmds for functions bellow
  autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning
  autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

  autocmd CompleteDone * silent! pclose!
augroup END


"  Functions

"    Return '[\s]' if trailing white space is detected
function! StatuslineTrailingSpaceWarning()
  if !exists("b:statusline_trailing_space_warning")
    if search('\s\+$', 'nw') != 0
      let b:statusline_trailing_space_warning = '[\s]'
    else
      let b:statusline_trailing_space_warning = ''
    endif
  endif
  return b:statusline_trailing_space_warning
endfunction

"    Return '[&et]' if &et is set wrong
"    Return '[mixed-indenting]' if spaces and tabs are used to indent
function! StatuslineTabWarning()
  if !exists("b:statusline_tab_warning")
    let tabs = search('^\t', 'nw') != 0
    let spaces = search('^ [^*]', 'nw') != 0

    if tabs && spaces
      let b:statusline_tab_warning =  '[mixed-indenting]'
    elseif (spaces && !&et) || (tabs && &et)
      let b:statusline_tab_warning = '[et]'
    else
      let b:statusline_tab_warning = ''
    endif
  endif
  return b:statusline_tab_warning
endfunction

function! MyRunGrep()
    let pattern = trim(input('Search for pattern: ', expand('<cword>')))
    if pattern == ''
      return
    endif
    let pattern = shellescape(pattern)
    echo "\r"

    let files = trim(input('Limit for files pattern: ', '**'))
    if files == ''
      return
    endif
    echo "\r"

    :echo "Rg " . pattern . "-g '" . files "'"
    :execute "Rg " . pattern . " -g '" . files "'"
endfunction


"  Source ~/.vimrc_local, if any
if filereadable(expand("~/.vimrc_local"))
  source ~/.vimrc_local
endif
