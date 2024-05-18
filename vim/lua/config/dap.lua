local dap = require("dap")
local utils = require("utils")
local dap_python = require("dap-python")

local hast_last_run = false

local base_path = os.getenv("HOME")
dap_python.setup(base_path .. "/.debugpy/bin/python3")
dap_python.test_runner = "pytest"
dap_python.resolve_python = utils.find_python

require("dap.ext.vscode").load_launchjs()
