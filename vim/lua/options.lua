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

-- Set leader to ,
vim.g.mapleader = ","

-- Use lua parser and highlight
vim.g.ts_highlight_lua = true

-- General
vim.opt.mouse = "nv"
vim.opt.linebreak = true
vim.opt.swapfile = false
vim.opt.updatetime = 500

-- Ui
vim.opt.number = true
vim.opt.cursorline = false
vim.opt.signcolumn = "number"
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = {
  tab = "»·",
  trail = "·",
  extends = "→",
  precedes = "←",
  nbsp = "␣",
}
vim.opt.showbreak = [[↪ ]]
vim.opt.showmode = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 5
vim.opt.showtabline = 1
vim.opt.smoothscroll = true

-- Theme
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Dev
vim.opt.textwidth = 99
vim.opt.colorcolumn = "+1"
vim.opt.showmatch = true
vim.opt.matchpairs = extend(vim.opt.matchpairs, { "<:>" })
vim.opt.formatoptions = extend(vim.opt.formatoptions, { "1", "o" })
vim.opt.whichwrap = extend(vim.opt.whichwrap, { "<", ">", "[", "]", "~" })
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

-- Spell
vim.opt.spelllang = { "en_us", "pt_br" }
for _, dic in ipairs({
  "/usr/share/dict/words",
  "/usr/share/dict/brazilian",
  "/usr/share/dict/american-english",
}) do
  if vim.fn.filereadable(dic) == 1 then
    extend(vim.opt.dictionary, { dic })
  end
end

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildmode = { "list:longest", "full" }

-- Persistent undo
vim.opt.undofile = true
vim.opt.undolevels = 10000

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
  lua = { indent = 2 },
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
  yaml = { indent = 2 },
  zsh = { indent = 2 },
}

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
