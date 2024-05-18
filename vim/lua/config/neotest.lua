local neotest = require("neotest")
local utils = require("utils")

local function split(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^%s]+)") do
    table.insert(t, str)
  end
  return t
end

local runner = os.getenv("NEOTEST_PYTHON_RUNNER") or "pytest"
local args = split(os.getenv("NEOTEST_PYTHON_ARGS") or "-vvv --no-cov --disable-warnings")

---@diagnostic disable-next-line: missing-fields
require("neotest").setup({
  adapters = {
    require("neotest-python")({
      runner = runner,
      args = args,
      python = utils.find_python(),
    }),
  },
  quickfix = {
    enabled = false,
    open = false,
  },
  output = {
    enabled = true,
    open_on_run = false,
  },
  status = {
    enabled = true,
    signs = true,
    virtual_text = true,
  },
})
