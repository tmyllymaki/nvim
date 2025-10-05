return {
  -- 'folke/trouble.nvim',
  'h-michael/trouble.nvim',
  branch = 'fix/decoration-provider-api',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  enabled = not vim.g.is_perf,
  cmd = 'Trouble',
  config = function()
    require('trouble').setup {
      auto_close = true,
      auto_preview = true,
      auto_jump = true,
    }
  end,
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
    {
      '<leader>xr',
      '<cmd>Trouble lsp_references toggle focus=false win.position=bottom<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
  },
}
