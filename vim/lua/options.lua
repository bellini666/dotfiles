local utils = require("utils")

local M = {}
local opt = vim.opt
local g = vim.g
local cmd = vim.cmd
local indent = 4

-- Set python3 host path
vim.g.python_host_prog = "/usr/bin/python"
vim.g.python3_host_prog = "/usr/bin/python3"

-- Set leader to ,
g.mapleader = ","

-- Default encoding
opt.enc = "utf-8"
opt.ff = "unix"
opt.ffs = { "unix", "dos" }

-- General
opt.mouse = "nv"
opt.synmaxcol = 2500
opt.ruler = true
opt.showcmd = true
opt.linebreak = true
opt.hidden = true
opt.autoread = true
opt.swapfile = false
opt.modeline = false
opt.history = 4000

-- Ui
opt.number = true
opt.lazyredraw = true
opt.cursorline = true
opt.signcolumn = "number"
opt.laststatus = 2
opt.list = true
opt.listchars = {
    tab = "»·",
    trail = "·",
    extends = "→",
    precedes = "←",
    nbsp = "×",
}
opt.showbreak = [[↪\ ]]
opt.showmode = false
opt.lazyredraw = true
opt.splitright = true
opt.splitbelow = true

-- Theme
opt.termguicolors = true
opt.background = "dark"

-- Dev
opt.textwidth = 99
opt.colorcolumn = "+1"
opt.autoindent = true
opt.smartindent = true
opt.showmatch = true
opt.wrap = true
opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
opt.formatoptions = utils.merge(opt.formatoptions, { "1", "t", "o", "j" })
opt.whichwrap = utils.merge(opt.whichwrap, { "h", "l", "<", ">", "[", "]", "~" })
opt.backspace = { "indent", "eol", "start" }
opt.shortmess = utils.merge(opt.shortmess, { "c" })
opt.completeopt = { "menu", "menuone", "noselect" }

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false

-- Tabs
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = indent
opt.softtabstop = indent
opt.tabstop = indent

-- Performance
opt.updatetime = 100
opt.timeoutlen = 400
opt.redrawtime = 1500
opt.ttimeoutlen = 10

-- Spell
opt.spelllang = "en_us,pt_br"
opt.dictionary = utils.merge(opt.dictionary, {
    "/usr/share/dict/words",
    "/usr/share/dict/brazilian",
    "/usr/share/dict/american-english",
})

-- Search
opt.wildmenu = true
opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true
opt.hlsearch = true
opt.wildmode = { "list:longest", "full" }
opt.wildignore = utils.merge(opt.wildignore, {
    "*.DS_Store",
    "*.bak",
    "*.class",
    "*.gif",
    "*.jpeg",
    "*.jpg",
    "*.min.js",
    "*.o",
    "*.obj",
    "*.out",
    "*.png",
    "*.pyc",
    "*.so",
    "*.swp",
    "*.zip",
    "*/*-egg-info/*",
    "*/.egg-info/*",
    "*/.expo/*",
    "*/.git/*",
    "*/.hg/*",
    "*/.mypy_cache/*",
    "*/.next/*",
    "*/.pnp/*",
    "*/.pytest_cache/*",
    "*/.repo/*",
    "*/.sass-cache/*",
    "*/.svn/*",
    "*/.venv/*",
    "*/.yarn/*",
    "*/.yarn/*",
    "*/__pycache__/*",
    "*/bower_modules/*",
    "*/build/*",
    "*/dist/*",
    "*/node_modules/*",
    "*/target/*",
    "*/venv/*",
    "*~",
})

M.setup = function()
    cmd([[
    colorscheme jellybeans-nvim
    syntax on
    filetype plugin indent on
    ]])
end

M.setup_gui = function()
    if g.GuiLoaded ~= nil then
        opt.mouse = "a"
        g.GuiInternalClipboard = 1
        vim.rpcnotify(1, "Gui", "Font", "Inconsolata Nerd Font 12")
        vim.rpcnotify(1, "Gui", "Option", "Popupmenu", 0)
        vim.rpcnotify(1, "Gui", "Command", "SetCursorBlink", "0")
    end
end

M.setup_colors = function()
    -- Tango colors for builtin terminal
    cmd([[
    let g:terminal_color_0  = '#2e3436'
    let g:terminal_color_1  = '#cc0000'
    let g:terminal_color_2  = '#4e9a06'
    let g:terminal_color_3  = '#c4a000'
    let g:terminal_color_4  = '#3465a4'
    let g:terminal_color_5  = '#75507b'
    let g:terminal_color_6  = '#0b939b'
    let g:terminal_color_7  = '#d3d7cf'
    let g:terminal_color_8  = '#555753'
    let g:terminal_color_9  = '#ef2929'
    let g:terminal_color_10 = '#8ae234'
    let g:terminal_color_11 = '#fce94f'
    let g:terminal_color_12 = '#729fcf'
    let g:terminal_color_13 = '#ad7fa8'
    let g:terminal_color_14 = '#00f5e9'
    let g:terminal_color_15 = '#eeeeec'
    ]])

    -- LSP
    opt.termguicolors = true
    cmd([[
    highlight! DiagnosticHint guifg=LightGrey
    highlight! DiagnosticUnderlineHint cterm=undercurl gui=undercurl guisp=LightGrey

    highlight! DiagnosticInfo guifg=LightBlue
    highlight! DiagnosticUnderlineInfo cterm=undercurl gui=undercurl guisp=LightBlue

    highlight! DiagnosticWarn guifg=Orange
    highlight! DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guisp=Orange

    highlight! DiagnosticError guifg=#ef2929
    highlight! DiagnosticsUnderlineError cterm=undercurl gui=undercurl guisp=#ef2929
    ]])

    -- Spell
    cmd([[
    highlight! SpellRare guibg=NONE cterm=undercurl gui=undercurl guisp=LightGrey
    highlight! SpellLocal guibg=NONE cterm=undercurl gui=undercurl guisp=LightBlue
    highlight! SpellCap guibg=NONE cterm=undercurl gui=undercurl guisp=Orange
    highlight! SpellBad guibg=NONE cterm=undercurl gui=undercurl guisp=#ef2929
    ]])

    -- Float menu color
    cmd([[
    highlight NormalFloat guibg=#141414
    highlight FloatBorder guifg=#80A0C2 guibg=NONE
    ]])

    -- Pmenu colors
    cmd([[
    highlight Pmenu guifg=#e8e8d3 guibg=#424242
    highlight PmenuSel guifg=#141414 guibg=#597bc5
    highlight PmenuThumb guibg=#d0d0bd
    ]])

    -- vim-cmp
    cmd([[
    highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
    highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
    highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
    highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
    highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
    highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
    highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
    highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
    highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
    highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
    highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    ]])

    -- telescope
    cmd([[
    highlight! TelescopeBorder guifg=#80A0C2
    highlight! TelescopePromptPrefix guifg=#cf6a4c
    ]])

    -- nvim-tree
    cmd([[
    highlight! NvimTreeImageFile guifg=#f0a0c0
    highlight! NvimTreeGitDirty guifg=#cf6a4c
    highlight! NvimTreeGitDeleted guifg=#902020
    highlight! NvimTreeGitStaged guifg=#437019
    highlight! NvimTreeGitMerge  guifg=#437019
    highlight! NvimTreeGitRenamed guifg=#ffb964
    highlight! NvimTreeGitNew  guifg=#ffb964
    highlight! NvimTreeIndentMarker guifg=#888888
    highlight! NvimTreeSymlink guifg=#99ad6a
    highlight! NvimTreeFolderIcon guifg=#2B5B77
    highlight! NvimTreeRootFolder guifg=#a0a8b0
    highlight! NvimTreeExecFile guifg=#d2ebbe
    highlight! NvimTreeSpecialFile guifg=#fad07a
    ]])

    -- vim-visual-multi
    cmd([[
    let g:VM_Mono_hl = 'Cursor'
    let g:VM_Extend_hl = 'Visual'
    let g:VM_Cursor_hl = 'Cursor'
    let g:VM_Insert_hl = 'Cursor'
    ]])
end

return M
