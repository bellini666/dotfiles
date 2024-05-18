local utils = require("utils")
local wk = require("which-key")

wk.register({
  ["<esc>"] = { "<cmd>noh<cr><esc>", "Clear", mode = { "i", "n" } },
  ["<C-Up>"] = { "15<C-y>", "Up 1 page", mode = { "i", "n" } },
  ["<C-Down>"] = { "15<C-e>", "Down 1 page", mode = { "i", "n" } },
  ["<"] = { "<gv", "Continuous visual indenting", mode = "v" },
  [">"] = { ">gv", "Continuous visual indenting", mode = "v" },
  ["<A-Left>"] = { "gT", "Previous tab" },
  ["<A-Right>"] = { "gt", "Next tab" },
  ["z="] = { utils.spell_suggest, "Spell suggest" },
  ["#"] = { "*", "Search highlighted word forward", mode = { "n", "x", "o" } },
  ["*"] = { "#", "Search highlighted word backward", mode = { "n", "x", "o" } },
  p = { '"_dP', "Paste", noremap = true, silent = true, mode = "v" },
  s = {
    function()
      require("flash").jump()
    end,
    "Flash",
    mode = { "n", "x", "o" },
  },
  S = {
    function()
      require("flash").treesitter()
    end,
    "Flash Treesitter",
    mode = { "n", "x", "o" },
  },
  r = {
    function()
      require("flash").remote()
    end,
    "Remote Flash",
    mode = "o",
  },
  R = {
    function()
      require("flash").treesitter_search()
    end,
    "Treesitter Search",
    mode = { "o", "x" },
  },
  ["<C-s>"] = {
    function()
      require("flash").toggle()
    end,
    "Toggle Flash Search",
    mode = { "c" },
  },
  ["<leader>"] = {
    y = { '"+y', "Copy to clipboard", silent = true, mode = "v" },
    p = { '"+p', "Copy to clipboard", silent = true, mode = { "n", "v" } },
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
    v = {
      b = {
        function()
          require("gitsigns").blame_line({ full = true })
        end,
        "Blame current line",
        silent = true,
      },
    },
    s = {
      j = {
        function()
          require("treesj").toggle()
        end,
        "Treesj Toggle",
        mode = { "n" },
      },
    },
    c = {
      name = "ChatGPT",
      c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
      e = {
        "<cmd>ChatGPTEditWithInstruction<CR>",
        "Edit with instruction",
        mode = { "n", "v" },
      },
      g = {
        "<cmd>ChatGPTRun grammar_correction<CR>",
        "Grammar Correction",
        mode = { "n", "v" },
      },
      t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
      d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
      w = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
      o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
      s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
      f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
      x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
      l = {
        "<cmd>ChatGPTRun code_readability_analysis<CR>",
        "Code Readability Analysis",
        mode = { "n", "v" },
      },
    },
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
  ["<C-d>"] = {
    utils.run_tests,
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
    "Toggle neotest output",
  },
  ["<F12>"] = {
    function()
      require("neotest").summary.toggle()
    end,
    "Toggle neotest summary",
  },
  g = {
    K = {
      function()
        require("dap.ui.widgets").hover()
      end,
      "DAP hover",
      mode = { "n", "v" },
    },
    e = {
      function()
        require("trouble").toggle({ mode = "diagnostics", focus = false, filter = { buf = 0 } })
      end,
      "Document diagnostics",
    },
    E = {
      function()
        require("trouble").toggle({ mode = "diagnostics", focus = false })
      end,
      "Document diagnostics",
    },
  },
  ["<C-q>"] = {
    function()
      require("trouble").toggle({ mode = "diagnostics", focus = false })
    end,
    "Toggle trouble",
  },
  ["["] = {
    b = {
      function()
        require("goto-breakpoints").prev()
      end,
      "Go to previous breakpoint",
      silent = true,
      mode = "n",
    },
    d = {
      vim.diagnostic.goto_prev,
      "Go to previous diagnostic",
      silent = true,
    },
    q = {
      function()
        require("trouble").prev({ jump = true })
      end,
      "Previous trouble result",
    },
    Q = {
      function()
        require("trouble").first({ jump = true })
      end,
      "First trouble result",
    },
  },
  ["]"] = {
    b = {
      function()
        require("goto-breakpoints").next()
      end,
      "Go to next breakpoint",
      silent = true,
      mode = "n",
    },
    S = {
      function()
        require("goto-breakpoints").stopped()
      end,
      "Go to next breakpoint",
      silent = true,
      mode = "n",
    },
    d = {
      vim.diagnostic.goto_next,
      "Go to next diagnostic",
      silent = true,
    },
    q = {
      function()
        require("trouble").next({ jump = true })
      end,
      "Next trouble result",
    },
    Q = {
      function()
        require("trouble").last({ jump = true })
      end,
      "Last trouble result",
    },
  },
  ["<C-w>"] = {
    t = { "<cmd>tab split<cr>", "Duplicate tab" },
    m = { "<cmd>WinShift<cr>", "WinShift mode" },
    x = { "<cmd>WinShift swap<cr><C-w><C-w>", "Swap splits" },
    r = {
      function()
        require("smart-splits").start_resize_mode()
      end,
      "Smart resize",
    },
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
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client.server_capabilities.completionProvider then
      vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[ev.buf].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    -- lsp
    wk.register({
      K = { vim.lsp.buf.hover, "LSP hover", buffer = ev.buf, silent = true },
      ["<C-K>"] = {
        vim.lsp.buf.signature_help,
        "LSP signature help",
        buffer = ev.buf,
        silent = true,
      },
      ["<C-LeftMouse>"] = {
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        "LSP hover",
        buffer = ev.buf,
        silent = true,
      },
      g = {
        d = {
          function()
            require("telescope.builtin").lsp_definitions()
          end,
          "LSP go to definition",
          buffer = ev.buf,
          silent = true,
        },
        D = { vim.lsp.buf.declaration, "LSP go to declaration", buffer = ev.buf, silent = true },
        I = {
          function()
            require("telescope.builtin").lsp_implementations()
          end,
          "LSP go to implementation",
          buffer = ev.buf,
          silent = true,
        },
        c = {
          name = "callhierarchy",
          i = {
            function()
              require("telescope.builtin").lsp_incoming_calls()
            end,
            "LSP incoming calls",
            buffer = ev.buf,
            silent = true,
          },
          o = {
            function()
              require("telescope.builtin").lsp_outgoing_calls()
            end,
            "LSP outgoing calls",
            buffer = ev.buf,
            silent = true,
          },
        },
        r = {
          function()
            require("telescope.builtin").lsp_references({ jump_type = "never" })
          end,
          "LSP references",
          buffer = ev.buf,
          silent = true,
        },
        s = {
          function()
            require("telescope.builtin").lsp_document_symbols()
          end,
          "LSP document symbols",
          buffer = ev.buf,
          silent = true,
        },
        S = {
          function()
            require("telescope.builtin").lsp_workspace_symbols()
          end,
          "LSP workspace symbols",
          buffer = ev.buf,
          silent = true,
        },
      },
      ["<leader>"] = {
        D = {
          function()
            require("telescope.builtin").lsp_type_definitions()
          end,
          "LSP type definition",
          buffer = ev.buf,
          silent = true,
        },
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
