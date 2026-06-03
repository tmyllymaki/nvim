-- monaspace.nvim — Monaspace font ligature/texture-healing support.
-- NOTE: the original spec used `enable = false` (a typo for `enabled`), so this
-- plugin was effectively ENABLED. Preserved as enabled. To actually disable it,
-- replace the body below with `do return end`.
vim.pack.add { 'https://github.com/jackplus-xyz/monaspace.nvim' }

require('monaspace').setup {
  use_default = true,
}
