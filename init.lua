-- basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- user options (adapted/frankensteined from Kickstart.nvim)
vim.o.number = true
--vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.swapfile = true
vim.o.expandtab = true
vim.o.winborder = "rounded"
vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
end) -- sync nvim and OS clipboard

vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
-- Decrease update time
vim.o.updatetime = 250
-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
vim.spell.set = { 'en_us', 'pt_br' }

-- netrw explorer settings
vim.g.netrw_bufsettings = 'noma nomod nu nowrap ro nobl'
vim.g.netrw_banner = 0

-- lsp config
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
    end,
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})
vim.lsp.enable({
    "lua_ls",
    "basedpyright",
    "r",
    "clangd",
    "css-lsp",
    "glow",
    "harper-ls",
    "html-lsp",
    "julia-lsp",
    "ltex-ls-plus",
    "lua-language-server",
})

-- plugins
vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/lervag/vimtex' },
    { src = 'https://github.com/nvim-mini/mini.diff' },
    { src = 'https://github.com/nvim-mini/mini.notify' },
    { src = 'https://github.com/nvim-mini/mini.pick' },
    { src = 'https://github.com/nvim-mini/mini.icons' },
    { src = 'https://github.com/nvim-mini/mini.starter' },
    { src = 'https://github.com/nvim-mini/mini.statusline' },
    { src = 'https://github.com/nvim-mini/mini.pairs' },
    { src = 'https://github.com/nvim-mini/mini.surround' },
    { src = 'https://github.com/nvim-mini/mini.snippets' }
    --    {src = ''},
    --    {src = ''},
})

require 'mason'.setup {}
require 'nvim-treesitter.config'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "julia", "latex", "css", "r", "ruby", "html" },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
require 'mini.diff'.setup{}
require 'mini.notify'.setup{}
require 'mini.pick'.setup{}
require 'mini.icons'.setup{}
require 'mini.starter'.setup{}
require 'mini.statusline'.setup{}
require 'mini.pairs'.setup{
    mappings = {
        ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].' },
        ['>'] = { action = 'close', pair = '<>', neigh_pattern = '[^\\].' },
    },
}
require 'mini.surround'.setup{}
require 'mini.snippets'.setup{}


-- keymapping
vim.keymap.set('n', '<leader>w', ':write<CR>')              -- save
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>') -- save + shoutout file
vim.keymap.set('n', '<leader>q', ':quit<CR>')               -- quit
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)       --select language format
vim.keymap.set('n', '<leader>e', ':Lexplore<CR>')           -- file explorer
vim.keymap.set('n', '<leader>nt', ':tabNext<CR>')           -- next tab
vim.keymap.set('n', '<leader>t', ':tabnew<CR>')             -- create new tab
vim.keymap.set('n', '<leader>bt', ':tabprevious<CR>')       -- create new tab
vim.keymap.set('n', '<leader>b', ':ls<CR>')                 -- show buffers
vim.keymap.set('n', '<leader>ba', ':ls a<CR>')              -- show active buffers
vim.keymap.set('n', '<leader>m', ':map<CR>')                -- show list of mappings
vim.keymap.set('i', '<C-c>', '<C-x><C-o>')                  -- omnicompletion (native)
vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
