vim.g.python_host_prog = "/usr/bin/python"
vim.g.python3_host_prog = "/usr/bin/python3"

local mods = {
    "options",
    "plugins",
    "mappings",
    "autocmds",
}

for _, module in ipairs(mods) do
    local ok, err = pcall(require, module)
    if not ok then
        error("Error loading " .. module .. "\n\n" .. err)
    end
end

require("options").setup()
