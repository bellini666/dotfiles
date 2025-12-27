local M = {}

-- Set leader to ,
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- General
vim.o.mouse = "nv"
vim.o.linebreak = true
vim.o.swapfile = false
vim.o.updatetime = 500

-- Ui
vim.o.number = true
vim.o.cursorline = false
vim.o.signcolumn = "number"
vim.o.laststatus = 3
vim.o.list = true
vim.opt.listchars = {
  tab = "»·",
  trail = "·",
  extends = "→",
  precedes = "←",
  nbsp = "␣",
}
vim.o.showbreak = [[↪ ]]
vim.o.showmode = false
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.scrolloff = 5
vim.o.showtabline = 1
vim.o.smoothscroll = true
vim.o.title = true

-- Theme
vim.o.termguicolors = true
vim.o.background = "dark"

-- Dev
vim.o.textwidth = vim.env.NEOVIM_TEXTWIDTH and (tonumber(vim.env.NEOVIM_TEXTWIDTH) - 1) or 99
vim.o.colorcolumn = "+1"
vim.o.showmatch = true
vim.opt.matchpairs:append("<:>")
vim.opt.formatoptions:append("1o")
vim.opt.whichwrap:append("<,>,[,],~")
vim.opt.shortmess:append("a")
vim.o.completeopt = "menu,menuone,noselect"
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Folding
vim.o.foldenable = false

-- Tabs
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- Spell
vim.opt.spelllang = { "en_us", "pt_br" }
for _, dic in ipairs({
  "/usr/share/dict/words",
  "/usr/share/dict/brazilian",
  "/usr/share/dict/american-english",
}) do
  if vim.fn.filereadable(dic) == 1 then
    vim.opt.dictionary:append(dic)
  end
end

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildmode = "list:longest,full"

-- Persistent undo
vim.o.undofile = true
vim.o.undolevels = 10000

-- Filetypes
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
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
  if pcall(vim.treesitter.start) then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end

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
