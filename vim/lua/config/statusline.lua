local utils = require("utils")
local devicons = require("nvim-web-devicons")

local padch = "·"

if not devicons.has_loaded() then
    devicons.setup()
end

local function dap_status()
    local ok, dap = pcall(require, "dap")
    if not ok then
        return ""
    end
    return dap.status()
end

local function ftype()
    local encoding = vim.opt_local.fileencoding:get() or ""
    local filetype = vim.bo.filetype or ""
    if encoding == "" or filetype == "" then
        return ""
    end

    local f_name, f_extension = vim.fn.expand("%:t"), vim.fn.expand("%:e")
    local icon, color = devicons.get_icon(f_name, f_extension, { default = true })
    if icon then
        -- TODO: Add color to the icon
        filetype = ("%s %s"):format(icon, filetype)
    end

    return ("%s | %s"):format(encoding, filetype)
end

local function line()
    local nbline = vim.fn.line("$")
    local line = vim.fn.line(".")
    local nbcol = vim.fn.col("$") - 1
    local col = vim.fn.col(".")
    return ("%d/%d·%d/%d"):format(line, nbline, col, nbcol)
end

require("hardline").setup({
    bufferline = false,
    theme = "jellybeans",
    sections = { -- define sections
        { class = "mode", item = require("hardline.parts.mode").get_item },
        { class = "high", item = require("hardline.parts.git").get_item, hide = 100 },
        { class = "med", item = require("hardline.parts.filename").get_item },
        {
            class = "high",
            item = require("hardline.parts.treesitter-context").get_item,
            hide = 100,
        },
        "%<",
        { class = "med", item = "%=" },
        { class = "low", item = require("hardline.parts.wordcount").get_item, hide = 100 },
        { class = "error", item = require("hardline.parts.lsp").get_error },
        { class = "warning", item = require("hardline.parts.lsp").get_warning },
        { class = "warning", item = require("hardline.parts.whitespace").get_item },
        { class = "med", item = dap_status, hide = 100 },
        { class = "high", item = ftype, hide = 80 },
        { class = "mode", item = line },
    },
})
