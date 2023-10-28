local dap = require("dap")
local utils = require("utils")
local dap_python = require("dap-python")

local M = {}
local hast_last_run = false

dap_python.setup("~/.debugpy/bin/python3", {})
dap_python.test_runner = "pytest"
dap_python.resolve_python = utils.find_python

table.insert(dap.configurations.python, {
  type = "python",
  request = "launch",
  name = "Launch Django",
  cwd = "${workspaceFolder}/",
  program = "${workspaceFolder}/manage.py",
  args = {
    "runserver",
    "0.0.0.0:8080",
    "--noreload",
  },
  console = "integratedTerminal",
  autoReload = {
    enable = true,
  },
  django = true,
})

require("dap.ext.vscode").load_launchjs()

M.run = function()
  local opts = {
    "Test Last Run",
    "Test Last Run (debug)",
    "Test Closest",
    "Test Closest (debug)",
    "Test File",
  }
  if not hast_last_run then
    table.remove(opts, 1)
    table.remove(opts, 1)
  end
  vim.ui.select(opts, {
    prompt = "What to run:",
  }, function(choice)
    if choice == "Test File" then
      require("neotest").run.run(vim.fn.expand("%"))
      hast_last_run = true
    elseif choice == "Test Closest" then
      require("neotest").run.run()
      hast_last_run = true
    elseif choice == "Test Closest (debug)" then
      require("neotest").run.run({ strategy = "dap" })
      hast_last_run = true
    elseif choice == "Test Last Run" then
      require("neotest").run.run_last()
      hast_last_run = true
    elseif choice == "Test Last Run (debug)" then
      require("neotest").run.run_last({ strategy = "dap" })
      hast_last_run = true
    end
  end)
end

return M
