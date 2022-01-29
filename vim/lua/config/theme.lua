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
                        alt = utils.lighten(jellybeans.bg.base, 0.95),
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

    -- Tabline setup
    local tabline_default = require("tabline.themes.default").theme()
    local tabline_theme = vim.tbl_deep_extend("force", tabline_default, {
        name = "jellybeans",

        TSelect = "link %s ThemerNormal",
        TSelectDim = "link %s ThemerDimmed",
        TSelectSep = "link %s ThemerSubtle",
        TSelectMod = "link %s ThemerAccent",

        TSpecial = "link %s ThemerNormal",
        TSpecialDim = "link %s ThemerDimmed",
        TSpecialSep = "link %s ThemerSubtle",
        TSpecialMod = "link %s ThemerAccent",

        TVisible = "link %s ThemerFloat",
        TVisibleDim = "link %s ThemerDimmedFloat",
        TVisibleSep = "link %s ThemerSubtleFloat",
        TVisibleMod = "link %s ThemerAccentFloat",

        THidden = "link %s ThemerFloat",
        THiddenDim = "link %s ThemerDimmedFloat",
        THiddenSep = "link %s ThemerSubtleFloat",
        THiddenMod = "link %s ThemerAccentFloat",

        TExtra = "link %s ThemerFloat",
        TExtraDim = "link %s ThemerDimmedFloat",
        TExtraSep = "link %s ThemerSubtleFloat",
        TExtraMod = "link %s ThemerAccentFloat",

        TFill = "link %s ThemerNormalFloat",
        TNumSel = "link %s ThemerAccentFloat",
        TNum = "link %s ThemerAccentFloat",
        TCorner = "link %s ThemerAccentFloat",
    })
    require("tabline.setup").setup({
        modes = { "tabs" },
        theme = tabline_theme.name,
    })
    require("tabline.themes").apply(tabline_theme)
end

return M
