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
            require("nvim-treesitter.configs").setup({
                ensure_installed = "maintained",
                highlight = {
                    enable = true,
                    disable = {},
                },
                indent = {
                    enable = true,
                    -- FIXME: Reenable this when treesitter indenting is working for python
                    disable = { "python" },
                },
                incremental_selection = {
                    enable = true,
                },
            })
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
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
            {
                "onsails/lspkind-nvim",
                requires = { "nvim-treesitter/nvim-treesitter" },
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

    -- File browsing
    use({
        "nvim-telescope/telescope.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })
            require("telescope").load_extension("fzf")
        end,
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-lua/popup.nvim",
            "nvim-treesitter/nvim-treesitter",
            "neovim/nvim-lspconfig",
            { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
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
    use({ "mhinz/vim-grepper" })

    -- Statusline
    use({
        "ojroques/nvim-hardline",
        config = function()
            require("config.statusline")
        end,
        requires = {
            {
                "SmiteshP/nvim-gps",
                config = function()
                    require("nvim-gps").setup()
                end,
                requires = { "neovim/nvim-lspconfig" },
            },
            "kyazdani42/nvim-web-devicons",
            "tpope/vim-fugitive",
        },
    })

    -- Language specifics
    use({ "Vimjas/vim-python-pep8-indent" })

    -- Misc
    use({
        "mbbill/undotree",
    })
    use({
        "inkarkat/vcscommand.vim",
        config = function()
            vim.g.VCSCommandMapPrefix = "<Leader>v"
            vim.g.VCSCommandDeleteOnHide = 1
        end,
    })
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    })
    use({ "mg979/vim-visual-multi", branch = "master" })
    use({ "tpope/vim-fugitive" })
    use({ "tpope/vim-surround" })
    use({ "tpope/vim-unimpaired" })
    use({ "wakatime/vim-wakatime" })

    if BOOTSTRAPED then
        packer.sync()
    end
end)
