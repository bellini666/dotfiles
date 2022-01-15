local colors = require("colors").colors.theme

require("nvim-treesitter.configs").setup({
    ensure_installed = "maintained",
    highlight = {
        enable = true,
        use_languagetree = true,
    },
    indent = {
        enable = true,
        -- FIXME: Re-enable this when treesitter indenting is working for python
        disable = { "python" },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            scope_incremental = ";",
            node_incremental = ".",
            node_decremental = ",",
        },
    },
    matchup = {
        enable = true,
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
        colors = {
            colors.hoki,
            colors.green_smoke,
            colors.raw_sienna,
            colors.wewak,
            colors.goldenrod,
            colors.purple,
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner",
            },
        },
        lsp_interop = {
            enable = true,
            border = "single",
            peek_definition_code = {
                ["<leader>df"] = "@function.outer",
                ["<leader>dF"] = "@class.outer",
            },
        },
    },
})
