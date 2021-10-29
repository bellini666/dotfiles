local M = {}

M.merge = function(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

M.concat = function(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

M.map = function(modes, key, result, options)
    options = M.merge({
        noremap = true,
        silent = false,
        expr = false,
        nowait = false,
    }, options or {})
    if type(modes) ~= "table" then
        modes = { modes }
    end

    for i = 1, #modes do
        vim.api.nvim_set_keymap(modes[i], key, result, options)
    end
end

M.bmap = function(buf, modes, key, result, options)
    options = M.merge({
        noremap = true,
        silent = false,
        expr = false,
        nowait = false,
    }, options or {})
    if type(modes) ~= "table" then
        modes = { modes }
    end

    for i = 1, #modes do
        vim.api.nvim_buf_set_keymap(buf, modes[i], key, result, options)
    end
end

M.diagnostics = function(opts, bufnr, line_nr, client_id)
    opts = opts or {}

    bufnr = bufnr or 0
    line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)

    local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts, client_id)
    if vim.tbl_isempty(line_diagnostics) then
        return
    end

    local diagnostic_message = ""
    for i, diagnostic in ipairs(line_diagnostics) do
        diagnostic_message = diagnostic_message .. string.format("%d: %s", i, diagnostic.message or "")
        if i ~= #line_diagnostics then
            diagnostic_message = diagnostic_message .. "\n"
        end
    end
    print(diagnostic_message)
end

M.grep = function()
    local t_builtin = require("telescope.builtin")
    local t_config = require("telescope.config")

    local search = vim.fn.trim(vim.fn.input("rg > ", vim.fn.expand("<cword>")))
    local dir = vim.fn.trim(vim.fn.input("dir > ", "./", "dir"))
    local args = t_config.values.vimgrep_arguments
    local pattern = vim.fn.trim(vim.fn.input("file patterns > ", "*"))
    if pattern ~= "*" then
        args = M.concat(args, { "-g", pattern })
    end
    t_builtin.grep_string({
        search = search,
        search_dirs = { dir },
        vimgrep_arguments = args,
    })
end

M.toggle_qf = function()
    local qf_exists = false
    for _, win in pairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            qf_exists = true
        end
    end
    if qf_exists == true then
        vim.cmd("cclose")
        return
    end
    if not vim.tbl_isempty(vim.fn.getqflist()) then
        vim.cmd("copen")
    end
end

return M
