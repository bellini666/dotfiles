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
map("n", "<leader>tn", "<cmd>set number!<cr>:set number?<CR>")
map("n", "<leader>tp", "<cmd>set paste!<cr>:set paste?<CR>")
map("n", "<leader>ts", "<cmd>set spell!<cr>:set spell?<CR>")
map("n", "<leader>td", '<cmd>lua require("dapui").toggle()<cr>')
map("n", "<F2>", "<cmd>UndotreeToggle<cr>")
map("n", "<F4>", "<cmd>NvimTreeToggle<cr>")

-- File utils
map("n", "<C-F>", utils.lazy("telescope.builtin", "live_grep"))
map("n", "<C-B>", utils.lazy("telescope.builtin", "buffers"))
map("n", "<C-P>", utils.find_files)
map("n", "<C-G>", utils.grep)

-- Dap
map("n", "<F1>", utils.lazy("dap", "toggle_breakpoint"))
map("n", "<F5>", utils.lazy("dap", "continue"))
map("n", "<F6>", utils.lazy("dap", "step_over"))
map("n", "<F7>", utils.lazy("dap", "sep_into"))
map("n", "<F8>", utils.lazy("dap", "step_out"))
map("n", "<Leader>df", utils.lazy("config.dap", "test_func"))
map("n", "<Leader>dc", utils.lazy("config.dap", "test_class"))
map({ "n", "v" }, "gK", utils.lazy("dapui", "eval"))

-- Tabs management
map("n", "<A-Left>", "gT")
map("n", "<A-Right>", "gt")

-- Comment with Ctrl-/
map("n", "<C-_>", "gcc", { remap = true })
map("v", "<C-_>", "gc", { remap = true })
map("n", "<C-/>", "gcc", { remap = true })
map("v", "<C-/>", "gc", { remap = true })

-- Trouble
map("n", "<C-q>", "<cmd>TroubleToggle<cr>")
map("n", "]q", utils.lazy("trouble", "next", { { skip_groups = true, jump = true } }))
map("n", "[q", utils.lazy("trouble", "previous", { { skip_groups = true, jump = true } }))

-- Winshift
map("n", "<C-w>m", "<cmd>WinShift<cr>")
map("n", "<C-w>x", "<cmd>WinShift swap<cr>")

-- Reload treesitter
map("n", "<Leader>rt", "<cmd>write | edit | TSBufEnable highlight<cr>")

-- Fix spell with telescope
map("n", "z=", utils.spell_suggest)

-- Ctrl-Up/Down scrolls 10 lunes and keep the screen centered
map("n", "<C-Up>", "10kzz")
map("n", "<C-Down>", "10jzz")

-- Terminal toggle
map({ "n", "t" }, "<C-Z>", utils.lazy("FTerm", "toggle"), { silent = true })

M.setup_lsp = function(client, bufnr)
    local opts = { buffer = true, silent = true }

    -- omnifunc
    vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

    -- diagnostic
    map("n", "[d", vim.diagnostic.goto_prev, opts)
    map("n", "]d", vim.diagnostic.goto_next, opts)
    map("n", "<leader>e", vim.diagnostic.open_float, opts)
    map("n", "ge", "<cmd>TroubleToggle document_diagnostics<cr>", opts)
    map("n", "gE", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)

    -- lsp
    map("n", "K", vim.lsp.buf.hover, opts)
    map({ "i", "n" }, "<C-K>", vim.lsp.buf.signature_help, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "<C-LeftMouse>", vim.lsp.buf.definition, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gI", vim.lsp.buf.implementation, opts)
    map("n", "gci", vim.lsp.buf.incoming_calls, opts)
    map("n", "gco", vim.lsp.buf.outgoing_calls, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gs", vim.lsp.buf.document_symbol, opts)
    map("n", "gS", vim.lsp.buf.workspace_symbol, opts)
    map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("v", "<leader>ca", vim.lsp.buf.range_code_action, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
end

return M
