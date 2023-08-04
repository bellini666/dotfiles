local M = {}

local format_enabled = true

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
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.uv.cwd()

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

M.toggle_format = function()
  -- Mimic :set <option>?
  format_enabled = not format_enabled
  print((format_enabled and "  " or "no") .. "format")
end

M.lsp_format = function(opts)
  opts = opts or {}
  if format_enabled or opts.force then
    vim.lsp.buf.format({
      filter = function(client)
        local excluded = {
          html = true,
          jsonls = true,
          pyright = true,
          sumneko_lua = true,
          tsserver = true,
        }
        return not excluded[client.name]
      end,
    })
  end
end

M.lsp_handler = function(parser, title, action, opts)
  local function handle_result(err, result, ctx, ...)
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
      vim.lsp.util.jump_to_location(
        result[1],
        vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
      )
    else
      pickers
        .new(opts, {
          prompt_title = title,
          finder = finders.new_table({
            results = parser(result, ctx),
            entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
          }),
          previewer = conf.qflist_previewer(opts),
          sorter = conf.generic_sorter(opts),
          push_cursor_on_edit = true,
          push_tagstack_on_edit = true,
        })
        :find()
    end
  end
  return handle_result
end

M.lsp_locs_handler = function(...)
  return M.lsp_handler(function(result, ctx)
    return vim.lsp.util.locations_to_items(
      result,
      vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
    )
  end, ...)
end

M.lsp_symbols_handler = function(...)
  return M.lsp_handler(function(result, ctx)
    return vim.lsp.util.symbols_to_items(result, ctx.bufnr)
  end, ...)
end

M.lsp_calls_handler = function(direction, ...)
  local function handler(result, ctx)
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
      if pattern == "" or pattern == "*" then
        pattern = nil
      end

      require("telescope.builtin").live_grep({
        search_dirs = { dir },
        glob_pattern = pattern,
      })
    end)
  end)
end

M.find_file = function(file, prefixes, start_from, stop_at)
  local util = require("null-ls.utils")

  if start_from == nil then
    start_from = vim.api.nvim_buf_get_name(0)
  end

  if prefixes == nil then
    prefixes = { "" }
  elseif type(prefixes) == "string" then
    prefixes = { prefixes }
  end

  for _, prefix in ipairs(prefixes) do
    local full_cmd = prefix and util.path.join(prefix, file) or file

    for dir in vim.fs.parents(start_from) do
      local maybe_file = util.path.join(dir, full_cmd)
      if vim.fn.filereadable(maybe_file) == 1 then
        return maybe_file
      end
      if dir == stop_at then
        break
      end
    end
  end
end

M.find_cmd = function(cmd, prefixes, start_from, stop_at)
  local util = require("null-ls.utils")

  if start_from == nil then
    start_from = vim.api.nvim_buf_get_name(0)
  end

  if prefixes == nil then
    prefixes = { "" }
  elseif type(prefixes) == "string" then
    prefixes = { prefixes }
  end

  local found
  for _, prefix in ipairs(prefixes) do
    local full_cmd = prefix and util.path.join(prefix, cmd) or cmd

    for dir in vim.fs.parents(start_from) do
      local maybe_executable = util.path.join(dir, full_cmd)
      if util.is_executable(maybe_executable) then
        found = maybe_executable
        break
      end
      if dir == stop_at then
        break
      end
    end

    if found ~= nil then
      break
    end
  end

  return found or cmd
end

return M
