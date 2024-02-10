local M = {}

local format_enabled = true
local diagnostics_enabled = true
local inside_git_dir = {}
local lsp_excluded = {
  html = true,
  jsonls = true,
  pyright = true,
  sumneko_lua = true,
  lua_ls = true,
  taplo = true,
  tsserver = true,
}

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
  local cwd = opts.cwd
  opts.cwd = cwd and vim.fn.expand(cwd) or vim.uv.cwd()

  if inside_git_dir[opts.cwd] == nil then
    inside_git_dir[opts.cwd] = lsp_util.find_git_ancestor(opts.cwd) ~= nil
  end

  local cmd
  if inside_git_dir[opts.cwd] then
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

M.toggle_diagnostics = function()
  if diagnostics_enabled then
    vim.diagnostic.disable()
  else
    vim.diagnostic.enable()
  end
  diagnostics_enabled = not diagnostics_enabled
end

M.lsp_format = function(opts)
  opts = opts or {}
  if format_enabled or opts.force then
    vim.lsp.buf.format({
      filter = function(client)
        return not lsp_excluded[client.name]
      end,
    })
  end
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

M.find_python = function()
  local p
  if vim.env.VIRTUAL_ENV then
    p = require("null-ls.utils").path.join(vim.env.VIRTUAL_ENV, "bin", "python3")
  else
    local env_info = nil
    if M.find_file("poetry.lock") then
      env_info =
        vim.fn.system({ "poetry", "env", "info", "--path", "-C", vim.api.nvim_buf_get_name(0) })
    end

    if env_info ~= nil and string.find(env_info, "could not find") == nil then
      p = require("null-ls.utils").path.join(env_info:gsub("\n", ""), "bin", "python3")
    else
      p = M.find_cmd("python3", ".venv/bin")
    end
  end
  return p
end

return M
