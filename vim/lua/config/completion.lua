local cmp = require("cmp")

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

local default_format = require("lspkind").cmp_format({ with_text = false })

cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "nvim_lua" },
    { name = "async_path" },
    { name = "buffer" },
  }),
  completion = {
    autocomplete = false,
  },
  ---@diagnostic disable-next-line: missing-fields
  formatting = {
    format = function(entry, vim_item)
      if vim.tbl_contains({ "path", "async_path" }, entry.source.name) then
        local icon, hl_group =
          require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
        if icon then
          vim_item.kind = icon
          vim_item.kind_hl_group = hl_group
          return vim_item
        end
      end
      return default_format(entry, vim_item)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.core:reset()
      end

      if not require("cmp").complete() then
        fallback()
      end
    end, { "i", "n" }),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping(function(fallback)
      local selected = cmp.get_selected_entry()
      if not selected then
        fallback()
        return
      end

      local is_ai = selected.source.name == "codeium" or selected.source.name == "copilot"
      local behavior = is_ai and cmp.ConfirmBehavior.Replace or cmp.ConfirmBehavior.Select
      if not cmp.confirm({ behavior = behavior, select = false }) then
        fallback()
      end
    end, { "i", "s" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
      elseif require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      -- cmp.config.compare.scopes,
      cmp.config.compare.score,
      require("cmp-under-comparator").under,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      -- cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  window = {
    follow_cursor = true,
    completion = cmp.config.window.bordered({}),
    documentation = cmp.config.window.bordered({}),
  },
  experimental = {
    ghost_text = {
      hl_group = "Comment",
    },
  },
})

cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

cmp.event:on("menu_opened", function()
  vim.b.copilot_suggestion_hidden = true
end)

cmp.event:on("menu_closed", function()
  vim.b.copilot_suggestion_hidden = false
end)
