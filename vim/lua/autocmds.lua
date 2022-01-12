local M = {}

vim.cmd([[
augroup __autocmds
  autocmd!

  " Packer
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile

  " Colors
  autocmd ColorScheme * lua require("colors").setup()

  " Filetypes
  autocmd FileType * lua require("options").setup_ft()

augroup END
]])

M.setup_lsp = function(client, bufnr)
    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
          augroup __lsp_document_format
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1500)
          augroup END
        ]])
    end

    if client.resolved_capabilities.document_highlight then
        vim.cmd([[
          augroup __lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          augroup END
        ]])
    end

    if client.resolved_capabilities.code_lens then
        vim.cmd([[
          augroup __lsp_code_lens_refresh
            autocmd! * <buffer>
            autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()
          augroup END
        ]])
    end
end

return M
