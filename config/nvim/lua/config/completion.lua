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
