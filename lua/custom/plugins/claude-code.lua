local function smart_toggle(term)
  if term:is_open() then
    if term:is_focused() then
      term:close()
    else
      term:focus()
    end
  else
    term:open()
  end
end

local toggle_key = '<C-,>'
local send_key = '<A-f>'

-- Store Claude terminal globally so other plugins can access it
_G.ClaudeCodeTerminal = nil

local function setup_toggleterm_provider()
  local claude_terminal = {}

  local toggleterm_provider = {
    setup = function(config)
      local Terminal = require('toggleterm.terminal').Terminal
      claude_terminal = Terminal:new {
        id = 69,
        direction = 'float',
        close_on_exit = false,
        hidden = true,
        float_opts = {
          border = 'curved',
        },
        on_open = function(t)
          vim.keymap.set({ 'n', 't' }, toggle_key, function()
            t:toggle()
          end, { noremap = true, silent = true, buffer = t.bufnr })
        end,
      }
      -- Expose globally for direction cycling
      _G.ClaudeCodeTerminal = claude_terminal
    end,

    open = function(cmd_string, env_table, effective_config, focus)
      claude_terminal.cmd = cmd_string
      claude_terminal.env = env_table
      claude_terminal:open()
    end,

    close = function()
      claude_terminal:close()
    end,

    simple_toggle = function(cmd_string, env_table, effective_config)
      claude_terminal.cmd = cmd_string
      claude_terminal.env = env_table
      claude_terminal:toggle()
    end,

    focus_toggle = function(cmd_string, env_table, effective_config)
      claude_terminal.cmd = cmd_string
      claude_terminal.env = env_table
      smart_toggle(claude_terminal)
    end,

    get_active_bufnr = function()
      if claude_terminal.bufnr then
        return claude_terminal.bufnr
      end
      return nil
    end,

    get_terminal = function()
      return claude_terminal
    end,

    is_available = function()
      local ok, _ = pcall(require, 'toggleterm')
      return ok
    end,
  }

  return toggleterm_provider
end
return {
  'coder/claudecode.nvim',
  enabled = false, -- Replaced by sidekick.nvim
  dependencies = { 'folke/snacks.nvim' },
  config = true,
  keys = {
    -- { toggle_key, '<cmd>ClaudeCodeFocus<cr>', desc = 'Claude Code', mode = { 'n', 'x' } },
    { toggle_key, '<cmd>ClaudeCodeFocus --continue<cr>', desc = 'Claude Code', mode = { 'n', 'x' } },
    { '<leader>a', nil, desc = 'AI/Claude Code' },
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
    { send_key, '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { send_key, '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    {
      send_key,
      '<cmd>ClaudeCodeTreeAdd<cr>',
      desc = 'Add file',
      ft = { 'NvimTree', 'neo-tree', 'oil' },
    },
    -- { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    -- { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    -- {
    --   '<leader>as',
    --   '<cmd>ClaudeCodeTreeAdd<cr>',
    --   desc = 'Add file',
    --   ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
    -- },
    -- Diff management
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
  },
  opts = {
    -- terminal_cmd = '/opt/homebrew/bin/claude', -- Unsandboxed
    terminal_cmd = 'sandboxed-claude', -- Runs claude inside sandbox-exec profile
    terminal = {
      provider = setup_toggleterm_provider(),
      ---@module "snacks"
      ---@type snacks.win.Config|{}
      -- snacks_win_opts = {
      --   position = 'float',
      --   width = 0.9,
      --   height = 0.9,
      --   keys = {
      --     claude_hide = {
      --       toggle_key,
      --       function(self)
      --         self:hide()
      --       end,
      --       mode = 't',
      --       desc = 'Hide',
      --     },
      --   },
      -- },
    },
  },
}
-- return {
--   'greggh/claude-code.nvim',
--   dependencies = {
--     'nvim-lua/plenary.nvim', -- Required for git operations
--   },
--   config = function()
--     require('claude-code').setup {
--       window = {
--         position = 'float',
--         float = {
--           width = '90%', -- Take up 90% of the editor width
--           height = '90%', -- Take up 90% of the editor height
--           row = 'center', -- Center vertically
--           col = 'center', -- Center horizontally
--           relative = 'editor',
--           border = 'rounded', -- Use double border style
--         },
--       },
--     }
--   end,
-- }
