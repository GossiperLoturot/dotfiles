-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.mouse = ""
vim.opt.undofile = true


-- bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- definitions
local treesitter_servers = { "cpp", "rust", "c_sharp", "python", "typescript", "lua", "bash", "diff" }
local language_servers = {
  ["clangd"] = { cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed", "--header-insertion=iwyu" } },
  ["rust_analyzer"] = {},
  ["csharp_ls"] = {},
  ["pyright"] = {},
  ["ts_ls"] = {},
  ["lua_ls"] = {}
}
local linter_servers = {
  ["cpp"] = { "cpplint" },
  ["rust"] = { "clippy" },
  ["python"] = { "ruff", "mypy" },
  ["typescript"] = { "biomejs", "eslint" },
  ["lua"] = { "luacheck" },
  ["bash"] = { "shellcheck", "bash" }
}
local task_templates = { "builtin", "meson-build", "meson-compile", "meson-test" }


-- plugins
require("lazy").setup({
  -- colorscheme
  {
    "GossiperLoturot/termin.vim",
    version = "*",
    lazy = false,
    priority = 1000,
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
  {
    "unblevable/quick-scope",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- indent line
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require("ibl").setup() end
  },

  -- indent width auto-detection
  {
    "nmac427/guess-indent.nvim",
    branch = "main",
    event = "BufReadPre",
    config = function() require("guess-indent").setup() end
  },

  -- syntax analyzer
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install(treesitter_servers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = treesitter_servers,
        callback = function() vim.treesitter.start() end
      })
    end
  },

  -- easily to jump
  {
    "smoka7/hop.nvim",
    version = "*",
    keys = {
      { "gw", mode = { "n", "v", "o" }, desc = "hop words" },
      { "gl", mode = { "n", "v", "o" }, desc = "hop lines" },
    },
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
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require("nvim-surround").setup() end
  },

  -- comment supports, split one-line and join multi-line
  {
    "nvim-mini/mini.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("mini.comment").setup({})
      require("mini.splitjoin").setup({ mappings = { toggle = "<Space>s" } })
    end
  },

  -- completion register
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "Kaiser-Yang/blink-cmp-dictionary", lazy = true },
    config = function()
      local cmp = require("blink.cmp")
      cmp.setup({
        keymap = { preset = "super-tab" },
        completion = {
          list = { selection = { auto_insert = false } },
          documentation = { auto_show = true, auto_show_delay_ms = 0 },
          menu = { draw = { columns = {
            { "label", "label_description", gap = 1 },
            { "kind", "source_name", gap = 1 },
          } } }
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "dictionary" },
          providers = { dictionary = {
            module = "blink-cmp-dictionary",
            name = "Dict",
            async = true,
            score_offset = -1000,
            max_items = 8,
            opts = { dictionary_files = { "/usr/share/dict/words" } },
          } },
        },
        cmdline = {
          keymap = { preset = "inherit" },
          completion = {
            menu = { auto_show = true },
            list = { selection = { auto_insert = false } }
          }
        }
      })

      local caps = cmp.get_lsp_capabilities({})
      vim.lsp.config("*", { capabilities = caps })
    end
  },

  -- lsp register
  {
    "neovim/nvim-lspconfig",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- lsp completion

      -- setup lsp
      for name, config in pairs(language_servers) do
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end

      -- diagnostics column sign
      local suffix_fn = function(diagnostic)
        return string.format(" [%s.%s]", diagnostic.source, diagnostic.code)
      end
      vim.diagnostic.config({
        float = { suffix = suffix_fn },
        virtual_text = { suffix = suffix_fn },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "|",
            [vim.diagnostic.severity.WARN] = "|",
            [vim.diagnostic.severity.INFO] = "|",
            [vim.diagnostic.severity.HINT] = "|"
          }
        }
      })

      -- key mapping
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "hover lsp hint" })
      vim.keymap.set("n", "<Space>K", vim.diagnostic.open_float, { desc = "hover diagnostic" })
      vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, { desc = "run lsp rename" })
    end
  },

  -- linter register
  {
    "mfussenegger/nvim-lint",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- setup linter
      local linters_by_ft = {}
      local linters_any = {}
      for language, linter_servers_by_ft in pairs(linter_servers) do
        for _, linter_server in ipairs(linter_servers_by_ft) do
          local cmd = lint.linters[linter_server].cmd

          -- if cmd is function, call it. for example, biomejs, eslint, etc.
          if type(cmd) == "function" then
            cmd = cmd()
          end

          -- check available linter server
          if vim.fn.executable(cmd) ~= 0 then
            if language == "*" then
              -- linter any
              table.insert(linters_any, linter_server)
            else
              -- linter by ft
              if not linters_by_ft[language] then
                linters_by_ft[language] = {}
              end
              table.insert(linters_by_ft[language], linter_server)
            end
          end
        end
      end

      -- autocmd mapping
      lint.linters_by_ft = linters_by_ft
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        callback = function()
          lint.try_lint()
          for _, linter in ipairs(linters_any) do
            lint.try_lint(linter)
          end
        end
      })
    end
  },

  -- notify indicator
  {
    "j-hui/fidget.nvim",
    version = "*",
    event = { "LspAttach" },
    config = function() require("fidget").setup() end
  },

  -- fuzzy finder
  {
    "ibhagwan/fzf-lua",
    branch = "main",
    event = "VeryLazy",
    config = function()
      local fzf_lua = require("fzf-lua")
      fzf_lua.setup({ lsp = { symbols = { symbol_style = 3 } } })
      fzf_lua.register_ui_select()

      -- key mapping
      vim.keymap.set("n", "gd", fzf_lua.lsp_definitions, { desc = "show lsp definitions" })
      vim.keymap.set("n", "gD", fzf_lua.lsp_typedefs, { desc = "show lsp type definitions" })
      vim.keymap.set("n", "gx", fzf_lua.lsp_declarations, { desc = "show lsp declaration" })
      vim.keymap.set("n", "gi", fzf_lua.lsp_implementations, { desc = "show lsp implementations" })
      vim.keymap.set("n", "gr", fzf_lua.lsp_references, { desc = "show lsp references" })
      vim.keymap.set("n", "<Space>a", fzf_lua.lsp_code_actions, { desc = "show lsp code actions" })
      vim.keymap.set("n", "<Space>f", fzf_lua.files, { desc = "show file list" })
      vim.keymap.set("n", "<Space>F", fzf_lua.live_grep, { desc = "show live grep" })
      vim.keymap.set("n", "<Space>b", fzf_lua.buffers, { desc = "show buffer list" })
      vim.keymap.set("n", "<Space>o", fzf_lua.lsp_document_symbols, { desc = "show symbols in document" })
      vim.keymap.set("n", "<Space>w", fzf_lua.diagnostics_workspace, { desc = "show diagnostics in workspace" })
    end
  },

  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-tree").setup({
        view = { side = "right" },
        sync_root_with_cwd = true,
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

  -- github copilot
  {
    "zbirenbaum/copilot.lua",
    version = "*",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = { enable = false },
        suggestion = { enable = true, auto_trigger = true }
      })
    end
  },

  -- task runner
  {
    "stevearc/overseer.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      local overseer = require("overseer")
      overseer.setup({ templates = task_templates })
      vim.keymap.set("n", "<Space>q", function() overseer.run_task() end, { desc = "open task actions" })
      vim.keymap.set("n", "<Space>Q", function() overseer.toggle({ direction = "left" }) end, { desc = "toggle task window" })
    end
  },

  -- git visualization
  {
    "lewis6991/gitsigns.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({ signcolumn = false, numhl = true })

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

