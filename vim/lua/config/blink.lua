local blink = require("blink.cmp")

local kind_icons = require("blink.cmp.config").appearance.kind_icons
kind_icons["Copilot"] = ""

blink.setup({
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
  },
  appearance = {
    nerd_font_variant = "mono",
    kind_icons = kind_icons,
  },
  sources = {
    default = { "copilot", "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
      copilot = {
        name = "copilot",
        module = "blink-cmp-copilot",
        score_offset = 200,
        async = true,
        transform_items = function(_, items)
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1
          CompletionItemKind[kind_idx] = "Copilot"
          for _, item in ipairs(items) do
            item.kind = kind_idx
          end
          return items
        end,
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
      selection = { preselect = true, auto_insert = true },
    },
    ghost_text = { enabled = true },
    documentation = { auto_show = true },
    menu = {
      auto_show = function(ctx)
        return ctx.mode ~= "cmdline" and not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
      end,
    },
  },
})
