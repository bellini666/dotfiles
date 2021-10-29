local map = require("utils").map

local M = {}

-- Clear highlight when refreshing.
map("n", "<C-L>", "<cmd>nohls<CR><C-L>")
map("i", "<C-L>", "<cmd><C-O>:nohls<CR><C-L>")
map("c", "<C-L>", "<cmd><C-O>:nohls<CR><C-L>")

-- Make Y compatible with D
map("n", "Y", "y$")

-- Shift + Insert to paste
map("n", "<S-Insert>", '"+p')
map("i", "<S-Insert>", '<C-O>"+p')
map("c", "<S-Insert>", "<MiddleMouse>")

-- Continous visual indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Tooglers
map("n", "<Leader>tl", "<cmd>set list!<CR>:set list?<CR>")
map("n", "<Leader>tn", "<cmd>set number!<CR>:set number?<CR>")
map("n", "<Leader>tp", "<cmd>set paste!<CR>:set paste?<CR>")
map("n", "<Leader>ts", "<cmd>set spell!<CR>:set spell?<CR>")
map("n", "<Leader>tq", '<cmd>lua require("utils").toggle_qf()<CR>')
map("n", "<F2>", "<cmd>UndotreeToggle<CR>")
map("n", "<F4>", "<cmd>NvimTreeToggle<CR>")

-- Utils
map("n", "z=", "<cmd>Telescope spell_suggest theme=cursor<CR>")
map("n", "<C-P>", "<cmd>Telescope find_files theme=dropdown<CR>")
map("n", "<C-F>", "<cmd>Telescope live_grep<CR>")
map("n", "<C-B>", "<cmd>Telescope buffers<CR>")
map("n", "<C-G>", '<cmd>lua require("utils").grep()<CR>', { silent = true })
map("n", "<C-_>", "gcc", { silent = true, noremap = false })
map("v", "<C-_>", "gc", { silent = true, noremap = false })

return M
