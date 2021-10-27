local map = require("utils").map

local M = {}

-- Clear highlight when refreshing.
map("n", "<C-L>", ":nohls<CR><C-L>")
map("i", "<C-L>", ":<C-O>:nohls<CR><C-L>")

-- Make Y compatible with D
map("n", "Y", "y$")
map("!", "Q", "gq")

-- Shift + Insert to paste
map("n", "<S-Insert>", '"+p')
map("i", "<S-Insert>", '<C-O>"+p')
map("!", "<S-Insert>", "<MiddleMouse>")

-- Continous visual indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Tooglers
map("n", "<Leader>tl", ":set list!<CR>:set list?<CR>")
map("n", "<Leader>tn", ":set number!<CR>:set number?<CR>")
map("n", "<Leader>tp", ":set paste!<CR>:set paste?<CR>")
map("n", "<Leader>ts", ":set spell!<CR>:set spell?<CR>")
map("n", "<F2>", ":UndotreeToggle<CR>")
map("n", "<F4>", ":NvimTreeToggle<CR>")

-- Utils
map("n", "<C-P>", ":Telescope find_files<CR>")
map("n", "<C-F>", ":Telescope live_grep<CR>")
map("n", "<C-B>", ":Telescope buffers<CR>")
map("n", "z=", ":Telescope spell_suggest theme=get_dropdown<CR>")
map("n", "<Leader>gr", ':lua require("utils").grep()<CR>', { silent = true })

return M
