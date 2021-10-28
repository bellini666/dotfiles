local nvim_lsp = require("lspconfig")
local lsp_util = require("lspconfig/util")
local null_ls = require("null-ls")
local utils = require("utils")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local find_cmd = function(cmd, prefixes, start_from, stop_at)
    if type(prefixes) == "string" then
        prefixes = { prefixes }
    end

    local found
    for _, prefix in ipairs(prefixes) do
        local full_cmd = prefix and lsp_util.path.join(prefix, cmd) or cmd
        local possibility

        -- if start_from is a dir, test it first since transverse will start from its parent
        if start_from and lsp_util.path.is_dir(start_from) then
            possibility = lsp_util.path.join(start_from, full_cmd)
            if vim.fn.executable(possibility) > 0 then
                found = possibility
                break
            end
        end

        lsp_util.path.traverse_parents(start_from, function(dir)
            possibility = lsp_util.path.join(dir, full_cmd)
            if vim.fn.executable(possibility) > 0 then
                found = possibility
                return true
            end
            -- use cwd as a stopping point to avoid scanning the entire file system
            if stop_at and dir == stop_at then
                return true
            end
        end)

        if found ~= nil then
            break
        end
    end

    return found or cmd
end

local find_cmd_func = function(cmd, prefixes)
    return function(params)
        local client = require("null-ls.utils").get_client()
        local cwd = client and client.root_dir or vim.fn.getcwd()
        return find_cmd(cmd, prefixes, params.bufname, cwd) or cmd
    end
end

local on_attach = function(client, bufnr)
    vim.cmd([[augroup __formating]])
    vim.cmd([[autocmd! * <buffer>]])
    vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()]])
    vim.cmd([[ autocmd CursorHold * lua require("utils").diagnostics() ]])
    vim.cmd([[augroup END]])

    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local opts = { noremap = true, silent = true }
    utils.bmap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    utils.bmap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    utils.bmap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    utils.bmap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    utils.bmap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    utils.bmap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    utils.bmap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    utils.bmap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
    utils.bmap(bufnr, "n", "<leader>so", [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
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
            p = find_cmd("python3", ".venv/bin", config.root_dir)
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
