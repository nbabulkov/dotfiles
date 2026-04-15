---@diagnostic disable: undefined-global (only for: vim)
-- Neovim IDE Baseline (Python + TypeScript + Go)
-- Single-file init.lua aimed at stability and sane defaults.
-- Features: file viewer, LSP, treesitter, completion, formatters, linters, debugger, Telescope search,
-- Git integration, and AI chat (CodeCompanion with Azure OpenAI + LM Studio local models).
--
-- Prereqs (system): ripgrep, node>=18, npm, python3-venv/pipx, git, go
-- Recommended global tools: `pipx install ruff debugpy` | `npm i -g typescript typescript-language-server prettier`
-- Set API keys via env vars: AZURE_OPENAI_API_KEY, AZURE_OPENAI_ENDPOINT
-- Optional: LM Studio running on localhost:1234 for local models

-- 0) Ensure bun binaries are in PATH
vim.env.PATH = vim.fn.expand("~/.bun/bin") .. ":" .. vim.env.PATH

-- 0) Basic options
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400
vim.opt.swapfile = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.scrolloff = 5
vim.opt.expandtab = false -- use actual tab characters
vim.opt.tabstop = 4       -- tab width display
vim.opt.shiftwidth = 4    -- indent width with >> etc.
vim.opt.list = true
vim.opt.listchars = {
	space = "·", -- visible spaces (UTF-8 middle dot U+00B7)
	tab = "→ ", -- visible tabs (UTF-8 rightwards arrow U+2192)
	trail = "$", -- trailing spaces
	extends = ">", -- lines too long
	precedes = "<" -- lines that continue left
}

-- 1) Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable',
		lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 2) Plugins
require('lazy').setup({
	-- Themes
	{ 'folke/tokyonight.nvim',     lazy = false,     priority = 1000 },
	{
		"tiagovla/tokyodark.nvim",
		opts = {
			-- custom options here
		},
		config = function(_, opts)
			require("tokyodark").setup(opts) -- calling setup is optional
			vim.cmd [[colorscheme tokyodark]]
		end,
	},
	{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false,   priority = 1000 },

	-- UI / UX
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			options = { theme = 'auto' },
			sections = {
				lualine_b = { 'branch', 'diff', 'diagnostics' },
				lualine_c = {
					{ 'filename', path = 3, shorting_target = 0 },
				},
			},
			tabline = {
				lualine_a = {
					{
						'tabs',
						mode = 2, -- show tab number + name
						max_length = vim.o.columns,
						fmt = function(name, context)
							local ok, tab_name = pcall(vim.api.nvim_tabpage_get_var, context.tabId, 'tab_name')
							if ok and tab_name and tab_name ~= '' then
								return tab_name
							end
							return name
						end,
					},
				},
			},
		},
	},
	{ "nvim-tree/nvim-web-devicons", opts = {} },
	{
		'folke/which-key.nvim',
		config = function()
			local wk = require('which-key')
			wk.setup({})
			-- Keymap spec lives in lua/keymaps.lua so :Lazy reload which-key.nvim
			-- re-reads the file and re-applies bindings.
			package.loaded['keymaps'] = nil
			wk.add(require('keymaps'))
		end,
	},
	{
		"levouh/tint.nvim",
		opts = {
			tint = -30, -- how much to darken (more negative = darker)
			saturation = 0.5, -- reduce color saturation in unfocused windows
			highlight_ignore_patterns = {},
			tint_background_colors = true,
		},
	},
	{
		'lewis6991/satellite.nvim',
		opts = {
			current_only = false,
			winblend = 50,
			zindex = 40,
			excluded_filetypes = {},
			width = 2,
			handlers = {
				cursor = {
					enable = true,
					symbols = { '⎺', '⎻', '⎼', '⎽' },
				},
				search = {
					enable = true,
				},
				diagnostic = {
					enable = true,
					signs = { '-', '=', '≡' },
					min_severity = vim.diagnostic.severity.HINT,
				},
				gitsigns = {
					enable = true,
					signs = {
						add = '│',
						change = '│',
						delete = '-',
					},
				},
				marks = {
					enable = true,
					show_builtins = false,
					key = 'm',
				},
				quickfix = {
					signs = { '-', '=', '≡' },
				},
			},
		},
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			explorer = { enabled = false },
			indent = { enabled = true },
			input = { enabled = true },
			picker = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
	},

	-- mini.nvim modules (only load what we use)
	{ 'echasnovski/mini.pairs',      version = '*', opts = {} },
	{ 'echasnovski/mini.surround',   version = '*', opts = {} },

	-- Markdown rendering
	{
		'MeanderingProgrammer/render-markdown.nvim',
		ft = { 'markdown' },
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
		opts = {
			-- Wide tables break when lines wrap — extmark virtual text can't
			-- track wrapped cells, so disable wrap in rendered markdown view.
			-- With wrap off, overly wide tables scroll horizontally intact.
			win_options = {
				wrap = { default = vim.o.wrap, rendered = false },
			},
			-- Stop render from un-rendering the cursor row. Eliminates the
			-- flicker you get when scrolling horizontally across wide tables.
			anti_conceal = { enabled = false },
			pipe_table = {
				-- 'trimmed' pads cells to the max *visible* column width,
				-- so columns align even when conceal changes cell width
				-- (e.g. **bold** → bold). Tighter than 'padded', which
				-- reserves width for concealed chars too. Conceal and
				-- highlights apply, so bold/italics/inline code render.
				cell = 'trimmed',
				-- Rounded corners on the top/bottom borders.
				preset = 'round',
			},
		},
	},

	-- Lua LSP support for Neovim config editing
	{ 'folke/lazydev.nvim',      ft = 'lua', opts = {} },

	-- File explorer
	{
		'nvim-neo-tree/neo-tree.nvim',
		branch = 'v3.x',
		dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
		opts = {
			close_if_last_window = true,
			filesystem = {
				filtered_items = {
					hide_gitignored = false,
					hide_dotfiles = false,
					hide_hidden = false,
				},
				components = {
					-- Override the root name so long paths clip from the beginning
					-- (keeping the project dir visible) instead of from the end.
					name = function(config, node, state)
						local result = require('neo-tree.sources.common.components').name(config, node, state)
						if node:get_depth() == 1 and result.text then
							local winid = state.winid
							if winid and vim.api.nvim_win_is_valid(winid) then
								local win_width = vim.api.nvim_win_get_width(winid)
								-- leave a little room for icon + padding
								local max = math.max(8, win_width - 4)
								local text = result.text
								local w = vim.api.nvim_strwidth(text)
								if w > max then
									local excess = w - max + 1 -- +1 for the ellipsis
									result.text = '…' .. text:sub(excess + 1)
								end
							end
						end
						return result
					end,
				},
			},
			window = {
				width = 40,
				auto_expand_width = false,
				mappings = {
					["<space>"] = "none",
				},
			},
		},
	},

	-- Git
	{ 'lewis6991/gitsigns.nvim', opts = {} },
	{
		'NeogitOrg/neogit',
		opts = {
			graph_style = "kitty",
		},
		dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' }
	},
	{
		'kdheepak/lazygit.nvim',
		cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
		dependencies = { 'nvim-lua/plenary.nvim' },
	},
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		opts = {
			-- or "fzf-lua" or "snacks" or "default"
			picker = "telescope",
			-- bare Octo command opens picker of commands
			enable_builtin = true,
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			-- OR "ibhagwan/fzf-lua",
			-- OR "folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
		},
	},

	-- Git worktree
	{
		'ThePrimeagen/git-worktree.nvim',
		dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
		config = function()
			require('git-worktree').setup({})
			require('telescope').load_extension('git_worktree')
		end,
	},

	-- TUIs
	{
		'jrop/tuis.nvim',
		config = function()
			-- Optional: set up keymaps
			vim.keymap.set('n', '<leader>m', function()
				require('tuis').choose()
			end, { desc = 'Choose Morph UI' })
		end
	},

	-- Telescope (code search, files, symbols)
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.5',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
			'nvim-telescope/telescope-live-grep-args.nvim',
		},
		config = function()
			local telescope = require('telescope')
			local actions = require('telescope.actions')
			telescope.setup({
				defaults = {
					mappings = {
						i = {
							['<C-u>'] = false,
							['<C-d>'] = false,
							['<C-j>'] = actions.move_selection_next,
							['<C-k>'] = actions.move_selection_previous,
							['<PageDown>'] = actions.results_scrolling_down,
							['<PageUp>'] = actions.results_scrolling_up,
						},
					},
				},
			})
			telescope.load_extension('fzf')
			telescope.load_extension('live_grep_args')
		end,
	},

	-- Treesitter
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		opts = {
			ensure_installed = { 'lua', 'vim', 'vimdoc', 'query', 'python', 'javascript', 'typescript', 'tsx', 'json', 'yaml', 'bash', 'markdown', 'sql', 'go', 'gomod', 'gosum', 'gowork', 'gotmpl', 'rust', 'toml' },
			highlight = { enable = true },
			indent = { enable = true },
		},
		config = function(_, opts)
			require('nvim-treesitter.configs').setup(opts)
		end,
	},

	-- LSP + tooling
	{ 'neovim/nvim-lspconfig' },
	{ 'williamboman/mason.nvim', build = ':MasonUpdate', opts = {} },
	{
		'williamboman/mason-lspconfig.nvim',
		opts = {
			ensure_installed = { 'pyright', 'ruff', 'ts_ls', 'lua_ls', 'bashls', 'jsonls', 'yamlls', 'gopls', 'rust_analyzer' },
		},
	},
	{
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		opts = {
			ensure_installed = {
				-- linters/formatters
				'ruff', 'prettier', 'biome', 'eslint_d', 'sqruff',
				'goimports-reviser', 'gofumpt', 'golangci-lint',
				-- debug adapters
				'debugpy', 'js-debug-adapter', 'delve', 'codelldb',
			},
			run_on_start = true,
		},
	},

	-- AI inline completion
	{
		'milanglacier/minuet-ai.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
	},

	-- Completion
	{ 'hrsh7th/nvim-cmp' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/cmp-path' },
	{
		'L3MON4D3/LuaSnip',
		version = "v2.*",
		build = "make install_jsregexp"
	},
	{ 'saadparwaiz1/cmp_luasnip' },
	{ 'onsails/lspkind.nvim' },

	-- Formatting & linting
	{ 'stevearc/conform.nvim' },
	{ 'mfussenegger/nvim-lint' },

	-- Debugger
	{ 'mfussenegger/nvim-dap' },
	{
		'rcarriga/nvim-dap-ui',
		dependencies = { 'nvim-neotest/nvim-nio' },
		opts = {},
		config = function(_, opts)
			local dapui = require('dapui')
			dapui.setup(opts)
			local dap = require('dap')
			dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
			dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
		end,
	},
	{
		'jay-babu/mason-nvim-dap.nvim',
		opts = { ensure_installed = { 'python', 'js', 'delve', 'codelldb' } },
	},
	{
		'mxsdev/nvim-dap-vscode-js',
		opts = { node_path = 'node', adapters = { 'pwa-node', 'pwa-chrome' } },
	},

	-- Go
	{
		'leoluz/nvim-dap-go',
		dependencies = { 'mfussenegger/nvim-dap' },
		ft = 'go',
		opts = {},
	},
	{
		'olexsmir/gopher.nvim',
		ft = 'go',
		build = ':GoInstallDeps',
		opts = {},
	},

	-- Rust
	{
		'Saecki/crates.nvim',
		event = 'BufRead Cargo.toml',
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {
			completion = {
				cmp = { enabled = true },
			},
		},
	},

	-- Testing
	{
		'nvim-neotest/neotest',
		lazy = true,
		dependencies = {
			'nvim-neotest/nvim-nio',
			'nvim-lua/plenary.nvim',
			'antoinemadec/FixCursorHold.nvim',
			'nvim-treesitter/nvim-treesitter',
			'fredrikaverpil/neotest-golang',
			'rouge8/neotest-rust',
		},
		config = function()
			require('neotest').setup({
				adapters = {
					require('neotest-golang')({
						args = { '-count=1', '-race' },
						recursive_run = true,
					}),
					require('neotest-rust')({}),
				},
			})
		end,
	},

	-- Database (SQL)
	{ 'tpope/vim-dadbod',                     lazy = true },
	{
		'kristijanhusak/vim-dadbod-ui',
		dependencies = { 'tpope/vim-dadbod' },
		cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_execute_on_save = false -- don't auto-execute on save, use <leader>S instead
			vim.g.db_ui_win_position = 'right'
		end,
	},
	{ 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },

	-- AI/LLMs
	{
		"olimorris/codecompanion.nvim",
		opts = {
			display = {
				chat = {
					window = {
						layout = "vertical", -- Options: "vertical", "horizontal", "float"
						position = "right", -- This moves it to the right side
						width = 0.3, -- Percentage of the screen (0.3 = 30%)
					},
				},
			},
			adapters = {
				http = {
					-- Groq cloud inference (OpenAI-compatible API)
					groq = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = "cmd:security find-generic-password -s GROQ_API_KEY -w",
							},
							name = "Groq",
							url = "https://api.groq.com/openai/v1/chat/completions",
							schema = {
								model = {
									default = "moonshotai/kimi-k2-instruct-0905",
								},
							},
							handlers = {
								-- Groq doesn't accept 'id' or 'opts' fields in messages
								form_messages = function(self, messages)
									for _, msg in ipairs(messages) do
										msg.id = nil
										msg.opts = nil
										if msg.name then
											msg.name = tostring(msg.name)
										else
											msg.name = nil
										end
										local supported = { role = true, content = true, name = true }
										for prop in pairs(msg) do
											if not supported[prop] then
												msg[prop] = nil
											end
										end
									end
									return { messages = messages }
								end,
							},
						})
					end,
					-- LM Studio local models (OpenAI-compatible API on localhost:1234)
					lmstudio = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							env = {
								url = "http://localhost:1234",
								api_key = "lm-studio",
							},
							schema = {
								model = {
									default = "qwen/qwen3-4b-2507",
								},
							},
						})
					end,
				},
				acp = {
					claude_code = function()
						return require("codecompanion.adapters").extend("claude_code", {
							env = {
								CLAUDE_CODE_OAUTH_TOKEN =
								"REDACTED"
							},
							commands = {
								default = { vim.fn.expand("~/.local/bin/claude-agent-acp-wrapper") },
								yolo = { vim.fn.expand("~/.local/bin/claude-agent-acp-wrapper"), "--yolo" },
							},
						})
					end,
				},
			},
			strategies = {
				chat = {
					adapter = {
						name = "claude_code",
						model = "opus",
					},
				},
				inline = {
					adapter = "groq",
				},
				cmd = {
					adapter = "groq",
				},
			},
			opts = {
				log_level = "DEBUG",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/mcphub.nvim",
		},
		extensions = {
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_vars = true,
					make_slash_commands = true,
					show_result_in_chat = true
				}
			}
		}
	},

	-- Obsidian.nvim – note-taking inside Neovim with Obsidian vaults
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			workspaces = {
				{
					name = "personal",
					path = "~/Documents/obsidian-vaults/personal",
				},
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			new_notes_location = "current_dir",
			preferred_link_style = "wiki",
			ui = {
				enable = true,
				checkboxes = {
					[" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
					["x"] = { char = "", hl_group = "ObsidianDone" },
				},
			},
		},
	},

}, {
	checker = { enabled = false },
})

-- 3) Colorscheme
vim.cmd.colorscheme('moonfly')
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "#121212", fg = "#555555" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e", fg = "#cdd6f4" })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1e1e2e", fg = "#89b4fa" })
	end,
})
-- 4) Keymaps — spec lives in lua/keymaps.lua (registered via which-key plugin config).

-- Go-specific keymaps (buffer-local via which-key, only active in Go files)
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'go',
	callback = function(args)
		require('which-key').add({
			buffer = args.buf,
			-- Go code generation (gopher.nvim) — under LSP group
			{ "<leader>lj", "<CMD>GoTagAdd json<CR>",                           desc = "Add json tags" },
			{ "<leader>ly", "<CMD>GoTagAdd yaml<CR>",                           desc = "Add yaml tags" },
			{ "<leader>lJ", "<CMD>GoTagRm json<CR>",                            desc = "Remove json tags" },
			{ "<leader>le", "<CMD>GoIfErr<CR>",                                 desc = "Insert if err" },
			{ "<leader>li", "<CMD>GoImpl<CR>",                                  desc = "Implement interface" },
			{ "<leader>lG", "<CMD>GoGenerate<CR>",                              desc = "Go generate" },
			{ "<leader>lc", "<CMD>GoCmt<CR>",                                   desc = "Generate doc comment" },
			-- Go test generation (gopher.nvim) — under Test group
			{ "<leader>nT", "<CMD>GoTestAdd<CR>",                               desc = "Generate test for func" },
			{ "<leader>nA", "<CMD>GoTestsAll<CR>",                              desc = "Generate all tests" },
			{ "<leader>nE", "<CMD>GoTestsExp<CR>",                              desc = "Generate exported tests" },
			-- Debug Go test (nvim-dap-go) — under Debug group
			{ "<leader>dg", function() require('dap-go').debug_test() end,      desc = "Debug Go test" },
			{ "<leader>dG", function() require('dap-go').debug_last_test() end, desc = "Debug last Go test" },
		})
	end,
})

-- Cargo.toml-specific keymaps (crates.nvim)
vim.api.nvim_create_autocmd('BufRead', {
	pattern = 'Cargo.toml',
	callback = function(args)
		local crates = require('crates')
		require('which-key').add({
			buffer = args.buf,
			{ "<leader>R",  group = "Crates" },
			{ "<leader>Ri", crates.show_popup,              desc = "Crate info" },
			{ "<leader>Rv", crates.show_versions_popup,     desc = "Versions" },
			{ "<leader>Rf", crates.show_features_popup,     desc = "Features" },
			{ "<leader>Rd", crates.show_dependencies_popup, desc = "Dependencies" },
			{ "<leader>Ru", crates.update_crate,            desc = "Update crate" },
			{ "<leader>RU", crates.upgrade_crate,           desc = "Upgrade crate" },
			{ "<leader>Ra", crates.update_all_crates,       desc = "Update all" },
			{ "<leader>RA", crates.upgrade_all_crates,      desc = "Upgrade all" },
			{ "<leader>RH", crates.open_homepage,           desc = "Open homepage" },
			{ "<leader>RR", crates.open_repository,         desc = "Open repo" },
		})
	end,
})

-- 5) Completion (cmp)
local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')
require('cmp').setup({
	snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then cmp.select_prev_item() elseif luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end
		end, { 'i', 's' }),
	}),
	sources = cmp.config.sources({
		{ name = 'minuet' },
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' }, -- FIX: was missing despite cmp_luasnip being installed
		{ name = 'path' },
		{ name = 'buffer' },
	}),
	formatting = { format = lspkind.cmp_format({ mode = 'symbol_text', maxwidth = 50 }) },
})

-- Add obsidian cmp source for markdown files
cmp.setup.filetype('markdown', {
	sources = cmp.config.sources({
		{ name = 'obsidian' },
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'path' },
		{ name = 'buffer' },
	}),
})

-- Minuet AI inline completion (Groq + llama-3.3-70b)
require('minuet').setup({
	provider = 'openai_compatible',
	throttle = 1000,
	debounce = 500,
	n_completions = 1,
	provider_options = {
		openai_compatible = {
			api_key = function()
				return vim.fn.system('security find-generic-password -s GROQ_API_KEY -w'):gsub('%s+$',
					'')
			end,
			end_point = 'https://api.groq.com/openai/v1/chat/completions',
			model = 'llama-3.3-70b-versatile',
			name = 'Groq',
			stream = true,
			optional = {
				max_tokens = 256,
				top_p = 0.9,
			},
		},
	},
	virtualtext = {
		auto_trigger_ft = {}, -- disable auto-trigger, use manual keybind
		keymap = {
			accept = '<A-A>',
			accept_line = '<A-a>',
			accept_n_lines = '<A-z>',
			next = '<A-j>',
			prev = '<A-k>',
			dismiss = '<A-e>',
		},
	},
})

-- SQL completion via dadbod
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'sql', 'mysql', 'plsql' },
	callback = function()
		cmp.setup.buffer({
			sources = cmp.config.sources({
				{ name = 'vim-dadbod-completion' },
				{ name = 'buffer' },
			}),
		})
	end,
})

-- 6) LSP servers (Neovim 0.11+ native vim.lsp.config API)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Global defaults for all servers
vim.lsp.config('*', {
	capabilities = capabilities,
})

-- Python: Ruff for linting/formatting, Pyright for typing
vim.lsp.config('ruff', {
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root = vim.fs.root(fname, { 'pyproject.toml', 'ruff.toml', '.ruff.toml' })
		if root then
			on_dir(root)
		end
	end,
})
vim.lsp.config('pyright', {
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root = vim.fs.root(fname, { 'pyproject.toml', 'pyrightconfig.json' })
		if root then
			on_dir(root)
		end
	end,
})

-- TypeScript/JavaScript
vim.lsp.config('ts_ls', {})

-- JSON / YAML / Bash
vim.lsp.config('jsonls', {})
vim.lsp.config('yamlls', {})
vim.lsp.config('bashls', {})

-- Lua (Neovim config editing — lazydev.nvim provides vim.* completions)
vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

-- Go
vim.lsp.config('gopls', {
	settings = {
		gopls = {
			gofumpt = true,
			analyses = {
				unusedparams = true,
				shadow = true,
				nilness = true,
				unusedwrite = true,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
})

-- Rust
vim.lsp.config('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
			check = {
				command = 'clippy',
			},
			cargo = {
				allFeatures = true,
			},
		},
	},
})

-- Enable all configured servers
vim.lsp.enable({ 'ruff', 'pyright', 'ts_ls', 'jsonls', 'yamlls', 'bashls', 'lua_ls', 'gopls', 'rust_analyzer' })

-- LSP keymaps (buffer-local, set on attach)
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local bufnr = args.buf
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end
		map('n', 'gd', vim.lsp.buf.definition, 'Goto Def')
		map('n', 'gr', vim.lsp.buf.references, 'Refs')
		map('n', 'gi', vim.lsp.buf.implementation, 'Impl')
		map('n', 'K', function()
			vim.lsp.buf.hover({ border = 'rounded' })
		end, 'Hover')
		map('n', '<leader>lf', function() require('conform').format({ async = true, lsp_fallback = true }) end, 'Format')
	end,
})

-- 7) Format on save via conform
local function biome_or_prettier(bufnr)
	if vim.fs.find({ 'biome.json', 'biome.jsonc' }, { upward = true, path = vim.api.nvim_buf_get_name(bufnr) })[1] then
		return { 'biome' }
	end
	return { 'prettier' }
end

require('conform').setup({
	formatters_by_ft = {
		python = { 'ruff_fix', 'ruff_format' },
		javascript = biome_or_prettier,
		typescript = biome_or_prettier,
		javascriptreact = biome_or_prettier,
		typescriptreact = biome_or_prettier,
		json = biome_or_prettier,
		yaml = { 'prettier' },
		markdown = { 'prettier' },
		go = { 'goimports-reviser', 'gofumpt' },
		rust = { 'rustfmt' },
		sh = { 'shfmt' },
		sql = { 'sqruff' },
		mysql = { 'sqruff' },
		plsql = { 'sqruff' },
	},
	formatters = {
		sqruff = {
			prepend_args = { '--dialect', 'postgres' },
		},
	},
})
vim.api.nvim_create_autocmd('BufWritePre',
	{
		pattern = '*',
		callback = function() require('conform').format({ async = false, lsp_fallback = true }) end
	}
)

-- 8) Linting via nvim-lint (eslint_d for JS/TS — no ESLint LSP to avoid double diagnostics)
local lint = require('lint')
lint.linters_by_ft = {
	python = { 'ruff' },
	javascript = { 'eslint_d' },
	typescript = { 'eslint_d' },
	javascriptreact = { 'eslint_d' },
	typescriptreact = { 'eslint_d' },
	go = { 'golangcilint' },
	sql = { 'sqruff' },
	mysql = { 'sqruff' },
	plsql = { 'sqruff' },
}
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
	callback = function() require('lint').try_lint() end,
})

-- 9) DAP configurations
local dap = require('dap')

-- JS/TS DAP configurations
for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
	dap.configurations[language] = {
		{
			type = 'pwa-node', request = 'launch', name = 'Launch file', program = '${file}', cwd = '${workspaceFolder}'
		},
		{ type = 'pwa-node', request = 'attach', name = 'Attach', processId = require('dap.utils').pick_process, cwd = '${workspaceFolder}' },
	}
end

-- Python DAP configuration
dap.adapters.python = function(cb, config)
	if config.request == 'attach' and config.connect then
		-- Attach mode: connect directly to the debugpy server (no adapter middleware)
		cb({
			type = 'server',
			host = config.connect.host or '127.0.0.1',
			port = config.connect.port,
		})
	else
		-- Launch mode: start debugpy adapter via stdio
		local debugpy_python = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
		cb({
			type = 'executable',
			command = debugpy_python,
			args = { '-m', 'debugpy.adapter' },
		})
	end
end
dap.adapters.debugpy = dap.adapters.python
dap.configurations.python = {
	{
		type = 'python',
		request = 'launch',
		name = 'Launch file',
		program = '${file}',
		cwd = '${workspaceFolder}',
		console = 'integratedTerminal',
	},
}

-- Rust DAP configuration (codelldb via Mason)
local codelldb_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb'
local liblldb_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib'
dap.adapters.codelldb = {
	type = 'server',
	port = '${port}',
	executable = {
		command = codelldb_path,
		args = { '--port', '${port}' },
	},
}
dap.configurations.rust = {
	{
		type = 'codelldb',
		request = 'launch',
		name = 'Launch',
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
	},
}

-- 10) Command abbreviation: type :cc instead of :CodeCompanion
vim.cmd([[cab cc CodeCompanion]])

-- End of file
