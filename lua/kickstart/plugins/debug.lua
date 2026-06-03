--
-- debug.lua
--
-- nvim-dap setup, primarily for .NET (netcoredbg via easy-dotnet) debugging.

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/Cliffback/netcoredbg-macOS-arm64.nvim',
  'https://github.com/jbyuki/one-small-step-for-vimkind',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
}

require('dapui').setup {
  icons = { expanded = '', collapsed = '', current_frame = '' },
  mappings = {
    expand = { '<CR>' },
    open = 'o',
    remove = 'd',
    edit = 'e',
    repl = 'r',
    toggle = 't',
  },
  element_mappings = {},
  expand_lines = true,
  force_buffers = true,
  layouts = {
    {
      elements = {
        { id = 'scopes', size = 1 },
      },
      size = 10,
      position = 'bottom',
    },
    {
      elements = {
        'breakpoints',
        'stacks',
        'watches',
      },
      size = 45,
      position = 'right',
    },
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = 'single',
    mappings = {
      ['close'] = { 'q', '<Esc>' },
    },
  },
  controls = {
    enabled = vim.fn.exists '+winbar' == 1,
    element = 'repl',
    icons = {
      pause = '',
      play = '',
      step_into = '',
      step_over = '',
      step_out = '',
      step_back = '',
      run_last = '',
      terminate = '',
      disconnect = '',
    },
  },
  render = {
    max_type_length = nil,
    max_value_lines = 100,
    indent = 1,
  },
}

require('nvim-dap-virtual-text').setup {
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = false,
  show_stop_reason = true,
  commented = false,
  only_first_definition = true,
  all_references = false,
  clear_on_continue = false,
  ---@param variable Variable
  ---@param buf number
  ---@param stackframe dap.StackFrame
  ---@param node userdata
  ---@param options nvim_dap_virtual_text_options
  ---@return string|nil
  display_callback = function(variable, buf, stackframe, node, options)
    if options.virt_text_pos == 'inline' then
      return ' = ' .. variable.value
    else
      return variable.name .. ' = ' .. variable.value
    end
  end,
  virt_text_pos = 'eol',
  all_frames = false,
  virt_lines = false,
  virt_text_win_col = nil,
}

require('mason-nvim-dap').setup {
  automatic_installation = true,
  handlers = {},
  ensure_installed = {},
}

local dap = require 'dap'
dap.set_log_level 'TRACE'
local dapui = require 'dapui'
-- Only register if easy-dotnet is loaded
if pcall(require, 'easy-dotnet') then
  require('easy-dotnet.netcoredbg').register_dap_variables_viewer()
end

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

vim.keymap.set('n', '<F5>', dap.continue, {})

vim.keymap.set('n', '<F6>', function()
  dap.close()
  dapui.close()
end, {})

vim.keymap.set('n', '<F10>', dap.step_over, {})
vim.keymap.set('n', '<leader>dO', dap.step_over, {})
vim.keymap.set('n', '<leader>dC', dap.run_to_cursor, {})
vim.keymap.set('n', '<leader>dr', dap.repl.toggle, {})
vim.keymap.set('n', '<leader>dj', dap.down, {})
vim.keymap.set('n', '<leader>dk', dap.up, {})
vim.keymap.set('n', '<F11>', dap.step_into, {})
vim.keymap.set('n', '<F12>', dap.step_out, {})
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<F2>', require('dap.ui.widgets').hover, {})

vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = 'DapBreakpoint', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '󰳟', texthl = '', linehl = 'DapStopped', numhl = '' })
