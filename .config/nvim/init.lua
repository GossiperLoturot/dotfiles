-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.tabstop = 2
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.laststatus = 3

vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gx", vim.lsp.buf.declaration)
vim.keymap.set("n", "<Space>K", vim.diagnostic.open_float)
vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename)
vim.keymap.set("n", "<Space>l", vim.lsp.buf.format)

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
    end
  },

  -- highligt f jump char
  { "unblevable/quick-scope" },

  -- indent line
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function() require("indent_blankline").setup() end
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
      "windwp/nvim-autopairs"
    },
    config = function()
      local cmp = require("cmp")
      local snip = require("luasnip")
      cmp.setup({
        -- setup completions
        snippet = {
          expand = function(args)
            snip.lsp_expand(args.body)
          end
        },
        sources = cmp.config.sources({
          { name = "luasnip" },
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "spell" }
        }),
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<Tab>"] = cmp.mapping.confirm(),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if snip.expand_or_jumpable() then
              snip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-d>"] = cmp.mapping.scroll_docs(1),
          ["<C-u>"] = cmp.mapping.scroll_docs(-1)
        },
        completion = {
          completeopt = "menu,menuone,noinsert"
        }
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
    end
  },

  -- linter and formatter
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-null-ls.nvim"
    },
    config = function()
      require("mason-null-ls").setup({ handlers = {} })
      require("null-ls").setup()
    end
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- setup telescope
      local actions = require("telescope.actions")
      require("telescope").setup({
        pickers = {
          buffers = {
            mappings = {
              n = { ["<C-B>"] = actions.delete_buffer },
              i = { ["<C-B>"] = actions.delete_buffer },
            }
          }
        }
      })

      -- mapping
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
            show = {
              file = false,
              folder = false,
              folder_arrow = false,
              git = false,
              modified = false,
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
    "https://github.com/j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end
  }
},

-- lazy configure
{
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤",
    }
  }
})
