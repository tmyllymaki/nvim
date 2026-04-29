--[[
=====================================================================
Personal Neovim config — migrated from kickstart.nvim (lazy.nvim)
to the built-in `vim.pack` plugin manager.

Structure (see MIGRATION.md):
  SECTION 1  Foundation   — options, leaders, keymaps, autocmds, diagnostics
  SECTION 2  vim.pack      — build hooks (PackChanged)
  SECTION 3  UI / UX       — guess-indent, gitsigns, which-key, todo, mini, colorscheme
  SECTION 4  Search        — provided by snacks (lua/custom/plugins/snacks.lua)
  SECTION 5  LSP           — mason, LspAttach, servers
  SECTION 6  Formatting    — conform
  SECTION 7  Completion    — blink.cmp, LuaSnip, lazydev
  SECTION 8  Treesitter    — master branch + textobjects
  SECTION 9  kickstart/* + custom plugin loader

`vim.pack` has no declarative lazy-loading and no dependency resolution: every
dependency is listed explicitly and everything loads at startup (cached by
`vim.loader`). Each `lua/custom/plugins/*.lua` is imperative (adds + sets up its
own plugin); the loader in `custom/plugins/init.lua` requires them all.
--]]

-- ============================================================
-- SECTION 1: FOUNDATION
-- ============================================================
do
  -- Cache compiled Lua modules for faster startup.
  vim.loader.enable()

  -- Leaders must be set before plugins load.
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = true

  -- [[ Options ]]
  vim.o.number = true
  vim.opt.relativenumber = true
  vim.o.mouse = 'a'
  vim.o.showmode = false
  vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
  end)
  vim.o.breakindent = true
  vim.o.undofile = true
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.signcolumn = 'yes'
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.o.inccommand = 'split'
  vim.o.cursorline = true
  vim.o.scrolloff = 10
  vim.opt.confirm = true
  vim.g.matchparen_timeout = 2
  vim.g.matchparen_insert_timeout = 2
  vim.opt.swapfile = false

  -- Don't block the UI with a "hit-enter" prompt for long/multi-line messages;
  -- display them briefly and auto-continue instead. Everything is still
  -- available via `:messages`. Bump `wait` (max 10000) if 500ms is too quick.
  vim.o.messagesopt = 'wait:500,history:500'

  -- Global statusline (so views can fully collapse).
  vim.opt.laststatus = 3

  -- Folding (treesitter-based; see Section 8 for the FileType hook).
  vim.opt.foldenable = false
  vim.opt.foldlevel = 99

  -- Better diff options.
  vim.opt.diffopt:append {
    'linematch:60',
    'internal',
    'filler',
    'closeoff',
  }
  vim.opt.fillchars:append { diff = '░' }

  -- Disable automatic comment insertion on newline.
  vim.cmd 'autocmd BufEnter * set formatoptions-=cro'
  vim.cmd 'autocmd BufEnter * setlocal formatoptions-=cro'

  -- conceallevel for markdown (required for obsidian.nvim).
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
      vim.opt_local.conceallevel = 2
    end,
  })

  -- PowerShell indentation.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'ps1',
    callback = function()
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
    end,
  })

  -- [[ Diagnostics ]]
  vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      format = function(diagnostic)
        local diagnostic_message = {
          [vim.diagnostic.severity.ERROR] = diagnostic.message,
          [vim.diagnostic.severity.WARN] = diagnostic.message,
          [vim.diagnostic.severity.INFO] = diagnostic.message,
          [vim.diagnostic.severity.HINT] = diagnostic.message,
        }
        return diagnostic_message[diagnostic.severity]
      end,
    },
  }

  -- [[ Basic Keymaps ]]
  -- CodeCompanion (plugin currently disabled; maps kept as-is).
  vim.keymap.set({ 'n', 'v' }, '<LocalLeader>aa', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
  vim.keymap.set({ 'n', 'v' }, '<LocalLeader>at', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
  vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })
  vim.cmd [[cab cc CodeCompanion]]

  -- Center the cursor after half-page jumps.
  vim.keymap.set('n', '<C-d>', '<C-d>zz')
  vim.keymap.set('n', '<C-u>', '<C-u>zz')

  -- Clear search highlight.
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode more easily.
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Open the current file in a new tab.
  vim.keymap.set('n', '<leader>ot', function()
    local current_file = vim.fn.expand '%:p'
    vim.cmd.tabnew(current_file)
  end, { desc = '[O]pen [T]ab with current file' })

  -- [[ Autocommands ]]
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
      vim.hl.on_yank()
    end,
  })
end

-- ============================================================
-- SECTION 2: vim.pack — build hooks
-- ============================================================
do
  -- Run a shell build command in the plugin directory and report failures.
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local output = (result.stderr ~= '' and result.stderr) or result.stdout or ''
      if output == '' then
        output = 'No output from build command.'
      end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- Run the appropriate build step after a plugin is installed/updated.
  -- See `:help vim.pack-events`.
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
          run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
        end
      elseif name == 'nvim-treesitter' then
        if not ev.data.active then
          vim.cmd.packadd 'nvim-treesitter'
        end
        vim.cmd 'TSUpdate'
      elseif name == 'fff.nvim' then
        -- Downloads a prebuilt binary or builds from source via rustup.
        local ok, err = pcall(function()
          require('fff.download').download_or_build_binary()
        end)
        if not ok then
          vim.notify('fff.nvim binary build failed:\n' .. tostring(err) .. "\nRun :lua require('fff.download').download_or_build_binary()", vim.log.levels.ERROR)
        end
      elseif name == 'avante.nvim' then
        run_build(name, { 'make' }, ev.data.path)
      elseif name == 'pipeline.nvim' then
        run_build(name, { 'make' }, ev.data.path)
      elseif name == 'mcphub.nvim' then
        run_build(name, { 'npm', 'install', '-g', 'mcp-hub@latest' }, ev.data.path)
      elseif name == 'likec4.nvim' then
        run_build(name, { 'npm', 'install', '-g', '@likec4/language-server' }, ev.data.path)
      end
    end,
  })
end

--- Helper to build a GitHub URL from `owner/repo`.
---@param repo string
---@return string
local function gh(repo)
  return 'https://github.com/' .. repo
end

-- ============================================================
-- SECTION 3: UI / CORE UX
-- ============================================================
do
  -- Detect indentation automatically.
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Nerd Font icons (used by many plugins below).
  vim.pack.add { gh 'nvim-tree/nvim-web-devicons' }

  -- Git signs in the gutter (base config; recommended keymaps added in
  -- kickstart.plugins.gitsigns, Section 9).
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  }

  -- Pending-keybind hints.
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },
    spec = {
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>n', group = '[N]otes' },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  }

  -- Highlight TODO/NOTE/etc. in comments.
  vim.pack.add { gh 'nvim-lua/plenary.nvim', gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- mini.nvim: small modules (ai, surround, statusline).
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  require('mini.ai').setup {
    -- Move the "next" textobject variants off an/in so Neovim 0.12's built-in
    -- treesitter incremental selection (an/in/]n/[n) is usable on the `main`
    -- branch. Use aa/ii for around-next/inside-next instead.
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }
  require('mini.surround').setup()

  local statusline = require 'mini.statusline'
  statusline.setup { use_icons = vim.g.have_nerd_font }

  -- Append the easy-dotnet job indicator to the mode section.
  local job_indicator_fn = function()
    local ok, jobs = pcall(require, 'easy-dotnet.ui-modules.jobs')
    if ok then
      return jobs.lualine()
    end
    return ''
  end
  statusline.section_modes = function()
    local mode = statusline.section_base_modes()
    local indicator = job_indicator_fn()
    return mode .. (indicator ~= '' and (' ' .. indicator) or '')
  end
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function()
    return '%2l:%-2v'
  end

  -- [[ Colorscheme ]]
  -- nightfox provides the active schemes (carbonfox/dayfox); the full theme
  -- list lives in lua/custom/plugins/themes.lua.
  vim.pack.add { gh 'EdenEast/nightfox.nvim' }

  local function get_system_theme()
    local system = vim.loop.os_uname().sysname
    if system == 'Darwin' then
      local handle = io.popen 'defaults read -g AppleInterfaceStyle 2>/dev/null'
      if handle then
        local result = handle:read '*a'
        handle:close()
        return result:match 'Dark' and 'dark' or 'light'
      end
    elseif system == 'Linux' then
      local kde_handle = io.popen 'kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null'
      if kde_handle then
        local kde_result = kde_handle:read '*a'
        kde_handle:close()
        if kde_result and kde_result:match '[Dd]ark' then
          return 'dark'
        elseif kde_result and kde_result:match '[Ll]ight' then
          return 'light'
        end
      end
    end
    return 'dark'
  end

  local function set_theme_from_system()
    if get_system_theme() == 'dark' then
      vim.cmd.colorscheme 'carbonfox'
    else
      vim.cmd.colorscheme 'dayfox'
    end
  end

  vim.o.background = get_system_theme()
  set_theme_from_system()
end

-- ============================================================
-- SECTION 4: SEARCH & NAVIGATION
-- Provided by snacks.picker — see lua/custom/plugins/snacks.lua.
-- Telescope is installed only as an orgmode/swift dependency.
-- ============================================================

-- ============================================================
-- SECTION 5: LSP
-- ============================================================
do
  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
    gh 'crashdummyy/mason-registry',
  }

  -- mason with the registries needed for roslyn/easy-dotnet tools.
  require('mason').setup {
    registries = {
      'github:mason-org/mason-registry',
      'github:crashdummyy/mason-registry',
    },
  }

  -- Runs each time an LSP attaches to a buffer.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      -- grr/gri/grd/gd/gO/gW/grt are set globally via snacks.picker (snacks.lua).
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      map('grs', vim.lsp.buf.signature_help, 'Signature help')
      map('grh', vim.lsp.buf.hover, 'Signature hover')

      local function client_supports_method(client, method, bufnr)
        if vim.fn.has 'nvim-0.11' == 1 then
          return client:supports_method(method, bufnr)
        else
          return client.supports_method(method, { bufnr = bufnr })
        end
      end

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })
        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end

      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
        map('<leader>tl', function()
          vim.g.codelens_enabled = not vim.g.codelens_enabled
          if vim.g.codelens_enabled then
            vim.lsp.codelens.refresh { bufnr = event.buf }
          else
            vim.lsp.codelens.clear(nil, event.buf)
          end
        end, '[T]oggle Code[L]ens')
      end
    end,
  })

  ---@class LspServersConfig
  ---@field mason table<string, vim.lsp.Config>
  ---@field others table<string, vim.lsp.Config>
  local servers = {
    mason = {
      tailwindcss = {},
      pyright = {},
      rust_analyzer = {},
      powershell_es = {
        settings = {
          powershell = {
            codeFormatting = {
              preset = 'Stroustrup',
            },
          },
        },
      },
    },
    others = {
      gleam = {},
      nixd = {
        nixpkgs = {
          expr = 'import <nixpkgs> { }',
        },
        formatting = {
          command = { 'alejandra' },
        },
      },
    },
  }

  local ensure_installed = vim.tbl_keys(servers.mason or {})
  vim.list_extend(ensure_installed, {
    'stylua', -- Used to format Lua code
  })
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  -- mason-tool-installer registers :MasonToolsInstall on VimEnter, which is
  -- AFTER this eagerly-loaded section runs. Defer the explicit trigger until the
  -- command exists, and pcall it so a failure can never abort init.lua.
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      pcall(vim.cmd, 'MasonToolsInstall')
    end,
  })

  -- Merge configs onto nvim-lspconfig defaults.
  for server, config in pairs(vim.tbl_extend('keep', servers.mason, servers.others)) do
    if not vim.tbl_isempty(config) then
      vim.lsp.config(server, config)
    end
  end

  require('mason-lspconfig').setup {
    ensure_installed = {},
    automatic_enable = true,
  }

  -- Enable servers that are not installed via Mason.
  if not vim.tbl_isempty(servers.others) then
    vim.lsp.enable(vim.tbl_keys(servers.others))
  end
end

-- ============================================================
-- SECTION 6: FORMATTING (conform)
-- ============================================================
do
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 3000,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      scss = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'yamlfix' },
      cs = { 'csharpier', lsp_format = 'fallback' },
      sql = { 'sqruff', lsp_format = 'fallback' },
      swift = { 'swiftformat' },
    },
    formatters = {
      csharpier = {
        command = 'csharpier',
        args = {
          'format',
          '--write-stdout',
        },
        to_stdin = true,
      },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = '[F]ormat buffer' })

  vim.api.nvim_create_user_command('FormatDisable', function(args)
    if args.bang then
      vim.b.disable_autoformat = true
    else
      vim.g.disable_autoformat = true
    end
  end, {
    desc = 'Disable autoformat-on-save',
    bang = true,
  })
  vim.api.nvim_create_user_command('FormatEnable', function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
  end, {
    desc = 'Re-enable autoformat-on-save',
  })
end

-- ============================================================
-- SECTION 7: COMPLETION (blink.cmp + LuaSnip + lazydev)
-- ============================================================
do
  -- lazydev configures the Lua LSP for editing your Neovim config.
  vim.pack.add { gh 'folke/lazydev.nvim' }
  require('lazydev').setup {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  }

  -- Snippet engine.
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- Completion engine + its source providers.
  vim.pack.add {
    { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' },
    { src = gh 'saghen/blink.compat', version = vim.version.range '2.*' },
    gh 'Kaiser-Yang/blink-cmp-avante',
    gh 'giuxtaposition/blink-cmp-copilot',
  }
  require('blink.compat').setup {}

  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  require('blink.cmp').setup {
    enabled = function()
      return not vim.list_contains({ 'DressingInput' }, vim.bo.filetype) and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
    end,
    keymap = {
      preset = 'enter',
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-h>'] = { 'snippet_backward', 'fallback' },
    },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      ghost_text = {
        enabled = true,
        show_with_selection = true,
        show_without_selection = false,
        show_with_menu = true,
        show_without_menu = true,
      },
    },
    sources = {
      default = { 'copilot', 'avante', 'snippets', 'lsp', 'path', 'lazydev', 'buffer' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        copilot = { module = 'blink-cmp-copilot', score_offset = 100 },
        avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
          opts = {},
        },
        ['easy-dotnet'] = {
          name = 'easy-dotnet',
          module = 'easy-dotnet.completion.blink',
          score_offset = 10000,
          async = true,
        },
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
      },
      per_filetype = {
        codecompanion = { 'codecompanion' },
        sql = { 'snippets', 'dadbod', 'buffer' },
        csproj = { 'easy-dotnet', 'avante', 'snippets', 'lsp', 'path', 'buffer' },
        fsproj = { 'easy-dotnet', 'avante', 'snippets', 'lsp', 'path', 'buffer' },
      },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
      frecency = {
        enabled = true,
        path = vim.fn.stdpath 'state' .. '/blink/cmp/frecency.dat',
      },
      use_proximity = true,
    },
    signature = { enabled = true },
  }
end

-- ============================================================
-- SECTION 8: TREESITTER (main branch + textobjects)
-- ============================================================
do
  -- Migrated to the `main` branch (no module system). Highlighting/folding/
  -- indentation are enabled per-buffer via a FileType autocmd; textobjects use
  -- the rewritten nvim-treesitter-textobjects `main` API (explicit keymaps).
  vim.pack.add {
    { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  }

  -- Workaround: the `set-lang-from-info-string!` directive (markdown code-block
  -- injections) doesn't unwrap the list-of-nodes form Neovim 0.11+ passes,
  -- crashing `get_node_text`. Kept defensively (core API, branch-agnostic).
  local aliases = { ex = 'elixir', pl = 'perl', sh = 'bash', uxn = 'uxntal', ts = 'typescript' }
  vim.treesitter.query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
    local node = match[pred[2]]
    if type(node) == 'table' then
      node = node[1]
    end
    if not node then
      return
    end
    local alias = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata['injection.language'] = vim.filetype.match { filename = 'a.' .. alias } or aliases[alias] or alias
  end, { force = true, all = false })

  -- All `main`-branch API usage is below. vim.pack.add does NOT auto-switch an
  -- already-installed plugin from `master` to `main` (see :h vim.pack.add), so
  -- the first launch after this change may still have treesitter on master,
  -- where these calls error. Guard with pcall + a notification telling the user
  -- to run :lua vim.pack.update(), rather than aborting the rest of init.lua.
  local function setup_treesitter()
    -- Ensure a base set of parsers is installed.
    require('nvim-treesitter').install {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
    }

    -- Enable highlighting, folding and indentation for a buffer's language.
    ---@param buf integer
    ---@param language string
    local function treesitter_try_attach(buf, language)
      if not vim.treesitter.language.add(language) then
        return
      end
      vim.treesitter.start(buf, language)

      -- Treesitter-based folding (folds stay open via foldlevel/foldenable in S1).
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'

      -- Treesitter-based indentation (skipped for ruby, as before).
      if language ~= 'ruby' then
        local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
        if has_indent_query then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end
    end

    local available_parsers = require('nvim-treesitter').get_available()
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then
          return
        end
        local installed = require('nvim-treesitter').get_installed 'parsers'
        if vim.tbl_contains(installed, language) then
          treesitter_try_attach(buf, language)
        elseif vim.tbl_contains(available_parsers, language) then
          -- Auto-install then attach (replaces the old `auto_install`).
          require('nvim-treesitter').install(language):await(function()
            treesitter_try_attach(buf, language)
          end)
        else
          treesitter_try_attach(buf, language)
        end
      end,
    })

    -- [[ Textobjects (main-branch API) ]]
    require('nvim-treesitter-textobjects').setup {
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true, -- record moves in the jumplist
      },
    }

    local ts_select = require 'nvim-treesitter-textobjects.select'
    local ts_move = require 'nvim-treesitter-textobjects.move'

    -- Select (visual + operator-pending)
    vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer', 'textobjects') end, { desc = 'Select outer function' })
    vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner', 'textobjects') end, { desc = 'Select inner function' })
    vim.keymap.set({ 'x', 'o' }, 'ac', function() ts_select.select_textobject('@class.outer', 'textobjects') end, { desc = 'Select outer class' })
    vim.keymap.set({ 'x', 'o' }, 'ic', function() ts_select.select_textobject('@class.inner', 'textobjects') end, { desc = 'Select inner class' })
    vim.keymap.set({ 'x', 'o' }, 'as', function() ts_select.select_textobject('@local.scope', 'locals') end, { desc = 'Select language scope' })

    -- Move: next start
    vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() ts_move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'Next function start' })
    vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() ts_move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'Next class start' })
    vim.keymap.set({ 'n', 'x', 'o' }, ']o', function() ts_move.goto_next_start({ '@loop.inner', '@loop.outer' }, 'textobjects') end, { desc = 'Next loop start' })
    vim.keymap.set({ 'n', 'x', 'o' }, ']s', function() ts_move.goto_next_start('@local.scope', 'locals') end, { desc = 'Next scope' })
    vim.keymap.set({ 'n', 'x', 'o' }, ']z', function() ts_move.goto_next_start('@fold', 'folds') end, { desc = 'Next fold' })
    -- Move: next end
    vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() ts_move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'Next function end' })
    vim.keymap.set({ 'n', 'x', 'o' }, '][', function() ts_move.goto_next_end('@class.outer', 'textobjects') end, { desc = 'Next class end' })
    -- Move: previous start
    vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() ts_move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Previous function start' })
    vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() ts_move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'Previous class start' })
    -- Move: previous end
    vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() ts_move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'Previous function end' })
    vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() ts_move.goto_previous_end('@class.outer', 'textobjects') end, { desc = 'Previous class end' })
  end

  local ok, err = pcall(setup_treesitter)
  if not ok then
    vim.schedule(function()
      vim.notify(
        'Treesitter `main` setup failed — the plugin may still be on the `master` branch.\n'
          .. 'Run `:lua vim.pack.update()`, confirm the update with `:write`, then restart Neovim.\n\n'
          .. tostring(err),
        vim.log.levels.WARN
      )
    end)
  end

  -- NOTE: `lsp_interop`/`peek_definition_code` (<leader>df, <leader>dF) was
  -- removed in the textobjects `main` branch, so those maps are dropped.
  -- Incremental selection is now Neovim's built-in (an/in/]n/[n); mini.ai's
  -- next-variants moved to aa/ii in Section 3 to free an/in. The `matchup`
  -- module is gone (vim-matchup is disabled anyway).
end

-- ============================================================
-- SECTION 9: kickstart/plugins + custom plugins
-- ============================================================
do
  require 'kickstart.plugins.autopairs'
  require 'kickstart.plugins.gitsigns' -- recommended gitsigns keymaps

  -- DAP / debugging is heavy (~195ms at startup); load it on the first debug
  -- action. The module's keymaps (F5, <leader>b, F10, …) come with it.
  require('custom.lazy').load {
    keys = { { '<F5>' }, { '<leader>b' } },
    setup = function()
      require 'kickstart.plugins.debug'
    end,
  }

  -- Roslyn / .NET LSP config.
  require 'custom.lsp.roslyn'

  -- Loads every file in lua/custom/plugins/*.lua.
  require 'custom.plugins'

  -- Load LuaSnip snippets (after LuaSnip is configured in Section 7).
  for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/custom/snippets/*.lua', true)) do
    loadfile(path)()
  end

  -- Database connections from a gitignored secrets file (optional).
  local ok, custom_dbs = pcall(require, 'db_secrets')
  if ok then
    vim.g.dbs = custom_dbs
  end
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

