local M = {}

local utils = require("utils")
local wk = require("which-key")

wk.add({
  {
    "<C-c>",
    '"+y',
    desc = "Copy to clipboard",
    mode = { "v", "x", "n" },
  },
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
      Snacks.picker.buffers()
    end,
    desc = "Find buffers",
  },
  { "<C-d>", utils.run_tests, desc = "Run tests" },
  { "<C-p>", utils.find_files, desc = "Find files" },
  {
    "<C-s>",
    function()
      require("dropbar.api").pick()
    end,
    desc = "Dropbar pick",
  },
  {
    "<C-q>",
    function()
      Snacks.picker.resume()
    end,
    desc = "Toggle snacks",
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
    "<F2>",
    function()
      Snacks.picker.undo()
    end,
    desc = "Toggle Undotree",
  },
  { "<F4>", "<cmd>Neotree reveal toggle<cr>", desc = "Toggle Neotree" },
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
  { "<leader>e", vim.diagnostic.open_float, desc = "Open diagnostic float" },
  {
    group = "toggle",
    { "<leader>td", utils.toggle_diagnostics, desc = "Toggle diagnostics" },
    { "<leader>tf", utils.toggle_format, desc = "Toggle format" },
    { "<leader>ti", utils.toggle_inlay_hints, desc = "Toggle inlay hints" },
    { "<leader>tl", "<cmd>set list!<cr>:set list?<CR>", desc = "Toggle list" },
    { "<leader>tn", "<cmd>set number!<cr>:set number?<CR>", desc = "Toggle number" },
    { "<leader>tp", "<cmd>set paste!<cr>:set paste?<CR>", desc = "Toggle paste" },
    { "<leader>ts", "<cmd>set spell!<cr>:set spell?<CR>", desc = "Toggle spell" },
    { "<leader>tw", "<cmd>set wrap!<cr>:set wrap?<CR>", desc = "Toggle wrap" },
  },
  {
    "<leader>vb",
    function()
      Snacks.git.blame_line()
    end,
    desc = "Blame current line",
  },
  {
    "<leader>pf",
    function()
      vim.fn.setreg("+", vim.fn.expand("%:t"))
      vim.notify("File name copied to clipboard", "info")
    end,
    desc = "Copy file name to system clipboard",
  },
  {
    "<leader>pp",
    function()
      vim.fn.setreg("+", vim.fn.expand("%:p"))
      vim.notify("File path copied to clipboard", "info")
    end,
    desc = "Copy file path to system clipboard",
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
      ---@diagnostic disable-next-line: missing-fields, missing-fields, missing-fields
      require("trouble").toggle({
        mode = "diagnostics",
        focus = false,
        filter = {
          ["not"] = { severity = vim.diagnostic.severity.HINT },
        },
      })
    end,
    desc = "Document diagnostics",
  },
  {
    "gE",
    function()
      ---@diagnostic disable-next-line: missing-fields
      require("trouble").toggle({
        mode = "diagnostics",
        focus = false,
        filter = {
          ["not"] = { severity = vim.diagnostic.severity.HINT },
        },
      })
    end,
    desc = "Workspace diagnostics",
  },
  {
    "z=",
    function()
      Snacks.picker.spelling()
    end,
    desc = "Spell suggest",
  },
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
    mode = { "n", "v" },
    { "<C-.>", "<cmd>CodeCompanion<cr>", desc = "Code companion prompt" },
    { "<F9>", "<cmd>CodeCompanionActions<cr>", desc = "Code companion actions" },
    { "<C-F9>", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Code companion chat" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", desc = "Code companion add" },
    {
      "<leader>rr",
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      desc = "Find & Replace",
    },
  },
  {
    mode = { "i" },
    {
      "<C-f>",
      function()
        require("blink.cmp").show({ sources = { "ripgrep" } })
      end,
      desc = "Complete with ripgrep",
    },
  },
  {
    mode = { "n" },
    { "<C-/>", "gcc", desc = "Toggle comment", remap = true },
    {
      "<C-f>",
      function()
        Snacks.picker.grep({ hidden = true, follow = true })
      end,
      desc = "Live grep",
    },
  },
  {
    mode = { "v", "x" },
    {
      "<C-f>",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Grep word",
    },
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

  local jump = { tagstack = true, reuse_win = false }

  -- lsp mappings
  wk.add({
    {
      mode = { "n", "v" },
      {
        "<leader>ca",
        vim.lsp.buf.code_action,
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
      group = "LSP Navigation",
      {
        "<C-LeftMouse>",
        function()
          Snacks.picker.lsp_definitions({ auto_confirm = true, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP hover",
      },
      {
        "gd",
        function()
          Snacks.picker.lsp_definitions({ auto_confirm = true, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP go to definition",
      },
      {
        "gD",
        function()
          Snacks.picker.lsp_declarations({ auto_confirm = true, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP go to declarations",
      },
      {
        "grr",
        function()
          Snacks.picker.lsp_references({ auto_confirm = false, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP references",
      },
      {
        "<leader>D",
        function()
          Snacks.picker.lsp_type_definitions({ auto_confirm = true, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP type definition",
      },
      {
        "gs",
        function()
          Snacks.picker.lsp_symbols({ auto_confirm = false, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP document symbols",
      },
      {
        "gI",
        function()
          Snacks.picker.lsp_implementations({ auto_confirm = false, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP go to implementation",
      },
      {
        "gS",
        function()
          Snacks.picker.lsp_workspace_symbols({ auto_confirm = false, jump = jump })
        end,
        buffer = ev.buf,
        desc = "LSP workspace symbols",
      },
    },
  })
end

return M
