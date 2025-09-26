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

local function activate_env(path)
    assert(vim.fn.has 'nvim-0.10' == 1, 'requires Nvim 0.10 or newer')
    local bufnr = vim.api.nvim_get_current_buf()
    local julials_clients = vim.lsp.get_clients { bufnr = bufnr, name = 'julials' }
    assert(
        #julials_clients > 0,
        'method julia/activateenvironment is not supported by any servers active on the current buffer'
    )
    local function _activate_env(environment)
        if environment then
            for _, julials_client in ipairs(julials_clients) do
                julials_client:notify('julia/activateenvironment', { envPath = environment })
            end
            vim.notify('Julia environment activated: \n`' .. environment .. '`', vim.log.levels.INFO)
        end
    end
    if path then
        path = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ':p'))
        local found_env = false
        for _, project_file in ipairs(root_files) do
            local file = vim.uv.fs_stat(vim.fs.joinpath(path, project_file))
            if file and file.type then
                found_env = true
                break
            end
        end
        if not found_env then
            vim.notify('Path is not a julia environment: \n`' .. path .. '`', vim.log.levels.WARN)
            return
        end
        _activate_env(path)
    else
        local depot_paths = vim.env.JULIA_DEPOT_PATH
            and vim.split(vim.env.JULIA_DEPOT_PATH, vim.fn.has 'win32' == 1 and ';' or ':')
            or { vim.fn.expand '~/.julia' }
        local environments = {}
        vim.list_extend(environments, vim.fs.find(root_files, { type = 'file', upward = true, limit = math.huge }))
        for _, depot_path in ipairs(depot_paths) do
            local depot_env = vim.fs.joinpath(vim.fs.normalize(depot_path), 'environments')
            vim.list_extend(
                environments,
                vim.fs.find(function(name, env_path)
                    return vim.tbl_contains(root_files, name) and string.sub(env_path, #depot_env + 1):match '^/[^/]*$'
                end, { path = depot_env, type = 'file', limit = math.huge })
            )
        end
        environments = vim.tbl_map(vim.fs.dirname, environments)
        vim.ui.select(environments, { prompt = 'Select a Julia environment' }, _activate_env)
    end
end

vim.lsp.config('julia-lsp', {
    cmd = { "julia", "--startup-file=no", "--history-file=no", "-e", '    # Load LanguageServer.jl: attempt to load from ~/.julia/environments/nvim-lspconfig\n    # with the regular load path as a fallback\n    ls_install_path = joinpath(\n        get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),\n        "environments", "nvim-lspconfig"\n    )\n    pushfirst!(LOAD_PATH, ls_install_path)\n    using LanguageServer\n    popfirst!(LOAD_PATH)\n    depot_path = get(ENV, "JULIA_DEPOT_PATH", "")\n    project_path = let\n        dirname(something(\n            ## 1. Finds an explicitly set project (JULIA_PROJECT)\n            Base.load_path_expand((\n                p = get(ENV, "JULIA_PROJECT", nothing);\n                p === nothing ? nothing : isempty(p) ? nothing : p\n            )),\n            ## 2. Look for a Project.toml file in the current working directory,\n            ##    or parent directories, with $HOME as an upper boundary\n            Base.current_project(),\n            ## 3. First entry in the load path\n            get(Base.load_path(), 1, nothing),\n            ## 4. Fallback to default global environment,\n            ##    this is more or less unreachable\n            Base.load_path_expand("@v#.#"),\n        ))\n    end\n    @info "Running language server" VERSION pwd() project_path depot_path\n    server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)\n    server.runlinter = true\n    run(server)\n  ' },
    filetypes = { 'julia' },
    on_attach = function(_, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, 'LspJuliaActivateEnv', activate_env, {
            desc = 'Activate a Julia environment',
            nargs = '?',
            complete = 'file',
        })
    end,
    root_markers = { 'Project.toml', 'JuliaProject.toml' }
})

local language_id_mapping = {
    bib = 'bibtex',
    pandoc = 'markdown',
    plaintex = 'tex',
    rnoweb = 'rsweave',
    rst = 'restructuredtext',
    tex = 'latex',
    text = 'plaintext',
}

vim.lsp.config('ltex-ls-plus', {
    cmd = { 'ltex-ls-plus' },
    filetypes = {
        'bib',
        'context',
        'gitcommit',
        'html',
        'markdown',
        'org',
        'pandoc',
        'plaintex',
        'quarto',
        'mail',
        'mdx',
        'rmd',
        'rnoweb',
        'rst',
        'tex',
        'text',
        'typst',
        'xhtml',
    },
    root_markers = { '.git' },
    get_language_id = function(_, filetype)
        return language_id_mapping[filetype] or filetype
    end,
    settings = {
        ltex = {
            enabled = {
                'bib',
                'context',
                'gitcommit',
                'html',
                'markdown',
                'org',
                'pandoc',
                'plaintex',
                'quarto',
                'mail',
                'mdx',
                'rmd',
                'rnoweb',
                'rst',
                'tex',
                'latex',
                'text',
                'typst',
                'xhtml',
            },
        },
    },
})


vim.lsp.enable({
    "lua_ls",
    "basedpyright",
    "clangd",
    "julia-lsp",
    "ltex-ls-plus",
})

-- plugins
vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
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
require 'mini.diff'.setup {}
require 'mini.notify'.setup {}
require 'mini.pick'.setup {}
require 'mini.icons'.setup {}
require 'mini.starter'.setup {}
require 'mini.statusline'.setup {}
require 'mini.pairs'.setup {
    mappings = {
        ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].' },
        ['>'] = { action = 'close', pair = '<>', neigh_pattern = '[^\\].' },
    },
}
require 'mini.surround'.setup {}
require 'mini.snippets'.setup {}


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
