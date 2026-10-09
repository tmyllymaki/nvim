-- hop.nvim — EasyMotion-style jumps, like IdeaVim's EasyJump.
vim.pack.add { { src = 'https://github.com/smoka7/hop.nvim', version = vim.version.range '*' } }

require('hop').setup {
  -- Home-row keys first, so the shortest labels are the easiest to type.
  keys = 'asdfghjklqwertyuiopzxcvbnm',
}

-- High-contrast labels that stay readable in both dark and light themes.
local function set_hop_highlights()
  vim.api.nvim_set_hl(0, 'HopNextKey', { fg = '#000000', bg = '#ffd400', bold = true })
  vim.api.nvim_set_hl(0, 'HopNextKey1', { fg = '#000000', bg = '#ffd400', bold = true })
  vim.api.nvim_set_hl(0, 'HopNextKey2', { fg = '#000000', bg = '#ffa64d' })
end
set_hop_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hop_highlights })

-- Label the start of every visible word and jump to the one picked.
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>jw', function()
  require('hop').hint_words()
end, { desc = 'Jump to word' })
