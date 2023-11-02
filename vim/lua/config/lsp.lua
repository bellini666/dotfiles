local nvim_lsp = require("lspconfig")
local utils = require("utils")

local augroup_formatting = vim.api.nvim_create_augroup("LspFormatting", {})
local augroup_codelens = vim.api.nvim_create_augroup("LspCodelens", {})

local excluded_paths = {
  "lib/python%d.%d+/site-packages/",
}

local lsp_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend(
    "force",
    capabilities,
    require("cmp_nvim_lsp").default_capabilities(capabilities)
  )
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
  return capabilities
end

local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_clear_autocmds({ group = augroup_formatting, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        require("utils").lsp_format({ bufnr = bufnr })
      end,
      group = augroup_formatting,
    })
  end

  if client.server_capabilities.codeLensProvider then
    vim.api.nvim_clear_autocmds({ group = augroup_codelens, buffer = bufnr })
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
      group = augroup_codelens,
    })
  end
end

local _util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return _util_open_floating_preview(contents, syntax, opts, ...)
end

local handlers = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ...)
    for _, path in pairs(excluded_paths) do
      if result.uri:match(path) ~= nil then
        return
      end
    end

    local min = vim.diagnostic.severity.INFO
    result.diagnostics = vim.tbl_filter(function(t)
      return t.severity <= min
    end, result.diagnostics)
    return vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ...)
  end, {
    underline = {
      severity = {
        min = vim.diagnostic.severity.WARN,
      },
    },
  }),
  ["textDocument/rename"] = function(_, result, ...)
    local title = nil
    local msg = {}

    if result and result.documentChanges then
      local fname
      local old = vim.fn.expand("<cword>")
      local new = "<unknown>"
      local root = vim.uv.cwd()
      for _, c in pairs(result.documentChanges) do
        new = c.edits[1].newText
        fname = "." .. c.textDocument.uri:gsub("file://" .. root, "")
        table.insert(msg, ("%d changes -> %s"):format(#c.edits, fname))
      end
      title = ("Rename: %s -> %s"):format(old, new)
    end

    local ret = vim.lsp.handlers["textDocument/rename"](_, result, ...)

    if not vim.tbl_isempty(msg) then
      vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, { title = title })
      -- Save the modified files after the rename
      vim.cmd("wall")
    end

    return ret
  end,
  ["textDocument/definition"] = utils.lsp_locs_handler("LSP Definitions", "definitions"),
  ["textDocument/references"] = utils.lsp_locs_handler(
    "LSP References",
    "references",
    { jump_type = "never" }
  ),
  ["textDocument/typeDefinition"] = utils.lsp_locs_handler(
    "LSP Type Definitions",
    "typeDefinitions"
  ),
  ["textDocument/implementation"] = utils.lsp_locs_handler(
    "LSP Implementations",
    "implementations"
  ),
  ["workspace/symbol"] = utils.lsp_symbols_handler(
    "LSP Workspace Symbols",
    "symbols",
    { ignore_filename = false }
  ),
  ["textDocument/documentSymbol"] = utils.lsp_symbols_handler(
    "LSP Document Symbols",
    "document symbols",
    { ignore_filename = true }
  ),
  ["callHierarchy/incomingCalls"] = utils.lsp_calls_handler(
    "from",
    "LSP Incoming Calls",
    "incoming calls"
  ),
  ["callHierarchy/outgoingCalls"] = utils.lsp_calls_handler(
    "to",
    "LSP Outgoing Calls",
    "outgoing calls"
  ),
}

-- https://github.com/microsoft/pyright
nvim_lsp.pyright.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
  on_attach = on_attach,
  before_init = function(_, config)
    config.settings.python.pythonPath = utils.find_python()
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        disableOrganizeImports = true,
      },
    },
  },
})

-- https://github.com/theia-ide/typescript-language-server
nvim_lsp.tsserver.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
  on_attach = on_attach,
})

-- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli
nvim_lsp.graphql.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
  on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.eslint.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.cssls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.html.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/redhat-developer/yaml-language-server
nvim_lsp.yamlls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
  settings = {
    yaml = {
      validate = true,
      completion = true,
      hover = true,
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
      format = {
        enable = false,
      },
    },
  },
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.jsonls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
  init_options = {
    provideFormatter = false,
  },
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

-- https://taplo.tamasfe.dev/cli/usage/language-server.html
nvim_lsp.taplo.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
})

-- https://github.com/LuaLS/lua-language-server
nvim_lsp.lua_ls.setup({
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
  handlers = handlers,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = { vim.env.VIMRUNTIME },
        maxPreload = 10000,
        preloadFileSize = 1000,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- https://github.com/jose-elias-alvarez/null-ls.nvim
local diagnostics_format = "[#{c}] #{m} (#{s})"
local null_ls = require("null-ls")
local nhelpers = require("null-ls.helpers")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
null_ls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
  on_attach = on_attach,
  sources = {
    -- gitrebase code_actions,
    code_actions.gitrebase,
    -- github actioins
    diagnostics.actionlint,
    -- cspell
    diagnostics.cspell.with({
      diagnostics_format = diagnostics_format,
      condition = function(utils)
        return utils.root_has_file({ "cspell.json", "cspell.config.yaml", "cspell.config.cjs" })
      end,
    }),
    -- python
    diagnostics.flake8.with({
      diagnostics_format = diagnostics_format,
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          ".flake8",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      runtime_condition = nhelpers.cache.by_bufnr(function()
        local bufname = vim.api.nvim_buf_get_name(0)
        for _, path in pairs(excluded_paths) do
          if bufname:match(path) ~= nil then
            return false
          end
        end

        local pyproject = utils.find_file("pyproject.toml")
        if pyproject then
          local file = assert(io.open(pyproject, "r"))
          local content = file:read("*all")
          if string.find(content, "tool.ruff") then
            return false
          end
        end
        return true
      end),
    }),
    formatting.isort.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          ".isort.cfg",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      extra_args = { "--profile", "black" },
      runtime_condition = nhelpers.cache.by_bufnr(function()
        local bufname = vim.api.nvim_buf_get_name(0)
        for _, path in pairs(excluded_paths) do
          if bufname:match(path) ~= nil then
            return false
          end
        end

        local pyproject = utils.find_file("pyproject.toml")
        if pyproject then
          local file = assert(io.open(pyproject, "r"))
          local content = file:read("*all")
          if string.find(content, "tool.ruff.isort") then
            return false
          end
        end
        return true
      end),
    }),
    formatting.black.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      extra_args = { "--fast" },
      runtime_condition = nhelpers.cache.by_bufnr(function()
        local bufname = vim.api.nvim_buf_get_name(0)
        for _, path in pairs(excluded_paths) do
          if bufname:match(path) ~= nil then
            return false
          end
        end

        local pyproject = utils.find_file("pyproject.toml")
        if pyproject then
          local file = assert(io.open(pyproject, "r"))
          local content = file:read("*all")
          if string.find(content, "tool.ruff.format") then
            return false
          end
        end
        return true
      end),
    }),
    diagnostics.ruff.with({
      diagnostics_format = diagnostics_format,
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      runtime_condition = nhelpers.cache.by_bufnr(function()
        local bufname = vim.api.nvim_buf_get_name(0)
        for _, path in pairs(excluded_paths) do
          if bufname:match(path) ~= nil then
            return false
          end
        end

        local pyproject = utils.find_file("pyproject.toml")
        if pyproject then
          local file = assert(io.open(pyproject, "r"))
          local content = file:read("*all")
          if string.find(content, "tool.ruff") then
            return true
          end
        end
        return false
      end),
    }),
    formatting.ruff.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      runtime_condition = nhelpers.cache.by_bufnr(function()
        local pyproject = utils.find_file("pyproject.toml")
        if pyproject then
          local file = assert(io.open(pyproject, "r"))
          local content = file:read("*all")
          if string.find(content, "tool.ruff") then
            return true
          end
        end
        return false
      end),
      extra_args = { "--unfixable", "T20,ERA001,F841" },
    }),
    formatting.ruff_format.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      runtime_condition = nhelpers.cache.by_bufnr(function()
        local pyproject = utils.find_file("pyproject.toml")
        if pyproject then
          local file = assert(io.open(pyproject, "r"))
          local content = file:read("*all")
          if string.find(content, "tool.ruff.format") then
            return true
          end
        end
        return false
      end),
    }),
    -- djlint
    formatting.djlint.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          ".djlintrc",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
    }),
    diagnostics.djlint.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return require("null-ls.utils").root_pattern(
          ".djlintrc",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      diagnostics_format = diagnostics_format,
    }),
    -- javascript/typescript
    formatting.prettier.with({
      prefer_local = "node_modules/.bin",
    }),
    -- sh/bash
    code_actions.shellcheck,
    diagnostics.shellcheck.with({
      diagnostics_format = diagnostics_format,
    }),
    formatting.shfmt.with({
      extra_args = function(params)
        return { "-i", tostring(vim.opt_local.shiftwidth:get()) }
      end,
    }),
    -- lua
    formatting.stylua.with({
      condition = function(utils)
        return utils.root_has_file({ "stylua.toml", ".stylua.toml" })
      end,
    }),
    -- json
    formatting.fixjson,
    -- yaml
    diagnostics.yamllint.with({
      diagnostics_format = diagnostics_format,
      extra_args = function(params)
        return {
          "-d",
          string.format(
            "{extends: default, rules: {line-length: {max: %d}}}",
            vim.opt_local.textwidth:get() + 1
          ),
        }
      end,
    }),
    formatting.yamlfix.with({
      env = function(params)
        return {
          YAMLFIX_LINE_LENGTH = tostring(vim.opt_local.textwidth:get() + 1),
          YAMLFIX_SECTION_WHITELINES = "1",
          YAMLFIX_quote_representation = '"',
          YAMLFIX_SEQUENCE_STYLE = "block_style",
        }
      end,
    }),
    -- markdown
    diagnostics.markdownlint.with({
      diagnostics_format = diagnostics_format,
    }),
    -- toml
    formatting.taplo,
  },
})
