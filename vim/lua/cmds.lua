vim.cmd([[command Format :lua require("utils").lsp_format({force = true})]])
vim.cmd([[command TSReload :write | edit | TSBufEnable highlight]])
