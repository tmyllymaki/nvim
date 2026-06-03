-- multicursors.nvim — multi-cursor editing (powered by hydra).
-- Lazy-loaded on its commands / <Leader>, .
require('custom.lazy').load {
  src = 'https://github.com/smoka7/multicursors.nvim',
  deps = { 'https://github.com/nvimtools/hydra.nvim' },
  cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
  setup = function()
    require('multicursors').setup {}
  end,
}

vim.keymap.set({ 'v', 'n' }, '<Leader>,', '<cmd>MCstart<cr>', {
  desc = 'Create a selection for selected text or word under the cursor',
})
