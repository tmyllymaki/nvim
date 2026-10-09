-- sidekick.nvim — AI CLI integration + Next Edit Suggestions (NES).
vim.pack.add { 'https://github.com/folke/sidekick.nvim' }

local function link_chat_to_normal()
  vim.api.nvim_set_hl(0, 'SidekickChat', { link = 'Normal' })
end

-- Keep the chat background linked to Normal across colorscheme changes.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('SidekickChatBg', { clear = true }),
  callback = link_chat_to_normal,
})
link_chat_to_normal()

require('sidekick').setup {
  nes = {
    enabled = true,
  },
  cli = {
    -- tools = {
    --   claude = {
    --     cmd = { 'sandboxed-claude', '--dangerously-skip-permissions' },
    --   },
    -- },
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
  if require('custom.float_layout').hide_snacks() then
    require('sidekick.cli').show { focus = true }
  else
    require('sidekick.cli').toggle()
  end
end, { desc = 'Sidekick Toggle' })

-- Modal <-> fullscreen layout toggle, shared with the snacks terminal (<C-ö>).
local float_layout = require 'custom.float_layout'
vim.keymap.set({ 'n', 't' }, '<leader>aF', function()
  float_layout.toggle()
end, { desc = 'Toggle Float Fullscreen' })

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
