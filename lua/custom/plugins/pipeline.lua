-- pipeline.nvim — CI/CD pipeline viewer. (Built via the PackChanged hook.)
-- Lazy-loaded on :Pipeline — it does heavy synchronous work at setup, so it was
-- ~660ms of startup when eager.
require('custom.lazy').load {
  src = 'https://github.com/topaxi/pipeline.nvim',
  cmd = 'Pipeline',
  setup = function()
    require('pipeline').setup {}
  end,
}

vim.keymap.set('n', '<leader>ci', '<cmd>Pipeline<cr>', { desc = 'Open pipeline.nvim' })
