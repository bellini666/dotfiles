local M = {}

M.setup = function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
  end
  vim.opt.runtimepath:prepend(lazypath)

  require("lazy").setup("plugins", {
    install = { colorscheme = { "kanagawa", "default" } },
    checker = { enabled = true },
    dev = {
      path = os.getenv("HOME") .. "/dev",
    },
  })
end

return M
