local nvim_lsp = require("lspconfig")
local lsp_util = require("lspconfig/util")
local null_ls = require("null-ls")
local utils = require("utils")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local flags = {
    debounce_text_changes = 0,
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local on_attach = function(client, bufnr)
    require("autocmds").setup_lsp(client, bufnr)
    require("mappings").setup_lsp(client, bufnr)
end

local _util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "single"
    return _util_open_floating_preview(contents, syntax, opts, ...)
end

local handlers = {
    ["textDocument/publishDiagnostics"] = function(_, result, ...)
        local min = vim.diagnostic.severity.INFO
        result.diagnostics = vim.tbl_filter(function(t)
            return t.severity <= min
        end, result.diagnostics)
        return vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ...)
    end,
    ["textDocument/rename"] = function(_, result, ...)
        local title = nil
        local msg = {}

        if result and result.changes then
            local fname
            local old = vim.fn.expand("<cword>")
            local new = "<unknown>"
            local root = vim.loop.cwd()
            for f, c in pairs(result.changes) do
                new = c[1].newText
                fname = "." .. f:gsub("file://" .. root, "")
                table.insert(msg, ("%d changes -> %s"):format(#c, fname))
            end
            title = ("Rename: %s -> %s"):format(old, new)
        end

        local ret = vim.lsp.handlers["textDocument/rename"](_, result, ...)

        if not vim.tbl_isempty(msg) then
            vim.notify(msg, vim.log.levels.INFO, { title = title })
            -- Save the modified files after the rename
            vim.cmd([[wall]])
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
    flags = flags,
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
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
    flags = flags,
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        on_attach(client, bufnr)
    end,
})

-- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli
nvim_lsp.graphql.setup({
    capabilities = capabilities,
    handlers = handlers,
    flags = flags,
    on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.eslint.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
})

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.cssls.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.html.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
})

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
})

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
})

-- https://github.com/redhat-developer/yaml-language-server
nvim_lsp.yamlls.setup({
    handlers = handlers,
    flags = flags,
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
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = {
        provideFormatter = false,
    },
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
        },
    },
})

-- https://github.com/sumneko/lua-language-server
local sumneko_root_path = lsp_util.path.join(vim.env.HOME, ".local_build", "lua-language-server")
local sumneko_binary = lsp_util.path.join(sumneko_root_path, "bin", "Linux", "lua-language-server")
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
nvim_lsp.sumneko_lua.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    handlers = handlers,
    flags = flags,
    cmd = { sumneko_binary, "-E", lsp_util.path.join(sumneko_root_path, "/main.lua") },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = runtime_path,
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
local diagnostics_format = "[#{c}] #{m} (#{s})"
local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics
null_ls.setup({
    handlers = handlers,
    flags = flags,
    capabilities = capabilities,
    on_attach = on_attach,
    sources = {
        -- shellcheck code_actions,
        null_ls.builtins.code_actions.shellcheck,
        -- codepell
        d.codespell.with({
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
        }),
        -- python
        d.flake8.with({
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
            -- Ignore some errors that are always fixed by black
            extra_args = { "--extend-ignore", "E1,E2,E3,F821,E731,R504,SIM106" },
        }),
        f.isort.with({
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
            extra_args = { "--profile", "black" },
        }),
        f.black.with({
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
            extra_args = { "--fast", "-W", "6" },
        }),
        -- javascript/typescript
        f.prettier.with({
            diagnostics_format = diagnostics_format,
            prefer_local = "node_modules/.bin",
        }),
        -- sh/bash
        d.shellcheck.with({
            diagnostics_format = diagnostics_format,
        }),
        f.shfmt.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "-i", "2" },
        }),
        -- lua
        f.stylua.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "--indent-type", "Spaces", "--column-width", "100" },
        }),
        -- json
        f.fixjson.with({
            diagnostics_format = diagnostics_format,
        }),
        -- yaml
        d.yamllint.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "-d", "{extends: default, rules: {line-length: {max: 100}}}" },
        }),
        -- sql
        f.sqlformat.with({
            diagnostics_format = diagnostics_format,
        }),
        -- toml
        f.taplo.with({
            diagnostics_format = diagnostics_format,
        }),
        -- css/scss/sass/less
        f.stylelint.with({
            diagnostics_format = diagnostics_format,
        }),
    },
})
