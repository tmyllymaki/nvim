return {
  'folke/sidekick.nvim',
  event = 'VeryLazy',
  opts = {
    nes = {
      enabled = true,
    },
    cli = {
      tools = {
        claude = {
          cmd = { 'sandboxed-claude', '--dangerously-skip-permissions' },
        },
      },
      win = {
        layout = 'float',
        float = {
          width = 0.9,
          height = 0.9,
          border = 'rounded',
          title = ' Sidekick ',
          title_pos = 'center',
        },
      },
      mux = {
        enabled = false,
      },
    },
  },
  keys = {
    -- Tab for NES (Next Edit Suggestions) - falls through to normal Tab
    {
      '<Tab>',
      function()
        if not require('sidekick').nes_jump_or_apply() then
          return '<Tab>'
        end
      end,
      expr = true,
      desc = 'NES / Tab',
    },
    -- Focus CLI with the same key you're used to
    {
      '<C-,>',
      function() require('sidekick.cli').toggle() end,
      desc = 'Sidekick Toggle',
      mode = { 'n', 't', 'i', 'x' },
    },
    -- <leader>a prefix: AI actions
    {
      '<leader>aa',
      function() require('sidekick.cli').toggle() end,
      desc = 'Sidekick Toggle CLI',
    },
    {
      '<leader>ac',
      function() require('sidekick.cli').toggle { name = 'claude', focus = true } end,
      desc = 'Toggle Claude',
    },
    {
      '<leader>aC',
      function() require('sidekick.cli').toggle { name = 'copilot', focus = true } end,
      desc = 'Toggle Copilot CLI',
    },
    {
      '<leader>as',
      function() require('sidekick.cli').select() end,
      desc = 'Select CLI',
    },
    {
      '<leader>ar',
      function() require('sidekick.cli').toggle { name = 'claude', focus = true, resume = true } end,
      desc = 'Resume Claude',
    },
    {
      '<leader>ad',
      function() require('sidekick.cli').close() end,
      desc = 'Detach CLI Session',
    },
    -- Send context
    {
      '<A-f>',
      function() require('sidekick.cli').send { msg = '{file}' } end,
      desc = 'Send File',
    },
    {
      '<A-f>',
      function() require('sidekick.cli').send { msg = '{selection}' } end,
      mode = 'x',
      desc = 'Send Selection',
    },
    {
      '<leader>at',
      function() require('sidekick.cli').send { msg = '{this}' } end,
      mode = { 'x', 'n' },
      desc = 'Send This',
    },
    {
      '<leader>af',
      function() require('sidekick.cli').send { msg = '{file}' } end,
      desc = 'Send File',
    },
    {
      '<leader>av',
      function() require('sidekick.cli').send { msg = '{selection}' } end,
      mode = 'x',
      desc = 'Send Visual Selection',
    },
    {
      '<leader>ap',
      function() require('sidekick.cli').prompt() end,
      mode = { 'n', 'x' },
      desc = 'Select Prompt',
    },
  },
}
