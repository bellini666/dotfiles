local M = {}

M.setup = function()
    -- Themer setup
    local themer = require("themer")
    local utils = require("themer.utils.colors")
    local jellybeans = require("themer.modules.themes.jellybeans")
    themer.setup({
        colorscheme = "jellybeans",
        remaps = {
            palette = {
                jellybeans = {
                    bg = {
                        alt = utils.lighten(jellybeans.bg.base, 0.92),
                    },
                    pum = {
                        fg = jellybeans.fg,
                        bg = utils.lighten(jellybeans.bg.base, 0.85),
                        sel = {
                            bg = utils.darken(jellybeans.uri, 0.75),
                        },
                        sbar = utils.lighten(jellybeans.bg.base, 0.85),
                        thumb = utils.lighten(jellybeans.bg.base, 0.65),
                    },
                    border = jellybeans.blue,
                    match = utils.darken(jellybeans.uri, 0.75),
                },
            },
            highlights = {
                jellybeans = {
                    base = {
                        Visual = { bg = utils.lighten(jellybeans.bg.selected, 0.9) },
                        NormalFloat = {
                            bg = jellybeans.bg.base,
                        },
                    },
                },
            },
        },
    })

    local c = require("themer.modules.core.api").get_cp("jellybeans")
    local lualine_jellybeans = require("lualine.themes.jellybeans")
    local lualine_get_color = function(a_bg)
        return {
            a = { bg = a_bg, fg = c.bg.alt, gui = "NONE" },
            b = { bg = utils.lighten(c.bg.alt, 0.95), fg = c.accent },
            c = { bg = c.bg.alt, fg = c.cursorlinenr },
        }
    end
    local lualine_theme = vim.tbl_deep_extend("force", lualine_jellybeans, {
        normal = lualine_get_color(c.blue),
        insert = lualine_get_color(c.yellow),
        command = lualine_get_color(c.syntax.constant),
        visual = lualine_get_color(c.magenta),
        replace = lualine_get_color(c.syntax.constant),
        inactive = lualine_get_color(c.bg.alt),
    })
    require("lualine").setup({
        options = {
            theme = lualine_theme,
            component_separators = { left = "｜", right = "｜" },
        },
        sections = {
            lualine_b = { "branch", "diagnostics" },
            lualine_c = {
                { "filename", path = 1 },
            },
            lualine_x = {
                {
                    "lsp_progress",
                    spinner_symbols = { "◴", "◷", "◶", "◵" },
                },
                "encoding",
                "fileformat",
                "filetype",
            },
        },
        extensions = {
            "nvim-tree",
        },
    })

    -- Tabline setup
    local tabline_theme = require("tabline.themes.default").theme()
    tabline_theme = vim.tbl_extend("force", tabline_theme, {
        TFill = "link %s ThemerNormalFloat",
        TNumSel = "link %s ThemerAccentFloat",
        TNum = "link %s ThemerAccentFloat",
        TCorner = "link %s ThemerAccentFloat",
    })
    for _, hl_name in ipairs({ "TSelect", "TSpecial" }) do
        tabline_theme = vim.tbl_extend("force", tabline_theme, {
            [hl_name] = "link %s ThemerNormal",
            [hl_name .. "Dim"] = "link %s ThemerDimmed",
            [hl_name .. "Sep"] = "link %s ThemerSubtle",
            [hl_name .. "Mod"] = "link %s ThemerAccent",
        })
    end
    for _, hl_name in ipairs({ "TVisible", "THidden", "TExtra" }) do
        tabline_theme = vim.tbl_extend("force", tabline_theme, {
            [hl_name] = "link %s ThemerFloat",
            [hl_name .. "Dim"] = "link %s ThemerDimmedFloat",
            [hl_name .. "Sep"] = "link %s ThemerSubtleFloat",
            [hl_name .. "Mod"] = "link %s ThemerAccentFloat",
        })
    end
    require("tabline.setup").setup({
        modes = { "tabs" },
        theme = tabline_theme.name,
    })
    require("tabline.themes").apply(tabline_theme)
end

return M
