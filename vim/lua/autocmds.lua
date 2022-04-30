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
  if client.server_capabilities.documentFormattingProvider then
    local group_id = vim.api.nvim_create_augroup(
      ("_lsp_formatting_%d"):format(bufnr),
      { clear = true }
    )
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = require("utils").lsp_format,
      group = group_id,
    })
  end

  if client.server_capabilities.codeLensProvider then
    local group_id = vim.api.nvim_create_augroup(
      ("_lsp_codelens_%d"):format(bufnr),
      { clear = true }
    )
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
      group = group_id,
    })
  end

  -- Not using this right now as it is annoying
  if client.server_capabilities.documentHighlightProvider and false then
    local group_id = vim.api.nvim_create_augroup(
      ("_lsp_highlight_%d"):format(bufnr),
      { clear = true }
    )
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
      group = group_id,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
      group = group_id,
    })
  end
end

return M
