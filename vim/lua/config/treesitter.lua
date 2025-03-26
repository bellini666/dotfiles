require("nvim-treesitter.configs").setup({
  ignore_install = {},
  modules = {},
  auto_install = false,
  sync_install = false,
  ensure_installed = "all",
  highlight = {
    enable = true,
    disable = { "csv" },
    use_languagetree = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-Space>",
      node_incremental = "<C-Space>",
      scope_incremental = false,
      node_decremental = "<BS>",
    },
  },
  matchup = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
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
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]]"] = "@class.outer",
        ["]f"] = "@function.outer",
        ["]a"] = "@parameter.outer",
        ["]b"] = "@block.outer",
        ["]l"] = "@loop.outer",
        ["]/"] = "@comment.outer",
        ["]="] = "@assignment.outer",
      },
      goto_next_end = {
        ["]["] = "@class.outer",
        ["]F"] = "@function.outer",
        ["]A"] = "@parameter.outer",
        ["]B"] = "@block.outer",
        ["]L"] = "@loop.outer",
      },
      goto_previous_start = {
        ["[["] = "@class.outer",
        ["[f"] = "@function.outer",
        ["[a"] = "@parameter.outer",
        ["[b"] = "@block.outer",
        ["[l"] = "@loop.outer",
        ["[/"] = "@comment.outer",
        ["[="] = "@assignment.outer",
      },
      goto_previous_end = {
        ["[]"] = "@class.outer",
        ["[F"] = "@function.outer",
        ["[A"] = "@parameter.outer",
        ["[B"] = "@block.outer",
        ["[L"] = "@loop.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    lsp_interop = {
      enable = true,
      border = "single",
      peek_definition_code = {
        ["<leader>dp"] = "@function.outer",
        ["<leader>dP"] = "@class.outer",
      },
    },
  },
})

require("colorizer").setup({
  filetypes = {
    "*",
    "!python",
    toml = { names = false },
    yaml = { names = false },
    json = { names = false },
    checkhealth = { names = false },
  },
})
