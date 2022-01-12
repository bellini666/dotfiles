local M = {}

local function extend(opt, list)
    if opt._info.flaglist then
        local flaglist = {}
        for _, v in ipairs(list) do
            flaglist[v] = true
        end
        list = flaglist
    end
    return opt + list
end

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
vim.opt.matchpairs = extend(vim.opt.matchpairs, { "<:>" })
vim.opt.formatoptions = extend(vim.opt.formatoptions, { "1", "o" })
vim.opt.whichwrap = extend(vim.opt.whichwrap, { "<", ">", "[", "]", "~" })
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.shortmess = extend(vim.opt.shortmess, { "a" })
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
vim.opt.spelllang = { "en_us", "pt_br" }
vim.opt.dictionary = extend(vim.opt.dictionary, {
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
vim.opt.wildignore = extend(vim.opt.wildignore, {
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
    markdown = { spell = true },
    po = { spell = true },
    python = { indent = 4 },
    scss = { indent = 2 },
    sh = { indent = 2 },
    tags = { spell = false },
    text = { spell = true },
    typescript = { indent = 2 },
    typescriptreact = { indent = 2 },
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
        else
            vim.opt_local.spell = config.spell or false
        end
    end
end

return M
