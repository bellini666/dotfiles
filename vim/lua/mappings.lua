local M = {}

local utils = require("utils")
local wk = require("which-key")

wk.add({
  { "<A-/>", desc = "Toggle comment" },
  { "<A-Left>", "gT", desc = "Previous tab" },
  { "<A-Right>", "gt", desc = "Next tab" },
  {
    "<A-Down>",
    function()
      if vim.api.nvim_get_mode().mode:lower() == "v" then
        require("moveline").block_down()
      else
        require("moveline").down()
      end
    end,
    desc = "Move line down",
    mode = { "i", "n", "v" },
  },
  {
    "<A-Up>",
    function()
      if vim.api.nvim_get_mode().mode:lower() == "v" then
        require("moveline").block_up()
      else
        require("moveline").up()
      end
    end,
    desc = "Move line up",
    mode = { "i", "n", "v" },
  },
  {
    "<C-b>",
    function()
      require("telescope.builtin").buffers()
    end,
    desc = "Find buffers",
  },
  { "<C-d>", utils.run_tests, desc = "Run tests" },
  {
    "<C-f>",
    function()
      require("telescope.builtin").live_grep()
    end,
    desc = "Live grep",
  },
  { "<C-p>", utils.find_files, desc = "Find files" },
  {
    "<C-q>",
    function()
      require("trouble").toggle({ mode = "diagnostics", focus = false })
    end,
    desc = "Toggle trouble",
  },
  { "<C-w>m", "<cmd>WinShift<cr>", desc = "WinShift mode" },
  {
    "<C-w>r",
    function()
      require("smart-splits").start_resize_mode()
    end,
    desc = "Smart resize",
  },
  { "<C-w>t", "<cmd>tab split<cr>", desc = "Duplicate tab" },
  { "<C-w>x", "<cmd>WinShift swap<cr><C-w><C-w>", desc = "Swap splits" },
  {
    "<F1>",
    function()
      require("dap").toggle_breakpoint()
    end,
    desc = "Toggle breakpoint",
  },
  { "<F2>", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
  {
    "<F3>",
    function()
      require("telescope").extensions.vstask.tasks()
    end,
    desc = "Tasks",
  },
  { "<F4>", "<cmd>Neotree reveal toggle<cr>", desc = "Toggle Neotree" },
  {
    "<F5>",
    function()
      require("dap").continue()
    end,
    desc = "DAP continue",
  },
  {
    "<F6>",
    function()
      require("dap").step_over()
    end,
    desc = "DAP step over",
  },
  {
    "<F7>",
    function()
      require("dap").sep_into()
    end,
    desc = "DAP step into",
  },
  {
    "<F8>",
    function()
      require("dap").step_out()
    end,
    desc = "DAP step out",
  },
  {
    "<F9>",
    function()
      require("dapui").toggle()
    end,
    desc = "Toggle DAP UI",
  },
  {
    "<F10>",
    function()
      require("neotest").output_panel.toggle()
    end,
    desc = "Toggle neotest output",
  },
  {
    "<F12>",
    function()
      require("neotest").summary.toggle()
    end,
    desc = "Toggle neotest summary",
  },
  {
    "gK",
    function()
      require("dap.ui.widgets").hover()
    end,
    desc = "DAP hover",
  },
  { "<leader>e", vim.diagnostic.open_float, desc = "Open diagnostic float" },
  {
    group = "toggle",
    { "<leader>td", utils.toggle_diagnostics, desc = "Toggle diagnostics" },
    { "<leader>tf", utils.toggle_format, desc = "Toggle format" },
    { "<leader>tl", "<cmd>set list!<cr>:set list?<CR>", desc = "Toggle list" },
    { "<leader>tn", "<cmd>set number!<cr>:set number?<CR>", desc = "Toggle number" },
    { "<leader>tp", "<cmd>set paste!<cr>:set paste?<CR>", desc = "Toggle paste" },
    { "<leader>ts", "<cmd>set spell!<cr>:set spell?<CR>", desc = "Toggle spell" },
  },
  {
    "<leader>vb",
    function()
      require("gitsigns").blame_line({ full = true })
    end,
    desc = "Blame current line",
  },
  {
    "[Q",
    function()
      ---@diagnostic disable-next-line: missing-parameter, missing-fields
      require("trouble").first({ jump = true })
    end,
    desc = "First trouble result",
  },
  {
    "[b",
    function()
      require("goto-breakpoints").next()
    end,
    desc = "Go to previous breakpoint",
  },
  {
    "[q",
    function()
      ---@diagnostic disable-next-line: missing-parameter, missing-fields
      require("trouble").prev({ jump = true })
    end,
    desc = "Previous trouble result",
  },
  {
    "]Q",
    function()
      ---@diagnostic disable-next-line: missing-parameter, missing-fields
      require("trouble").last({ jump = true })
    end,
    desc = "Last trouble result",
  },
  {
    "]b",
    function()
      require("goto-breakpoints").next()
    end,
    desc = "Go to next breakpoint",
  },
  {
    "]q",
    function()
      ---@diagnostic disable-next-line: missing-parameter, missing-fields
      require("trouble").next({ jump = true })
    end,
    desc = "Next trouble result",
  },
  {
    "ge",
    function()
      require("trouble").toggle({ mode = "diagnostics", focus = false, filter = { buf = 0 } })
    end,
    desc = "Document diagnostics",
  },
  {
    "gE",
    function()
      require("trouble").toggle({ mode = "diagnostics", focus = false })
    end,
    desc = "Workspace diagnostics",
  },
  { "z=", utils.spell_suggest, desc = "Spell suggest" },
  {
    mode = { "n", "o", "x" },
    { "#", "*", desc = "Search highlighted word forward" },
    { "*", "#", desc = "Search highlighted word backward" },
    {
      "S",
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "s",
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
  },
  {
    mode = { "v" },
    { "<", "<gv", desc = "Continuous visual indenting" },
    { ">", ">gv", desc = "Continuous visual indenting" },
    { "p", '"_dP', desc = "Paste", remap = false },
    { "<C-/>", "gc", desc = "Toggle comment", remap = true },
  },
  {
    mode = { "n" },
    { "<C-/>", "gcc", desc = "Toggle comment", remap = true },
  },
  {
    mode = { "i", "n" },
    { "<C-Down>", "15<C-e>", desc = "Down 1 page" },
    { "<C-Up>", "15<C-y>", desc = "Up 1 page" },
    { "<esc>", "<cmd>noh<cr><esc>", desc = "Clear" },
  },
})

M.setup_lsp = function(ev)
  local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

  if client.server_capabilities.completionProvider then
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
  end
  if client.server_capabilities.definitionProvider then
    vim.bo[ev.buf].tagfunc = "v:lua.vim.lsp.tagfunc"
  end

  -- lsp mappings
  wk.add({
    {
      mode = { "n", "v" },
      {
        "<leader>ca",
        function()
          require("tiny-code-action").code_action()
        end,
        buffer = ev.buf,
        desc = "LSP code action",
        group = "LSP Actions",
        noremap = true,
        silent = true,
      },
    },
    {
      mode = { "i", "n" },
      {
        "<C-K>",
        vim.lsp.buf.signature_help,
        buffer = ev.buf,
        desc = "LSP signature help",
        group = "LSP Actions",
      },
    },
    {
      "<leader>rn",
      vim.lsp.buf.rename,
      buffer = ev.buf,
      desc = "LSP rename",
      group = "LSP Actions",
    },
    {
      group = "workspace",
      {
        "<leader>wa",
        vim.lsp.buf.add_workspace_folder,
        buffer = ev.buf,
        desc = "LSP add workspace folder",
      },
      {
        "<leader>wl",
        function()
          vim.print(vim.lsp.buf.list_workspace_folders())
        end,
        buffer = ev.buf,
        desc = "LSP list workspace",
      },
      {
        "<leader>wr",
        vim.lsp.buf.remove_workspace_folder,
        buffer = ev.buf,
        desc = "LSP remove workspace folder",
      },
    },
    { "K", vim.lsp.buf.hover, buffer = ev.buf, desc = "LSP hover", group = "LSP Actions" },
    {
      group = "callhierarchy",
      {
        "gic",
        function()
          require("telescope.builtin").lsp_incoming_calls()
        end,
        buffer = ev.buf,
        desc = "LSP incoming calls",
      },
      {
        "goc",
        function()
          require("telescope.builtin").lsp_outgoing_calls()
        end,
        buffer = ev.buf,
        desc = "LSP outgoing calls",
      },
    },
    {
      group = "LSP Navigation",
      {
        "<C-LeftMouse>",
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        buffer = ev.buf,
        desc = "LSP hover",
      },
      {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        buffer = ev.buf,
        desc = "LSP go to definition",
      },
      { "gD", vim.lsp.buf.declaration, buffer = ev.buf, desc = "LSP go to declaration" },
      {
        "grr",
        function()
          require("telescope.builtin").lsp_references({ jump_type = "never" })
        end,
        buffer = ev.buf,
        desc = "LSP references",
      },
      {
        "<leader>D",
        function()
          require("telescope.builtin").lsp_type_definitions()
        end,
        buffer = ev.buf,
        desc = "LSP type definition",
      },
      {
        "gs",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        buffer = ev.buf,
        desc = "LSP document symbols",
      },
      {
        "gI",
        function()
          require("telescope.builtin").lsp_implementations()
        end,
        buffer = ev.buf,
        desc = "LSP go to implementation",
      },
      {
        "gS",
        function()
          require("telescope.builtin").lsp_workspace_symbols()
        end,
        buffer = ev.buf,
        desc = "LSP workspace symbols",
      },
    },
  })
end

return M
