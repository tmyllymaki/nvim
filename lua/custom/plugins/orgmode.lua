return {
  'nvim-orgmode/orgmode',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-orgmode/telescope-orgmode.nvim',
    'nvim-orgmode/org-bullets.nvim',
    'Saghen/blink.cmp',
  },
  event = 'VeryLazy',
  config = function()
    require('orgmode').setup {
      org_agenda_files = '~/Documents/org/**/*',
      org_default_notes_file = '~/Documents/org/refile.org',
    }
    require('org-bullets').setup()
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
  end,
}
