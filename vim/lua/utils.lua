local M = {}

M.lazy = function(mod, func, ...)
    local arg = ... or {}
    return function()
        return require(mod)[func](unpack(arg))
    end
end

M.trim = function(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

M.find_files = function(opts)
    local lsp_util = require("lspconfig.util")
    local t_builtin = require("telescope.builtin")
    local t_themes = require("telescope.themes")

    if opts == nil then
        opts = {}
    end
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

    local cmd
    if lsp_util.find_git_ancestor(opts.cwd) then
        cmd = t_builtin.git_files
    else
        cmd = t_builtin.find_files
    end

    return cmd(t_themes.get_dropdown(opts))
end

M.spell_suggest = function(opts)
    local t_builtin = require("telescope.builtin")
    local t_themes = require("telescope.themes")
    return t_builtin.spell_suggest(t_themes.get_cursor(opts))
end

M.lsp_handler = function(parser, title, action, opts)
    local function handle_result(err, result, ...)
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local make_entry = require("telescope.make_entry")
        local conf = require("telescope.config").values

        if err then
            vim.api.nvim_err_writeln(string.format('Error executing "%s": %s', action, err.message))
            return
        end

        -- textDocument/definition can return Location or Location[]
        if result ~= nil and not vim.tbl_islist(result) then
            result = { result }
        end

        opts = opts or {}
        if not result or #result == 0 then
            vim.api.nvim_err_writeln(string.format('No results for "%s"', action))
            return
        elseif #result == 1 and opts.jump_type ~= "never" then
            if opts.jump_type == "tab" then
                vim.cmd("tabedit")
            elseif opts.jump_type == "split" then
                vim.cmd("new")
            elseif opts.jump_type == "vsplit" then
                vim.cmd("vnew")
            end
            vim.lsp.util.jump_to_location(result[1])
        else
            pickers.new(opts, {
                prompt_title = title,
                finder = finders.new_table({
                    results = parser(result),
                    entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
                }),
                previewer = conf.qflist_previewer(opts),
                sorter = conf.generic_sorter(opts),
            }):find()
        end
    end
    return handle_result
end

M.lsp_locs_handler = function(...)
    return M.lsp_handler(vim.lsp.util.locations_to_items, ...)
end

M.lsp_symbols_handler = function(...)
    return M.lsp_handler(vim.lsp.util.symbols_to_items, ...)
end

M.lsp_calls_handler = function(direction, ...)
    local function handler(result)
        local items = {}
        for _, res in pairs(result) do
            local item = res[direction]
            for _, range in pairs(res.fromRanges) do
                table.insert(items, {
                    filename = assert(vim.uri_to_fname(item.uri)),
                    text = item.name,
                    lnum = range.start.line + 1,
                    col = range.start.character + 1,
                })
            end
        end
        return items
    end
    return M.lsp_handler(handler, ...)
end

M.grep = function()
    vim.ui.input({ prompt = "Directory: ", default = "./", completion = "dir" }, function(dir)
        dir = vim.trim(dir or "")
        if dir == "" then
            return
        end

        vim.ui.input({ prompt = "File pattern: ", default = "*" }, function(pattern)
            pattern = vim.trim(pattern or "")
            if pattern == "" then
                return
            end

            local args = require("telescope.config").values.vimgrep_arguments
            if pattern ~= "*" then
                vim.list_extend(args, { "-g", pattern })
            end

            require("telescope.builtin").live_grep({
                search_dirs = { dir },
                vimgrep_arguments = args,
            })
        end)
    end)
end

M.node_at_cursor = function()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local expr = ts_utils.get_node_at_cursor()

    local func
    local class

    while expr do
        if expr:type() == "function_definition" then
            func = (ts_utils.get_node_text(expr:child(1)))[1]
        end
        if expr:type() == "class_definition" then
            class = (ts_utils.get_node_text(expr:child(1)))[1]
        end
        expr = expr:parent()
    end

    return {
        func = func,
        class = class,
    }
end

M.find_cmd = function(cmd, prefixes, start_from, stop_at)
    local path = require("lspconfig/util").path

    if type(prefixes) == "string" then
        prefixes = { prefixes }
    end

    local found
    for _, prefix in ipairs(prefixes) do
        local full_cmd = prefix and path.join(prefix, cmd) or cmd
        local possibility

        -- if start_from is a dir, test it first since transverse will start from its parent
        if start_from and path.is_dir(start_from) then
            possibility = path.join(start_from, full_cmd)
            if vim.fn.executable(possibility) > 0 then
                found = possibility
                break
            end
        end

        path.traverse_parents(start_from, function(dir)
            possibility = path.join(dir, full_cmd)
            if vim.fn.executable(possibility) > 0 then
                found = possibility
                return true
            end
            -- use cwd as a stopping point to avoid scanning the entire file system
            if stop_at and dir == stop_at then
                return true
            end
        end)

        if found ~= nil then
            break
        end
    end

    return found or cmd
end

return M
