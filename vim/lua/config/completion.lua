local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 then
    return false
  end
  return vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

---@diagnostic disable-next-line
cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "buffer" },
    { name = "luasnip" },
    { name = "path" },
  }),
  formatting = {
    format = lspkind.cmp_format(),
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  documentation = {
    border = "single",
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      require("cmp-under-comparator").under,
      cmp.recently_used,
      cmp.kind,
      cmp.sort_text,
      cmp.length,
      cmp.order,
    },
  },
  experimental = {
    -- native_menu = true,
    -- ghost_text = true,
  },
})

cmp.event:on(
  "confirm_done",
  require("nvim-autopairs.completion.cmp").on_confirm_done({
    map_char = { tex = "" },
  })
)

-- Use buffer source for `/`.
-- cmp.setup.cmdline("/", {
--     sources = {
--         { name = "buffer" },
--     },
-- })

-- Use cmdline & path source for ':'.
-- cmp.setup.cmdline(":", {
--     sources = cmp.config.sources({
--         { name = "path" },
--         { name = "cmdline" },
--     }),
-- })
