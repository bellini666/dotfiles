-- Disable deprecation warnings for now
---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0

local augroup = vim.api.nvim_create_augroup("_my_init_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = augroup,
  callback = function()
    require("cmds")
    require("mappings")
  end,
})

require("options")
require("autocmds")
require("bootstrap").setup()
