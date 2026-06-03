-- zen-mode.nvim — distraction-free editing. Lazy-loaded on :ZenMode.
require('custom.lazy').load {
  src = 'https://github.com/folke/zen-mode.nvim',
  cmd = 'ZenMode',
  setup = function()
    require('zen-mode').setup {
      window = {
        width = 140,
      },
    }
  end,
}
