-- easy-dotnet.nvim — .NET project/test/debug tooling. Lazy-loaded on .NET files.
-- (plenary + snacks are loaded eagerly at startup.)
require('custom.lazy').load {
  src = 'https://github.com/GustavEikaas/easy-dotnet.nvim',
  ft = { 'cs', 'fs', 'fsproj', 'csproj', 'sln', 'slnx' },
  setup = function()
    local function get_secret_path(secret_guid)
      local home_dir = vim.fn.expand '~'
      return home_dir .. '/.microsoft/usersecrets/' .. secret_guid .. '/secrets.json'
    end

    -- Resolve the netcoredbg binary from whichever plugin dir it lives in
    -- (vim.pack installs under site/pack/core/opt, not the old lazy/ path).
    local function resolve_netcoredbg()
      local found = vim.api.nvim_get_runtime_file('netcoredbg/netcoredbg', false)[1]
      if found then
        return found
      end
      return vim.fs.joinpath(vim.fn.stdpath 'data', 'site/pack/core/opt/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg')
    end

    local dotnet = require 'easy-dotnet'
    local netcoredbg_path = resolve_netcoredbg()
    -- Options are not required
    dotnet.setup {
      projx_lsp = {
        enabled = true,
      },
      lsp = {
        enabled = true, -- Enable builtin roslyn lsp
        set_fold_expr = false,
        preload_roslyn = true, -- Start loading roslyn before any buffer is opened
        roslynator_enabled = true, -- Automatically enable roslynator analyzer
        easy_dotnet_analyzer_enabled = true, -- Enable roslyn analyzer from easy-dotnet-server
        easy_dotnet_extension_enabled = false, -- Needs to be true for enhanced_rename and create_type_from_usage
        enhanced_rename = false, -- auto rename file when renaming class
        create_type_from_usage = false, -- code action for creating class from unresolved symbol in a separate file
        restart_roslyn_on_branch_change = false, -- Restart Roslyn when Git HEAD changes
        auto_refresh_codelens = true,
        suggest_updates = true, -- Periodically suggest roslyn-language-server updates
        analyzer_assemblies = {}, -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
        razor = {
          enabled = true,
          html = {
            enabled = true,
            cmd = nil, -- Auto-detect project node_modules/.bin/vscode-html-language-server, then PATH
            request_timeout = 5000,
          },
        },
        config = {
          settings = {
            ['csharp|inlay_hints'] = {
              csharp_enable_inlay_hints_for_implicit_object_creation = true,
              csharp_enable_inlay_hints_for_implicit_variable_types = true,

              csharp_enable_inlay_hints_for_lambda_parameter_types = true,
              csharp_enable_inlay_hints_for_types = true,
              dotnet_enable_inlay_hints_for_indexer_parameters = true,
              dotnet_enable_inlay_hints_for_literal_parameters = true,
              dotnet_enable_inlay_hints_for_object_creation_parameters = true,
              dotnet_enable_inlay_hints_for_other_parameters = true,
              dotnet_enable_inlay_hints_for_parameters = true,
              dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
              dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
              dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
            },
            ['csharp|code_lens'] = {
              dotnet_enable_references_code_lens = true,
            },
            ['csharp|completion'] = {
              dotnet_provide_regex_completions = true,
              dotnet_show_name_completion_suggestions = true,
              dotnet_show_completion_items_from_unimported_namespaces = true,
            },
            ['csharp|formatting'] = {
              dotnet_organize_imports_on_format = true,
            },
            ['csharp|background_analysis'] = {
              background_analysis = {
                dotnet_analyzer_diagnostics_scope = 'fullSolution',
                dotnet_compiler_diagnostics_scope = 'fullSolution',
              },
            },
          },
        },
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
          passed = '',
          skipped = '',
          failed = '',
          success = '',
          reload = '',
          test = '',
          sln = '󰘐',
          project = '󰘐',
          dir = '',
          package = '',
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
        type = 'file_scoped',
        enabled = true,
        use_clipboard_json = {
          behavior = 'prompt', --'auto' | 'prompt' | 'never',
          register = '+', -- which register to check
        },
      },
      picker = 'snacks',
      background_scanning = true,
      notifications = {
        --Set this to false if you have configured lualine to avoid double logging
        handler = function(start_event)
          local spinner = require('easy-dotnet.ui-modules.spinner').new()
          spinner:start_spinner(start_event.job.name)
          ---@param finished_event JobEvent
          return function(finished_event)
            spinner:stop_spinner(finished_event.result.msg, finished_event.result.level)
          end
        end,
      },
      debugger = {
        -- Path to custom coreclr DAP adapter
        -- When set, this fully overrides `engine`; easy-dotnet-server uses this binary as-is.
        -- When nil, easy-dotnet-server falls back to its own bundled debugger selected by `engine`.
        bin_path = nil,
        -- bin_path = netcoredbg_path,
        -- Which bundled debugger to use when `bin_path` is nil.
        --   "netcoredbg" (default) — Samsung netcoredbg
        --   "dncdbg"               — viewizard/dncdbg (a fork of netcoredbg with a richer set of features)
        --   "sharpdbg"             — MattParkerDev/sharpdbg (a new debugger written in C#)
        engine = 'sharpdbg',
        console = 'integratedTerminal', -- Controls where the target app runs: "integratedTerminal" (Neovim buffer) or "externalTerminal" (OS window)
        apply_value_converters = true,
        auto_register_dap = true,
        -- Sample the debugged process' CPU/memory usage so the `easy-dotnet_cpu` and `easy-dotnet_mem`
        -- dapui widgets have data to draw. Set to false to turn sampling off and unregister the widgets.
        mem_cpu_usage = true,
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
      Snacks.picker.files {
        title = 'Select Directory for New File',
        cmd = 'fd --type d --hidden --exclude .git',
        confirm = function(picker, item)
          picker:close()
          if item then
            dotnet.createfile(item.file or item.text)
          else
            dotnet.createfile(vim.fn.getcwd())
          end
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
