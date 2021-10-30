local nvim_lsp = require("lspconfig")
local lsp_util = require("lspconfig/util")
local null_ls = require("null-ls")
local utils = require("utils")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local find_cmd_func = function(cmd, prefixes)
    return function(params)
        local client = require("null-ls.utils").get_client()
        local cwd = client and client.root_dir or vim.fn.getcwd()
        return utils.find_cmd(cmd, prefixes, params.bufname, cwd) or cmd
    end
end

local on_attach = function(client, bufnr)
    require("autocmds").setup_lsp(client, bufnr)
    require("mappings").setup_lsp(client, bufnr)
end

local handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = {
            severity_limit = "Information",
        },
        signs = {
            severity_limit = "Information",
        },
        virtual_text = {
            spacing = 4,
            severity_limit = "Information",
        },
    }),
}

-- https://github.com/microsoft/pyright
nvim_lsp.pyright.setup({
    capabilities = capabilities,
    handlers = handlers,
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        on_attach(client)
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
})

-- https://github.com/theia-ide/typescript-language-server
nvim_lsp.tsserver.setup({
    capabilities = capabilities,
    handlers = handlers,
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        on_attach(client)
    end,
})

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup({ handlers = handlers, capabilities = capabilities, on_attach = on_attach })

-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
nvim_lsp.cssls.setup({ handlers = handlers, capabilities = capabilities, on_attach = on_attach })

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
nvim_lsp.html.setup({ handlers = handlers, capabilities = capabilities, on_attach = on_attach })

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup({ handlers = handlers, capabilities = capabilities, on_attach = on_attach })

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup({ handlers = handlers, capabilities = capabilities, on_attach = on_attach })

-- https://github.com/vscode-langservers/vscode-json-languageserver
nvim_lsp.jsonls.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { "json-languageserver", "--stdio" },
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
            },
        },
    },
})

-- Linting/Formatting
local diagnostics_format = "[#{c}] #{m} (#{s})"
local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics
null_ls.config({
    sources = {
        d.flake8.with({
            name = "flake8",
            diagnostics_format = diagnostics_format,
            command = find_cmd_func("flake8", ".venv/bin"),
            cwd = function(params)
                return nvim_lsp["pyright"].get_root_dir(params.bufname) or params.cwd
            end,
        }),
        f.black.with({
            name = "black",
            diagnostics_format = diagnostics_format,
            command = find_cmd_func("black", ".venv/bin"),
            cwd = function(params)
                return nvim_lsp["pyright"].get_root_dir(params.bufname) or params.cwd
            end,
        }),
        f.isort.with({
            name = "isort",
            diagnostics_format = diagnostics_format,
            command = find_cmd_func("isort", ".venv/bin"),
            cwd = function(params)
                return nvim_lsp["pyright"].get_root_dir(params.bufname) or params.cwd
            end,
        }),
        f.prettier.with({
            name = "prettier",
            diagnostics_format = diagnostics_format,
            command = find_cmd_func("prettier", "node_modules/.bin"),
            cwd = function(params)
                return nvim_lsp["tsserver"].get_root_dir(params.bufname) or params.cwd
            end,
        }),
        d.eslint.with({
            name = "eslint",
            diagnostics_format = diagnostics_format,
            command = find_cmd_func("eslint", "node_modules/.bin"),
            cwd = function(params)
                return nvim_lsp["tsserver"].get_root_dir(params.bufname) or params.cwd
            end,
        }),
        f.stylua.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "--indent-type", "Spaces" },
        }),
        f.shfmt.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "-i", "2" },
        }),
        d.shellcheck.with({
            diagnostics_format = diagnostics_format,
        }),
        f.fixjson.with({
            diagnostics_format = diagnostics_format,
        }),
        d.yamllint.with({
            diagnostics_format = diagnostics_format,
        }),
        f.sqlformat.with({
            diagnostics_format = diagnostics_format,
        }),
    },
})
nvim_lsp["null-ls"].setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
})
