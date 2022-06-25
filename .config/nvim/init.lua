vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }

-- Plugin Manager
require('packer').startup(function(use)
	use({ 'wbthomason/packer.nvim' })
	use({ 'joshdick/onedark.vim' })
	use({ 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true } })
	use({ 'nvim-treesitter/nvim-treesitter' })
	use({ 'lukas-reineke/indent-blankline.nvim' })
	use({ 'unblevable/quick-scope' })
	use({ 'phaazon/hop.nvim' })
	use({ 'tpope/vim-repeat' })
	use({ 'tpope/vim-commentary' })
	use({ 'tpope/vim-surround' })
	use({ 'hrsh7th/nvim-cmp', requires = { 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' } })
	use({ 'hrsh7th/cmp-nvim-lsp' })
	use({ 'hrsh7th/cmp-buffer' })
	use({ 'hrsh7th/cmp-emoji' })
	use({ 'f3fora/cmp-spell' })
	use({ 'williamboman/nvim-lsp-installer' })
	use({ 'neovim/nvim-lspconfig' })
	use({ 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } })
	use({ 'weilbith/nvim-code-action-menu' })
	use({ 'j-hui/fidget.nvim' })
end)

-- Colorscheme
vim.cmd([[colorscheme onedark]])
vim.cmd([[highlight clear SpellBad]])
vim.cmd([[highlight clear SpellCap]])
vim.cmd([[highlight clear SpellRare]])
vim.cmd([[highlight clear SpellLocal]])
vim.cmd([[highlight QuickScopePrimary gui='underline' guifg='#5fffff']])
vim.cmd([[highlight QuickScopeSecondary gui='underline' guifg='#ff5fff']])

-- Status Line
require('lualine').setup({
	options = { globalstatus = true }
})

-- Syntax Highlight
require('nvim-treesitter.configs').setup({
	highlight = { enable = true }
})

-- Indent Line
require("indent_blankline").setup({
	show_current_context = true
})

-- Enhanced Goto
local hop = require('hop')
hop.setup({})
vim.keymap.set({ 'n', 'v', 'o' }, 'gw', hop.hint_words)
vim.keymap.set({ 'n', 'v', 'o' }, 'gl', hop.hint_lines_skip_whitespace)

-- Completion
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

-- LSP Completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- LSP Server Manager
local nvim_lsp_installer = require('nvim-lsp-installer')
nvim_lsp_installer.setup({})
local nvim_lsp_servers = nvim_lsp_installer.get_installed_servers()

-- LSP Configurations
for _, server in pairs(nvim_lsp_servers) do
	require('lspconfig')[server.name].setup({
		capabilities = capabilities,
		settings = {
			['rust-analyzer'] = { checkOnSave = { command = 'clippy' } }
		}
	})
end
local telescope = require('telescope.builtin')
local code_action_menu = require('code_action_menu')
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', 'gx', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gd', telescope.lsp_definitions)
vim.keymap.set('n', 'gD', telescope.lsp_type_definitions)
vim.keymap.set('n', 'gi', telescope.lsp_implementations)
vim.keymap.set('n', 'gr', telescope.lsp_references)
vim.keymap.set('n', '<Space>K', vim.diagnostic.open_float)
vim.keymap.set('n', '<Space>f', telescope.find_files)
vim.keymap.set('n', '<Space>F', telescope.live_grep)
vim.keymap.set('n', '<Space>b', telescope.buffers)
vim.keymap.set('n', '<Space>a', code_action_menu.open_code_action_menu)
vim.keymap.set('n', '<Space>r', vim.lsp.buf.rename)
vim.keymap.set('n', '<Space>l', vim.lsp.buf.formatting)
vim.keymap.set('n', '<Space>w', telescope.diagnostics)

-- LSP Indicator
require('fidget').setup({})
