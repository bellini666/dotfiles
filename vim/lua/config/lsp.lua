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

local flags = {
    debounce_text_changes = 150,
}

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
    flags = flags,
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
    flags = flags,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.eslint.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
})

-- https://github.com/iamcco/vim-language-server
nvim_lsp.vimls.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.cssls.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
})

-- https://github.com/hrsh7th/vscode-langservers-extracted
nvim_lsp.html.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
})

-- https://github.com/bash-lsp/bash-language-server
nvim_lsp.bashls.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
})

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
nvim_lsp.dockerls.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
})

-- https://github.com/redhat-developer/yaml-language-server
nvim_lsp.yamlls.setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
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
    flags = flags,
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
    flags = flags,
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

-- https://github.com/jose-elias-alvarez/null-ls.nvim
local diagnostics_format = "[#{c}] #{m} (#{s})"
local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics
null_ls.config({
    sources = {
        d.flake8.with({
            name = "flake8",
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
        }),
        f.isort.with({
            name = "isort",
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
            extra_args = { "--profile", "black" },
        }),
        f.black.with({
            name = "black",
            diagnostics_format = diagnostics_format,
            prefer_local = ".venv/bin",
            extra_args = { "--fast" },
        }),
        f.prettier.with({
            name = "prettier",
            diagnostics_format = diagnostics_format,
            prefer_local = "node_modules/.bin",
        }),
        f.stylua.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "--indent-type", "Spaces" },
        }),
        d.shellcheck.with({
            diagnostics_format = diagnostics_format,
        }),
        f.shfmt.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "-i", "2" },
        }),
        f.fixjson.with({
            diagnostics_format = diagnostics_format,
        }),
        d.yamllint.with({
            diagnostics_format = diagnostics_format,
            extra_args = { "-d", "{extends: default, rules: {line-length: {max: 100}}}" },
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
    flags = flags,
})
