local map = vim.keymap.set
local utils = require("utils")

local M = {}

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
map("n", "<leader>td", '<cmd>lua require("dapui").toggle()<cr>')
map("n", "<F2>", "<cmd>Telescope undo<cr>")
map("n", "<F4>", "<cmd>Telescope file_browser<cr>")

-- File utils
map("n", "<C-F>", utils.lazy("telescope.builtin", "live_grep"))
map("n", "<C-B>", utils.lazy("telescope.builtin", "buffers"))
map("n", "<C-P>", utils.find_files)
map("n", "<C-G>", utils.grep)

-- Testing
map("n", "<F8>", function()
  require("neotest").summary.toggle()
end)
map("n", "<Leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end)
map("n", "<Leader>tt", function()
  require("neotest").run.run()
end)

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

-- Fix spell with telescope
map("n", "z=", utils.spell_suggest)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true })
map({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true })

-- Move Lines
map({ "n", "i" }, "<A-Down>", "<Plug>(unimpaired-move-down)")
map("v", "<A-Down>", "<Plug>(unimpaired-move-selection-down)gv")
map({ "n", "i" }, "<A-Up>", "<Plug>(unimpaired-move-up)")
map("v", "<A-Up>", "<Plug>(unimpaired-move-selection-up)gv")

-- Apply last change to next search result
map("n", "g.", '/\\V<C-r>"<CR>cgn<C-a><Esc>')

-- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { noremap = true, silent = true })

-- Center search results
map("n", "n", "nzz", { noremap = true, silent = true })
map("n", "N", "Nzz", { noremap = true, silent = true })

-- Terminal toggle
map({ "n", "t" }, "<F1>", utils.lazy("FTerm", "toggle"), { silent = true })

M.setup_lsp = function(client, bufnr)
  local opts = { buffer = true, silent = true }

  -- omnifunc
  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

  -- diagnostic
  map("n", "[d", vim.diagnostic.goto_prev, opts)
  map("n", "]d", vim.diagnostic.goto_next, opts)
  map("n", "<leader>e", vim.diagnostic.open_float, opts)
  map("n", "ge", utils.lazy("telescope.builtin", "diagnostics", { { bufnr = 0 } }))
  map("n", "gE", utils.lazy("telescope.builtin", "diagnostics"))

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
  map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  map("n", "<leader>rn", vim.lsp.buf.rename, opts)
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  map("n", "<leader>wl", function()
    vim.pretty_print(vim.lsp.buf.list_workspace_folders())
  end, opts)
end

return M
