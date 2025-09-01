-- basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- user options (adapted/frankensteined from Kickstart.nvim)
vim.o.number = true
vim.o.relativenumber = true
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
vim.spell.set = {'en_us', 'pt_br'}

-- keymapping
vim.keymap.set('n', '<leader>w', ':write<CR>') -- save
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>') -- save + shoutout file
vim.keymap.set('n', '<leader>q', ':quit<CR>') -- quit
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format) --select language format
vim.keymap.set('n', '<leader>e', ':Lexplore<CR>') -- file explorer
vim.keymap.set('n', '<leader>nt', ':tabNext<CR>') -- next tab
vim.keymap.set('n', '<leader>t', ':tabnew<CR>') -- create new tab
vim.keymap.set('n', '<leader>bt', ':tabprevious<CR>') -- create new tab
vim.keymap.set('n', '<leader>b', ':ls<CR>') -- show buffers
vim.keymap.set('n', '<leader>ba', ':ls a<CR>') -- show active buffers
vim.keymap.set('n', '<leader>m', ':map<CR>') -- show list of mappings
vim.keymap.set('i', '<C-c>', '<C-x><C-o>') -- omnicompletion (native)

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

-- plugins
vim.pack.add({
    {src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main'},
    {src = 'https://github.com/neovim/nvim-lspconfig'},
    {src = 'https://github.com/mason-org/mason.nvim'},
    {src = 'https://github.com/lervag/vimtex'},
--    {src = ''},
--    {src = ''},
--    {src = ''},
--    {src = ''},
--    {src = ''},
--    {src = ''},
--    {src = ''},
--    {src = ''},
--    {src = ''},
})

require 'mason'.setup()
--
--vim.lsp.config('*',{
--    root_markers = {'.git'},
--})
--
--vim.lsp.config('lua_ls', {
--    cmd = {'lua-language-server'},
--    filetypes = {'lua'},
--    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml"},
--      on_init = function(client)
--        if client.workspace_folders then
--          local path = client.workspace_folders[1].name
--          if
--            path ~= vim.fn.stdpath('config')
--            and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
--          then
--            return
--          end
--        end
--        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
--          runtime = {
--            -- Tell the language server which version of Lua you're using (most
--            -- likely LuaJIT in the case of Neovim)
--            version = 'LuaJIT',
--            -- Tell the language server how to find Lua modules same way as Neovim
--            -- (see `:h lua-module-load`)
--            path = {
--              'lua/?.lua',
--              'lua/?/init.lua',
--            },
--          },
--          -- Make the server aware of Neovim runtime files
--          workspace = {
--            checkThirdParty = false,
--            library = {
--              vim.env.VIMRUNTIME
--              -- Depending on the usage, you might want to add additional paths
--              -- here.
--              -- '${3rd}/luv/library'
--              -- '${3rd}/busted/library'
--            }
--            -- Or pull in all of 'runtimepath'.
--            -- NOTE: this is a lot slower and will cause issues when working on
--            -- your own configuration.
--            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
--            -- library = {
--            --   vim.api.nvim_get_runtime_file('', true),
--            -- }
--          }
--        })
--      end,
--      settings = {
--        Lua = {}
--      }
--})
--
--vim.lsp.config('texlab',{
--    cmd = {'texlab'},
--    filetypes = {'tex', 'plaintex', 'bib'},
--    root_markers = {'.latexmkrc', '.texlabroot', 'Tectonic.toml'},
--    settings = {
--      texlab = {
--        bibtexFormatter = "texlab",
--        build = {
--          args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
--          executable = "latexmk",
--          forwardSearchAfter = false,
--          onSave = false
--        },
--        chktex = {
--          onEdit = false,
--          onOpenAndSave = false
--        },
--        diagnosticsDelay = 300,
--        formatterLineLength = 80,
--        forwardSearch = {
--          args = {}
--        },
--        latexFormatter = "latexindent",
--        latexindent = {
--          modifyLineBreaks = false
--        }
--      }
--    },
--})
--
--vim.lsp.config('basedpyright',{
--    cmd = { "basedpyright-langserver", "--stdio" },
--    filetypes = {'python'},
--    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json"},
--    settings = {
--      basedpyright = {
--        analysis = {
--          autoSearchPaths = true,
--          diagnosticMode = "openFilesOnly",
--          useLibraryCodeForTypes = true
--        }
--      }
--    }
--})
--
--vim.lsp.config('julials',{
--    cmd = { "julia", "--startup-file=no", "--history-file=no", "-e", '    # Load LanguageServer.jl: attempt to load from ~/.julia/environments/nvim-lspconfig\n    # with the regular load path as a fallback\n    ls_install_path = joinpath(\n        get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),\n        "environments", "nvim-lspconfig"\n    )\n    pushfirst!(LOAD_PATH, ls_install_path)\n    using LanguageServer\n    popfirst!(LOAD_PATH)\n    depot_path = get(ENV, "JULIA_DEPOT_PATH", "")\n    project_path = let\n        dirname(something(\n            ## 1. Finds an explicitly set project (JULIA_PROJECT)\n            Base.load_path_expand((\n                p = get(ENV, "JULIA_PROJECT", nothing);\n                p === nothing ? nothing : isempty(p) ? nothing : p\n            )),\n            ## 2. Look for a Project.toml file in the current working directory,\n            ##    or parent directories, with $HOME as an upper boundary\n            Base.current_project(),\n            ## 3. First entry in the load path\n            get(Base.load_path(), 1, nothing),\n            ## 4. Fallback to default global environment,\n            ##    this is more or less unreachable\n            Base.load_path_expand("@v#.#"),\n        ))\n    end\n    @info "Running language server" VERSION pwd() project_path depot_path\n    server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)\n    server.runlinter = true\n    run(server)\n  ' },
--    filetypes = {'julia'},
--    root_markers = { "Project.toml", "JuliaProject.toml" },
--})
--
----vim.lsp.config('',{})
----
----vim.lsp.config('',{
----})
--
--vim.lsp.enable('lua_ls', 'basedpyright', 'texlab', 'julials')
--
--
