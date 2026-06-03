-- oil.nvim — edit the filesystem like a buffer.
-- Loaded EAGERLY on purpose: oil hijacks directory buffers / replaces netrw, so
-- `nvim <dir>` opens oil. That hijack is set up in `setup()`, so deferring it
-- breaks the workflow (and lets netrw load instead). Oil's docs also advise
-- against lazy-loading. (netrw is left enabled as a lightweight fallback.)
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

-- Icon provider (mini.icons ships with mini.nvim, loaded eagerly).
require('mini.icons').setup {}

local detail = false
require('oil').setup {
  keymaps = {
    ['gd'] = {
      desc = 'Toggle file detail view',
      callback = function()
        detail = not detail
        if detail then
          require('oil').set_columns { 'icon', 'permissions', 'size', 'mtime' }
        else
          require('oil').set_columns { 'icon' }
        end
      end,
    },
  },
}

vim.keymap.set('n', '<leader>e', function()
  require('oil').open()
end, { noremap = true, silent = true, desc = 'Open Oil' })
