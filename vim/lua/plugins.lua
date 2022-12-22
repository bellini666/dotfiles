return {
  -- Theme
  {
    "rebelot/kanagawa.nvim",
    config = function()
      require("kanagawa").setup({
        transparent = true,
        globalStatus = true,
      })
      vim.cmd("colorscheme kanagawa")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "NvChad/nvim-colorizer.lua",
    },
    build = ":TSUpdate",
    config = function()
      require("config.treesitter")
    end,
  },
  {
    "nvim-treesitter/playground",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
      "b0o/schemastore.nvim",
      "SmiteshP/nvim-navic",
      {
        "ray-x/lsp_signature.nvim",
        config = function()
          require("lsp_signature").setup({
            hint_enable = false,
            toggle_key = "<C-K>",
          })
        end,
      },
    },
    config = function()
      require("config.lsp")
    end,
  },
  {
    -- FIXME: Go back to the original repo once my PRs are merged
    -- "folke/trouble.nvim",
    "bellini666/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "TroubleToggle", "Trouble" },
    config = function()
      require("trouble").setup({
        close = "<C-q>",
        padding = false,
        auto_preview = false,
        use_diagnostic_signs = true,
        track_cursor = true,
      })
    end,
  },

  -- Completion
  {
    "windwp/nvim-autopairs",
    event = "BufReadPost",
    config = function()
      require("nvim-autopairs").setup({
        disable_in_macro = true,
        check_ts = true,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "onsails/lspkind-nvim",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("lspkind").init({
            preset = "codicons",
          })
        end,
      },
    },
    event = "InsertEnter",
    config = function()
      require("config.completion")
    end,
  },

  -- Testing
  {
    "nvim-neotest/neotest",
    event = "BufReadPost",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            args = { "-vvv" },
          }),
        },
      })
    end,
  },
  {
    "andrewferrier/debugprint.nvim",
    event = "BufReadPost",
    config = function()
      require("debugprint").setup()
    end,
  },

  -- UI
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "arkav/lualine-lsp-progress",
      "SmiteshP/nvim-navic",
    },
    config = function()
      require("config.statusline")
    end,
  },
  {

    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "tabs",
          diagnostics = "nvim_lsp",
          color_icons = true,
          show_close_icon = false,
          always_show_bufferline = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              separator = true,
              padding = 1,
            },
          },
        },
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("dressing").setup({
        input = {
          insert_only = true,
        },
      })
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        timeout = 750,
      })
      vim.notify = notify
    end,
  },
  {
    "sindrets/winshift.nvim",
    event = "BufReadPost",
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      vim.g.navic_silence = 1
      require("nvim-navic").setup({
        separator = " ⇒ ",
      })
    end,
  },

  -- File browsing
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local trouble = require("trouble.providers.telescope")
      local actions = require("telescope.actions")
      telescope.load_extension("fzf")
      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = " ",
          dynamic_preview_title = true,
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<c-q>"] = trouble.open_with_trouble,
            },
            n = {
              ["<C-q>"] = trouble.open_with_trouble,
            },
          },
        },
        pickers = {
          buffers = {
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
              },
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
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    config = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = true,
        },
      })
    end,
  },

  -- Terminal integration
  {
    "numToStr/FTerm.nvim",
    config = function()
      require("FTerm").setup({
        border = "double",
        dimensions = {
          height = 0.9,
          width = 0.9,
        },
      })
    end,
    cmd = "FTerm",
  },

  -- Language specifics
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },

  -- Text editing
  {
    "tpope/vim-repeat",
    keys = { "." },
  },
  {
    "tpope/vim-unimpaired",
    event = "BufReadPost",
  },
  {
    "tpope/vim-fugitive",
    event = "BufReadPost",
  },
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>" },
      { "<C-x>" },
      { "<C-a>", mode = "v" },
      { "<C-x>", mode = "v" },
    },
  },
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
  },
  {
    "kylechui/nvim-surround",
    event = "BufReadPost",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  {
    "ggandor/leap.nvim",
    event = "BufReadPost",
    config = function()
      require("leap").set_default_keymaps()
    end,
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  },
  {
    "mg979/vim-visual-multi",
    config = function()
      vim.g.VM_silent_exit = 1
      vim.g.VM_quit_after_leaving_insert_mode = 1
      vim.g.VM_show_warnings = 0
    end,
    branch = "master",
    keys = { "<C-n>" },
  },
  {
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help", "Trouble" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase", "neo-tree" },
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({})
    end,
    keys = { { "gcc" }, { "gc", mode = "v" } },
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
  },
}
