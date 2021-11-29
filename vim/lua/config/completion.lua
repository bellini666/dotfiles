local cmp = require("cmp")
local lspkind = require("lspkind")

vim.cmd([[
" gray
highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
" blue
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
" light blue
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
" pink
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
" front
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
]])

cmp.setup({
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
        { name = "vsnip" },
        { name = "nvim_lua" },
    }),
    formatting = {
        format = lspkind.cmp_format(),
    },
    mapping = {
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
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
