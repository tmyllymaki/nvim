-- fff.nvim — fast fuzzy file picker. (Binary built via the PackChanged hook.)
vim.pack.add { 'https://github.com/dmtrKovalenko/fff.nvim' }

require('fff').setup {
  debug = {
    enabled = false,
    show_scores = false,
  },
}

vim.keymap.set('n', '<leader>ff', function()
  require('fff').find_files()
end, { desc = 'FFFind files' })

vim.keymap.set('n', '<leader>fg', function()
  require('fff').live_grep()
end, { desc = 'LiFFFe grep' })

vim.keymap.set('n', '<leader>fz', function()
  require('fff').live_grep {
    grep = {
      modes = { 'fuzzy', 'plain' },
    },
  }
end, { desc = 'Live fffuzy grep' })
