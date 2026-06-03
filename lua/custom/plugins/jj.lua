-- jj.nvim — Jujutsu VCS integration.
vim.pack.add {
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/nicolasgb/jj.nvim',
}

require('jj').setup {
  diff = {
    backend = 'diffview',
  },
}
