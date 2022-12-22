require("options")
require("bootstrap")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("cmds")
    require("mappings")
  end,
})
