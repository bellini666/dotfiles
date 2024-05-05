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
      {
        "folke/neodev.nvim",
        opts = {},
      },
      "nvimtools/none-ls.nvim",
      "b0o/schemastore.nvim",
      "SmiteshP/nvim-navic",
    },
    config = function()
      require("config.lsp")
    end,
  },
  {
    "folke/trouble.nvim",
    branch = "dev",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Trouble" },
    opts = {
      auto_preview = false,
      modes = {
        diagnostics = {
          sort = { "severity", "pos", "filename", "message" },
        },
        telescope = {
          sort = { "pos", "filename", "severity", "message" },
        },
        quickfix = {
          sort = { "pos", "filename", "severity", "message" },
        },
        loclist = {
          sort = { "pos", "filename", "severity", "message" },
        },
      },
    },
  },

  -- Completion
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      disable_in_macro = true,
      check_ts = true,
    },
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
            symbol_map = {
              Copilot = "",
              Codeium = "",
            },
          })
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#69ae6a" })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#69ae6a" })
        end,
      },
      {
        "zbirenbaum/copilot-cmp",
        config = function()
          require("copilot_cmp").setup()
        end,
      },
    },
    event = "InsertEnter",
    config = function()
      require("config.completion")
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    build = ":Copilot auth",
    event = "VeryLazy",
    opts = {
      suggestion = { enabled = true, auto_trigger = true },
      panel = { enabled = false },
      filetypes = {
        ["*"] = true,
      },
    },
  },

  -- Testing
  {
    "mfussenegger/nvim-dap",
    event = "BufReadPost",
    config = function()
      require("config.dap")
    end,
    dependencies = {
      { "ofirgall/goto-breakpoints.nvim" },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          all_frames = true,
        },
      },
      {
        "mfussenegger/nvim-dap-python",
        config = false,
      },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "nvim-neotest/nvim-nio",
        },
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
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
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
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
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
          {
            filetype = "undotree",
            text = "Undo Tree",
            separator = true,
            padding = 1,
          },
        },
      },
    },
  },
  {
    "stevearc/dressing.nvim",
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
      ---@diagnostic disable-next-line: missing-fields
      notify.setup({
        background_colour = "#000000",
        timeout = 2000,
      })
      vim.notify = notify
    end,
  },
  {
    "sindrets/winshift.nvim",
    cmd = "WinShift",
  },
  {
    "mrjones2014/smart-splits.nvim",
    lazy = true,
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
      local open_with_trouble = require("trouble.sources.telescope").open
      local add_to_trouble = require("trouble.sources.telescope").add
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
              ["<c-q>"] = open_with_trouble,
              ["<c-s>"] = add_to_trouble,
            },
            n = {
              ["<c-q>"] = open_with_trouble,
              ["<c-s>"] = add_to_trouble,
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
        follow_current_file = {
          enabled = true,
        },
      },
    },
  },
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
  },

  -- AI
  {
    "jackMort/ChatGPT.nvim",
    cmd = { "ChatGPT", "ChatGPTRun", "ChatGPTEditWithInstruction" },
    config = function()
      local openai_key = vim.fs.joinpath(vim.fn.expand("$HOME"), ".openai_key")
      require("chatgpt").setup({
        api_key_cmd = "cat " .. openai_key,
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },

  -- Language specific
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    ft = "markdown",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  -- Text editing
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    opts = {
      plugins = {
        spelling = {
          enabled = false,
        },
      },
    },
  },
  {
    "willothy/moveline.nvim",
    build = "make",
  },
  {
    "tpope/vim-repeat",
    keys = { "." },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      signcolumn = false,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    init = function()
      vim.g.undotree_CursorLine = 0
    end,
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
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
      },
    },
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
      lastplace_ignore_filetype = {
        "gitcommit",
        "gitrebase",
        "neo-tree",
        "neotest-summary",
        "undotree",
      },
    },
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
  },
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = { "<leader>sj" },
    config = function()
      require("treesj").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
}
