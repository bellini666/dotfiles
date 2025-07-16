require("nvim-treesitter").install({ "stable" })
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v", -- charwise
      ["@function.outer"] = "V", -- linewise
      ["@class.outer"] = "<c-v>", -- blockwise
    },
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
})

-- SELECT MAPPINGS
local select_mappings = {
  -- format: keymap = textobject
  ["af"] = "@function.outer",
  ["if"] = "@function.inner",
  ["ac"] = "@class.outer",
  ["ic"] = "@class.inner",
  ["aa"] = "@parameter.outer",
  ["ia"] = "@parameter.inner",
  ["ab"] = "@block.outer",
  ["ib"] = "@block.inner",
  ["al"] = "@loop.outer",
  ["il"] = "@loop.inner",
  ["a/"] = "@comment.outer",
  ["i/"] = "@comment.inner",
  ["a="] = "@assignment.outer",
  ["i="] = "@assignment.inner",
}
for mapping, textobject in pairs(select_mappings) do
  vim.keymap.set({ "x", "o" }, mapping, function()
    require("nvim-treesitter-textobjects.select").select_textobject(textobject, "textobjects")
  end)
end

-- MOVE MAPPINGS
local move_mappings = {
  next_start = {
    ["]]"] = "@class.outer",
    ["]f"] = "@function.outer",
    ["]a"] = "@parameter.outer",
    ["]b"] = "@block.outer",
    ["]l"] = "@loop.outer",
    ["]/"] = "@comment.outer",
    ["]="] = "@assignment.outer",
  },
  next_end = {
    ["]["] = "@class.outer",
    ["]F"] = "@function.outer",
    ["]A"] = "@parameter.outer",
    ["]B"] = "@block.outer",
    ["]L"] = "@loop.outer",
  },
  previous_start = {
    ["[["] = "@class.outer",
    ["[f"] = "@function.outer",
    ["[a"] = "@parameter.outer",
    ["[b"] = "@block.outer",
    ["[l"] = "@loop.outer",
    ["[/"] = "@comment.outer",
    ["[="] = "@assignment.outer",
  },
  previous_end = {
    ["[]"] = "@class.outer",
    ["[F"] = "@function.outer",
    ["[A"] = "@parameter.outer",
    ["[B"] = "@block.outer",
    ["[L"] = "@loop.outer",
  },
}
for direction, mappings in pairs(move_mappings) do
  for mapping, textobject in pairs(mappings) do
    vim.keymap.set({ "n", "x", "o" }, mapping, function()
      require("nvim-treesitter-textobjects.move")["goto_" .. direction](textobject, "textobjects")
    end)
  end
end

-- SWAP MAPPINGS
local swap_mappings = {
  -- format: keymap = { direction = "next/previous", textobject }
  ["<leader>a"] = { direction = "next", textobject = "@parameter.inner" },
  ["<leader>A"] = { direction = "previous", textobject = "@parameter.inner" },
}
for mapping, config in pairs(swap_mappings) do
  vim.keymap.set("n", mapping, function()
    require("nvim-treesitter-textobjects.swap")["swap_" .. config.direction](config.textobject)
  end)
end
