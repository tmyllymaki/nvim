-- octo.nvim — GitHub issues/PRs. Lazy-loaded on :Octo.
-- (plenary, snacks, nvim-web-devicons are already loaded eagerly at startup.)
require('custom.lazy').load {
  src = 'https://github.com/pwntester/octo.nvim',
  cmd = 'Octo',
  setup = function()
    require('octo').setup {
      picker = 'snacks',
      enable_builtin = true,
    }
  end,
}
