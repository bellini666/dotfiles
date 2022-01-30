local mods = {
  "options",
  "mappings",
  "autocmds",
  "plugins",
}

for _, module in ipairs(mods) do
  local ok, err = pcall(require, module)
  if not ok then
    error("Error loading " .. module .. "\n\n" .. err)
  end
end

require("options").setup()
