---@type vim.lsp.Config
return {
  cmd = { "pytest-language-server" },
  filetypes = { "python" },
  root_markers = { ".pytest.ini", "tox.ini", "setup.cfg", "setup.py", "pyproject.toml", ".git" },
  settings = {},
}
