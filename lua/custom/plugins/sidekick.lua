-- sidekick.nvim — AI CLI integration + Next Edit Suggestions (NES).
vim.pack.add { 'https://github.com/folke/sidekick.nvim' }

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

-- (was `init`) Keep the chat background linked to Normal and expose a command.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('SidekickChatBg', { clear = true }),
  callback = link_chat_to_normal,
})
link_chat_to_normal()
vim.api.nvim_create_user_command('SidekickToggleFullscreen', toggle_fullscreen, {
  desc = 'Toggle Sidekick between modal and fullscreen float',
})

require('sidekick').setup {
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
}

-- Tab for NES (Next Edit Suggestions) - falls through to normal Tab.
vim.keymap.set('n', '<Tab>', function()
  if not require('sidekick').nes_jump_or_apply() then
    return '<Tab>'
  end
end, { expr = true, desc = 'NES / Tab' })

vim.keymap.set({ 'n', 't', 'i', 'x' }, '<C-,>', function()
  require('sidekick.cli').toggle()
end, { desc = 'Sidekick Toggle' })

vim.keymap.set({ 'n', 't' }, '<leader>aF', toggle_fullscreen, { desc = 'Sidekick Toggle Fullscreen' })

vim.keymap.set('n', '<leader>aa', function()
  require('sidekick.cli').toggle()
end, { desc = 'Sidekick Toggle CLI' })

vim.keymap.set('n', '<leader>ac', function()
  require('sidekick.cli').toggle { name = 'claude', focus = true }
end, { desc = 'Toggle Claude' })

vim.keymap.set('n', '<leader>aC', function()
  require('sidekick.cli').toggle { name = 'copilot', focus = true }
end, { desc = 'Toggle Copilot CLI' })

vim.keymap.set('n', '<leader>as', function()
  require('sidekick.cli').select()
end, { desc = 'Select CLI' })

vim.keymap.set('n', '<leader>ar', function()
  require('sidekick.cli').toggle { name = 'claude', focus = true, resume = true }
end, { desc = 'Resume Claude' })

vim.keymap.set('n', '<leader>ad', function()
  require('sidekick.cli').close()
end, { desc = 'Detach CLI Session' })

vim.keymap.set('n', '<A-f>', function()
  require('sidekick.cli').send { msg = '{file}' }
end, { desc = 'Send File' })

vim.keymap.set('x', '<A-f>', function()
  require('sidekick.cli').send { msg = '{selection}' }
end, { desc = 'Send Selection' })

vim.keymap.set({ 'x', 'n' }, '<leader>at', function()
  require('sidekick.cli').send { msg = '{this}' }
end, { desc = 'Send This' })

vim.keymap.set('n', '<leader>af', function()
  require('sidekick.cli').send { msg = '{file}' }
end, { desc = 'Send File' })

vim.keymap.set('x', '<leader>av', function()
  require('sidekick.cli').send { msg = '{selection}' }
end, { desc = 'Send Visual Selection' })

vim.keymap.set({ 'n', 'x' }, '<leader>ap', function()
  require('sidekick.cli').prompt()
end, { desc = 'Select Prompt' })
