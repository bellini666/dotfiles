local M = {}
local registered_cache = {}

vim.cmd([[
augroup __autocmds
  autocmd!

  " Packer
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile

  " Gui
  autocmd UIEnter * lua require("options").setup_gui()

  " Colors
  autocmd ColorScheme * lua require("colors").setup()

  " Filetypes
  autocmd FileType * lua require("options").setup_ft()

augroup END
]])

M.setup_lsp = function(client, bufnr)
    -- We can't clear autocmds because null-ls doesn't register itself anymore...
    local cache = registered_cache[bufnr]
    if cache == nil then
        cache = {}
        registered_cache[bufnr] = cache
    end

    if not cache["formatting"] and client.resolved_capabilities.document_formatting then
        vim.cmd([[
        augroup __lsp_document_format
          autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1500)
        augroup END
        ]])
        cache["formatting"] = true
    end

    if not cache["highlight"] and client.resolved_capabilities.document_highlight then
        vim.cmd([[
        augroup __lsp_document_highlight
          autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]])
        cache["highlight"] = true
    end

    if not cache["code_lens"] and client.resolved_capabilities.code_lens then
        vim.cmd([[
        augroup __lsp_code_lens_refresh
          autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()
        augroup END
        ]])
        cache["code_lens"] = true
    end
end

return M
