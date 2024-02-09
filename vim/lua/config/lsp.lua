require("neodev").setup({})

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
local function _my_open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return _util_open_floating_preview(contents, syntax, opts, ...)
end
vim.lsp.util.open_floating_preview = _my_open_floating_preview

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
  autostart = os.getenv("DISABLE_PYRIGHT") ~= "1",
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

-- https://github.com/hashicorp/terraform-ls
nvim_lsp.terraformls.setup({
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
      completion = {
        callSnippet = "Replace",
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
  should_attach = function(bufnr)
    return os.getenv("DISABLE_NULL_LS") ~= "1"
  end,
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
      condition = function(utils)
        return os.getenv("USE_RUFF") == "0"
      end,
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
      condition = function(utils)
        return os.getenv("USE_RUFF") == "0"
      end,
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
      condition = function(utils)
        return os.getenv("USE_RUFF") == "0"
      end,
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
      condition = function(utils)
        local use_ruff = os.getenv("USE_RUFF")
        return use_ruff == nil or use_ruff == "1"
      end,
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
      extra_args = { "--unfixable", "T20,ERA001,F841" },
      condition = function(utils)
        local use_ruff = os.getenv("USE_RUFF")
        return use_ruff == nil or use_ruff == "1"
      end,
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
      condition = function(utils)
        local use_ruff = os.getenv("USE_RUFF")
        return use_ruff == nil or use_ruff == "1"
      end,
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
