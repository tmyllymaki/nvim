local vault_path = vim.fn.expand '~/projects/Obsidian/Work'

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  event = 'VeryLazy',
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = 'Work',
        path = vault_path,
      },
    },
    daily_notes = {
      folder = 'Daily',
      date_format = '%Y-%m-%d',
      template = 'Daily.md',
    },
    templates = {
      folder = 'Templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
      create_new = true,
    },
    checkbox = {
      order = { ' ', 'x' },
    },
    ---@param title string|nil
    ---@return string
    note_id_func = function(title)
      if title then
        return title
      end
      return tostring(os.date '%Y-%m-%d') .. '-' .. tostring(math.random(1000, 9999))
    end,
  },
  keys = {
    { '<leader>nd', '<cmd>Obsidian today<cr>', desc = 'Daily note (today)' },
    {
      '<leader>nh',
      function()
        vim.cmd('edit ' .. vault_path .. '/Home.md')
      end,
      desc = 'Home',
    },
    { '<leader>nn', '<cmd>Obsidian new<cr>', desc = 'New note' },
    { '<leader>ns', '<cmd>Obsidian search<cr>', desc = 'Search vault' },
    { '<leader>nf', '<cmd>Obsidian quick_switch<cr>', desc = 'Find note' },
    { '<leader>nb', '<cmd>Obsidian backlinks<cr>', desc = 'Backlinks' },
    { '<leader>nl', '<cmd>Obsidian links<cr>', desc = 'Browse links' },
    { '<leader>nx', '<cmd>Obsidian extract_note<cr>', desc = 'Extract to note', mode = 'v' },
    { '<leader>ny', '<cmd>Obsidian yesterday<cr>', desc = 'Yesterday' },
    { '<leader>nw', '<cmd>Obsidian tomorrow<cr>', desc = 'Tomorrow' },
    {
      '<leader>np',
      function()
        vim.cmd('edit ' .. vault_path .. '/Tasks.md')
      end,
      desc = 'Tasks',
    },
    {
      '<leader>no',
      function()
        require('telescope.builtin').grep_string {
          cwd = vault_path,
          search = '- [ ] ',
          prompt_title = 'Open Tasks',
        }
      end,
      desc = 'Open tasks',
    },
    {
      '<leader>nc',
      function()
        vim.ui.input({ prompt = 'Task: ' }, function(input)
          if not input or input == '' then return end
          vim.ui.input({ prompt = 'Due date (YYYY-MM-DD, empty to skip): ' }, function(date)
            local task = '- [ ] ' .. input
            if date and date ~= '' then
              task = task .. ' 📅 ' .. date
            end
            local tasks_path = vault_path .. '/Tasks.md'
            local file = io.open(tasks_path, 'a')
            if file then
              file:write(task .. '\n')
              file:close()
              vim.notify('Task captured: ' .. input)
            end
          end)
        end)
      end,
      desc = 'Capture task',
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)

    -- Extend obsidian's smart action to add/remove completion dates
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function(ev)
        vim.keymap.set('n', '<cr>', function()
          local actions = require 'obsidian.actions'
          local line_before = vim.api.nvim_get_current_line()
          local was_unchecked = line_before:match '%[ %]' ~= nil
          local was_checked = line_before:match '%[x%]' ~= nil

          -- Run obsidian's smart action (it's expr-style, returns a command string)
          local result = actions.smart_action()
          if result and result ~= '' then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(result, true, false, true), 'n', false)
          end

          -- Post-process: add/remove completion date after the toggle applies
          if was_unchecked or was_checked then
            vim.schedule(function()
              local line = vim.api.nvim_get_current_line()
              local today = os.date '%Y-%m-%d'
              if line:match '%[x%]' and not line:match '✅' then
                vim.api.nvim_set_current_line(line .. ' ✅ ' .. today)
              elseif line:match '%[ %]' then
                vim.api.nvim_set_current_line(line:gsub(' ?✅ %d%d%d%d%-%d%d%-%d%d', ''))
              end
            end)
          end
        end, { buffer = ev.buf, desc = 'Obsidian Smart Action' })
      end,
    })
  end,
}
