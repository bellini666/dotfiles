return {
  -- Theme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        transparent = true,
        globalStatus = true,
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
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
    event = "BufReadPost",
    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
      "b0o/schemastore.nvim",
      "SmiteshP/nvim-navic",
      {
        "ray-x/lsp_signature.nvim",
        opts = {
          hint_enable = false,
          toggle_key = "<C-K>",
        },
      },
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
          "numToStr/Comment.nvim",
          "nvim-telescope/telescope.nvim",
        },
        config = function()
          local navbuddy = require("nvim-navbuddy")
          local actions = require("nvim-navbuddy.actions")
          navbuddy.setup({
            lsp = {
              auto_attach = true,
              preference = {
                "pyright",
                "tsserver",
                "graphql",
                "cssls",
                "html",
                "bashls",
                "dockerls",
                "yamlls",
                "jsonls",
                "taplo",
                "lua_ls",
              },
            },
            mappings = {
              ["<Left>"] = require("nvim-navbuddy.actions").parent,
              ["<Right>"] = require("nvim-navbuddy.actions").children,
              ["<Up>"] = require("nvim-navbuddy.actions").previous_sibling,
              ["<Down>"] = require("nvim-navbuddy.actions").next_sibling,
              ["<C-Up>"] = require("nvim-navbuddy.actions").move_up,
              ["<C-Down>"] = require("nvim-navbuddy.actions").move_down,
            },
          })
        end,
      },
    },
    config = function()
      require("config.lsp")
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      close = "<C-q>",
      padding = false,
      auto_preview = false,
      use_diagnostic_signs = true,
    },
  },

  -- Completion
  {
    "windwp/nvim-autopairs",
    event = "BufReadPost",
    opts = {
      disable_in_macro = true,
      check_ts = true,
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
      },
      filetypes = {
        ["*"] = true,
      },
    },
    event = "VeryLazy",
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "FelipeLema/cmp-async-path",
      "lukas-reineke/cmp-under-comparator",
      {
        "zbirenbaum/copilot-cmp",
        dependencies = {
          "copilot.lua",
        },
        config = true,
      },
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
        build = "make install_jsregexp",
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
            symbol_map = {
              Copilot = "",
            },
          })
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#69ae6a" })
        end,
      },
    },
    event = "InsertEnter",
    config = function()
      require("config.completion")
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      keymaps = {
        submit = { "<C-Enter>", "<C-Space>" },
      },
    },
    cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions" },
  },

  -- Testing
  {
    "mfussenegger/nvim-dap",
    event = "BufReadPost",
    config = function()
      require("config.dap")
    end,
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        config = false,
      },
      {
        "rcarriga/nvim-dap-ui",
        config = true,
      },
    },
  },
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
            args = { "-vvv", "--no-cov", "--disable-warnings" },
          }),
        },
        quickfix = {
          enabled = false,
          open = false,
        },
        output = {
          enabled = true,
          open_on_run = false,
        },
        status = {
          enabled = true,
          signs = true,
          virtual_text = true,
        },
      })
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
    "utilyre/barbecue.nvim",
    event = "VeryLazy",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      attach_navic = false,
    },
  },
  {
    "xiyaowong/virtcolumn.nvim",
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
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
          {
            filetype = "neotest-summary",
            text = "Tests",
            separator = true,
            padding = 1,
          },
        },
      },
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        insert_only = true,
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        timeout = 2000,
      })
      vim.notify = notify
    end,
  },
  {
    "sindrets/winshift.nvim",
    event = "BufReadPost",
  },
  {
    "mrjones2014/smart-splits.nvim",
    event = "BufReadPost",
    opts = {
      resize_mode = {
        quit_key = "<ESC>",
        resize_keys = { "<Left>", "<Down>", "<Up>", "<Right>" },
      },
    },
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.g.navic_silence = 1
    end,
    opts = {
      separator = " ⇒ ",
    },
  },

  -- Tasks
  {
    "EthanJWright/vs-tasks.nvim",
    name = "vstask",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    lazy = true,
    opts = {
      telescope_keys = {
        split = "<CR>",
        vertical = "<C-v>",
        tab = "<C-t>",
        current = "<C-c>",
      },
    },
  },

  -- File browsing
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
    },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          prompt_prefix = "🔍 ",
          selection_caret = " ",
          dynamic_preview_title = true,
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<c-q>"] = require("trouble.providers.telescope").open_with_trouble,
            },
            n = {
              ["<C-q>"] = require("trouble.providers.telescope").open_with_trouble,
            },
          },
        },
        pickers = {
          buffers = {
            mappings = {
              i = {
                ["<A-d>"] = actions.delete_buffer + actions.move_to_top,
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
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = true,
      },
    },
  },

  -- Terminal integration
  {
    "numToStr/FTerm.nvim",
    opts = {
      border = "double",
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
    },
    cmd = "FTerm",
  },

  -- Text editing
  {
    "willothy/moveline.nvim",
    build = "make",
    lazy = true,
  },
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
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  },
  {
    "monaqa/dial.nvim",
    event = "BufReadPost",
  },
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
  },
  {
    "kylechui/nvim-surround",
    event = "BufReadPost",
    config = true,
  },
  {
    "ggandor/leap.nvim",
    event = "BufReadPost",
    config = function()
      require("leap").set_default_keymaps()
    end,
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
    opts = {
      lastplace_ignore_buftype = { "quickfix", "nofile", "help", "Trouble" },
      lastplace_ignore_filetype = { "gitcommit", "gitrebase", "neo-tree", "neotest-summary" },
    },
  },
  {
    "numToStr/Comment.nvim",
    config = true,
    keys = { { "gcc" }, { "gc", mode = "v" } },
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
  },
}
