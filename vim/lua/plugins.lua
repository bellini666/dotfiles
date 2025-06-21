return {
  -- Theme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
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
    init = function()
      require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end, { force = true, all = false })
    end,
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
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
      "SmiteshP/nvim-navic",
    },
    config = function()
      require("config.lsp")
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    init = function()
      vim.g.lazydev_enabled = true
    end,
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },
  {
    "Bilal2453/luvit-meta",
    lazy = true,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, {
        bigfile = { enabled = true },
        explorer = { enabled = true },
        git = { enabled = true },
        gitbrowse = { enabled = true },
        image = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        picker = {
          enabled = true,
          actions = require("trouble.sources.snacks").actions,
          win = {
            input = {
              keys = {
                ["<c-q>"] = {
                  "trouble_open",
                  mode = { "n", "i" },
                },
              },
            },
          },
          formatters = {
            file = {
              truncate = 100,
            },
          },
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = true,
    opts = {
      auto_preview = false,
      modes = {
        diagnostics = {
          sort = { "severity", "pos", "filename", "message" },
        },
        snacks = {
          sort = { "pos", "filename", "severity", "message" },
        },
        snacks_files = {
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
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "toml", "markdown" },
        group = vim.api.nvim_create_augroup("EmbedTomlMd", {}),
        callback = function()
          require("otter").activate()
        end,
      })
    end,
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
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "mikavilpas/blink-ripgrep.nvim",
    },
    event = "InsertEnter",
    version = "*",
    config = function()
      require("config.blink")
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
      copilot_model = "claude-3-7-sonnet",
      logger = {
        log_to_file = true,
        file = vim.fn.stdpath("log") .. "/copilot-lua.log",
        file_log_level = vim.log.levels.WARN,
        print_log = false,
        print_log_level = vim.log.levels.WARN,
        trace_lsp = "off", -- "off" | "messages" | "verbose"
        trace_lsp_progress = false,
      },
    },
  },

  -- Testing
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("config.neotest")
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
        signature = {
          enabled = false,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        { filter = { event = "msg_show", find = "written" } },
        { filter = { event = "msg_show", find = "yanked" } },
        { filter = { event = "msg_show", find = "%d+L, %d+B" } },
        { filter = { event = "msg_show", find = "; after #%d+" } },
        { filter = { event = "msg_show", find = "; before #%d+" } },
        { filter = { event = "msg_show", find = "%d fewer lines" } },
        { filter = { event = "msg_show", find = "%d more lines" } },
        { filter = { event = "msg_show", find = "<ed" } },
        { filter = { event = "msg_show", find = ">ed" } },
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
    "Bekaboo/dropbar.nvim",
    opts = {
      menu = {
        preview = false,
      },
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
    "sindrets/winshift.nvim",
    cmd = "WinShift",
  },
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
    },
    config = true,
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
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
    opts = function(_, opts)
      opts.close_if_last_window = true
      opts.filesystem = {
        follow_current_file = {
          enabled = true,
        },
      }

      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end
      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
    end,
  },

  -- AI
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          model = "claude-3-7-sonnet",
        },
        inline = {
          adapter = "copilot",
          model = "claude-3-7-sonnet",
        },
        agent = {
          adapter = "copilot",
          model = "claude-3-7-sonnet",
        },
        cmd = {
          adapter = "copilot",
          model = "claude-3-7-sonnet",
        },
      },
    },
  },

  -- Language specific
  {
    "mrcjkb/rustaceanvim",
    version = "*",
    lazy = false,
  },
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
    init = function()
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
      },
    },
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
  },
  {
    "MagicDuck/grug-far.nvim",
    keys = { "<leader>rr" },
    config = true,
  },
  {
    "kylechui/nvim-surround",
    event = "BufReadPost",
    opts = {
      keymaps = {
        -- disable conflicting keymaps
        normal_cur = false,
        normal_line = false,
        normal_cur_line = false,
      },
    },
  },
}
