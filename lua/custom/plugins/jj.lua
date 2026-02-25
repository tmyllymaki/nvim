return {
  'nicolasgb/jj.nvim',
  dependencies = { 'sindrets/diffview.nvim' },
  version = '*', -- Use latest stable release
  -- Or from the main branch (uncomment the branch line and comment the version line)
  -- branch = "main",
  config = function()
    require('jj').setup {
      diff = {
        backend = 'diffview',
      },
    }
  end,
}
