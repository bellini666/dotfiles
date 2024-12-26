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
    use_nvim_cmp_as_default = true,
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
    list = { selection = "manual" },
    ghost_text = { enabled = true },
    documentation = { auto_show = true },
    menu = { auto_show = false },
  },
})

local augroup = vim.api.nvim_create_augroup("_blink_augroup_", { clear = true })

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpCompletionMenuOpen",
  group = augroup,
  callback = function()
    require("copilot.suggestion").dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpCompletionMenuClose",
  group = augroup,
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})
