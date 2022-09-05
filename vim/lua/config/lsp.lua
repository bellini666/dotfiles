local nvim_lsp = require("lspconfig")
local lsp_util = require("lspconfig/util")
local utils = require("utils")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local on_attach = function(client, bufnr)
  require("autocmds").setup_lsp(client, bufnr)
  require("mappings").setup_lsp(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end
end

local _util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return _util_open_floating_preview(contents, syntax, opts, ...)
end

local handlers = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ...)
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
      local root = vim.loop.cwd()
      for _, c in pairs(result.documentChanges) do
        new = c.edits[1].newText
        fname = "." .. c.textDocument.uri:gsub("file://" .. root, "")
        table.insert(msg, ("%d changes -> %s"):format(#c.edits, fname))
      end
      title = ("Rename: %s -> %s"):format(old, new)
    end

    local ret = vim.lsp.handlers["textDocument/rename"](_, result, ...)

    if not vim.tbl_isempty(msg) then
      vim.notify(msg, vim.log.levels.INFO, { title = title })
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
  capabilities = capabilities,
  handlers = handlers,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
  before_init = function(_, config)
    local p
    if vim.env.VIRTUAL_ENV then
      p = lsp_util.path.join(vim.env.VIRTUAL_ENV, "bin", "python3")
    else
      p = utils.find_cmd("python3", ".venv/bin", config.root_dir)
    end
    config.settings.python.pythonPath = p
  end,
  settings = {
    disableOrganizeImports = true,
  },
})

-- https://github.com/theia-ide/typescript-language-server
nvim_lsp.tsserver.setup({
  capabilities = capabilities,
  handlers = handlers,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
})

-- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli
nvim_lsp.graphql.setup({
  capabilities = capabilities,
  handlers = handlers,
  on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.eslint.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
})

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.cssls.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.html.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
})

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
})

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
})

-- https://github.com/redhat-developer/yaml-language-server
nvim_lsp.yamlls.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    yaml = {
      format = {
        printWidth = 100,
      },
    },
  },
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.jsonls.setup({
  handlers = handlers,
  capabilities = capabilities,
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

-- https://github.com/sumneko/lua-language-server
nvim_lsp.sumneko_lua.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
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
        library = vim.api.nvim_get_runtime_file("", true),
        maxPreload = 10000,
        preloadFileSize = 1000,
      },
    },
  },
})

-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls = require("null-ls")
local nutils = require("null-ls.utils")
local nhelpers = require("null-ls.helpers")
local diagnostics_format = "[#{c}] #{m} (#{s})"
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
null_ls.setup({
  handlers = handlers,
  capabilities = capabilities,
  on_attach = on_attach,
  sources = {
    -- refactoring.nvim code_actions,
    code_actions.refactoring,
    -- shellcheck code_actions,
    code_actions.shellcheck,
    -- gitrebase code_actions,
    code_actions.gitrebase,
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
        return nutils.root_pattern(
          ".flake8",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      -- Ignore some errors that are always fixed by black
      extra_args = { "--extend-ignore", "E1,E2,E3,F821,E731,R504,SIM106" },
    }),
    formatting.isort.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return nutils.root_pattern(
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
    }),
    formatting.black.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return nutils.root_pattern(
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json"
        )(params.bufname)
      end),
      extra_args = { "--fast", "-W", "6" },
    }),
    -- djlint
    formatting.djlint.with({
      prefer_local = ".venv/bin",
      cwd = nhelpers.cache.by_bufnr(function(params)
        return nutils.root_pattern(
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
        return nutils.root_pattern(
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
    diagnostics.shellcheck.with({
      diagnostics_format = diagnostics_format,
    }),
    formatting.shfmt.with({
      extra_args = { "-i", "2" },
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
      extra_args = { "-d", "{extends: default, rules: {line-length: {max: 100}}}" },
    }),
    -- markdown
    diagnostics.markdownlint.with({
      diagnostics_format = diagnostics_format,
    }),
    -- sql
    formatting.sqlformat,
    -- toml
    formatting.taplo,
    -- css/scss/sass/less
    formatting.stylelint,
  },
})
