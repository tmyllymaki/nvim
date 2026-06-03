-- trouble.nvim — diagnostics/quickfix/LSP list. (Fork on a fix branch.)
-- Lazy-loaded on :Trouble (the keymaps below invoke it).
if vim.g.is_perf then
  return
end

require('custom.lazy').load {
  src = 'https://github.com/h-michael/trouble.nvim',
  version = 'fix/decoration-provider-api',
  cmd = 'Trouble',
  setup = function()
    require('trouble').setup {
      auto_close = true,
      auto_preview = true,
      auto_jump = true,
      win = {
        wo = {
          wrap = true,
        },
      },
    }
  end,
}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
vim.keymap.set('n', '<leader>xr', '<cmd>Trouble lsp_references toggle focus=false win.position=bottom<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
