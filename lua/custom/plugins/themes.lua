return {
  { 'miikanissi/modus-themes.nvim', priority = 1000 },
  { 'datsfilipe/vesper.nvim' },
  {
    'vague-theme/vague.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'p00f/alabaster.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'dgox16/oldworld.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'zenbones-theme/zenbones.nvim',
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = 'rktjmp/lush.nvim',
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
    -- config = function()
    --     vim.g.zenbones_darken_comments = 45
    --     vim.cmd.colorscheme('zenbones')
    -- end
  },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'ellisonleao/gruvbox.nvim', priority = 1000, config = true },
}
