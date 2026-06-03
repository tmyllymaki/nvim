local function link_chat_to_normal()
  vim.api.nvim_set_hl(0, 'SidekickChat', { link = 'Normal' })
end

local modal_float = { width = 0.9, height = 0.9, border = 'rounded' }
local fullscreen_float = { width = 1.0, height = 1.0, border = 'none' }

local fullscreen = false

local function toggle_fullscreen()
  fullscreen = not fullscreen
  local size = fullscreen and fullscreen_float or modal_float

  local ok_cfg, Config = pcall(require, 'sidekick.config')
  if ok_cfg and Config.cli and Config.cli.win then
    Config.cli.win.float = vim.tbl_deep_extend('force', Config.cli.win.float or {}, size)
  end

  local ok_term, Terminal = pcall(require, 'sidekick.cli.terminal')
  if not ok_term then
    return
  end
  for _, t in pairs(Terminal.terminals or {}) do
    t.opts.float = vim.tbl_deep_extend('force', t.opts.float or {}, size)
    if t:is_open() then
      local refocus = t:is_focused()
      t:hide()
      t:show()
      if refocus then
        t:focus()
      end
    end
  end
  vim.notify('Sidekick: ' .. (fullscreen and 'fullscreen' or 'modal'), vim.log.levels.INFO)
end

return {
  'folke/sidekick.nvim',
  event = 'VeryLazy',
  init = function()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('SidekickChatBg', { clear = true }),
      callback = link_chat_to_normal,
    })
    link_chat_to_normal()
    vim.api.nvim_create_user_command('SidekickToggleFullscreen', toggle_fullscreen, {
      desc = 'Toggle Sidekick between modal and fullscreen float',
    })
  end,
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
    {
      '<leader>aF',
      toggle_fullscreen,
      desc = 'Sidekick Toggle Fullscreen',
      mode = { 'n', 't' },
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
