local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
    }),
    formatting = {
        -- format = lspkind.cmp_format({ with_text = false, maxwidth = 50 }),
        format = lspkind.cmp_format(),
    },
    mapping = {
        ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item()),
        ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item()),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
})

-- Use buffer source for `/`.
cmp.setup.cmdline("/", {
    sources = {
        { name = "buffer" },
    },
})

-- Use cmdline & path source for ':'.
-- cmp.setup.cmdline(":", {
--     sources = cmp.config.sources({
--         { name = "path" },
--         { name = "cmdline" },
--     }),
-- })
