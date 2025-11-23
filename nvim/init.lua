-- Neovim IDE Baseline (Python + TypeScript)
-- Single-file init.lua aimed at stability and sane defaults.
-- Features: file viewer, LSP, treesitter, completion, formatters, linters, debugger, Telescope search,
-- Git integration, and AI chat (multi-LLM via Continue.nvim; optional CodeCompanion).
--
-- Prereqs (system): ripgrep, node>=18, npm, python3-venv/pipx, git
-- Recommended global tools: `pipx install ruff debugpy` | `npm i -g typescript typescript-language-server eslint_d prettier`
-- Set API keys via env vars: OPENAI_API_KEY, ANTHROPIC_API_KEY (optional), OPENROUTER_API_KEY (optional)

-- 0) Basic options
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400
vim.opt.swapfile = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.scrolloff = 5
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.list = true
vim.opt.listchars = {
  space = "·",   -- visible spaces
  tab = "→ ",    -- visible tabs
  trail = "$",   -- trailing spaces
  extends = ">", -- lines too long
  precedes = "<" -- lines that continue left
}
vim.g.codecompanion_adapter = "azure_openai"

-- 1) Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 2) Plugins
require('lazy').setup({
  -- UI / UX
  { 'echasnovski/mini.nvim', version = '*' },
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'folke/which-key.nvim', opts = {} },

  -- File explorer
  { 'nvim-neo-tree/neo-tree.nvim', branch = 'v3.x', dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' } },

  -- Git
  { 'lewis6991/gitsigns.nvim', opts = {} },
  { 'NeogitOrg/neogit', dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' } },

  -- Telescope (code search, files, symbols)
  { 'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope-live-grep-args.nvim' },

  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

  -- LSP + tooling
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim', build = ':MasonUpdate' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim' },

  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  {
    'L3MON4D3/LuaSnip',
     version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
     build = "make install_jsregexp"
  },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'onsails/lspkind.nvim' },

  -- Formatting & linting
  { 'stevearc/conform.nvim' },
  { 'mfussenegger/nvim-lint' },

  -- Debugger
  { 'mfussenegger/nvim-dap' },
  { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
  { 'jay-babu/mason-nvim-dap.nvim' },
  { 'mxsdev/nvim-dap-vscode-js' },

  -- AI/LLMs
  {
    "olimorris/codecompanion.nvim",
    opts = {

    adapters = {
        azure_openai = function()
          return require("codecompanion.adapters").extend("azure_openai", {
            env = {
              api_key = os.getenv("AZURE_OPENAI_API_KEY"),
              endpoint = os.getenv("AZURE_OPENAI_ENDPOINT"),
              api_version = "2025-04-01-preview",
            },
            schema = {
                model = {
                    default = "gpt-5-mini-devel",
                    choices = {
                        "gpt-5-mini-devel",
                    },
                },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "azure_openai",
        },
        inline = {
          adapter = "azure_openai",
        },
        cmd = {
          adapter = "azure_openai",
        },
      },
      opts = {
        -- Set debug logging
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

}, {
  checker = { enabled = false },
})

-- 3) Colorscheme & statusline
vim.cmd.colorscheme('tokyonight')
require('lualine').setup({ options = { theme = 'auto' } })

-- 4) which-key hints
local wk = require('which-key')
wk.add({
    { "<leader>a", group = "AI" },
    { "<leader>aa", function() require('codecompanion').toggle() end, desc = "Toggle LLMs" },
    { "<leader>d", group = "Debug" },
    { "<leader>db", function() require('dap').toggle() end, desc = "Toggle BP" },
    { "<leader>dc", function() require('dap').continue() end, desc = "Continue" },
    { "<leader>di", function() require('dap').step_into() end, desc = "Step Into" },
    { "<leader>do", function() require('dap').step_over() end, desc = "Step Over" },
    { "<leader>du", function() require('dapui').toggle() end, desc = "DAP UI" },
    { "<leader>e",  function() vim.cmd('Neotree toggle') end, desc = "Explorer" },
    { "<leader>f", group = "Find" },
    { "<leader>ff", function() require('telescope.builtin').find_files() end, desc = "Files" },
    { "<leader>fb", function() require('telescope.builtin').buffers() end, desc = "Buffers" },
    { "<leader>fg", function() require('telescope').extensions.live_grep_args.live_grep_args() end, desc = "Grep" },
    { "<leader>fs", function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, desc = "Symbols" },
    { "<leader>g", group = "Git" },
    { "<leader>gd", function() require('diffview').open() end, desc = "DiffView" },
    { "<leader>gg", function() require('neogit').open({ kind = 'vsplit' }) end, desc = "Neogit" },
    { "<leader>l", group = "LSP" },
    { "<leader>lf", function() require('conform').format({ async = true, lsp_fallback = true }) end, desc = "Format" },
    { "<leader>la", function() vim.lsp.buf.code_action() end,  desc = "Code Action" },
    { "<leader>lr", function() vim.lsp.buf.rename() end, desc = "Rename" },
})

-- 5) Telescope setup
local telescope = require('telescope')
telescope.setup({ defaults = { mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } } } })
telescope.load_extension('fzf')
telescope.load_extension('live_grep_args')

-- 6) Treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'vim', 'vimdoc', 'query', 'python', 'javascript', 'typescript', 'tsx', 'json', 'yaml', 'bash', 'markdown' },
  highlight = { enable = true },
  indent = { enable = true },
})

-- 7) Mason: LSP, DAP, and external tools
require('mason').setup()
require('mason-lspconfig').setup({ ensure_installed = { 'pyright', 'ruff', 'ts_ls', 'eslint', 'bashls', 'jsonls', 'yamlls' } })
require('mason-tool-installer').setup({
  ensure_installed = {
    -- linters/formatters
    'ruff', 'prettier', 'eslint_d',
    -- debug adapters
    'debugpy', 'js-debug-adapter',
  },
  run_on_start = true,
})

-- 8) Completion (cmp)
local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')
require('cmp').setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item() elseif luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'path' }, { name = 'buffer' } }),
  formatting = { format = lspkind.cmp_format({ mode = 'symbol_text', maxwidth = 50 }) },
})

-- 9) LSP servers
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Python: Ruff for linting/formatting, Pyright for typing
lspconfig.ruff.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities })

-- TypeScript/JavaScript
lspconfig.ts_ls.setup({ capabilities = capabilities })

-- JSON / YAML / Bash
lspconfig.jsonls.setup({ capabilities = capabilities })
lspconfig.yamlls.setup({ capabilities = capabilities })
lspconfig.bashls.setup({ capabilities = capabilities })

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map('n', 'gd', vim.lsp.buf.definition, 'Goto Def')
    map('n', 'gr', vim.lsp.buf.references, 'Refs')
    map('n', 'gi', vim.lsp.buf.implementation, 'Impl')
    map('n', 'K', vim.lsp.buf.hover, 'Hover')
    map('n', '<leader>lf', function() require('conform').format({ async = true, lsp_fallback = true }) end, 'Format')
  end,
})

-- 10) Format on save via conform
require('conform').setup({
  formatters_by_ft = {
    python = { 'ruff_fix', 'ruff_format' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    sh = { 'shfmt' },
  },
})
vim.api.nvim_create_autocmd('BufWritePre', { pattern = '*', callback = function() require('conform').format({ async = false, lsp_fallback = true }) end })

-- 11) Linting via nvim-lint
local lint = require('lint')
lint.linters_by_ft = {
  python = { 'ruff' },
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
}
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  callback = function() require('lint').try_lint() end,
})

-- 12) Git signs
require('gitsigns').setup()

-- 13) Debugging (DAP)
require('mason-nvim-dap').setup({ ensure_installed = { 'python', 'js' } })
local dap = require('dap')
local dapui = require('dapui')

-- JS/TS: vscode-js via nvim-dap-vscode-js
require('dap-vscode-js').setup({ node_path = 'node', adapters = { 'pwa-node', 'pwa-chrome' } })
for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
  dap.configurations[language] = {
    {
      type = 'pwa-node', request = 'launch', name = 'Launch file', program = '${file}', cwd = '${workspaceFolder}'
    },
    { type = 'pwa-node', request = 'attach', name = 'Attach', processId = require('dap.utils').pick_process, cwd = '${workspaceFolder}' },
  }
end

-- Python
require('dapui').setup()
dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end

-- 14) Neo-tree
require('neo-tree').setup({ close_if_last_window = true, filesystem = { filtered_items = { hide_gitignored = false } } })

-- 16) Small quality-of-life maps
vim.keymap.set('n', '<leader>\n', function() vim.cmd('noh') end, { desc = 'No highlight' })
vim.keymap.set('n', '<leader>qq', function() vim.cmd('qa') end, { desc = 'Quit all' })

-- End of file
