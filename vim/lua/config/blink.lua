local blink = require("blink.cmp")

local function trigger_copilot()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
    return true
  end
end

blink.setup({
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "snippet_forward", "select_next", trigger_copilot, "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", trigger_copilot, "fallback" },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
      ripgrep = {
        module = "blink-ripgrep",
        name = "Ripgrep",
      },
    },
  },
  signature = { enabled = true, window = { border = "single" } },
  completion = {
    list = {
      selection = { preselect = false, auto_insert = true },
    },
    ghost_text = { enabled = true },
    documentation = { auto_show = true },
    menu = {
      auto_show = function(ctx)
        return ctx.mode == "cmdline" and not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
      end,
    },
  },
})

local augroup = vim.api.nvim_create_augroup("_blink_augroup_", { clear = true })

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuOpen",
  group = augroup,
  callback = function()
    require("copilot.suggestion").dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuClose",
  group = augroup,
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})
