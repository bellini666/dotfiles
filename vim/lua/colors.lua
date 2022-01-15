local M = {}

-- Those are here for reference, they are not actually being used atm...
M.colors = {
    theme = {
        foreground = "#e8e8d3",
        background = "#151515",
        grey = "#888888",
        grey_one = "#1c1c1c",
        grey_two = "#f0f0f0",
        grey_three = "#333333",
        regent_grey = "#9098A0",
        scorpion = "#606060",
        cod_grey = "#101010",
        tundora = "#404040",
        zambezi = "#605958",
        silver_rust = "#ccc5c4",
        silver = "#c7c7c7",
        alto = "#dddddd",
        gravel = "#403c41",
        boulder = "#777777",
        cocoa_brown = "#302028",
        grey_chateau = "#a0a8b0",
        bright_grey = "#384048",
        shuttle_grey = "#535d66",
        mine_shaft = "#1f1f1f",
        temptress = "#40000a",
        bayoux_blue = "#556779",
        total_white = "#ffffff",
        total_black = "#000000",
        cadet_blue = "#b0b8c0",
        perano = "#b0d0f0",
        wewak = "#f0a0c0",
        mantis = "#70b950",
        raw_sienna = "#cf6a4c",
        highland = "#799d6a",
        hoki = "#668799",
        green_smoke = "#99ad6a",
        costa_del_sol = "#556633",
        biloba_flower = "#c6b6ee",
        morning_glory = "#8fbfdc",
        goldenrod = "#fad07a",
        ship_cove = "#8197bf",
        koromiko = "#ffb964",
        brandy = "#dad085",
        old_brick = "#902020",
        dark_blue = "#0000df",
        ripe_plum = "#540063",
        casal = "#2D7067",
        purple = "#700089",
        tea_green = "#d2ebbe",
        dell = "#437019",
        calypso = "#2B5B77",
    },
    diagnostics = {
        hint = "LightGrey",
        info = "LightBlue",
        warn = "Orange",
        error = "#ef2929",
    },
}

M.tabline_theme = {
    name = "mytheme",
    TSelect = "%s guifg=#e8e8d3 guibg=#151515",
    TVisible = "%s guifg=#799d6a guibg=#262626",
    THidden = "%s guifg=#6c6c6c guibg=#262626",
    TExtra = "%s guifg=#87af87 guibg=#151515",
    TSpecial = "%s guifg=#262626 guibg=#668799",
    TFill = "%s guifg=#6c6c6c guibg=#222222",
    TNumSel = "%s guifg=#556633 guibg=#363636",
    TNum = "%s guifg=#556633 guibg=#363636",
    TCorner = "%s guifg=#799d6a guibg=#262626",
    TSelectMod = "%s guifg=#cf6a4c guibg=#151515",
    TVisibleMod = "%s guifg=#cf6a4c guibg=#262626",
    THiddenMod = "%s guifg=#cf6a4c guibg=#262626",
    TExtraMod = "%s guifg=#cf6a4c guibg=#262626",
    TSelectDim = "%s guifg=#6c6c6c guibg=#151515",
    TSpecialDim = "%s guifg=#6c6c6c guibg=#151515",
    TVisibleDim = "%s guifg=#6c6c6c guibg=#262626",
    THiddenDim = "%s guifg=#6c6c6c guibg=#262626",
    TExtraDim = "%s guifg=#6c6c6c guibg=#262626",
    TSelectSep = "%s guifg=#99ad6a guibg=#151515",
    TSpecialSep = "%s guifg=#99ad6a guibg=#151515",
    TVisibleSep = "%s guifg=#6c6c6c guibg=#262626",
    THiddenSep = "%s guifg=#6c6c6c guibg=#262626",
    TExtraSep = "%s guifg=#6c6c6c guibg=#262626",
}

M.setup = function()
    -- Tango colors for builtin terminal
    vim.cmd([[
    let g:terminal_color_0  = '#2e3436'
    let g:terminal_color_1  = '#cc0000'
    let g:terminal_color_2  = '#4e9a06'
    let g:terminal_color_3  = '#c4a000'
    let g:terminal_color_4  = '#3465a4'
    let g:terminal_color_5  = '#75507b'
    let g:terminal_color_6  = '#0b939b'
    let g:terminal_color_7  = '#d3d7cf'
    let g:terminal_color_8  = '#555753'
    let g:terminal_color_9  = '#ef2929'
    let g:terminal_color_10 = '#8ae234'
    let g:terminal_color_11 = '#fce94f'
    let g:terminal_color_12 = '#729fcf'
    let g:terminal_color_13 = '#ad7fa8'
    let g:terminal_color_14 = '#00f5e9'
    let g:terminal_color_15 = '#eeeeec'
    ]])

    -- LSP/Diagnostic
    vim.cmd([[
    highlight! DiagnosticHint guifg=LightGrey
    highlight! DiagnosticUnderlineHint cterm=undercurl gui=undercurl guisp=LightGrey

    highlight! DiagnosticInfo guifg=LightBlue
    highlight! DiagnosticUnderlineInfo cterm=undercurl gui=undercurl guisp=LightBlue

    highlight! DiagnosticWarn guifg=Orange
    highlight! DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guisp=Orange

    highlight! DiagnosticError guifg=#ef2929
    highlight! DiagnosticUnderlineError cterm=undercurl gui=undercurl guisp=#ef2929

    highlight! link LspSignatureActiveParameter Search
    ]])

    -- Spell
    vim.cmd([[
    highlight! SpellRare guibg=NONE cterm=undercurl gui=undercurl guisp=LightGrey
    highlight! SpellLocal guibg=NONE cterm=undercurl gui=undercurl guisp=LightBlue
    highlight! SpellCap guibg=NONE cterm=undercurl gui=undercurl guisp=Orange
    highlight! SpellBad guibg=NONE cterm=undercurl gui=undercurl guisp=#ef2929
    ]])

    -- Float menu color
    vim.cmd([[
    highlight NormalFloat guibg=#151515
    highlight FloatBorder guifg=#80A0C2 guibg=NONE
    ]])

    -- Pmenu colors
    vim.cmd([[
    highlight Pmenu guifg=#e8e8d3 guibg=#424242
    highlight PmenuSel guifg=#151515 guibg=#597bc5
    highlight PmenuThumb guibg=#d0d0bd
    highlight link PmenuSbar Pmenu
    ]])

    -- Trouble
    vim.cmd([[
    highlight TroubleCount guifg=#e8e8d3 guibg=#333333
    ]])

    -- vim-cmp
    vim.cmd([[
    highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
    highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
    highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
    highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
    highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
    highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
    highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
    highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
    highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
    highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
    highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    ]])

    -- telescope
    vim.cmd([[
    highlight! link TelescopeBorder FloatBorder
    highlight! TelescopePromptPrefix guifg=#cf6a4c
    ]])

    -- nvim-tree
    vim.cmd([[
    highlight! NvimTreeImageFile guifg=#f0a0c0
    highlight! NvimTreeGitDirty guifg=#cf6a4c
    highlight! NvimTreeGitDeleted guifg=#902020
    highlight! NvimTreeGitStaged guifg=#437019
    highlight! NvimTreeGitMerge  guifg=#437019
    highlight! NvimTreeGitRenamed guifg=#ffb964
    highlight! NvimTreeGitNew  guifg=#ffb964
    highlight! NvimTreeIndentMarker guifg=#888888
    highlight! NvimTreeSymlink guifg=#99ad6a
    highlight! NvimTreeFolderIcon guifg=#2B5B77
    highlight! NvimTreeRootFolder guifg=#a0a8b0
    highlight! NvimTreeExecFile guifg=#d2ebbe
    highlight! NvimTreeSpecialFile guifg=#fad07a
    ]])

    -- vim-visual-multi
    vim.cmd([[
    let g:VM_Mono_hl = 'Cursor'
    let g:VM_Extend_hl = 'Visual'
    let g:VM_Cursor_hl = 'Cursor'
    let g:VM_Insert_hl = 'Cursor'
    ]])
end

return M
