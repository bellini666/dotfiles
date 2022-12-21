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

packer.init({
  luarocks = {
    python_cmd = "python3",
  },
  display = {
    open_cmd = "topleft 65vnew \\[packer\\]",
  },
})

return packer.startup(function(use, use_rocks)
  -- Packer manage itself
  use({ "wbthomason/packer.nvim" })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "NvChad/nvim-colorizer.lua",
      {
        "nvim-treesitter/playground",
        cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
      },
    },
    run = ":TSUpdate",
    config = function()
      require("config.treesitter")
    end,
  })

  -- LSP
  use({
    "neovim/nvim-lspconfig",
    requires = {
      "jose-elias-alvarez/null-ls.nvim",
      "b0o/schemastore.nvim",
    },
    config = function()
      require("config.lsp")
    end,
  })
  use({
    -- FIXME: Go back to the original repo once my PRs are merged
    -- "folke/trouble.nvim",
    "bellini666/trouble.nvim",
    requires = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("trouble").setup({
        close = "<C-q>",
        padding = false,
        auto_preview = false,
        use_diagnostic_signs = true,
        track_cursor = true,
      })
    end,
  })

  -- Completion
  use({
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        disable_in_macro = true,
        check_ts = true,
      })
    end,
  })
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      "windwp/nvim-autopairs",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        requires = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "onsails/lspkind-nvim",
        requires = {
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("lspkind").init({
            preset = "codicons",
          })
        end,
      },
    },
    config = function()
      require("config.completion")
    end,
  })

  -- Testing
  use({
    "nvim-neotest/neotest",
    requires = {
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
  })
  use({
    "andrewferrier/debugprint.nvim",
    config = function()
      require("debugprint").setup()
    end,
  })

  -- UI
  use({
    "folke/noice.nvim",
    requires = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        popupmenu = {
          backend = "cmp",
        },
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
          lsp_doc_border = true,
        },
      })
    end,
  })
  use({
    "themercorp/themer.lua",
    requires = {
      {
        "mg979/tabline.nvim",
        requires = { "nvim-tree/nvim-web-devicons" },
      },
      {
        "nvim-lualine/lualine.nvim",
        requires = {
          "nvim-tree/nvim-web-devicons",
          "arkav/lualine-lsp-progress",
        },
      },
    },
    config = function()
      require("config.theme").setup()
    end,
  })
  use({
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        timeout = 750,
      })
      vim.notify = notify
    end,
  })
  use({ "sindrets/winshift.nvim" })
  use({
    "SmiteshP/nvim-navic",
    requires = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      vim.g.navic_silence = 1
      require("nvim-navic").setup({
        highlight = true,
        separator = " ⇒ ",
      })
    end,
  })

  -- File browsing
  use({
    requires = {
      "folke/noice.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
    },
    "nvim-telescope/telescope.nvim",
    config = function()
      local telescope = require("telescope")
      local trouble = require("trouble.providers.telescope")
      local actions = require("telescope.actions")
      telescope.load_extension("noice")
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
  })
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
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
  })

  -- Terminal integration
  use({
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
  })

  -- Language specifics
  use({
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  })
  use({
    "towolf/vim-helm",
  })

  -- Text editing
  use({ "tpope/vim-repeat" })
  use({ "tpope/vim-unimpaired" })
  use({ "tpope/vim-speeddating" })
  use({ "tpope/vim-fugitive" })
  use({ "wakatime/vim-wakatime" })
  use({
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end,
  })
  use({
    "ggandor/leap.nvim",
    config = function()
      require("leap").set_default_keymaps()
    end,
  })
  use({
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  })
  use({
    "mg979/vim-visual-multi",
    config = function()
      -- Use colors from themer
      vim.g.VM_Mono_hl = "ThemerSearchResult"
      vim.g.VM_Extend_hl = "ThemerSearchResult"
      vim.g.VM_Cursor_hl = "ThemerSearchResult"
      vim.g.VM_Insert_hl = "Cursor"
      vim.g.VM_silent_exit = 1
      vim.g.VM_quit_after_leaving_insert_mode = 1
      vim.g.VM_show_warnings = 0
    end,
    branch = "master",
    requires = "themercorp/themer.lua",
    keys = "<C-n>",
  })
  use({
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help", "Trouble" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase" },
      })
    end,
  })
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({})
    end,
    keys = { { "n", "gcc" }, { "v", "gc" } },
  })
  use({ "andymass/vim-matchup" })

  if BOOTSTRAPED then
    packer.sync()
  end
end)
