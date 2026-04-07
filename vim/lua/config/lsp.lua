local augroup_lspattach = vim.api.nvim_create_augroup("_my_lsp_attach", { clear = true })
local augroup_formatting = vim.api.nvim_create_augroup("my_lsp_formatting", {})
local augroup_codelens = vim.api.nvim_create_augroup("_my_lsp_codelens", {})

local excluded_paths = {
  "lib/python%d.%d+/site-packages/",
}
local lsp_disable_format = {
  basedpyright = true,
  html = true,
  jsonls = os.getenv("DISABLE_JSONLS_FMT") == "1",
  lua_ls = true,
  pyright = true,
  sumneko_lua = true,
  taplo = os.getenv("DISABLE_TAPLO_FMT") == "1",
  tsserver = true,
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

    if lsp_disable_format[client.name] then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
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

-- Shared capabilities for every LSP server (configs live in `lsp/<name>.lua`).
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities({}, true),
})

local servers = {
  "autotools_ls", -- https://github.com/Freed-Wu/autotools-language-server
  "astro", -- https://github.com/withastro/language-tools/tree/main/packages/language-server
  "djls", -- https://github.com/joshuadavidthomas/django-language-server
  "ts_ls", -- https://github.com/theia-ide/typescript-language-server
  "biome", -- https://github.com/biomejs/biome
  "graphql", -- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli
  "eslint", -- https://github.com/hrsh7th/vscode-langservers-extracted
  "vimls", -- https://github.com/iamcco/vim-language-server
  "cssls", -- https://github.com/hrsh7th/vscode-langservers-extracted
  "html", -- https://github.com/hrsh7th/vscode-langservers-extracted
  "bashls", -- https://github.com/bash-lsp/bash-language-server
  "dockerls", -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  "terraformls", -- https://github.com/hashicorp/terraform-ls
  "gh_actions_ls", -- https://github.com/lttb/gh-actions-language-server
  "taplo", -- https://taplo.tamasfe.dev/cli/usage/language-server.html
  "stylua3p_ls", -- https://github.com/antonk52/lua-3p-language-servers
  "marksman", -- https://github.com/artempyanykh/marksman
  "pytest", -- https://github.com/bellini666/pytest-language-server
  "gopls", -- https://github.com/golang/tools
  "tilt_ls", -- https://github.com/tilt-dev/tilt
  "ruff", -- https://github.com/astral-sh/ruff
  "yamlls", -- https://github.com/redhat-developer/yaml-language-server
  "jsonls", -- https://github.com/hrsh7th/vscode-langservers-extracted
  "lua_ls", -- https://github.com/LuaLS/lua-language-server
  os.getenv("PYTHON_LSP") or "pyright", -- pyright|basedpyright|ty|pyrefly|pylsp
}

for _, name in ipairs(servers) do
  if os.getenv("DISABLE_" .. name:upper()) ~= "1" then
    vim.lsp.enable(name)
  end
end
