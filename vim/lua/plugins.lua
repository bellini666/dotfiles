local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
    BOOTSTRAPED = fn.system({
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
    use("wbthomason/packer.nvim")

    -- Core
    use({ "nvim-lua/plenary.nvim" })

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        requires = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("config.treesitter")
        end,
    })

    -- LSP
    use({
        "neovim/nvim-lspconfig",
        config = function()
            require("config.lsp")
        end,
        requires = {
            "hrsh7th/nvim-cmp",
            "jose-elias-alvarez/null-ls.nvim",
            "b0o/schemastore.nvim",
        },
    })

    use({
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                shade_terminals = false,
            })
        end,
    })

    -- Completion
    use({
        "hrsh7th/nvim-cmp",
        config = function()
            require("config.completion")
        end,
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
    })

    -- DAP
    use({
        "mfussenegger/nvim-dap",
        config = function()
            require("config.dap")
        end,
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
    })

    -- Visual
    use({
        "kyazdani42/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup()
        end,
    })
    use({
        "metalelf0/jellybeans-nvim",
        requires = {
            "rktjmp/lush.nvim",
            {
                "folke/lsp-colors.nvim",
                config = function()
                    require("lsp-colors").setup({
                        Error = "#902020",
                        Warning = "#cf6a4c",
                        Information = "#ffb964",
                        Hint = "#668799",
                    })
                end,
            },
        },
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
    use({ "rcarriga/nvim-notify" })

    -- File browsing
    use({
        "nvim-telescope/telescope.nvim",
        config = function()
            local actions = require("telescope.actions")
            require("telescope").setup({
                defaults = {
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
    })
    use({
        "kyazdani42/nvim-tree.lua",
        config = function()
            vim.g.nvim_tree_quit_on_open = 1
            require("nvim-tree").setup({
                auto_close = true,
            })
        end,
        requires = {
            "kyazdani42/nvim-web-devicons",
        },
    })

    -- Statusline
    use({
        "ojroques/nvim-hardline",
        config = function()
            require("config.statusline")
        end,
        requires = {
            "kyazdani42/nvim-web-devicons",
            "tpope/vim-fugitive",
            "nvim-treesitter/nvim-treesitter",
            "neovim/nvim-lspconfig",
            {
                "SmiteshP/nvim-gps",
                config = function()
                    require("nvim-gps").setup()
                end,
                requires = { "neovim/nvim-lspconfig" },
            },
        },
    })

    -- Language specifics
    use({ "Vimjas/vim-python-pep8-indent" })

    -- Text editing
    use({ "tpope/vim-repeat" })
    use({ "ggandor/lightspeed.nvim" })
    use({ "gabrielpoca/replacer.nvim" })
    use({ "mbbill/undotree" })
    use({ "mg979/vim-visual-multi", branch = "master" })
    use({ "tpope/vim-surround" })
    use({ "tpope/vim-unimpaired" })
    use({ "wellle/targets.vim" })
    use({ "wakatime/vim-wakatime" })
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
