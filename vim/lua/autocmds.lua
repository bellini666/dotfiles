local M = {}

local caps_available = {}

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

M.cap_exec = function(bufnr, cap, func, ...)
    if caps_available[bufnr] == nil then
        caps_available[bufnr] = {}
    end
    local active_tbl = caps_available[bufnr][cap]
    if not active_tbl or vim.tbl_isempty(active_tbl) then
        return
    end
    return func(...)
end

M.setup_lsp = function(client, bufnr)
    if caps_available[bufnr] == nil then
        caps_available[bufnr] = {}
    end
    local bcaps = caps_available[bufnr]

    for k, v in pairs(client.resolved_capabilities) do
        if bcaps[k] == nil then
            bcaps[k] = {}
        end
        bcaps[k][client.name] = v or nil
    end

    vim.cmd("augroup __lsp_cmds")
    vim.cmd("autocmd!")

    local _cmd = function(event, cap, func, opts)
        local args = string.format("%s, '%s', %s", bufnr, cap, func)
        if opts ~= nil then
            args = args .. ", " .. opts
        end
        return vim.cmd(
            string.format('autocmd %s <buffer> lua require("autocmds").cap_exec(%s)', event, args)
        )
    end
    _cmd("BufWritePre", "document_formatting", "vim.lsp.buf.formatting_sync", "{ nil, 1500 }")
    _cmd("CursorHold,CursorHoldI", "document_highlight", "vim.lsp.buf.document_highlight")
    _cmd("CursorMoved", "document_highlight", "vim.lsp.buf.clear_references")
    _cmd("BufEnter,CursorHold,CursorHoldI,InsertLeave", "code_lens", "vim.lsp.codelens.refresh")

    vim.cmd("augroup END")

    local original_stop = client.stop
    client.stop = function(...)
        for _, v in pairs(bcaps) do
            v[client.name] = nil
        end
        original_stop(...)
    end
end

return M
