-- neo-review.nvim — hunk-style review of agent changes, with comment threads
-- that Claude Code reads and answers through the /neo-review skill.
-- Claude runs in sidekick (<C-,>), so the plugin's own agent terminal is off.
vim.pack.add { 'https://github.com/ryanhobsonsmith/neo-review.nvim' }

require('neo-review').setup {
  -- Symlink the neo-review and guided-review skills into ~/.claude/skills.
  skill = { auto_install = true },
  keymaps = {
    agent_open = false,
    agent_ping = false,
  },
}
