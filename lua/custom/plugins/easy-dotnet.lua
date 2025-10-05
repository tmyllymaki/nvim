return {
  'GustavEikaas/easy-dotnet.nvim',
  -- 'nvim-telescope/telescope.nvim' or 'ibhagwan/fzf-lua' or 'folke/snacks.nvim'
  -- are highly recommended for a better experience
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  config = function()
    local function get_secret_path(secret_guid)
      local path = ''
      local home_dir = vim.fn.expand '~'
      local secret_path = home_dir .. '/.microsoft/usersecrets/' .. secret_guid .. '/secrets.json'
      path = secret_path
      return path
    end

    local dotnet = require 'easy-dotnet'
    local netcoredbg_path = vim.fn.stdpath 'data' .. '/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg'
    -- Options are not required
    dotnet.setup {
      lsp = {
        enabled = false, -- We've set this up manually
        roslynator_enabled = false, -- Automatically enable roslynator analyzer
        analyzer_assemblies = {}, -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
      },
      get_sdk_path = function()
        return '/opt/homebrew/bin/dotnet'
      end,
      ---@type TestRunnerOptions
      test_runner = {
        ---@type "split" | "float" | "buf"
        viewmode = 'float',
        enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
        noBuild = true,
        icons = {
          passed = '',
          skipped = '',
          failed = '',
          success = '',
          reload = '',
          test = '',
          sln = '󰘐',
          project = '󰘐',
          dir = '',
          package = '',
        },
        mappings = {
          run_test_from_buffer = { lhs = '<leader>r', desc = 'run test from buffer' },
          filter_failed_tests = { lhs = '<leader>fe', desc = 'filter failed tests' },
          debug_test = { lhs = '<leader>d', desc = 'debug test' },
          go_to_file = { lhs = 'g', desc = 'go to file' },
          run_all = { lhs = '<leader>R', desc = 'run all tests' },
          run = { lhs = '<leader>r', desc = 'run test' },
          peek_stacktrace = { lhs = '<leader>p', desc = 'peek stacktrace of failed test' },
          expand = { lhs = 'o', desc = 'expand' },
          expand_node = { lhs = 'E', desc = 'expand node' },
          expand_all = { lhs = '-', desc = 'expand all' },
          collapse_all = { lhs = 'W', desc = 'collapse all' },
          close = { lhs = 'q', desc = 'close testrunner' },
          refresh_testrunner = { lhs = '<C-r>', desc = 'refresh testrunner' },
        },
        --- Optional table of extra args e.g "--blame crash"
        additional_args = {},
      },
      new = {
        project = {
          prefix = 'sln', -- "sln" | "none"
        },
      },
      ---@param action "test" | "restore" | "build" | "run"
      terminal = function(path, action, args)
        args = args or ''
        local commands = {
          run = function()
            return string.format('dotnet run --project %s %s', path, args)
          end,
          test = function()
            return string.format('dotnet test %s %s', path, args)
          end,
          restore = function()
            return string.format('dotnet restore %s %s', path, args)
          end,
          build = function()
            return string.format('dotnet build %s %s', path, args)
          end,
          watch = function()
            return string.format('dotnet watch --project %s %s', path, args)
          end,
        }
        local command = commands[action]()
        if require('easy-dotnet.extensions').isWindows() == true then
          command = command .. '\r'
        end

        require('toggleterm').exec(command, nil, nil, nil, 'float')
      end,
      secrets = {
        path = get_secret_path,
      },
      csproj_mappings = true,
      fsproj_mappings = true,
      auto_bootstrap_namespace = {
        --block_scoped, file_scoped
        type = 'block_scoped',
        enabled = true,
        use_clipboard_json = {
          behavior = 'prompt', --'auto' | 'prompt' | 'never',
          register = '+', -- which register to check
        },
      },
      picker = 'telescope',
      background_scanning = true,
      notifications = {
        --Set this to false if you have configured lualine to avoid double logging
        handler = false,
      },
      debugger = {
        bin_path = netcoredbg_path,
        auto_register_dap = true,
        mappings = {
          open_variable_viewer = { lhs = 'T', desc = 'open variable viewer' },
        },
      },
      diagnostics = {
        default_severity = 'error',
        setqflist = false,
      },
    }

    -- Example command
    vim.api.nvim_create_user_command('Secrets', function()
      dotnet.secrets()
    end, {})

    -- dotnet.build_default_quickfix()
    vim.keymap.set('n', '<leader>mb', function()
      dotnet.build_default_quickfix()
    end, { desc = 'Build default project with quickfix' })

    vim.keymap.set('n', '<leader>mw', function()
      dotnet.watch_default()
    end, { desc = 'Watch default project' })

    vim.keymap.set('n', '<leader>mpa', function()
      dotnet.add_package()
    end, { desc = 'Add Nuget package' })

    vim.keymap.set('n', '<leader>ms', function()
      dotnet.secrets()
    end, { desc = 'Open dotnet user-secrets' })

    vim.keymap.set('n', '<leader>ma', function()
      local telescope = require 'telescope.builtin'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      telescope.find_files {
        prompt_title = 'Select Directory for New File',
        cwd = vim.fn.getcwd(),
        find_command = { 'fd', '--type', 'd', '--hidden', '--exclude', '.git' },
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              local selected_dir = selection.path or selection.value
              dotnet.createfile(selected_dir)
            else
              -- If no selection, use current directory
              dotnet.createfile(vim.fn.getcwd())
            end
          end)
          return true
        end,
      }
    end, { desc = 'Create a new file' })

    vim.keymap.set('n', '<leader>tt', function()
      dotnet.testrunner()
    end, { desc = 'Toggle test runner' })

    vim.keymap.set('n', '<leader>tr', function()
      dotnet.test()
    end, { desc = 'Run test' })
  end,
}
