local utils = require("utils")

---@type vim.lsp.Config
return {
  before_init = function(initialize_params, config)
    local python_path = utils.find_python()
    utils.ensure_tables(config, "settings", "python", "pyrefly")
    config.settings.python.pyrefly = python_path
    utils.ensure_tables(initialize_params, "initializationOptions", "settings", "python", "pyrefly")
    initialize_params.initializationOptions.settings.python.pyrefly = python_path
  end,
  handlers = {
    ["workspace/configuration"] = function(_, result, _)
      local response = {}
      for _, item in ipairs(result.items) do
        if item.section == "python" then
          table.insert(response, {
            analysis = {
              showHoverGoToLinks = false,
            },
          })
        else
          table.insert(response, vim.NIL)
        end
      end
      return response
    end,
  },
}
