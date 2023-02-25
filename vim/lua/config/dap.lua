local dap = require("dap")
local utils = require("utils")
local dap_python = require("dap-python")

dap_python.setup("~/.debugpy/bin/python3", {})
dap_python.test_runner = "pytest"
dap_python.resolve_python = function()
  if vim.env.VIRTUAL_ENV then
    return require("null-ls.utils").path.join(vim.env.VIRTUAL_ENV, "bin", "python3")
  end
  return utils.find_cmd("python3", ".venv/bin")
end
