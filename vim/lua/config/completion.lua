local cmp = require("cmp")

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

local default_format = require("lspkind").cmp_format({ with_text = false })

cmp.setup({
  sources = cmp.config.sources({
    { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "nvim_lua" },
    { name = "async_path" },
    { name = "buffer" },
  }),
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
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping(function(fallback)
      local selected = cmp.get_selected_entry()
      if not selected then
        fallback()
        return
      end

      local behavior = selected.source.name == "copilot" and cmp.ConfirmBehavior.Replace
        or cmp.ConfirmBehavior.Select
      if not cmp.confirm({ behavior = behavior, select = false }) then
        fallback()
      end
    end, { "i", "s" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        require("luasnip").expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        require("luasnip").jump(-1)
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
      -- cmp.config.compare.scopes,
      cmp.config.compare.exact,
      require("copilot_cmp.comparators").prioritize,
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
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
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
