-- nvim-surround — add/change/delete surrounding pairs.
vim.pack.add { { src = 'https://github.com/kylechui/nvim-surround', version = vim.version.range '^3.0.0' } }

require('nvim-surround').setup {
  surrounds = {
    -- try-catch
    ['e'] = {
      add = function()
        local left_surround = { 'try', '{' }
        local right_surround = {
          'catch (Exception ex)',
          '{',
          '',
          '}',
        }
        return { left_surround, right_surround }
      end,
    },
    -- try-finally
    ['f'] = {
      add = function()
        local left_surround = { 'try', '{' }
        local right_surround = {
          'finally',
          '{',
          '',
          '}',
        }
        return { left_surround, right_surround }
      end,
    },
    -- try-catch-finally
    ['x'] = {
      add = function()
        local left_surround = { 'try', '{' }
        local right_surround = {
          'catch (Exception ex)',
          '{',
          '',
          '}',
          'finally',
          '{',
          '',
          '}',
        }
        return { left_surround, right_surround }
      end,
    },
  },
}
