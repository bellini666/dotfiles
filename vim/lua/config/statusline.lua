local function dap_status()
    local ok, dap = pcall(require, "dap")
    if not ok then
        return ""
    end
    return dap.status()
end

local function error_status()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if count == 0 then
        return ""
    end
    return "E:" .. count
end

local function warn_status()
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if count == 0 then
        return ""
    end
    return "W:" .. count
end

require("hardline").setup({
    bufferline = false,
    theme = "jellybeans",
    sections = { -- define sections
        { class = "mode", item = require("hardline.parts.mode").get_item },
        { class = "high", item = require("hardline.parts.git").get_item, hide = 100 },
        { class = "med", item = require("hardline.parts.filename").get_item },
        { class = "high", item = require("hardline.parts.treesitter-context").get_item, hide = 100 },
        "%<",
        { class = "med", item = "%=" },
        { class = "low", item = require("hardline.parts.wordcount").get_item, hide = 100 },
        { class = "error", item = error_status },
        { class = "warning", item = warn_status },
        { class = "warning", item = require("hardline.parts.whitespace").get_item },
        { class = "med", item = dap_status, hide = 100 },
        { class = "high", item = require("hardline.parts.filetype").get_item, hide = 80 },
        { class = "mode", item = require("hardline.parts.line").get_item },
    },
})
