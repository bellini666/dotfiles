local utils = require("utils")

---@type vim.lsp.Config
return {
  before_init = function(initialize_params, config)
    local python_path = utils.find_python()
    utils.ensure_tables(config, "settings", "ty")
    config.settings.ty.interpreter = python_path
    utils.ensure_tables(initialize_params, "initializationOptions", "settings", "ty")
    initialize_params.initializationOptions.settings.ty.interpreter = python_path
  end,
  settings = {
    ty = {
      importStrategy = "fromEnvironment",
      diagnosticMode = "workspace",
      experimental = {
        rename = true,
        autoImport = true,
      },
    },
  },
}
