-- render-markdown.nvim — in-buffer markdown rendering. Lazy-loaded on markdown.
-- (treesitter + mini.nvim are already loaded eagerly in init.lua.)
require('custom.lazy').load {
  src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  ft = 'markdown',
  setup = function()
    require('render-markdown').setup {}
  end,
}
