local M = {}

local format_enabled = true
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

M.ensure_tables = function(obj, ...)
  for _, sub in ipairs({ ... }) do
    obj[sub] = obj[sub] or {}
    obj = obj[sub]
  end
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
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
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

local python_path = nil
local python_cmds = {}

M.find_python = function()
  if python_path ~= nil then
    return python_path
  end

  local p
  if vim.env.VIRTUAL_ENV then
    p = vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python3")
  else
    local env_info = nil

    local poetry_root = vim.fs.root(0, { "poetry.lock" })
    if poetry_root then
      env_info = vim.fn.system({ "poetry", "env", "info", "--path", "-C", poetry_root })
    end

    if env_info ~= nil and string.find(env_info, "could not find") == nil then
      p = vim.fs.joinpath(env_info:gsub("\n", ""), "bin", "python3")
    else
      local venv_dir = vim.fs.find(".venv", {
        upward = true,
        type = "directory",
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      })

      if #venv_dir > 0 then
        p = vim.fs.joinpath(venv_dir[1], "bin", "python3")
      else
        p = "python3"
      end
    end
  end

  python_path = p

  return p
end

M.find_python_cmd = function(cmd)
  if python_cmds[cmd] ~= nil then
    return python_cmds[cmd]
  end

  local python_bin = M.find_python()
  local python_dir = python_bin:match("(.*/)")

  local maybe_executable = vim.fs.joinpath(python_dir, cmd)
  if vim.fn.filereadable(maybe_executable) == 1 then
    python_cmds[cmd] = maybe_executable
    return maybe_executable
  end

  python_cmds[cmd] = cmd
  return cmd
end

local hast_last_run = false

M.run_tests = function()
  local opts = {
    "Test Last Run",
    "Test Last Run (debug)",
    "Test Closest",
    "Test Closest (debug)",
    "Test File",
    "Test Failed",
  }
  if not hast_last_run then
    table.remove(opts, 1)
    table.remove(opts, 1)
  end
  vim.ui.select(opts, {
    prompt = "What to run:",
  }, function(choice)
    if choice == "Test File" then
      require("neotest").run.run(vim.fn.expand("%"))
      hast_last_run = true
    elseif choice == "Test Closest" then
      require("neotest").run.run()
      hast_last_run = true
    elseif choice == "Test Closest (debug)" then
      require("neotest").run.run({ strategy = "dap" })
      hast_last_run = true
    elseif choice == "Test Last Run" then
      require("neotest").run.run_last()
      hast_last_run = true
    elseif choice == "Test Last Run (debug)" then
      require("neotest").run.run_last({ strategy = "dap" })
      hast_last_run = true
    elseif choice == "Test Failed" then
      require("neotest").run.run({ status = "failed" })
      hast_last_run = true
    end
  end)
end

return M
