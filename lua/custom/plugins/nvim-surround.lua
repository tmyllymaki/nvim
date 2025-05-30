return {
  'kylechui/nvim-surround',
  version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {
      -- Configuration here, or leave empty to use defaults
      surrounds = {
        -- You can add other custom surrounds or disable default ones here.
        -- For example, to disable the default 't' for HTML tags if it conflicts:
        -- ['t'] = false,

        ['e'] = { -- Key for the try-catch surround
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
        ['f'] = { -- Key for the try-catch surround
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
        -- try-catch-finally surround
        ['x'] = { -- Key for the try-catch surround
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
  end,
}
