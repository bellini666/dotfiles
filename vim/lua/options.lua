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

return M
