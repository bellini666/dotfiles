local M = {}

vim.cmd([[
augroup __autocmds
  " Packer
  autocmd BufWritePost plugins.lua PackerCompile

  " Gui
  autocmd UIEnter * lua require("options").setup_gui()

  " Dap
  autocmd FileType dapui* set statusline=\ 
  autocmd FileType dap-repl set statusline=\ 

  " Highlight on yank
  autocmd TextYankPost * silent! lua vim.highlight.on_yank()

  " Bash
  autocmd FileType sh,bash,zsh setlocal shiftwidth=2 softtabstop=2 expandtab

  " Javascript
  autocmd FileType javascript,javascript.jsx,javascriptreact setlocal shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType typescript.tsx,typescriptreact setlocal shiftwidth=2 softtabstop=2 expandtab

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
  autocmd FileType text,bzr,git,gitcommit setlocal spell

  " Jump to the last position when the file was last opened..
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END
]])

M.setup_lsp = function(client, bufnr)
    vim.cmd([[
      augroup _lsp_cursor_hold
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI * lua require("utils").diagnostics()
        autocmd CursorHold,CursorHoldI * lua require("nvim-lightbulb").update_lightbulb()
      augroup END
    ]])

    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
          augroup lsp_document_format
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()
          augroup END
        ]])
    end

    if client.resolved_capabilities.document_highlight then
        vim.cmd([[
          augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          augroup END
        ]])
    end

    if client.resolved_capabilities.code_lens then
        vim.cmd([[
          augroup lsp_code_lens_refresh
            autocmd! * <buffer>
            autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh()
            autocmd InsertLeave <buffer> lua vim.lsp.codelens.display()
          augroup END
        ]])
    end
end

return M
