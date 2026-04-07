local utils = require("utils")

---@type vim.lsp.Config
return {
  before_init = function(initialize_params, config)
    local python_path = utils.find_python()
    config.settings.python.pythonPath = python_path
    utils.ensure_tables(initialize_params, "initializationOptions", "settings", "python")
    initialize_params.initializationOptions.settings.python.pythonPath = python_path
  end,
  settings = {
    python = {
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
    -- Override the default rename handler to remove the `annotationId` from edits.
    --
    -- Pyright is being non-compliant here by returning `annotationId` in the edits, but not
    -- populating the `changeAnnotations` field in the `WorkspaceEdit`. This causes Neovim to
    -- throw an error when applying the workspace edit.
    --
    -- See:
    -- - https://github.com/neovim/neovim/issues/34731
    -- - https://github.com/microsoft/pyright/issues/10671
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
