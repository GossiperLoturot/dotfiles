vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }

vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', 'gx', vim.lsp.buf.declaration)
vim.keymap.set('n', '<Space>K', vim.diagnostic.open_float)
vim.keymap.set('n', '<Space>r', vim.lsp.buf.rename)
vim.keymap.set('n', '<Space>l', vim.lsp.buf.formatting)

-- bootstarp
local has_packer, _ = pcall(require, 'packer')
if not has_packer then
	local url = 'https://github.com/wbthomason/packer.nvim'
	local path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	vim.cmd(string.format([[!git clone --depth 1 %s %s]], url, path))
	vim.cmd([[packadd packer.nvim]])
end

-- plugins
require('packer').startup(function(use)

	-- package manager
	use({ 'wbthomason/packer.nvim' })

	-- colorscheme
	use({
		'joshdick/onedark.vim',
		config = function()
			vim.cmd([[colorscheme onedark]])
			vim.cmd([[highlight clear SpellBad]])
			vim.cmd([[highlight clear SpellCap]])
			vim.cmd([[highlight clear SpellRare]])
			vim.cmd([[highlight clear SpellLocal]])
			vim.cmd([[highlight QuickScopePrimary gui='underline' guifg='#5fffff']])
			vim.cmd([[highlight QuickScopeSecondary gui='underline' guifg='#ff5fff']])
		end
	})

	-- status line
	use({
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons' },
		config = function()
			require('lualine').setup({
				options = { globalstatus = true }
			})
		end
	})

	-- syntax analyzer
	use({
		'nvim-treesitter/nvim-treesitter',
		config = function()
			require('nvim-treesitter.configs').setup({
				highlight = { enable = true }
			})
		end
	})

	-- indent line
	use({
		'lukas-reineke/indent-blankline.nvim',
		config = function()
			require("indent_blankline").setup({
				show_current_context = true
			})
		end
	})

	-- highligt f jump char
	use({ 'unblevable/quick-scope' })

	-- easily to jump
	use({
		'phaazon/hop.nvim',
		config = function()
			local hop = require('hop')
			hop.setup({})
			vim.keymap.set({ 'n', 'v', 'o' }, 'gw', hop.hint_words)
			vim.keymap.set({ 'n', 'v', 'o' }, 'gl', hop.hint_lines_skip_whitespace)
		end
	})

	-- useful control
	use({ 'tpope/vim-repeat' })
	use({ 'tpope/vim-commentary' })
	use({ 'tpope/vim-surround' })

	-- auto pairs
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end
	})

	-- completion
	use({
		'hrsh7th/nvim-cmp',
		requires = {
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-emoji',
			'f3fora/cmp-spell'
		},
		config = function()
			local cmp = require('cmp')
			local snip = require('luasnip')
			cmp.setup({
				snippet = {
					expand = function(args)
						snip.lsp_expand(args.body)
					end
				},
				sources = cmp.config.sources({
					{ name = 'luasnip' },
					{ name = 'nvim_lsp' },
					{ name = 'buffer' },
					{ name = 'emoji' },
					{ name = 'spell' }
				}),
				mapping = {
					['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					['<Tab>'] = cmp.mapping.confirm(),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if snip.expand_or_jumpable() then
							snip.expand_or_jump()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<C-d>'] = cmp.mapping.scroll_docs(1),
					['<C-u>'] = cmp.mapping.scroll_docs(-1)
				},
				completion = {
					completeopt = 'menu,menuone,noinsert'
				},
				experimental = { ghost_text = true }
			})
		end
	})

	-- lsp
	use({
		'neovim/nvim-lspconfig',
		requires = {
			'williamboman/nvim-lsp-installer',
			'hrsh7th/cmp-nvim-lsp'
		},
		config = function()

			-- lsp installer
			local lsp_installer = require('nvim-lsp-installer')
			lsp_installer.setup({})
			local servers = lsp_installer.get_installed_servers()

			-- lsp completion
			local cap = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

			-- lsp configure
			local lsp_config = require('lspconfig')
			for _, server in ipairs(servers) do
				lsp_config[server.name].setup({ capabilities = cap })
			end
		end
	})

	-- fuzzy finder
	use({
		'nvim-telescope/telescope.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function()
			local telescope = require('telescope.builtin')
			vim.keymap.set('n', 'gd', telescope.lsp_definitions)
			vim.keymap.set('n', 'gD', telescope.lsp_type_definitions)
			vim.keymap.set('n', 'gi', telescope.lsp_implementations)
			vim.keymap.set('n', 'gr', telescope.lsp_references)
			vim.keymap.set('n', '<Space>f', telescope.find_files)
			vim.keymap.set('n', '<Space>F', telescope.live_grep)
			vim.keymap.set('n', '<Space>b', telescope.buffers)
			vim.keymap.set('n', '<Space>w', telescope.diagnostics)
		end
	})

	-- code action
	use({
		'weilbith/nvim-code-action-menu',
		config = function()
			local code_action_menu = require('code_action_menu')
			vim.keymap.set('n', '<Space>a', code_action_menu.open_code_action_menu)
		end
	})

	-- checker status
	use({
		'j-hui/fidget.nvim',
		config = function()
			require('fidget').setup({})
		end
	})

	-- bootstrap
	if not has_packer then
		require('packer').sync()
	end
end)
