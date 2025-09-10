return {
  'yetone/avante.nvim',
  enabled = true,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  -- ⚠️ must add this setting! ! !
  build = function()
    -- conditionally use the correct build system for the current OS
    if vim.fn.has 'win32' == 1 then
      return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    else
      return 'make'
    end
  end,
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    -- for example
    provider = 'copilot',
    auto_suggestions_provider = nil,
    providers = {
      copilot = {
        model = 'gpt-4.1-2025-04-14',
      },
    },
    web_search_engine = {
      provider = 'searxng', -- tavily, serpapi, google, kagi, brave, or searxng
    },
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      enable_cursor_planning_mode = true,
      auto_approve_tool_permissions = true,
      auto_apply_diff_after_generation = true,
    },
    shortcuts = {
      {
        name = 'refactor',
        description = 'Refactor code with best practices',
        details = 'Automatically refactor code to improve readability, maintainability, and follow best practices while preserving functionality',
        prompt = 'Please refactor this code following best practices, improving readability and maintainability while preserving functionality.',
      },
      {
        name = 'test',
        description = 'Generate unit tests',
        details = 'Create comprehensive unit tests covering edge cases, error scenarios, and various input conditions',
        prompt = 'Please generate comprehensive unit tests for this code, covering edge cases and error scenarios.',
      },
      -- Add more custom shortcuts...
      {
        name = 'review',
        description = 'Review current changes',
        details = 'Review the current changes in the file, providing feedback on code quality, style, and potential improvements',
        prompt = 'Please review the current changes in this file, providing feedback on code quality, style, and potential improvements.',
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'echasnovski/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    --'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'stevearc/dressing.nvim', -- for input provider dressing
    'folke/snacks.nvim', -- for input provider snacks
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
