local map = require("utils").map
local bmap = require("utils").bmap

local M = {}

-- Shift + Insert to paste
map("n", "<S-Insert>", '"+p')
map("i", "<S-Insert>", '<C-O>"+P')
map("c", "<S-Insert>", "<MiddleMouse>")

-- Continous visual indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Togglers
map("n", "<Leader>tl", "<cmd>set list!<CR>:set list?<CR>")
map("n", "<Leader>tn", "<cmd>set number!<CR>:set number?<CR>")
map("n", "<Leader>tp", "<cmd>set paste!<CR>:set paste?<CR>")
map("n", "<Leader>ts", "<cmd>set spell!<CR>:set spell?<CR>")
map("n", "<Leader>tq", '<cmd>lua require("utils").toggle_qf()<CR>')
map("n", "<Leader>td", '<cmd>lua require("dapui").toggle()<CR>')
map("n", "<F2>", "<cmd>UndotreeToggle<CR>")
map("n", "<F4>", "<cmd>NvimTreeToggle<CR>")

-- File utils
map("n", "z=", "<cmd>Telescope spell_suggest theme=cursor<CR>")
map("n", "<C-P>", "<cmd>Telescope git_files theme=dropdown<CR>")
map("n", "<C-F>", "<cmd>Telescope live_grep<CR>")
map("n", "<C-B>", "<cmd>Telescope buffers<CR>")
map("n", "<C-G>", '<cmd>lua require("utils").grep()<CR>', { silent = true })

-- Dap
map("n", "<F1>", '<cmd>lua require("dap").toggle_breakpoint()<CR>', { silent = true })
map("n", "<F5>", '<cmd>lua require("dap").continue()<CR>')
map("n", "<F6>", '<cmd>lua require("dap").step_over()<CR>')
map("n", "<F7>", '<cmd>lua require("dap").step_into()<CR>')
map("n", "<F8>", '<cmd>lua require("dap").step_out()<CR>')
map("n", "<Leader>df", '<cmd>lua require("config.dap").test_func()<CR>', { silent = true })
map("n", "<Leader>dc", '<cmd>lua require("config.dap").test_class()<CR>', { silent = true })
map("n", "gK", '<cmd>lua require("dapui").eval()<CR>', { silent = true })
map("v", "gK", '<cmd>lua require("dapui").eval()<CR>')

-- Snippets
map("i", "<Tab>", "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'", { expr = true, noremap = false })
map("s", "<Tab>", "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'", { expr = true, noremap = false })
map("i", "<S-Tab>", "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'", { expr = true, noremap = false })
map("s", "<S-Tab>", "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'", { expr = true, noremap = false })

-- Comment with Ctrl-/
map("n", "<C-_>", "gcc", { silent = true, noremap = false })
map("v", "<C-_>", "gc", { silent = true, noremap = false })
map("n", "<C-/>", "gcc", { silent = true, noremap = false })
map("v", "<C-/>", "gc", { silent = true, noremap = false })

-- Reload treesitter
map("n", "<Leader>rt", "<cmd>write | edit | TSBufEnable highlight<CR>")

-- Edit the quickfix
map("n", "<Leader>h", '<cmd>lua require("replacer").run()<CR>')

-- Fix spell with telescope
map("n", "z=", "<cmd>Telescope spell_suggest theme=cursor<CR>")

M.setup_lsp = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    local opts = { noremap = true, silent = true }
    bmap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    bmap(bufnr, "i", "<C-K>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    bmap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    bmap(bufnr, "n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
    bmap(bufnr, "n", "gi", "<cmd>lua require('telescope.builtin').lsp_implementations()<CR>", opts)
    bmap(bufnr, "n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
    bmap(bufnr, "n", "gs", "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>", opts)
    bmap(bufnr, "n", "ge", "<cmd>lua require('telescope.builtin').lsp_document_diagnostics()<CR>", opts)
    bmap(bufnr, "n", "gE", "<cmd>lua require('telescope.builtin').lsp_workspace_diagnostics()<CR>", opts)
    bmap(bufnr, "n", "<leader>D", "<cmd>lua require('telescope.builtin').lsp_type_definitions()<CR>", opts)
    bmap(bufnr, "n", "<leader>ca", "<cmd>lua require('telescope.builtin').lsp_code_actions()<CR>", opts)
    bmap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    bmap(bufnr, "n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    bmap(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    bmap(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    bmap(bufnr, "n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    bmap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    bmap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
    bmap(bufnr, "n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
end

return M
