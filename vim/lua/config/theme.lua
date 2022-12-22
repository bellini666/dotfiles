local M = {}

local function setup_theme()
  require("kanagawa").setup({
    transparent = true,
    globalStatus = true,
  })
  vim.cmd("colorscheme kanagawa")
end

local function setup_lualine()
  local navic = require("nvim-navic")
  local utils = require("themer.utils.colors")
  require("lualine").setup({
    options = {
      theme = "kanagawa",
      globalstatus = true,
      component_separators = { left = "｜", right = "｜" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        { "filename", path = 1 },
        { navic.get_location, cond = navic.is_available },
      },
      lualine_x = {
        {
          "lsp_progress",
          spinner_symbols = {
            "⠋",
            "⠙",
            "⠹",
            "⠸",
            "⠼",
            "⠴",
            "⠦",
            "⠧",
            "⠇",
            "⠏",
          },
        },
      },
      lualine_y = {
        "encoding",
        "fileformat",
        "filetype",
        "progress",
      },
    },
    extensions = {
      "neo-tree",
      "fugitive",
      "toggleterm",
    },
  })
end

local function setup_tabline()
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
end

M.setup = function()
  setup_theme()
  setup_lualine()
  setup_tabline()
end

return M
