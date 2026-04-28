return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
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
  },
  keys = {
    -- bufdelete
    { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
    { '<leader>bo', function() Snacks.bufdelete.other() end, desc = 'Delete Other Buffers' },
    -- gitbrowse
    { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git Browse', mode = { 'n', 'v' } },
    -- words
    { ']]', function() Snacks.words.jump(1, true) end, desc = 'Next Reference' },
    { '[[', function() Snacks.words.jump(-1, true) end, desc = 'Prev Reference' },
    -- notifier
    { '<leader>un', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
    { '<leader>uN', function() Snacks.notifier.hide() end, desc = 'Dismiss Notifications' },
    -- terminal
    { "<C-'>", function() Snacks.terminal.toggle() end, desc = 'Toggle Terminal', mode = { 'n', 't' } },
    -- picker: search
    { '<leader>sh', function() Snacks.picker.help() end, desc = 'Search Help' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Search Keymaps' },
    { '<leader>sf', function() Snacks.picker.files() end, desc = 'Search Files' },
    { '<leader>ss', function() Snacks.picker.pickers() end, desc = 'Search Pickers' },
    { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Search current Word', mode = { 'n', 'v' } },
    { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Search by Grep' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Search Diagnostics' },
    { '<leader>sr', function() Snacks.picker.resume() end, desc = 'Search Resume' },
    { '<leader>s.', function() Snacks.picker.recent() end, desc = 'Search Recent Files' },
    { '<leader><leader>', function() Snacks.picker.buffers() end, desc = 'Find existing buffers' },
    { '<leader>je', function() Snacks.picker.lsp_symbols() end, desc = 'Jump to document symbols' },
    { '<leader>jd', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Jump to workspace symbols' },
    { '<leader>/', function() Snacks.picker.lines() end, desc = 'Fuzzily search in current buffer' },
    { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = 'Search in Open Files' },
    { '<leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = 'Search Neovim files' },
    -- picker: LSP
    { 'grr', function() Snacks.picker.lsp_references() end, desc = 'Goto References' },
    { 'gri', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
    { 'grd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    { 'gO', function() Snacks.picker.lsp_symbols() end, desc = 'Document Symbols' },
    { 'gW', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Workspace Symbols' },
    { 'grt', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto Type Definition' },
  },
}
