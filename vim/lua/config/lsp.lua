local nvim_lsp = require("lspconfig")
local utils = require("utils")

local augroup_lspattach = vim.api.nvim_create_augroup("_my_lsp_attach", { clear = true })
local augroup_formatting = vim.api.nvim_create_augroup("my_lsp_formatting", {})
local augroup_codelens = vim.api.nvim_create_augroup("_my_lsp_codelens", {})

local excluded_paths = {
  "lib/python%d.%d+/site-packages/",
}

local lsp_capabilities = function()
  return require("blink.cmp").get_lsp_capabilities({
    workspace = {
      didChangeConfiguration = {
        dynamicRegistration = false,
      },
    },
  }, true)
end

vim.diagnostic.config({
  virtual_text = false,
  jump = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
    float = true,
  },
  signs = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  underline = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup_lspattach,
  pattern = "*",
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf

    if client.name == "ruff" then
      -- favor pyright over ruff
      client.server_capabilities.hoverProvider = false
    end

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
        callback = function()
          vim.lsp.codelens.refresh({ bufnr = bufnr })
        end,
        group = augroup_codelens,
      })
    end

    require("mappings").setup_lsp(args)
  end,
})

local _util_open_floating_preview = vim.lsp.util.open_floating_preview
local function _my_open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return _util_open_floating_preview(contents, syntax, opts, ...)
end
vim.lsp.util.open_floating_preview = _my_open_floating_preview

local handlers = {
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
}

-- https://github.com/microsoft/pyright
local python_lsp = os.getenv("PYTHON_LSP") or "pyright"
local python_diagnostic_overrides =
  vim.json.decode(os.getenv("PYRIGHT_DIAGNOSTIC_OVERRIDES") or "{}")
nvim_lsp[python_lsp].setup({
  capabilities = lsp_capabilities(),
  autostart = os.getenv("DISABLE_PYRIGHT") ~= "1",
  handlers = handlers,
  before_init = function(initialize_params, config)
    local python_path = utils.find_python()
    config.settings.python.pythonPath = python_path
    utils.ensure_tables(initialize_params.initializationOptions, "settings", "python")
    initialize_params.initializationOptions.settings.python.pythonPath = python_path
  end,
  settings = {
    [python_lsp == "basedpyright" and "basedpyright" or "python"] = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = os.getenv("PYRIGHT_DIAGNOSTIC_MODE") or "workspace",
        typeCheckingMode = os.getenv("PYRIGHT_TYPE_CHECKING_MODE") or "standard",
        useLibraryCodeForTypes = true,
        disableOrganizeImports = true,
        diagnosticSeverityOverrides = python_diagnostic_overrides,
      },
    },
  },
})

-- https://github.com/astral-sh/ruff
nvim_lsp.ruff.setup({
  capabilities = lsp_capabilities(),
  autostart = os.getenv("DISABLE_RUFF") ~= "1",
  handlers = handlers,
  settings = {
    prioritizeFileConfiguration = true,
    fixAll = true,
    organizeImports = true,
  },
})

-- https://ast-grep.github.io/
nvim_lsp.ast_grep.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
})

-- https://github.com/Freed-Wu/autotools-language-server
nvim_lsp.autotools_ls.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
})

-- https://github.com/withastro/language-tools/tree/main/packages/language-server
nvim_lsp.astro.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
})

-- https://github.com/theia-ide/typescript-language-server
nvim_lsp.ts_ls.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
})

-- https://github.com/biomejs/biome
nvim_lsp.biome.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
})

-- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli
nvim_lsp.graphql.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.eslint.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.cssls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.html.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/hashicorp/terraform-ls
nvim_lsp.terraformls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
})

-- https://github.com/redhat-developer/yaml-language-server
nvim_lsp.yamlls.setup({
  handlers = handlers,
  capabilities = lsp_capabilities(),
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
  init_options = {
    provideFormatter = true,
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
})

-- https://github.com/LuaLS/lua-language-server
nvim_lsp.lua_ls.setup({
  capabilities = lsp_capabilities(),
  handlers = handlers,
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
      return
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = {
          utils.get_root_path(),
          vim.env.VIMRUNTIME,
        },
      },
    })
  end,
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
  should_attach = function(bufnr)
    return os.getenv("DISABLE_NULL_LS") ~= "1"
  end,
  sources = {
    -- gitrebase code_actions,
    code_actions.gitrebase,
    -- github actioins
    diagnostics.actionlint,
    -- javascript/typescript
    formatting.prettier.with({
      prefer_local = "node_modules/.bin",
      condition = function(utils)
        return not utils.root_has_file({ "biome.json", "biome.jsonc" })
          and os.getenv("DISABLE_PRETTIER") ~= "1"
      end,
    }),
    -- sh/bash
    formatting.shfmt.with({
      extra_args = function(params)
        ---@diagnostic disable-next-line: undefined-field
        return { "-i", tostring(vim.opt_local.shiftwidth:get()) }
      end,
      condition = function(utils)
        return os.getenv("DISABLE_SHFMT") ~= "1"
      end,
    }),
    -- python
    require("none-ls.diagnostics.flake8").with({
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
        return os.getenv("DISABLE_RUFF") == "1"
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
        return os.getenv("DISABLE_RUFF") == "1"
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
        return os.getenv("DISABLE_RUFF") == "1"
      end,
    }),
    -- lua
    formatting.stylua.with({
      condition = function(utils)
        return utils.root_has_file({ "stylua.toml", ".stylua.toml" })
      end,
    }),
    -- yaml
    formatting.yamlfix.with({
      env = function(params)
        return {
          YAMLFIX_LINE_LENGTH = tostring(vim.opt_local.textwidth:get() + 1),
          YAMLFIX_SECTION_WHITELINES = "1",
          YAMLFIX_quote_representation = '"',
          YAMLFIX_SEQUENCE_STYLE = "block_style",
        }
      end,
      condition = function(utils)
        return os.getenv("DISABLE_YAMLFIX") ~= "1"
      end,
    }),
    -- markdown
    diagnostics.markdownlint.with({
      diagnostics_format = diagnostics_format,
    }),
  },
})
