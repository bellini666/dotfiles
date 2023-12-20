local utils = require("utils")
local wk = require("which-key")

wk.register({
  ["<esc>"] = { "<cmd>noh<cr><esc>", "Clear", mode = { "i", "n" } },
  ["<C-C>"] = { '"+y', "Copy to global register", mode = "v" },
  ["<C-S-V>"] = { '"+y', "Paste from global register", mode = { "i", "v", "c", "n" } },
  ["<"] = { "<gv", "Continuous visual indenting", mode = "v" },
  [">"] = { ">gv", "Continuous visual indenting", mode = "v" },
  ["<A-Left>"] = { "gT", "Previous tab" },
  ["<A-Right>"] = { "gt", "Next tab" },
  ["z="] = { utils.spell_suggest, "Spell suggest" },
  ["#"] = { "*", "Search highlighted word forward", mode = { "n", "x", "o" } },
  ["*"] = { "#", "Search highlighted word backward", mode = { "n", "x", "o" } },
  p = { '"_dP', "Paste", noremap = true, silent = true, mode = "v" },
  ["<leader>"] = {
    e = { vim.diagnostic.open_float, "Open diagnostic float", silent = true },
    t = {
      name = "toggle",
      f = { utils.toggle_format, "Toggle format" },
      l = { "<cmd>set list!<cr>:set list?<CR>", "Toggle list" },
      n = { "<cmd>set number!<cr>:set number?<CR>", "Toggle number" },
      p = { "<cmd>set paste!<cr>:set paste?<CR>", "Toggle paste" },
      s = { "<cmd>set spell!<cr>:set spell?<CR>", "Toggle spell" },
      d = { utils.toggle_diagnostics, "Toggle diagnostics" },
    },
  },
  ["<C-e>"] = {
    function()
      require("dropbar.api").pick()
    end,
    "Dropbar",
  },
  ["<C-p>"] = { utils.find_files, "Find files" },
  ["<C-f>"] = {
    function()
      require("telescope.builtin").live_grep()
    end,
    "Live grep",
  },
  ["<C-b>"] = {
    function()
      require("telescope.builtin").buffers()
    end,
    "Find buffers",
  },
  ["<C-g>"] = { utils.grep, "Custom grep" },
  ["<C-d>"] = {
    function()
      require("config.dap").run()
    end,
    "Run tests",
  },
  ["<F1>"] = {
    function()
      require("dap").toggle_breakpoint()
    end,
    "Toggle breakpoint",
  },
  ["<F2>"] = { "<cmd>UndotreeToggle<cr>", "Toggle Undotree" },
  ["<F3>"] = {
    function()
      require("telescope").extensions.vstask.tasks()
    end,
    "Tasks",
  },
  ["<F4>"] = { "<cmd>Neotree reveal toggle<cr>", "Toggle Neotree" },
  ["<F5>"] = {
    function()
      require("dap").continue()
    end,
    "DAP continue",
  },
  ["<F6>"] = {
    function()
      require("dap").step_over()
    end,
    "DAP step over",
  },
  ["<F7>"] = {
    function()
      require("dap").sep_into()
    end,
    "DAP step into",
  },
  ["<F8>"] = {
    function()
      require("dap").step_out()
    end,
    "DAP step out",
  },
  ["<F9>"] = {
    function()
      require("dapui").toggle()
    end,
    "Toggle DAP UI",
  },
  ["<F10>"] = {
    function()
      require("neotest").output_panel.toggle()
    end,
    "Toggle DAP output",
  },
  ["<F12>"] = {
    function()
      require("neotest").summary.toggle()
    end,
    "Toggle DAP summary",
  },
  g = {
    K = {
      function()
        require("dap.ui.widgets").hover()
      end,
      "DAP hover",
      mode = { "n", "v" },
    },
    e = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document diagnostics" },
    E = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace diagnostics" },
  },
  ["<C-q>"] = { "<cmd>TroubleToggle<cr>", "Toggle trouble" },
  ["["] = {
    d = {
      vim.diagnostic.goto_prev,
      "Go to previous diagnostic",
      silent = true,
    },
    q = {
      function()
        require("trouble").previous({ skip_groups = true, jump = true })
      end,
      "Previous trouble result",
    },
    Q = {
      function()
        require("trouble").first({ skip_groups = true, jump = true })
      end,
      "First trouble result",
    },
  },
  ["]"] = {
    d = {
      vim.diagnostic.goto_next,
      "Go to next diagnostic",
      silent = true,
    },
    q = {
      function()
        require("trouble").next({ skip_groups = true, jump = true })
      end,
      "Next trouble result",
    },
    Q = {
      function()
        require("trouble").last({ skip_groups = true, jump = true })
      end,
      "Last trouble result",
    },
  },
  ["<C-w>"] = {
    m = { "<cmd>WinShift<cr>", "WinShift mode" },
    x = { "<cmd>WinShift swap<cr><C-w><C-w>", "Swap splits" },
    r = {
      function()
        require("smart-splits").start_resize_mode()
      end,
      "Smart resize",
    },
  },
  ["<C-a>"] = {
    function()
      if vim.api.nvim_get_mode().mode:lower() == "v" then
        require("dial.map").inc_visual()
      else
        require("dial.map").inc_normal()
      end
    end,
    "Dial increment",
    noremap = true,
    mode = { "n", "v" },
  },
  ["<C-x>"] = {
    function()
      if vim.api.nvim_get_mode().mode:lower() == "v" then
        require("dial.map").dec_visual()
      else
        require("dial.map").dec_normal()
      end
    end,
    "Dial increment",
    noremap = true,
    mode = { "n", "v" },
  },
  ["<A-Up>"] = {
    function()
      if vim.api.nvim_get_mode().mode:lower() == "v" then
        require("moveline").block_up()
      else
        require("moveline").up()
      end
    end,
    "Move line up",
    silent = true,
    mode = { "n", "v", "i" },
  },
  ["<A-Down>"] = {
    function()
      if vim.api.nvim_get_mode().mode:lower() == "v" then
        require("moveline").block_down()
      else
        require("moveline").down()
      end
    end,
    "Move line down",
    silent = true,
    mode = { "n", "v", "i" },
  },
  ["<C-_>"] = "Toggle comment",
  ["<C-/>"] = "Toggle comment",
  ["<A-/>"] = "Toggle comment",
})

-- FIXME: Those mappings are not working on which-key
vim.keymap.set("n", "<C-_>", "gcc", { remap = true })
vim.keymap.set("v", "<C-_>", "gc", { remap = true })
vim.keymap.set("n", "<C-/>", "gcc", { remap = true })
vim.keymap.set("v", "<C-/>", "gc", { remap = true })
vim.keymap.set("n", "<A-/>", "gcc", { remap = true })
vim.keymap.set("v", "<A-/>", "gc", { remap = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- omnifunc
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- lsp
    wk.register({
      K = { vim.lsp.buf.hover, "LSP hover", buffer = ev.buf, silent = true },
      ["<C-K>"] = {
        vim.lsp.buf.signature_help,
        "LSP signature help",
        buffer = ev.buf,
        silent = true,
      },
      ["<C-LeftMouse>"] = { vim.lsp.buf.definition, "LSP hover", buffer = ev.buf, silent = true },
      g = {
        d = { vim.lsp.buf.definition, "LSP go to definition", buffer = ev.buf, silent = true },
        D = { vim.lsp.buf.declaration, "LSP go to declaration", buffer = ev.buf, silent = true },
        I = {
          vim.lsp.buf.implementation,
          "LSP go to implementation",
          buffer = ev.buf,
          silent = true,
        },
        c = {
          name = "callhierarchy",
          i = { vim.lsp.buf.incoming_calls, "LSP incoming calls", buffer = ev.buf, silent = true },
          o = { vim.lsp.buf.outgoing_calls, "LSP outgoing calls", buffer = ev.buf, silent = true },
        },
        r = { vim.lsp.buf.references, "LSP references", buffer = ev.buf, silent = true },
        s = { vim.lsp.buf.document_symbol, "LSP document symbols", buffer = ev.buf, silent = true },
        S = {
          vim.lsp.buf.workspace_symbol,
          "LSP workspace symbols",
          buffer = ev.buf,
          silent = true,
        },
      },
      ["<leader>"] = {
        D = { vim.lsp.buf.type_definition, "LSP type definition", buffer = ev.buf, silent = true },
        ca = {
          vim.lsp.buf.code_action,
          "LSP code action",
          buffer = ev.buf,
          silent = true,
          mode = { "n", "v" },
        },
        rn = { vim.lsp.buf.rename, "LSP rename", buffer = ev.buf, silent = true },
        w = {
          name = "workspace",
          l = {
            function()
              vim.print(vim.lsp.buf.list_workspace_folders())
            end,
            "LSP list workspace",
            buffer = ev.buf,
            silent = true,
          },
          a = {
            vim.lsp.buf.add_workspace_folder,
            "LSP add workspace folder",
            buffer = ev.buf,
            silent = true,
          },
          r = {
            vim.lsp.buf.add_workspace_folder,
            "LSP remove workspace folder",
            buffer = ev.buf,
            silent = true,
          },
        },
      },
    })
  end,
})
