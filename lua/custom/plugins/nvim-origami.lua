-- nvim-origami — nicer folds.
vim.pack.add { 'https://github.com/chrisgrieser/nvim-origami' }

-- (was `init`) disable vim's auto-folding.
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

require('origami').setup {
  autoFold = {
    -- Keep comments (e.g. C# /// <summary> blocks) open; only fold imports on load.
    kinds = { 'imports' },
  },
}
