local navic = require("nvim-navic")

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
