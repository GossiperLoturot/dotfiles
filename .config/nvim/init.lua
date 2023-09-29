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
    config = function() require("ibl").setup({}) end
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
    "phaazon/hop.nvim",
    config = function()
      local hop = require("hop")
      hop.setup()
      vim.keymap.set({ "n", "v", "o" }, "gw", hop.hint_words)
      vim.keymap.set({ "n", "v", "o" }, "gl", hop.hint_lines_skip_whitespace)
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

  -- completions
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "f3fora/cmp-spell",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "windwp/nvim-autopairs"
    },
    config = function()
      local cmp = require("cmp")
      local snip = require("luasnip")

      -- key mapping
      local mapping = {
        ["<C-n>"] = {
          i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          c = function() cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) end
        },
        ["<C-p>"] = {
          i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          c = function() cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select }) end
        },
        ["<Tab>"] = {
          i = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
          c = function() cmp.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }) end
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

      cmp.setup.cmdline("/", {
        mapping = mapping,
        sources = {
          { name = "nvim_lsp_document_symbol", group_index = 1 },
          { name = "buffer", group_index = 2 },
          { name = "spell", group_index = 2 }
        }
      })

      cmp.setup.cmdline(":", {
        mapping = mapping,
        sources = {
          { name = "cmdline", group_index = 1 },
          { name = "spell", group_index = 2 }
        },
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

  -- lsp
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "simrat39/rust-tools.nvim"
    },
    config = function()
      require("mason-lspconfig").setup()

      -- lsp completion
      local cap = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      -- setup lsp
      local lsp_config = require("lspconfig")
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lsp_config[server_name].setup({ capabilities = cap })
        end,
        ["rust_analyzer"] = function()
          require("rust-tools").setup()
        end
      })

      -- diagnostics column sign
      vim.fn.sign_define("DiagnosticSignInfo", { text = "*", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "*", texthl = "DiagnosticSignHint" })
      vim.fn.sign_define("DiagnosticSignWarn", { text = "*", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignError", { text = "*", texthl = "DiagnosticSignError" })

      -- key mapping
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "gx", vim.lsp.buf.declaration)
      vim.keymap.set("n", "<Space>K", vim.diagnostic.open_float)
      vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename)
      vim.keymap.set("n", "<Space>l", vim.lsp.buf.format)

    end
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- setup telescope
      require("telescope").setup({})

      -- key mapping
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "gd", telescope.lsp_definitions)
      vim.keymap.set("n", "gD", telescope.lsp_type_definitions)
      vim.keymap.set("n", "gi", telescope.lsp_implementations)
      vim.keymap.set("n", "gr", telescope.lsp_references)
      vim.keymap.set("n", "<Space>f", telescope.find_files)
      vim.keymap.set("n", "<Space>F", telescope.live_grep)
      vim.keymap.set("n", "<Space>b", telescope.buffers)
      vim.keymap.set("n", "<Space>w", telescope.diagnostics)
    end
  },

  -- code action
  {
    "weilbith/nvim-code-action-menu",
    config = function()
      vim.g.code_action_menu_show_diff = false

      local code_action_menu = require("code_action_menu")
      vim.keymap.set("n", "<Space>a", code_action_menu.open_code_action_menu)
    end
  },

  -- filter
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
      vim.keymap.set("n", "<Space>t", api.tree.toggle)
    end
  },

  -- lsp indicator
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function() require("fidget").setup({}) end
  },

  -- git visualization
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({})

      -- key mapping
      vim.keymap.set("n", "<Space>hs", gitsigns.stage_hunk)
      vim.keymap.set("n", "<Space>hr", gitsigns.reset_hunk)
      vim.keymap.set("n", "<Space>hu", gitsigns.undo_stage_hunk)
      vim.keymap.set("n", "<Space>hS", gitsigns.stage_buffer)
      vim.keymap.set("n", "<Space>hR", gitsigns.reset_buffer)
      vim.keymap.set("n", "<Space>hd", gitsigns.preview_hunk)
      vim.keymap.set("n", "<Space>hD", gitsigns.diffthis)

      vim.keymap.set("v", "<Space>hs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
      vim.keymap.set("v", "<Space>hr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
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
