local function dap_status()
    local ok, dap = pcall(require, "dap")
    if not ok then
        return ""
    end
    return dap.status()
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
        { class = "error", item = require("hardline.parts.lsp").get_error },
        { class = "warning", item = require("hardline.parts.lsp").get_warning },
        { class = "warning", item = require("hardline.parts.whitespace").get_item },
        { class = "med", item = dap_status, hide = 100 },
        { class = "high", item = require("hardline.parts.filetype").get_item, hide = 80 },
        { class = "mode", item = require("hardline.parts.line").get_item },
    },
})
