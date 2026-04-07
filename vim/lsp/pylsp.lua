---@type vim.lsp.Config
return {
  settings = {
    pylsp = {
      plugins = {
        autopep8 = { enabled = false },
        black = { enabled = false },
        flake8 = { enabled = false },
        isort = { enabled = false },
        mccabe = { enabled = false },
        pycodestyle = { enabled = false },
        pydocstyle = { enabled = false },
        pyflakes = { enabled = false },
        pylint = { enabled = false },
        yapf = { enabled = false },
        signature = {
          formatter = "ruff",
        },
      },
    },
  },
}
