local M = {}

local function setup_themer()
  local themer = require("themer")
  local utils = require("themer.utils.colors")
  local colors = require("themer.modules.themes.jellybeans")

  local bg_alt = utils.lighten(colors.bg.base, 0.9)
  local border = colors.blue

  themer.setup({
    colorscheme = "jellybeans",
    remaps = {
      palette = {
        jellybeans = {
          bg = {
            alt = bg_alt,
          },
          pum = {
            fg = colors.fg,
            bg = utils.lighten(colors.bg.base, 0.85),
            sbar = utils.lighten(colors.bg.base, 0.75),
            thumb = utils.lighten(colors.bg.base, 0.65),
            sel = {
              bg = colors.blue,
            },
          },
          border = border,
          match = utils.darken(colors.syntax.struct, 0.85),
        },
      },
      highlights = {
        jellybeans = {
          Visual = {
            bg = utils.lighten(colors.bg.selected, 0.9),
          },
          NormalFloat = {
            bg = bg_alt,
          },
          FloatBorder = {
            bg = bg_alt,
            fg = border,
          },
          LineNr = {
            link = "ThemerDimmed",
          },
        },
      },
    },
  })
end

local function setup_lualine()
  local utils = require("themer.utils.colors")
  local colors = require("themer.modules.core.api").get_cp("jellybeans")
  local theme = require("lualine.themes.jellybeans")
  local bgs = {
    normal = colors.blue,
    insert = colors.yellow,
    command = colors.syntax.constant,
    visual = colors.magenta,
    replace = colors.syntax.constant,
    inactive = colors.bg.alt,
  }
  for kind, bg in pairs(bgs) do
    vim.tbl_deep_extend("force", theme, {
      [kind] = {
        a = { bg = bg, fg = colors.bg.alt, gui = "NONE" },
        b = { bg = utils.lighten(colors.bg.alt, 0.95), fg = colors.accent },
        c = { bg = colors.bg.alt, fg = colors.cursorlinenr },
      },
    })
  end
  require("lualine").setup({
    options = {
      theme = theme,
      component_separators = { left = "｜", right = "｜" },
    },
    sections = {
      lualine_b = { "branch", "diagnostics" },
      lualine_c = {
        { "filename", path = 1 },
      },
      lualine_x = {
        {
          "lsp_progress",
          spinner_symbols = { "◴", "◷", "◶", "◵" },
        },
        "encoding",
        "fileformat",
        "filetype",
      },
    },
    extensions = {
      "nvim-tree",
    },
  })
end

local function setup_tabline()
  local themes = require("tabline.themes")
  local theme = require("tabline.themes.themer").theme()
  theme = vim.tbl_extend("force", theme, {
    name = "jellybeans",
    TFill = "link %s ThemerNormalFloat",
    TNumSel = "link %s ThemerAccentFloat",
    TNum = "link %s ThemerAccentFloat",
    TCorner = "link %s ThemerAccentFloat",
  })
  for _, hl_name in ipairs({ "TSelect", "TSpecial" }) do
    theme = vim.tbl_extend("force", theme, {
      [hl_name] = "link %s ThemerNormal",
      [hl_name .. "Dim"] = "link %s ThemerDimmed",
      [hl_name .. "Sep"] = "link %s ThemerSubtle",
      [hl_name .. "Mod"] = "link %s ThemerAccent",
    })
  end
  for _, hl_name in ipairs({ "TVisible", "THidden", "TExtra" }) do
    theme = vim.tbl_extend("force", theme, {
      [hl_name] = "link %s ThemerFloat",
      [hl_name .. "Dim"] = "link %s ThemerDimmedFloat",
      [hl_name .. "Sep"] = "link %s ThemerSubtleFloat",
      [hl_name .. "Mod"] = "link %s ThemerAccentFloat",
    })
  end
  themes.add(theme)
  require("tabline.setup").setup({
    modes = { "tabs" },
    theme = theme.name,
  })
end

M.setup = function()
  setup_themer()
  setup_lualine()
  setup_tabline()
end

return M
