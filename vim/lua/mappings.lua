local map = vim.keymap.set
local utils = require("utils")

local M = {}

-- Shift + Insert to paste
map("n", "<S-Insert>", '"+p')
map("i", "<S-Insert>", '<C-O>"+P')
map("c", "<S-Insert>", "<MiddleMouse>")

-- Continuous visual indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Togglers
map("n", "<leader>tl", "<cmd>set list!<cr>:set list?<CR>")
map("n", "<leader>tl", "<cmd>set list!<cr>:set list?<CR>")
map("n", "<leader>tn", "<cmd>set number!<cr>:set number?<CR>")
map("n", "<leader>tp", "<cmd>set paste!<cr>:set paste?<CR>")
map("n", "<leader>ts", "<cmd>set spell!<cr>:set spell?<CR>")
map("n", "<leader>tq", '<cmd>lua require("utils").toggle_qf()<cr>')
map("n", "<leader>td", '<cmd>lua require("dapui").toggle()<cr>')
map("n", "<F2>", "<cmd>UndotreeToggle<cr>")
map("n", "<F4>", "<cmd>NvimTreeToggle<cr>")

-- File utils
map("n", "<C-F>", utils.lazy("telescope.builtin", "live_grep"))
map("n", "<C-B>", utils.lazy("telescope.builtin", "buffers"))
map("n", "<C-P>", utils.find_files)
map("n", "<C-G>", utils.grep, { silent = true })

-- Dap
map("n", "<F1>", '<cmd>lua require("dap").toggle_breakpoint()<cr>', { silent = true })
map("n", "<F5>", '<cmd>lua require("dap").continue()<cr>')
map("n", "<F6>", '<cmd>lua require("dap").step_over()<cr>')
map("n", "<F7>", '<cmd>lua require("dap").step_into()<cr>')
map("n", "<F8>", '<cmd>lua require("dap").step_out()<cr>')
map("n", "<Leader>df", '<cmd>lua require("config.dap").test_func()<cr>', { silent = true })
map("n", "<Leader>dc", '<cmd>lua require("config.dap").test_class()<cr>', { silent = true })
map("n", "gK", '<cmd>lua require("dapui").eval()<cr>', { silent = true })
map("v", "gK", '<cmd>lua require("dapui").eval()<cr>')

-- Snippets
map(
    "i",
    "<Tab>",
    "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'",
    { expr = true, remap = true }
)
map(
    "s",
    "<Tab>",
    "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'",
    { expr = true, remap = false }
)
map(
    "i",
    "<S-Tab>",
    "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'",
    { expr = true, remap = true }
)
map(
    "s",
    "<S-Tab>",
    "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'",
    { expr = true, remap = true }
)

-- Tabs management
map("n", "<A-Left>", "gT")
map("n", "<A-Right>", "gT")

-- Comment with Ctrl-/
map("n", "<C-_>", "gcc", { silent = true, remap = true })
map("v", "<C-_>", "gc", { silent = true, remap = true })
map("n", "<C-/>", "gcc", { silent = true, remap = true })
map("v", "<C-/>", "gc", { silent = true, remap = true })

-- Reload treesitter
map("n", "<Leader>rt", "<cmd>write | edit | TSBufEnable highlight<cr>")

-- Edit the quickfix
map("n", "<Leader>rr", utils.lazy("replaces", "run"))

-- Fix spell with telescope
map("n", "z=", utils.lazy("telescope.builtin", "spell_suggest", { { theme = "cursor" } }))

-- Ctrl-Up/Down scrolls 10 lunes and keep the screen centered
map("n", "<C-Up>", "10kzz")
map("n", "<C-Down>", "10jzz")

-- Terminal toggle
map("n", "<C-Z>", utils.lazy("toggleterm", "toggle", { 0 }), { silent = true })
map("t", "<C-Z>", utils.lazy("toggleterm", "toggle_all"), { silent = true })
for i = 1, 5 do
    map(
        { "n", "t" },
        "<A-" .. i .. ">",
        utils.lazy("toggleterm", "toggle", { i }),
        { silent = true }
    )
end

M.setup_lsp = function(client, bufnr)
    local opts = { buffer = true, silent = true }

    -- omnifunc
    vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

    -- diagnostic
    map("n", "[d", vim.diagnostic.goto_prev, opts)
    map("n", "]d", vim.diagnostic.goto_next, opts)
    map("n", "<leader>e", vim.diagnostic.open_float, opts)
    map("n", "<leader>q", vim.diagnostic.setloclist, opts)
    map("n", "ge", utils.lazy("telescope.builtin", "diagnostics", { { bufnr = 0 } }))
    map("n", "gE", utils.lazy("telescope.builtin", "diagnostics"))

    -- lsp
    map("n", "K", vim.lsp.buf.hover, opts)
    map("i", "<C-K>", vim.lsp.buf.signature_help, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "<C-LeftMouse>", vim.lsp.buf.definition, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gI", vim.lsp.buf.implementation, opts)
    map("n", "gic", vim.lsp.buf.incoming_calls, opts)
    map("n", "goc", vim.lsp.buf.outgoing_calls, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gs", vim.lsp.buf.document_symbol, opts)
    map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
end

return M
