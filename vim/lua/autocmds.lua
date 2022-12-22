local M = {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = require("options").setup_ft,
})

local augroup = vim.api.nvim_create_augroup("LspAutocmds", {})

M.setup_lsp = function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = require("utils").lsp_format,
      group = augroup,
    })
  end

  if client.server_capabilities.codeLensProvider then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
      group = augroup,
    })
  end

  -- if client.server_capabilities.documentHighlightProvider then
  --   vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  --     buffer = bufnr,
  --     callback = vim.lsp.buf.document_highlight,
  --     group = augroup,
  --   })
  --   vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  --     buffer = bufnr,
  --     callback = vim.lsp.buf.clear_references,
  --     group = augroup,
  --   })
  -- end
end

return M
