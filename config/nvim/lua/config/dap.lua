local dap = require("dap")
local utils = require("utils")

local M = {}

dap.defaults.fallback.terminal_win_cmd = "10split new"
dap.defaults.python.exception_breakpoints = {}
dap.adapters.python_exec = {
    type = "executable",
    command = "/usr/bin/python3",
    args = { "-m", "debugpy.adapter" },
}
dap.adapters.python = {
    type = "server",
    host = "127.0.0.1",
    port = 5678,
}

-- Make sure that if we don't load nothing from launch.json,
-- we at least register a python launch file
require("dap.ext.vscode").load_launchjs()
if dap.configurations.python == nil or #dap.configurations.python == 0 then
    dap.configurations.python = {
        {
            name = "Python debug file",
            type = "python_exec",
            request = "launch",
            console = "integratedTerminal",
            program = "${file}",
            pythonPath = function()
                if vim.env.VIRTUAL_ENV then
                    return vim.env.VIRTUAL_ENV .. "bin/python3"
                end
                return utils.find_cmd("python3", ".venv/bin", vim.fn.expand("%:p"))
            end,
        },
    }
end

local function run_test(class, func)
    local path = vim.fn.expand("%:p")
    local tname = ""
    if class and func then
        tname = "::" .. class .. "::" .. func
    elseif class then
        tname = "::" .. class
    elseif func then
        tname = "::" .. func
    end

    dap.run({
        name = tname,
        type = "python_exec",
        request = "launch",
        module = "pytest",
        args = { "--no-cov", "-vvv", path .. tname },
        console = "integratedTerminal",
        pythonPath = function()
            if vim.env.VIRTUAL_ENV then
                return vim.env.VIRTUAL_ENV .. "bin/python3"
            end
            return utils.find_cmd("python3", ".venv/bin", path)
        end,
    })
end

function M.debug_file()
    local path = vim.fn.expand("%:p")
    dap.run({
        name = "Python debug file",
        type = "python_exec",
        request = "launch",
        console = "integratedTerminal",
        program = path,
        pythonPath = function()
            if vim.env.VIRTUAL_ENV then
                return vim.env.VIRTUAL_ENV .. "bin/python3"
            end
            return utils.find_cmd("python3", ".venv/bin", path)
        end,
    })
end

function M.test_class()
    local node = utils.node_at_cursor()
    if node.class == nil then
        print("No class found at cursor...")
        return
    end
    run_test(node.class)
end

function M.test_func()
    local node = utils.node_at_cursor()
    if node.func == nil then
        print("No func found at cursor...")
        return
    end
    run_test(node.class, node.func)
end

return M
