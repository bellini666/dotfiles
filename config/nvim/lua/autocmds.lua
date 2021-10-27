vim.cmd([[
augroup __autocmds
  " Packer
  autocmd BufWritePost plugins.lua PackerCompile

  " Gui
  autocmd UIEnter * lua require("options").setup_gui()

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
