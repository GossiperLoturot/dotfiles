-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

-- bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({
  -- colorscheme
  {
    "GossiperLoturot/termin.vim",
    config = function()
      vim.cmd([[colorscheme termin]])
      vim.cmd([[highlight clear SpellBad]])
      vim.cmd([[highlight clear SpellCap]])
      vim.cmd([[highlight clear SpellRare]])
      vim.cmd([[highlight clear SpellLocal]])
      vim.cmd([[highlight QuickScopePrimary gui=underline guifg=#5fffff]])
      vim.cmd([[highlight QuickScopeSecondary gui=underline guifg=#ff5fff]])
      vim.cmd([[highlight GitSignsAdd guifg=#98c379]])
      vim.cmd([[highlight GitSignsChange guifg=#e5c07b]])
      vim.cmd([[highlight GitSignsDelete guifg=#e06c75]])
    end
  },

  -- highligt f jump char
  { "unblevable/quick-scope" },

  -- indent line
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function() require("ibl").setup() end
  },

  -- indent width auto-detection
  {
    "nmac427/guess-indent.nvim",
    config = function() require("guess-indent").setup() end
  },

  -- syntax analyzer
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gn",
            node_incremental = "ii",
            scope_incremental = "iI",
            node_decremental = "id"
          }
        }
      })
    end
  },

  -- easily to jump
  {
    "smoka7/hop.nvim",
    config = function()
      local hop = require("hop")
      hop.setup()
      vim.keymap.set({ "n", "v", "o" }, "gw", hop.hint_words, { desc = "hop words" })
      vim.keymap.set({ "n", "v", "o" }, "gl", hop.hint_lines_skip_whitespace, { desc = "hop lines" })
    end
  },

  -- surround supports
  {
    "kylechui/nvim-surround",
    config = function() require("nvim-surround").setup() end
  },

  -- comment supports
  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end
  },

  -- auto pairs
  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup({ check_ts = true }) end
  },

  -- split one-line or join multi-line
  {
    "Wansmer/treesj",
    config = function() require("treesj").setup() end
  },

  -- github copilot
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        panel = { enable = false },
        suggestion = { enable = true, auto_trigger = true }
      })
    end
  },

  -- completion register
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "honza/vim-snippets",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "f3fora/cmp-spell",
      "windwp/nvim-autopairs"
    },
    config = function()
      local cmp = require("cmp")

      -- load snipet template
      local snip = require("luasnip")
      require("luasnip.loaders.from_snipmate").lazy_load()

      -- key mapping
      local mapping = {
        ["<C-n>"] = {
          i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        },
        ["<C-p>"] = {
          i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        },
        ["<Tab>"] = {
          i = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
        },
        ["<C-d>"] = {
          i = cmp.mapping.scroll_docs(1)
        },
        ["<C-u"] = {
          i = cmp.mapping.scroll_docs(-1)
        },
        ["<S-Tab>"] = {
          i = function() snip.expand_or_jump() end
        }
      }

      -- setup completions
      cmp.setup({
        snippet = {
          expand = function(args)
            snip.lsp_expand(args.body)
          end
        },
        mapping = mapping,
        sources = cmp.config.sources({
          { name = "luasnip", group_index = 1 },
          { name = "nvim_lsp", group_index = 2 },
          { name = "buffer", group_index = 3 },
          { name = "spell", group_index = 3 }
        }),
        completion = { completeopt = "menu,menuone,noinsert" },
      })

      -- completions + autopairs compability
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  },

  -- lsp and dap, linter, formatter installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  -- lsp register
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function()
      require("mason-lspconfig").setup()

      -- lsp completion
      local cap = require("cmp_nvim_lsp").default_capabilities()

      -- setup lsp
      local lsp_config = require("lspconfig")
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lsp_config[server_name].setup({ capabilities = cap })
        end
      })

      -- diagnostics column sign
      vim.fn.sign_define("DiagnosticSignInfo", { text = "*", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "*", texthl = "DiagnosticSignHint" })
      vim.fn.sign_define("DiagnosticSignWarn", { text = "*", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignError", { text = "*", texthl = "DiagnosticSignError" })

      -- key mapping
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "hover lsp hint" })
      vim.keymap.set("n", "<Space>K", vim.diagnostic.open_float, { desc = "hover diagnostic" })
      vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, { desc = "run lsp rename" })
      vim.keymap.set("n", "<Space>l", vim.lsp.buf.format, { desc = "run lsp format" })
    end
  },

  -- lsp indicator
  {
    "j-hui/fidget.nvim",
    config = function() require("fidget").setup() end
  },

  -- fuzzy finder
  {
    "ibhagwan/fzf-lua",
    config = function()
      -- setup fzf-lua
      local fzf_lua = require("fzf-lua")

      fzf_lua.setup()

      -- key mapping
      vim.keymap.set("n", "gd", fzf_lua.lsp_definitions, { desc = "show lsp definitions" })
      vim.keymap.set("n", "gD", fzf_lua.lsp_typedefs, { desc = "show lsp type definitions" })
      vim.keymap.set("n", "gx", fzf_lua.lsp_declarations, { desc = "show lsp declaration" })
      vim.keymap.set("n", "gi", fzf_lua.lsp_implementations, { desc = "show lsp implementations" })
      vim.keymap.set("n", "gr", fzf_lua.lsp_references, { desc = "show lsp references" })
      vim.keymap.set("n", "<space>a", fzf_lua.lsp_code_actions, { desc = "show lsp code actions" })
      vim.keymap.set("n", "<Space>f", fzf_lua.files, { desc = "show file list" })
      vim.keymap.set("n", "<Space>F", fzf_lua.live_grep, { desc = "show live grep" })
      vim.keymap.set("n", "<Space>b", fzf_lua.buffers, { desc = "show buffer list" })
      vim.keymap.set("n", "<Space>w", fzf_lua.diagnostics_workspace, { desc = "show diagnostics in workspace" })
    end
  },

  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        renderer = {
          icons = {
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "",
              modified = "",
              folder = { arrow_closed = "", arrow_open = "", default = "", open = "", empty = "", empty_open = "", symlink = "", symlink_open = "" },
              git = { unstaged = "", staged = "", unmerged = "", renamed = "", untracked = "", deleted = "", ignored = "" }
            }
          }
        }
      })

      local api = require("nvim-tree.api")
      vim.keymap.set("n", "<Space>t", api.tree.toggle, { desc = "toggle file tree" })
    end
  },

  -- git visualization
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({
        signcolumn = false,
        numhl = true,
      })

      -- key mapping
      vim.keymap.set("n", "<Space>gs", gitsigns.stage_hunk, { desc = "stage/unstage hunk" })
      vim.keymap.set("n", "<Space>gS", gitsigns.stage_buffer, { desc = "stage/unstage buffer" })
      vim.keymap.set("n", "<Space>gr", gitsigns.reset_hunk, { desc = "reset hunk" })
      vim.keymap.set("n", "<Space>gR", gitsigns.reset_buffer, { desc = "reset buffer" })
      vim.keymap.set("n", "<Space>gd", gitsigns.preview_hunk_inline, { desc = "preview hunk" })
      vim.keymap.set("n", "<Space>gD", gitsigns.diffthis, { desc = "show diff this" })
    end
  }
},

-- lazy configure
{
  ui = {
    icons = {
      cmd = "",
      config = "",
      event = "",
      ft = "",
      init = "",
      import = "",
      keys = "",
      lazy = "",
      loaded = "",
      not_loaded = "",
      plugin = "",
      runtime = "",
      source = "",
      start = "",
      task = "",
      list = { "", "", "", "" }
    }
  }
})

