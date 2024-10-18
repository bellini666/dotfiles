local M = {}

local neotest = require("neotest")
local utils = require("utils")

local function split(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^%s]+)") do
    table.insert(t, str)
  end
  return t
end

local runner = vim.env.NEOTEST_PYTHON_RUNNER or "pytest"
local args = split(vim.env.NEOTEST_PYTHON_ARGS or "-vvv --no-cov --disable-warnings --color=no")

M.get_cwd = function()
  local cwd = vim.uv.cwd()
  local cd_path = vim.env.NEOTEST_PYTHON_RUNNER
  if vim.env.NEOTEST_PYTHON_CD_DIR then
    cwd = vim.fs.joinpath(cwd, table.unpack(split(vim.env.NEOTEST_PYTHON_CD_DIR)))
  end
  return cwd
end

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

return M
