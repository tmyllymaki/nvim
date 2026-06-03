-- typst-preview.nvim — live Typst preview. Lazy-loaded on typst files.
require('custom.lazy').load {
  src = 'https://github.com/chomosuke/typst-preview.nvim',
  version = vim.version.range '1.*',
  ft = 'typst',
  setup = function()
    require('typst-preview').setup {}
  end,
}
