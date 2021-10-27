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

M.escape = function(str)
    for _, char in ipairs({ '"', "(", ")" }) do
        -- FIXME Why isn't gsub working?
        -- str = string.gsub(str, char, "\\" .. char)
        str = vim.fn.substitute(str, char, "\\" .. char, "g")
    end
    return str
end

M.grep = function()
    local pattern = vim.fn.trim(vim.fn.input("Search for pattern: ", vim.fn.expand("<cword>")))
    if pattern == "" then
        return
    end
    pattern = '"' .. M.escape(pattern) .. '"'

    local dirs = vim.fn.trim(vim.fn.input("Limit for directory: ", "./", "dir"))
    if dirs ~= "" then
        dirs = '"' .. dirs .. '"'
    end

    local files = vim.fn.trim(vim.fn.input("Limit for file patterns: ", "*"))
    if files == "*" then
        files = ""
    else
        files = '-g "' .. files .. '"'
    end

    local cmd = "GrepperRg " .. pattern .. " " .. dirs .. " " .. files
    print(cmd)
    vim.api.nvim_command(cmd)
end

return M
