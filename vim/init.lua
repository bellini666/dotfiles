vim.loader.enable()

require("options")
require("bootstrap")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("autocmds")
    require("cmds")
    require("mappings")
  end,
})
