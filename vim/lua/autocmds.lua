local M = {}

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "plugins.lua",
  callback = function()
    vim.cmd("source <afile>")
    vim.cmd("PackerCompile")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = require("options").setup_ft,
})

M.setup_lsp = function(client, bufnr)
  if client.resolved_capabilities.document_formatting then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = require("utils").lsp_format,
    })
  end

  if client.resolved_capabilities.code_lens then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    })
  end

  -- Not using this right now as it is annoying
  if client.resolved_capabilities.document_highlight and false then
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

return M
