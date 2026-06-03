-- GitHub Copilot (suggestion/panel disabled; used via blink-cmp-copilot menu
-- + sidekick NES).
vim.pack.add { 'https://github.com/zbirenbaum/copilot.lua' }

require('copilot').setup {
  suggestion = {
    enabled = false, -- using blink-cmp-copilot for completion menu + sidekick NES
  },
  panel = {
    enabled = false,
  },
  filetypes = {
    yaml = true,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ['.'] = false,
  },
}
