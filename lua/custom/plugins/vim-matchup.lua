-- vim-matchup — DISABLED (was `enabled = false`). The treesitter `matchup`
-- module in init.lua Section 8 references this plugin; kept disabled to match
-- the previous behavior. Remove the `do return end` below to enable.
do
  return
end

vim.pack.add { 'https://github.com/andymass/vim-matchup' }
vim.g.matchup_matchparen_offscreen = { method = 'popup' }
