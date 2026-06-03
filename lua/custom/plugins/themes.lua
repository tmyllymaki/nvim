-- Colorscheme options. The active scheme (carbonfox/dayfox via nightfox) is
-- selected by the system-theme detector in init.lua Section 3. The rest are
-- available for manual `:colorscheme` switching.
vim.pack.add {
  'https://github.com/miikanissi/modus-themes.nvim',
  'https://github.com/datsfilipe/vesper.nvim',
  'https://github.com/vague-theme/vague.nvim',
  'https://github.com/p00f/alabaster.nvim',
  'https://github.com/dgox16/oldworld.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/rktjmp/lush.nvim', -- zenbones dependency
  'https://github.com/zenbones-theme/zenbones.nvim',
  { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' },
  'https://github.com/ellisonleao/gruvbox.nvim',
  'https://github.com/oskarnurm/koda.nvim',
  'https://github.com/EdenEast/nightfox.nvim',
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
}

require('tokyonight').setup {}
require('gruvbox').setup {}
