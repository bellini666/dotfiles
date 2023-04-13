local map = vim.keymap.set
local utils = require("utils")

-- Global copy/paste helpers
map("v", "<C-C>", '"+y')
map({ "i", "v", "c", "n" }, "<C-S-V>", '"+p')

-- Continuous visual indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Togglers
map("n", "<leader>tf", utils.toggle_format)
map("n", "<leader>tl", "<cmd>set list!<cr>:set list?<CR>")
map("n", "<leader>tn", "<cmd>set number!<cr>:set number?<CR>")
map("n", "<leader>tp", "<cmd>set paste!<cr>:set paste?<CR>")
map("n", "<leader>ts", "<cmd>set spell!<cr>:set spell?<CR>")
map("n", "<F2>", "<cmd>UndotreeToggle<cr>")
map("n", "<F4>", "<cmd>Neotree reveal toggle<cr>")

-- File utils
map("n", "<C-F>", utils.lazy("telescope.builtin", "live_grep"))
map("n", "<C-B>", utils.lazy("telescope.builtin", "buffers"))
map("n", "<C-P>", utils.find_files)
map("n", "<C-G>", utils.grep)

-- Tasks
map("n", "<F3>", function()
  require("telescope").extensions.vstask.tasks()
end)

-- Testing
map("n", "<F1>", utils.lazy("dap", "toggle_breakpoint"))
map("n", "<F5>", utils.lazy("dap", "continue"))
map("n", "<F6>", utils.lazy("dap", "step_over"))
map("n", "<F7>", utils.lazy("dap", "sep_into"))
map("n", "<F8>", utils.lazy("dap", "step_out"))
map({ "n", "v" }, "gK", utils.lazy("dap.ui.widgets", "hover"))
map("n", "<F10>", utils.lazy("dapui", "toggle"))
map("n", "<F11>", function()
  require("neotest").output_panel.toggle()
end)
map("n", "<F12>", function()
  require("neotest").summary.toggle()
end)
map("n", "<C-D>", utils.lazy("config.dap", "run"))

-- Tabs management
map("n", "<A-Left>", "gT")
map("n", "<A-Right>", "gt")

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>")

-- Comment with Ctrl-/
map("n", "<C-_>", "gcc", { remap = true })
map("v", "<C-_>", "gc", { remap = true })
map("n", "<C-/>", "gcc", { remap = true })
map("v", "<C-/>", "gc", { remap = true })

-- Navigation
map("n", "<C-e>", utils.lazy("nvim-navbuddy", "open"))

-- dial.nvim
map("n", "<C-a>", utils.lazy("dial.map", "inc_normal"), { noremap = true })
map("n", "<C-x>", utils.lazy("dial.map", "dec_normal"), { noremap = true })
map("v", "<C-a>", utils.lazy("dial.map", "inc_visual"), { noremap = true })
map("v", "<C-x>", utils.lazy("dial.map", "dec_visual"), { noremap = true })
map("v", "g<C-a>", utils.lazy("dial.map", "inc_gvisual"), { noremap = true })
map("v", "g<C-x>", utils.lazy("dial.map", "dec_gvisual"), { noremap = true })

-- Trouble
map("n", "<C-q>", "<cmd>TroubleToggle<cr>")
map("n", "[q", utils.lazy("trouble", "previous", { { skip_groups = true, jump = true } }))
map("n", "]q", utils.lazy("trouble", "next", { { skip_groups = true, jump = true } }))
map("n", "[Q", utils.lazy("trouble", "first", { { skip_groups = true, jump = true } }))
map("n", "]Q", utils.lazy("trouble", "last", { { skip_groups = true, jump = true } }))

-- Winshift
map("n", "<C-w>m", "<cmd>WinShift<cr>")
map("n", "<C-w>x", "<cmd>WinShift swap<cr><C-w><C-w>")
map("n", "<C-w>r", utils.lazy("smart-splits", "start_resize_mode"))

-- Fix spell with telescope
map("n", "z=", utils.spell_suggest)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true })
map({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true })

-- Move Lines
map({ "n", "i" }, "<A-Up>", utils.lazy("moveline", "up"), { silent = true })
map({ "n", "i" }, "<A-Down>", utils.lazy("moveline", "down"), { silent = true })
map("v", "<A-Up>", utils.lazy("moveline", "block_up"), { silent = true })
map("v", "<A-Down>", utils.lazy("moveline", "block_down"), { silent = true })

-- Apply last change to next search result
map("n", "g.", '/\\V<C-r>"<CR>cgn<C-a><Esc>')

-- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { noremap = true, silent = true })

-- Center search results
map("n", "n", "nzz", { noremap = true, silent = true })
map("n", "N", "Nzz", { noremap = true, silent = true })

-- Terminal toggle
map({ "n", "t" }, "<F9>", utils.lazy("FTerm", "toggle"), { silent = true })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { silent = true })
map("n", "]d", vim.diagnostic.goto_next, { silent = true })
map("n", "<leader>e", vim.diagnostic.open_float, { silent = true })
map("n", "ge", "<cmd>TroubleToggle document_diagnostics<cr>")
map("n", "gE", "<cmd>TroubleToggle workspace_diagnostics<cr>")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    -- omnifunc
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- lsp
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<C-K>", vim.lsp.buf.signature_help, opts)
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
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<leader>wl", function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, opts)
  end,
})
