local nvim_lsp = require("lspconfig")
local utils = require("utils")

local augroup_lspattach = vim.api.nvim_create_augroup("_my_lsp_attach", { clear = true })
local augroup_formatting = vim.api.nvim_create_augroup("my_lsp_formatting", {})
local augroup_codelens = vim.api.nvim_create_augroup("_my_lsp_codelens", {})

local excluded_paths = {
  "lib/python%d.%d+/site-packages/",
}

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

local lsp_capabilities = function()
  return require("blink.cmp").get_lsp_capabilities({}, true)
end

local function enable(name, config)
  vim.lsp.config(
    name,
    vim.tbl_deep_extend("force", {
      capabilities = lsp_capabilities(),
      autostart = os.getenv("DISABLE_" .. name:upper()) ~= "1",
      handlers = handlers,
    }, config or {})
  )
  vim.lsp.enable(name)
end

-- write a foor loop with all plugins that only have enable in it and enable in the loop
local plugins = {
  -- https://github.com/Freed-Wu/autotools-language-server
  "autotools_ls",
  -- https://github.com/withastro/language-tools/tree/main/packages/language-server
  "astro",
  -- https://github.com/theia-ide/typescript-language-server
  "ts_ls",
  -- https://github.com/biomejs/biome
  "biome",
  -- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli
  "graphql",
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  "eslint",
  -- https://github.com/iamcco/vim-language-server
  "vimls",
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  "cssls",
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  "html",
  -- https://github.com/bash-lsp/bash-language-server
  "bashls",
  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  "dockerls",
  -- https://github.com/hashicorp/terraform-ls
  "terraformls",
  -- https://github.com/lttb/gh-actions-language-server
  "gh_actions_ls",
  -- https://taplo.tamasfe.dev/cli/usage/language-server.html
  "taplo",
  -- https://github.com/antonk52/lua-3p-language-servers
  "stylua3p_ls",
  -- https://github.com/artempyanykh/marksman
  "marksman",
}
for _, plugin in ipairs(plugins) do
  enable(plugin)
end

-- https://github.com/microsoft/pyright
local python_lsp = os.getenv("PYTHON_LSP") or "pyright"
local python_config_key = python_lsp == "basedpyright" and "basedpyright" or "python"
enable(python_lsp, {
  before_init = function(initialize_params, config)
    local python_path = utils.find_python()
    config.settings.python.pythonPath = python_path
    utils.ensure_tables(initialize_params, "initializationOptions", "settings", python_config_key)
    initialize_params.initializationOptions.settings.python.pythonPath = python_path
  end,
  settings = {
    [python_config_key] = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = os.getenv("PYRIGHT_DIAGNOSTIC_MODE") or "workspace",
        typeCheckingMode = os.getenv("PYRIGHT_TYPE_CHECKING_MODE") or "standard",
        useLibraryCodeForTypes = true,
        disableOrganizeImports = true,
        diagnosticSeverityOverrides = vim.json.decode(
          os.getenv("PYRIGHT_DIAGNOSTIC_OVERRIDES") or "{}"
        ),
      },
    },
  },
})

-- https://github.com/astral-sh/ruff
enable("ruff", {
  settings = {
    prioritizeFileConfiguration = true,
    fixAll = true,
    organizeImports = true,
  },
})

-- https://github.com/redhat-developer/yaml-language-server
enable("yamlls", {
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
enable("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

-- https://github.com/LuaLS/lua-language-server
enable("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
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
