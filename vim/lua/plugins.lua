local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    BOOTSTRAPED = vim.fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
end

local packer = require("packer")
return packer.startup(function(use)
    -- Packer manage itself
    use({ "wbthomason/packer.nvim" })

    -- Core
    use({ "nvim-lua/plenary.nvim" })

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        requires = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "RRethy/nvim-treesitter-textsubjects",
            "nvim-treesitter/playground",
            {
                "norcalli/nvim-colorizer.lua",
                config = function()
                    require("colorizer").setup()
                end,
            },
        },
        config = function()
            require("config.treesitter")
        end,
    })

    -- LSP
    use({
        "neovim/nvim-lspconfig",
        requires = {
            "hrsh7th/nvim-cmp",
            "b0o/schemastore.nvim",
        },
        config = function()
            require("config.lsp")
        end,
    })
    use({
        "jose-elias-alvarez/null-ls.nvim",
        requires = {
            "neovim/nvim-lspconfig",
        },
    })

    -- Completion
    use({
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
            "lukas-reineke/cmp-under-comparator",
            {
                "onsails/lspkind-nvim",
                requires = { "nvim-treesitter/nvim-treesitter" },
                config = function()
                    require("lspkind").init({
                        preset = "codicons",
                    })
                end,
            },
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("config.completion")
        end,
    })

    -- DAP
    use({
        "mfussenegger/nvim-dap",
        requires = {
            {
                "rcarriga/nvim-dap-ui",
                config = function()
                    require("dapui").setup()
                end,
            },
            {
                "theHamsta/nvim-dap-virtual-text",
                config = function()
                    require("nvim-dap-virtual-text").setup()
                end,
            },
        },
        config = function()
            require("config.dap")
        end,
    })

    -- UI
    use({ "kyazdani42/nvim-web-devicons" })
    use({
        "metalelf0/jellybeans-nvim",
        requires = { "rktjmp/lush.nvim" },
    })
    use({
        "mg979/vim-xtabline",
        config = function()
            vim.g.xtabline_settings = {
                tab_number_in_left_corner = 0,
                theme = "slate",
            }
        end,
    })
    use({ "stevearc/dressing.nvim" })
    use({
        "rcarriga/nvim-notify",
        config = function()
            local notify = require("notify")
            notify.setup({
                timeout = 1500,
            })
            vim.notify = notify
        end,
    })

    -- File browsing
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-lua/popup.nvim",
            "nvim-treesitter/nvim-treesitter",
            "neovim/nvim-lspconfig",
            "kyazdani42/nvim-web-devicons",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                run = "make",
                config = function()
                    require("telescope").load_extension("fzf")
                end,
            },
        },
        config = function()
            local actions = require("telescope.actions")
            require("telescope").setup({
                defaults = {
                    prompt_prefix = "🔍 ",
                    selection_caret = " ",
                    dynamic_preview_title = true,
                    mappings = {
                        i = {
                            ["<Esc>"] = actions.close,
                        },
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })
        end,
    })
    use({
        "kyazdani42/nvim-tree.lua",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
            vim.g.nvim_tree_quit_on_open = 1
            require("nvim-tree").setup({
                auto_close = true,
            })
        end,
    })

    -- Statusline
    use({
        "ojroques/nvim-hardline",
        requires = {
            "kyazdani42/nvim-web-devicons",
            "tpope/vim-fugitive",
            {
                "SmiteshP/nvim-gps",
                config = function()
                    require("nvim-gps").setup()
                end,
                requires = { "nvim-treesitter/nvim-treesitter" },
            },
        },
        config = function()
            require("config.statusline")
        end,
    })

    -- Terminal integration
    use({
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                shade_terminals = false,
            })
        end,
    })

    -- Language specifics
    use({ "Vimjas/vim-python-pep8-indent" })

    -- Text editing
    use({ "ggandor/lightspeed.nvim" })
    use({ "gabrielpoca/replacer.nvim" })
    use({ "mbbill/undotree" })
    use({ "mg979/vim-visual-multi", branch = "master" })
    use({ "tpope/vim-surround" })
    use({ "tpope/vim-unimpaired" })
    use({ "tpope/vim-speeddating" })
    use({ "wakatime/vim-wakatime" })
    use({
        "ethanholz/nvim-lastplace",
        config = function()
            require("nvim-lastplace").setup({
                lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                lastplace_ignore_filetype = { "gitcommit", "gitrebase" },
            })
        end,
    })
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    })
    use({
        "windwp/nvim-autopairs",
        requires = { "hrsh7th/nvim-cmp" },
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                disable_in_macro = true,
            })
            require("cmp").event:on(
                "confirm_done",
                require("nvim-autopairs.completion.cmp").on_confirm_done({ map_char = { tex = "" } })
            )
        end,
    })

    if BOOTSTRAPED then
        packer.sync()
    end
end)
