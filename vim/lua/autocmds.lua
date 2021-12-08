local M = {}

vim.cmd([[
augroup __autocmds
  autocmd! * <buffer>

  " Packer
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile

  " Gui
  autocmd UIEnter * lua require("options").setup_gui()
  autocmd ColorScheme * lua require("options").setup_colors()

  " Bash
  autocmd FileType sh,bash,zsh setlocal shiftwidth=2 softtabstop=2 expandtab

  " Javascript
  autocmd FileType javascript,javascript.jsx,javascriptreact setlocal shiftwidth=2 softtabstop=2 expandtab

  " Typescript
  autocmd FileType typescript.tsx,typescriptreact setlocal shiftwidth=2 softtabstop=2 expandtab

  " Graphql
  autocmd FileType graphql setlocal shiftwidth=2 softtabstop=2 expandtab

  " CSS
  autocmd FileType css,scss setlocal shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType scss setl iskeyword+=@-@

  " HTML/XML
  autocmd FileType html,xml setlocal shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType html,xml syn spell toplevel

  " Mail
  autocmd FileType mail setlocal spell
  autocmd FileType mail setlocal textwidth=74

  " PO
  autocmd FileType po setlocal spell

  " Misc
  autocmd FileType help,tags setlocal nospell
  autocmd FileType text,bzr,gitcommit setlocal spell

  " Jump to the last position when the file was last opened..
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END
]])

M.setup_lsp = function(client, bufnr)
    vim.cmd([[
      augroup _lsp_cursor_hold
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI * lua require("utils").diagnostics()
      augroup END
    ]])

    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
          augroup _lsp_document_format
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1500)
          augroup END
        ]])
    end

    if client.resolved_capabilities.document_highlight then
        vim.cmd([[
          augroup _lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          augroup END
        ]])
    end

    if client.resolved_capabilities.code_lens then
        vim.cmd([[
          augroup _lsp_code_lens_refresh
            autocmd! * <buffer>
            autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh()
            autocmd InsertLeave <buffer> lua vim.lsp.codelens.display()
          augroup END
        ]])
    end
end

return M
