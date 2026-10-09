-- structured-review.nvim — review agent-produced changes along the call graph,
-- as a client of the srev hub. Local checkout, not a vim.pack install.
-- Command: :SRev
local path = vim.fn.expand '~/dev/structured-review-nvim'
if not vim.uv.fs_stat(path) then
  return
end
vim.opt.rtp:prepend(path)
require('structured-review').setup {}

vim.keymap.set('n', '<leader>gv', '<cmd>SRev<cr>', { desc = 'Structured re[v]iew' })
