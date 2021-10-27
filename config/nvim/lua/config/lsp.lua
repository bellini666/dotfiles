local nvim_lsp = require("lspconfig")
local path = require("lspconfig/util").path
local null_ls = require("null-ls")
local utils = require("utils")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

ROOT_DIRS = {
    python = nil,
    node = nil,
}

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
    -- ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    --     virtual_text = false,
    -- }),
}

local function get_python_path(workspace)
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        if vim.env.VIRTUAL_ENV then
            return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
        end
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
    end

    -- Find and use virtualenv in workspace directory.
    for _, pattern in ipairs({ "./", "*/." }) do
        local match = vim.fn.glob(path.join(workspace, pattern, "poetry.lock"))
        if match ~= "" then
            local dir = path.dirname(match)
            local venv = vim.fn.trim(vim.fn.system("cd " .. dir .. " && poetry env info -p"))
            return path.join(venv, "bin", "python")
        end
        local vmatch = vim.fn.glob(path.join(workspace, pattern, ".venv"))
        if vmatch ~= "" then
            return path.join(vmatch, "bin", "python")
        end
    end

    -- Fallback to system Python.
    return "python3"
end

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
        ROOT_DIRS.python = config.root_dir
        config.settings.python.pythonPath = get_python_path(config.root_dir)
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
    before_init = function(_, config)
        ROOT_DIRS.node = config.root_dir
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
})

-- https://github.com/sumneko/lua-language-server
local sumneko_root_path = path.join(vim.env.HOME, ".local_build", "lua-language-server")
local sumneko_binary = path.join(sumneko_root_path, "bin", "Linux", "lua-language-server")
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
nvim_lsp.sumneko_lua.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    handlers = handlers,
    cmd = { sumneko_binary, "-E", path.join(sumneko_root_path, "/main.lua") },
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
local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics
null_ls.config({
    sources = {
        d.flake8.with({
            command = function()
                if ROOT_DIRS.python ~= nil then
                    local match = vim.fn.glob(path.join(ROOT_DIRS.python, ".venv", "bin", "flake8"))
                    if match ~= "" then
                        return match
                    end
                end
                return "flake8"
            end,
            cwd = function(params)
                return ROOT_DIRS.python or params.cwd
            end,
        }),
        f.black.with({
            command = function()
                if ROOT_DIRS.python ~= nil then
                    local match = vim.fn.glob(path.join(ROOT_DIRS.python, ".venv", "bin", "black"))
                    if match ~= "" then
                        return match
                    end
                end
                return "black"
            end,
            cwd = function(params)
                return ROOT_DIRS.python or params.cwd
            end,
        }),
        f.isort.with({
            command = function()
                if ROOT_DIRS.python ~= nil then
                    local match = vim.fn.glob(path.join(ROOT_DIRS.python, ".venv", "bin", "isort"))
                    if match ~= "" then
                        return match
                    end
                end
                return "isort"
            end,
            cwd = function(params)
                return ROOT_DIRS.python or params.cwd
            end,
        }),
        f.prettier.with({
            cwd = function(params)
                return ROOT_DIRS.node or params.cwd
            end,
        }),
        d.eslint.with({
            cwd = function(params)
                return ROOT_DIRS.node or params.cwd
            end,
        }),
        f.stylua.with({
            extra_args = { "--indent-type", "Spaces" },
        }),
        f.shfmt.with({
            extra_args = { "-i", "2" },
        }),
        d.shellcheck.with({
            diagnostics_format = "[#{c}] #{m} (#{s})",
        }),
        f.fixjson,
        d.yamllint,
        f.sqlformat,
    },
})
nvim_lsp["null-ls"].setup({
    handlers = handlers,
    capabilities = capabilities,
    on_attach = on_attach,
})
