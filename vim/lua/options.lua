local utils = require("utils")

local M = {}

-- Set python3 host path
vim.g.python_host_prog = "/usr/bin/python"
vim.g.python3_host_prog = "/usr/bin/python3"

-- Set leader to ,
vim.g.mapleader = ","

-- Default encoding
vim.opt.enc = "utf-8"
vim.opt.ff = "unix"
vim.opt.ffs = { "unix", "dos" }

-- General
vim.opt.mouse = "nv"
vim.opt.synmaxcol = 2500
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.linebreak = true
vim.opt.hidden = true
vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.modeline = false
vim.opt.history = 4000

-- Ui
vim.opt.number = true
vim.opt.lazyredraw = true
vim.opt.cursorline = true
vim.opt.signcolumn = "number"
vim.opt.laststatus = 2
vim.opt.list = true
vim.opt.listchars = {
    tab = "»·",
    trail = "·",
    extends = "→",
    precedes = "←",
    nbsp = "×",
}
vim.opt.showbreak = [[↪\ ]]
vim.opt.showmode = false
vim.opt.lazyredraw = true
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Theme
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Dev
vim.opt.textwidth = 99
vim.opt.colorcolumn = "+1"
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.showmatch = true
vim.opt.wrap = true
vim.opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
vim.opt.formatoptions = utils.merge(vim.opt.formatoptions, { "1", "t", "o", "j" })
vim.opt.whichwrap = utils.merge(vim.opt.whichwrap, { "h", "l", "<", ">", "[", "]", "~" })
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.shortmess = utils.merge(vim.opt.shortmess, { "c" })
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

-- Tabs
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Performance
vim.opt.updatetime = 100
vim.opt.timeoutlen = 400
vim.opt.redrawtime = 1500
vim.opt.ttimeoutlen = 10

-- Spell
vim.opt.spelllang = "en_us,pt_br"
vim.opt.dictionary = utils.merge(vim.opt.dictionary, {
    "/usr/share/dict/words",
    "/usr/share/dict/brazilian",
    "/usr/share/dict/american-english",
})

-- Search
vim.opt.wildmenu = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.wildmode = { "list:longest", "full" }
vim.opt.wildignore = utils.merge(vim.opt.wildignore, {
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

-- FT Configs
local ft_configs = {
    bash = { indent = 2 },
    css = { indent = 2 },
    gitcommit = { spell = true },
    graphql = { indent = 2 },
    help = { spell = false },
    html = { indent = 2, spell = "toplevel" },
    javascript = { indent = 2 },
    javascriptreact = { indent = 2 },
    ["javascript.jsx"] = { indent = 2 },
    po = { spell = true },
    python = { indent = 4 },
    scss = { indent = 2 },
    sh = { indent = 2 },
    tags = { spell = false },
    text = { spell = true },
    typescript = { indent = 2 },
    typescriptreact = { indent = 2 },
    ["typescript.tsx"] = { indent = 2 },
    xml = { indent = 2, spell = "toplevel" },
    zsh = { indent = 2 },
}

M.setup = function()
    vim.cmd([[
    colorscheme jellybeans-nvim
    syntax on
    filetype plugin indent on
    ]])
end

M.setup_ft = function()
    local config = ft_configs[vim.bo.filetype]
    if config == nil then
        return
    end

    if config.indent ~= nil then
        vim.opt_local.shiftwidth = config.indent
        vim.opt_local.softtabstop = config.indent
    end

    if config.spell ~= nil then
        if type(config.spell) == "string" then
            vim.cmd("syn spell " .. config.spell)
        elseif config.spell then
            vim.cmd("setlocal spell")
        else
            vim.cmd("setlocal nospell")
        end
    end
end

M.setup_gui = function()
    if vim.g.GuiLoaded ~= nil then
        vim.opt.mouse = "a"
        vim.g.GuiInternalClipboard = 1
        vim.rpcnotify(1, "Gui", "vim.opt.on", "Popupmenu", 0)
        vim.rpcnotify(1, "Gui", "Command", "SetCursorBlink", "0")
    end
end

M.setup_colors = function()
    -- Tango colors for builtin terminal
    vim.cmd([[
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
    vim.opt.termguicolors = true
    vim.cmd([[
    highlight! DiagnosticHint guifg=LightGrey
    highlight! DiagnosticUnderlineHint cterm=undercurl gui=undercurl guisp=LightGrey

    highlight! DiagnosticInfo guifg=LightBlue
    highlight! DiagnosticUnderlineInfo cterm=undercurl gui=undercurl guisp=LightBlue

    highlight! DiagnosticWarn guifg=Orange
    highlight! DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guisp=Orange

    highlight! DiagnosticError guifg=#ef2929
    highlight! DiagnosticUnderlineError cterm=undercurl gui=undercurl guisp=#ef2929
    ]])

    -- Spell
    vim.cmd([[
    highlight! SpellRare guibg=NONE cterm=undercurl gui=undercurl guisp=LightGrey
    highlight! SpellLocal guibg=NONE cterm=undercurl gui=undercurl guisp=LightBlue
    highlight! SpellCap guibg=NONE cterm=undercurl gui=undercurl guisp=Orange
    highlight! SpellBad guibg=NONE cterm=undercurl gui=undercurl guisp=#ef2929
    ]])

    -- Float menu color
    vim.cmd([[
    highlight NormalFloat guibg=#141414
    highlight FloatBorder guifg=#80A0C2 guibg=NONE
    ]])

    -- Pmenu colors
    vim.cmd([[
    highlight Pmenu guifg=#e8e8d3 guibg=#424242
    highlight PmenuSel guifg=#141414 guibg=#597bc5
    highlight PmenuThumb guibg=#d0d0bd
    ]])

    -- vim-cmp
    vim.cmd([[
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
    vim.cmd([[
    highlight! TelescopeBorder guifg=#80A0C2
    highlight! TelescopePromptPrefix guifg=#cf6a4c
    ]])

    -- nvim-tree
    vim.cmd([[
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
    vim.cmd([[
    let g:VM_Mono_hl = 'Cursor'
    let g:VM_Extend_hl = 'Visual'
    let g:VM_Cursor_hl = 'Cursor'
    let g:VM_Insert_hl = 'Cursor'
    ]])
end

return M
