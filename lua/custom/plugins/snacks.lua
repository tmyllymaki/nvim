-- snacks.nvim — picker, notifier, terminal, and assorted QoL modules.
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

---@type snacks.Config
require('snacks').setup {
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  notifier = { enabled = true },
  indent = { enabled = true },
  words = { enabled = true },
  rename = { enabled = true },
  image = { enabled = true },
  terminal = {
    enabled = true,
    win = {
      position = 'float',
      border = 'rounded',
      width = 0.9,
      height = 0.9,
    },
  },
  gitbrowse = { enabled = true },
  picker = {
    enabled = true,
    sources = {
      files = {
        hidden = true,
      },
      grep = {
        hidden = true,
      },
    },
  },
}

local map = vim.keymap.set

-- bufdelete
map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Delete Other Buffers' })
-- gitbrowse
map({ 'n', 'v' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse' })
-- words
map('n', ']]', function() Snacks.words.jump(1, true) end, { desc = 'Next Reference' })
map('n', '[[', function() Snacks.words.jump(-1, true) end, { desc = 'Prev Reference' })
-- notifier
map('n', '<leader>un', function() Snacks.notifier.show_history() end, { desc = 'Notification History' })
map('n', '<leader>uN', function() Snacks.notifier.hide() end, { desc = 'Dismiss Notifications' })
-- terminal
map({ 'n', 't' }, "<C-'>", function() Snacks.terminal.toggle() end, { desc = 'Toggle Terminal' })
-- picker: search
map('n', '<leader>sh', function() Snacks.picker.help() end, { desc = 'Search Help' })
map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Search Keymaps' })
map('n', '<leader>sf', function() Snacks.picker.files() end, { desc = 'Search Files' })
map('n', '<leader>ss', function() Snacks.picker.pickers() end, { desc = 'Search Pickers' })
map({ 'n', 'v' }, '<leader>sw', function() Snacks.picker.grep_word() end, { desc = 'Search current Word' })
map('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Search by Grep' })
map('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Search Diagnostics' })
map('n', '<leader>sr', function() Snacks.picker.resume() end, { desc = 'Search Resume' })
map('n', '<leader>s.', function() Snacks.picker.recent() end, { desc = 'Search Recent Files' })
map('n', '<leader><leader>', function() Snacks.picker.buffers() end, { desc = 'Find existing buffers' })
map('n', '<leader>je', function() Snacks.picker.lsp_symbols() end, { desc = 'Jump to document symbols' })
map('n', '<leader>jd', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'Jump to workspace symbols' })
map('n', '<leader>/', function() Snacks.picker.lines() end, { desc = 'Fuzzily search in current buffer' })
map('n', '<leader>s/', function() Snacks.picker.grep_buffers() end, { desc = 'Search in Open Files' })
map('n', '<leader>sn', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, { desc = 'Search Neovim files' })
-- picker: LSP
map('n', 'grr', function() Snacks.picker.lsp_references() end, { desc = 'Goto References' })
map('n', 'gri', function() Snacks.picker.lsp_implementations() end, { desc = 'Goto Implementation' })
map('n', 'grd', function() Snacks.picker.lsp_definitions() end, { desc = 'Goto Definition' })
map('n', 'gd', function() Snacks.picker.lsp_definitions() end, { desc = 'Goto Definition' })
map('n', 'gO', function() Snacks.picker.lsp_symbols() end, { desc = 'Document Symbols' })
map('n', 'gW', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'Workspace Symbols' })
map('n', 'grt', function() Snacks.picker.lsp_type_definitions() end, { desc = 'Goto Type Definition' })
