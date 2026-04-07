local utils = require("utils")

---@type vim.lsp.Config
return {
  before_init = function(initialize_params, config)
    local python_path = utils.find_python()
    config.settings.python.pythonPath = python_path
    utils.ensure_tables(initialize_params, "initializationOptions", "settings", "basedpyright")
    initialize_params.initializationOptions.settings.python.pythonPath = python_path
  end,
  settings = {
    basedpyright = {
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
  handlers = {
    [vim.lsp.protocol.Methods.textDocument_rename] = function(err, result, ctx)
      if err then
        vim.notify("Pyright rename failed: " .. err.message, vim.log.levels.ERROR)
        return
      end

      ---@cast result lsp.WorkspaceEdit
      for _, change in ipairs(result.documentChanges or {}) do
        for _, edit in ipairs(change.edits or {}) do
          if edit.annotationId then
            edit.annotationId = nil
          end
        end
      end

      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
    end,
  },
}
