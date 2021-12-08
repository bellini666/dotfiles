local cmp = require("cmp")
local lspkind = require("lspkind")

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
