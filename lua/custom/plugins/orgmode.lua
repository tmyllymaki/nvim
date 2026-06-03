-- orgmode + telescope-orgmode + org-bullets.
vim.pack.add {
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-orgmode/telescope-orgmode.nvim',
  'https://github.com/nvim-orgmode/org-bullets.nvim',
}

require('orgmode').setup {
  org_agenda_files = '~/Documents/org/**/*',
  org_default_notes_file = '~/Documents/org/refile.org',
}
require('org-bullets').setup()

-- Add the orgmode completion source to blink (merges with the Section 7 config).
require('blink.cmp').setup {
  sources = {
    per_filetype = {
      org = { 'orgmode' },
    },
    providers = {
      orgmode = {
        name = 'Orgmode',
        module = 'orgmode.org.autocompletion.blink',
        fallbacks = { 'buffer' },
      },
    },
  },
}

require('telescope').setup()
require('telescope').load_extension 'orgmode'
vim.keymap.set('n', '<leader>nr', require('telescope').extensions.orgmode.refile_heading)
vim.keymap.set('n', '<leader>nf', require('telescope').extensions.orgmode.search_headings)
vim.keymap.set('n', '<leader>ni', require('telescope').extensions.orgmode.insert_link)
