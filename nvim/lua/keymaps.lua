-- Global leader keymaps (registered via which-key).
-- Reload live with :Lazy reload which-key.nvim (new/changed keymaps only;
-- deleted keymaps persist until nvim restart).
return {
	-- AI
	{ "<leader>a",  group = "AI" },
	{ "<leader>aa", function() require('codecompanion').toggle() end,           desc = "Toggle chat" },
	{ "<leader>ac", function() vim.cmd('CodeCompanionActions') end,             desc = "Actions menu" },
	{ "<leader>ac", function() vim.cmd('CodeCompanionActions') end,             desc = "Actions menu",          mode = "v" },
	{ "<leader>ai", ":'<,'>CodeCompanion ",                                     desc = "Inline prompt",         mode = "v" },
	{ "<leader>av", function() vim.cmd('CodeCompanionChat Add') end,            desc = "Add selection to chat", mode = "v" },
	{ "<leader>ae", function() require('codecompanion').prompt('explain') end,  desc = "Explain code",          mode = "v" },
	{ "<leader>af", function() require('codecompanion').prompt('fix') end,      desc = "Fix code",              mode = "v" },
	{ "<leader>at", function() require('codecompanion').prompt('tests') end,    desc = "Generate tests",        mode = "v" },
	{ "<leader>al", function() require('codecompanion').prompt('lsp') end,      desc = "Explain LSP diagnostic" },
	{ "<leader>am", function() require('codecompanion').prompt('commit') end,   desc = "Commit message" },

	-- Buffers
	{ "<leader>b",  group = "Buffer" },
	{ "<leader>bb", function() require('telescope.builtin').buffers() end,      desc = "List buffers" },
	{ "<leader>bd", function() vim.cmd('bdelete') end,                          desc = "Close buffer" },
	{ "<leader>br", function() vim.cmd('edit') end,                             desc = "Reload buffer" },

	-- Debug
	{ "<leader>d",  group = "Debug" },
	{ "<leader>db", function() require('dap').toggle_breakpoint() end,          desc = "Toggle BP" },
	{ "<leader>dc", function() require('dap').continue() end,                   desc = "Continue" },
	{ "<leader>di", function() require('dap').step_into() end,                  desc = "Step Into" },
	{ "<leader>do", function() require('dap').step_over() end,                  desc = "Step Over" },
	{ "<leader>dO", function() require('dap').step_out() end,                   desc = "Step Out" },
	{ "<leader>dr", function() require('dap').run_to_cursor() end,              desc = "Run to cursor" },
	{ "<leader>dt", function() require('dap').terminate() end,                  desc = "Terminate" },
	{ "<leader>de", function() require('dapui').eval() end,                     desc = "Eval expression" },
	{ "<leader>de", function() require('dapui').eval() end,                     desc = "Eval selection",        mode = "v" },
	{ "<leader>du", function() require('dapui').toggle() end,                   desc = "DAP UI" },

	-- Explore
	{ "<leader>e",  group = "Explore" },
	{ "<leader>ee", function() vim.cmd('Neotree toggle') end,                   desc = "Neotree Toggle" },
	{ "<leader>er", function() vim.cmd('Neotree reveal') end,                   desc = "Neotree Reveal file" },
	{ "<leader>eb", function() vim.cmd('Neotree toggle source=buffers') end,    desc = "Neotree Buffers" },
	{ "<leader>eg", function() vim.cmd('Neotree toggle source=git_status') end, desc = "Neotree Git status" },

	-- Tabs
	{ "<leader>t",  group = "Tab" },
	{ "<leader>tc", function() vim.cmd('tabnew') end,                           desc = "New tab" },
	{ "<leader>tx", function() vim.cmd('tabclose') end,                         desc = "Close tab" },
	{ "<leader>to", function() vim.cmd('tabonly') end,                          desc = "Close other tabs" },
	{ "<leader>t1", "1gt",                                                      desc = "Tab 1" },
	{ "<leader>t2", "2gt",                                                      desc = "Tab 2" },
	{ "<leader>t3", "3gt",                                                      desc = "Tab 3" },
	{ "<leader>t4", "4gt",                                                      desc = "Tab 4" },
	{ "<leader>t5", "5gt",                                                      desc = "Tab 5" },
	{
		"<leader>tr",
		function()
			vim.ui.input({ prompt = "Tab name: " }, function(name)
				if name and name ~= "" then
					vim.api.nvim_tabpage_set_var(0, "tab_name", name)
					vim.cmd("redrawtabline")
				end
			end)
		end,
		desc = "Rename tab",
	},

	-- Find (Telescope)
	{ "<leader>f",  group = "Find" },
	{ "<leader>ff", function() require('telescope.builtin').find_files() end,                       desc = "Files" },
	{ "<leader>fb", function() require('telescope.builtin').buffers() end,                          desc = "Buffers" },
	{ "<leader>fg", function() require('telescope').extensions.live_grep_args.live_grep_args() end, desc = "Grep" },
	{ "<leader>fs", function() require('telescope.builtin').lsp_workspace_symbols() end,            desc = "Symbols" },
	{ "<leader>fr", function() require('telescope.builtin').oldfiles() end,                         desc = "Recent files" },
	{ "<leader>fh", function() require('telescope.builtin').help_tags() end,                        desc = "Help tags" },
	{ "<leader>fk", function() require('telescope.builtin').keymaps() end,                          desc = "Keymaps" },
	{ "<leader>fd", function() require('telescope.builtin').diagnostics() end,                      desc = "Diagnostics" },
	{ "<leader>fc", function() require('telescope.builtin').git_commits() end,                      desc = "Git commits" },
	{ "<leader>fB", function() require('telescope.builtin').git_branches() end,                     desc = "Git branches" },
	{ "<leader>f.", function() require('telescope.builtin').resume() end,                           desc = "Resume last" },

	-- Git
	{ "<leader>g",  group = "Git" },
	{ "<leader>gb", function() require('gitsigns').blame_line({ full = true }) end,                 desc = "Blame line" },
	{ "<leader>gB", function() require('gitsigns').toggle_current_line_blame() end,                 desc = "Toggle inline blame" },
	{
		"<leader>gd",
		function()
			local ok, lib = pcall(require, 'diffview.lib')
			if ok and #lib.views > 0 then vim.cmd('DiffviewClose') else vim.cmd('DiffviewOpen') end
		end,
		desc = "DiffView toggle"
	},
	{ "<leader>gg",  function() require('neogit').open() end,               desc = "Neogit" },
	{ "<leader>gl",  function() vim.cmd('LazyGit') end,                     desc = "LazyGit" },
	{ "<leader>gL",  function() require('neogit').open({ 'log' }) end,      desc = "Log" },
	{ "<leader>gh",  function() vim.cmd('DiffviewFileHistory %') end,       desc = "File history" },
	{ "<leader>gH",  function() vim.cmd('DiffviewFileHistory') end,         desc = "Repo history" },
	{ "<leader>gp",  function() require('gitsigns').preview_hunk() end,     desc = "Preview hunk" },
	{ "<leader>gs",  function() require('gitsigns').stage_hunk() end,       desc = "Stage hunk" },
	{ "<leader>gu",  function() require('gitsigns').undo_stage_hunk() end,  desc = "Undo stage hunk" },
	{ "<leader>gr",  function() require('gitsigns').reset_hunk() end,       desc = "Reset hunk" },
	{ "<leader>gS",  function() require('gitsigns').stage_buffer() end,     desc = "Stage buffer" },
	{ "<leader>gR",  function() require('gitsigns').reset_buffer() end,     desc = "Reset buffer" },
	{ "<leader>gw",  group = "Worktree" },
	{ "<leader>gws", "<CMD>Telescope git_worktree git_worktrees<CR>",       desc = "Switch worktree" },
	{ "<leader>gwc", "<CMD>Telescope git_worktree create_git_worktree<CR>", desc = "Create worktree" },
	{ "]c",          function() require('gitsigns').nav_hunk('next') end,   desc = "Next hunk" },
	{ "[c",          function() require('gitsigns').nav_hunk('prev') end,   desc = "Prev hunk" },

	-- Github
	{ "<leader>G",   group = "GitHub" },
	{
		{
			"<leader>Gi",
			"<CMD>Octo issue list<CR>",
			desc = "List GitHub Issues",
		},
		{
			"<leader>Gp",
			"<CMD>Octo pr list<CR>",
			desc = "List GitHub PullRequests",
		},
		{
			"<leader>Gd",
			"<CMD>Octo discussion list<CR>",
			desc = "List GitHub Discussions",
		},
		{
			"<leader>Gn",
			"<CMD>Octo notification list<CR>",
			desc = "List GitHub Notifications",
		},
		{
			"<leader>Gs",
			function()
				require("octo.utils").create_base_search_command { include_current_repo = true }
			end,
			desc = "Search GitHub",
		},
		{
			"<leader>Gr",
			"<CMD>Octo pr reload<CR>",
			desc = "Reload PR",
		},
	},


	-- LSP
	{ "<leader>l",     group = "LSP" },
	{ "<leader>lf",    function() require('conform').format({ async = true, lsp_fallback = true }) end,         desc = "Format" },
	{ "<leader>la",    function() vim.lsp.buf.code_action() end,                                                desc = "Code Action" },
	{ "<leader>lr",    function() vim.lsp.buf.rename() end,                                                     desc = "Rename" },
	{ "<leader>lt",    function() vim.lsp.buf.type_definition() end,                                            desc = "Type definition" },
	{ "<leader>ls",    function() require('telescope.builtin').lsp_document_symbols() end,                      desc = "Document symbols" },
	{ "<leader>lk",    function() vim.lsp.buf.signature_help() end,                                             desc = "Signature help" },

	-- Diagnostics
	{ "<leader>ld",    vim.diagnostic.open_float,                                                               desc = "Diagnostics float" },
	{ "]d",            function() vim.diagnostic.goto_next() end,                                               desc = "Next diagnostic" },
	{ "[d",            function() vim.diagnostic.goto_prev() end,                                               desc = "Prev diagnostic" },

	-- Obsidian
	{ "<leader>o",     group = "Obsidian" },
	{ "<leader>oo",    "<cmd>ObsidianOpen<cr>",                                                                 desc = "Open in Obsidian" },
	{ "<leader>on",    "<cmd>ObsidianNew<cr>",                                                                  desc = "New note" },
	{ "<leader>os",    "<cmd>ObsidianSearch<cr>",                                                               desc = "Search vault" },
	{ "<leader>oq",    "<cmd>ObsidianQuickSwitch<cr>",                                                          desc = "Quick switch" },
	{ "<leader>ot",    "<cmd>ObsidianToday<cr>",                                                                desc = "Today's daily note" },
	{ "<leader>ob",    "<cmd>ObsidianBacklinks<cr>",                                                            desc = "Backlinks" },
	{ "<leader>ol",    "<cmd>ObsidianLink<cr>",                                                                 mode = "v",                      desc = "Link selection" },
	{ "<leader>or",    "<cmd>ObsidianRename<cr>",                                                               desc = "Rename note" },
	{ "<leader>oc",    "<cmd>ObsidianToggleCheckbox<cr>",                                                       desc = "Toggle checkbox" },
	{ "<leader>og",    "<cmd>ObsidianTags<cr>",                                                                 desc = "Search tags" },

	-- Database
	{ "<leader>D",     group = "Database" },
	{ "<leader>Du",    function() vim.cmd('DBUIToggle') end,                                                    desc = "Toggle DBUI" },
	{ "<leader>Da",    function() vim.cmd('DBUIAddConnection') end,                                             desc = "Add connection" },
	{ "<leader>Df",    function() vim.cmd('DBUIFindBuffer') end,                                                desc = "Find buffer" },
	{ "<leader>De",    "<Plug>(DBUI_ExecuteQuery)",                                                             mode = { "n", "v" },             desc = "Execute query" },
	{ "<leader>Ds",    "<Plug>(DBUI_SaveQuery)",                                                                desc = "Save query" },

	-- Windows
	{ "<leader>w",     group = "Window" },
	{ "<leader>wh",    "<C-w>h",                                                                                desc = "Move left" },
	{ "<leader>wj",    "<C-w>j",                                                                                desc = "Move down" },
	{ "<leader>wk",    "<C-w>k",                                                                                desc = "Move up" },
	{ "<leader>wl",    "<C-w>l",                                                                                desc = "Move right" },
	{ "<leader>wv",    function() vim.cmd('vsplit') end,                                                        desc = "Vertical split" },
	{ "<leader>ws",    function() vim.cmd('split') end,                                                         desc = "Horizontal split" },
	{ "<leader>wq",    function() vim.cmd('close') end,                                                         desc = "Close window" },
	{ "<leader>wo",    function() vim.cmd('only') end,                                                          desc = "Close other windows" },
	{ "<leader>w=",    function() vim.cmd('wincmd =') end,                                                      desc = "Equal width" },

	-- Copy
	{ "<leader>c",     group = "Copy" },
	{ "<leader>cp",    function() vim.fn.setreg('+', vim.fn.expand('%:p')) end,                                 desc = "Absolute path" },
	{ "<leader>cr",    function() vim.fn.setreg('+', vim.fn.expand('%:.')) end,                                 desc = "Relative path" },
	{ "<leader>cf",    function() vim.fn.setreg('+', vim.fn.expand('%:t')) end,                                 desc = "Filename" },
	{ "<leader>cd",    function() vim.fn.setreg('+', vim.fn.getcwd()) end,                                      desc = "Working directory" },
	{ "<leader>cb",    function() vim.fn.setreg('+', vim.trim(vim.fn.system('git branch --show-current'))) end, desc = "Git branch" },

	-- Tests (neotest)
	{ "<leader>n",     group = "Test" },
	{ "<leader>nn",    function() require('neotest').run.run() end,                                             desc = "Run nearest" },
	{ "<leader>nf",    function() require('neotest').run.run(vim.fn.expand('%')) end,                           desc = "Run file" },
	{ "<leader>nd",    function() require('neotest').run.run({ strategy = 'dap' }) end,                         desc = "Debug nearest" },
	{ "<leader>ns",    function() require('neotest').run.stop() end,                                            desc = "Stop" },
	{ "<leader>no",    function() require('neotest').output.open({ enter = true }) end,                         desc = "Output" },
	{ "<leader>nO",    function() require('neotest').output_panel.toggle() end,                                 desc = "Output panel" },
	{ "<leader>nS",    function() require('neotest').summary.toggle() end,                                      desc = "Summary" },

	-- Misc
	{ "<leader>qq",    function() vim.cmd('qa') end,                                                            desc = "Quit all" },
	{ "<leader><Esc>", function() vim.cmd('noh') end,                                                           desc = "No highlight" },
	{ "<leader>sa",    "ggVG",                                                                                  desc = "Select all" },
	{ "<leader>P",     function() vim.cmd('Lazy') end,                                                          desc = "Plugin manager" },
	{ "<leader>tn",    function() vim.o.relativenumber = not vim.o.relativenumber end,                          desc = "Toggle relative numbers" },
	{ "<leader>rm",    function() vim.cmd('RenderMarkdown toggle') end,                                         desc = "Toggle markdown render" },
	{
		"<leader>rg",
		function()
			if vim.bo.filetype ~= 'markdown' then
				vim.notify('Not a markdown buffer', vim.log.levels.WARN)
				return
			end
			local file = vim.fn.expand('%:p')
			if file == '' then
				vim.notify('Buffer has no file on disk', vim.log.levels.WARN)
				return
			end
			-- Save first so glow sees the latest content, and so relative
			-- paths (images, links) resolve against the file's real location.
			vim.cmd('write')
			vim.cmd('tabnew')
			vim.cmd('terminal glow -p ' .. vim.fn.fnameescape(file))
			vim.cmd('startinsert')
		end,
		desc = "Preview in glow",
	},
	{ "<leader>rr",    function() vim.cmd('Lazy reload which-key.nvim') end,                                    desc = "Reload keymaps" },

	-- Tab cycling
	{ "<A-Tab>",       function() vim.cmd('tabnext') end,                                                       desc = "Next tab" },
	{ "<A-S-Tab>",     function() vim.cmd('tabprevious') end,                                                   desc = "Prev tab" },

	-- Buffer cycling
	{ "<Tab>",         function() vim.cmd('bnext') end,                                                         desc = "Next buffer",            mode = "n" },
	{ "<S-Tab>",       function() vim.cmd('bprevious') end,                                                     desc = "Prev buffer",            mode = "n" },

	-- Window navigation (Ctrl+hjkl)
	{ "<C-h>",         "<C-w>h",                                                                                desc = "Move to left window" },
	{ "<C-j>",         "<C-w>j",                                                                                desc = "Move to below window" },
	{ "<C-k>",         "<C-w>k",                                                                                desc = "Move to above window" },
	{ "<C-l>",         "<C-w>l",                                                                                desc = "Move to right window" },

	-- Resize windows (Ctrl+arrows)
	{ "<C-Up>",        function() vim.cmd('resize +2') end,                                                     desc = "Increase height" },
	{ "<C-Down>",      function() vim.cmd('resize -2') end,                                                     desc = "Decrease height" },
	{ "<C-Left>",      function() vim.cmd('vertical resize -2') end,                                            desc = "Decrease width" },
	{ "<C-Right>",     function() vim.cmd('vertical resize +2') end,                                            desc = "Increase width" },
}
