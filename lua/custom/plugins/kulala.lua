-- kulala.nvim — HTTP/REST client. Lazy-loaded on http/rest files
-- (it loads a large default config — ~290ms when eager).
require('custom.lazy').load {
  src = 'https://github.com/mistweaverco/kulala.nvim',
  ft = { 'http', 'rest' },
  setup = function()
    require('kulala').setup {
      global_keymaps = true,
      global_keymaps_prefix = '<leader>R',
      kulala_keymaps_prefix = '',
    }
  end,
}
