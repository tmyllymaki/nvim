return {
  'akinsho/toggleterm.nvim',
  enabled = false, -- replaced by snacks.terminal
  config = function()
    toggle_term = require 'toggleterm'
    toggle_term.setup()

    -- Direction cycling state and main terminal
    local Terminal = require('toggleterm.terminal').Terminal
    local terminals = require 'toggleterm.terminal'
    local directions = { 'float', 'vertical', 'tab' }
    -- Map all valid directions to their cycle index (includes horizontal for external terminals)
    local direction_to_idx = { float = 1, vertical = 2, tab = 3, horizontal = 2 }
    local MainTerminal = nil

    -- Get the currently focused toggleterm, or nil if not in a toggleterm
    local function get_focused_terminal()
      local bufnr = vim.api.nvim_get_current_buf()
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- Check if this is a toggleterm buffer
      if not bufname:match 'toggleterm' then
        return nil
      end

      -- Check if this is the Claude Code terminal (stored globally)
      if _G.ClaudeCodeTerminal and _G.ClaudeCodeTerminal.bufnr == bufnr then
        return _G.ClaudeCodeTerminal
      end

      -- Try to get by ID from buffer name
      local term_id = bufname:match 'toggleterm#(%d+)'
      if term_id then
        local term = terminals.get(tonumber(term_id))
        if term then return term end
      end

      -- Fallback: search all terminals for matching buffer
      local all_terms = terminals.get_all()
      for _, term in ipairs(all_terms) do
        if term.bufnr == bufnr then
          return term
        end
      end

      -- Last resort: check Claude Code terminal by ID match
      if _G.ClaudeCodeTerminal and term_id and tonumber(term_id) == 69 then
        return _G.ClaudeCodeTerminal
      end

      return nil
    end

    local function get_or_create_terminal()
      if not MainTerminal then
        MainTerminal = Terminal:new {
          id = 99,
          direction = 'float',
          close_on_exit = false,
          hidden = true,
          float_opts = { border = 'curved' },
        }
      end
      return MainTerminal
    end

    local function change_terminal_direction(direction)
      -- Try to get focused terminal, fall back to main terminal
      local term = get_focused_terminal() or get_or_create_terminal()
      if not term then return end

      -- Validate direction
      local valid_directions = { float = true, vertical = true, horizontal = true, tab = true }
      if not valid_directions[direction] then
        direction = 'float'
      end

      -- Close if open
      if term:is_open() then
        term:close()
      end

      -- Update direction property directly and ensure float_opts exists for float
      term.direction = direction
      if direction == 'float' and not term.float_opts then
        term.float_opts = { border = 'curved' }
      end

      -- Use pcall to catch any errors from toggleterm
      local ok, err = pcall(function()
        term:open()
      end)
      if not ok then
        vim.notify('Failed to change terminal direction: ' .. tostring(err), vim.log.levels.WARN)
        -- Try fallback to float
        term.direction = 'float'
        term.float_opts = term.float_opts or { border = 'curved' }
        term:open()
      end
    end

    local function cycle_terminal_direction()
      -- Get current terminal's direction
      local term = get_focused_terminal() or get_or_create_terminal()
      if not term then return end

      local current_direction = term.direction
      -- Validate current direction, default to 'float' if nil/invalid
      if type(current_direction) ~= 'string' or not direction_to_idx[current_direction] then
        current_direction = 'float'
      end
      -- Find current index
      local idx = direction_to_idx[current_direction] or 1
      -- Cycle to next
      idx = (idx % #directions) + 1
      change_terminal_direction(directions[idx])
    end

    vim.keymap.set({ 'n', 't' }, "<C-'>", function()
      get_or_create_terminal():toggle()
    end, { noremap = true, silent = true })
    vim.keymap.set({ 'n', 't' }, '<Space>!', function()
      toggle_term.toggle(2, nil, nil, 'horizontal')
    end, { noremap = true, silent = true })
    vim.keymap.set({ 'n', 't' }, '<C-ö>', function()
      toggle_term.toggle_all()
    end, { noremap = true, silent = true })

    -- Direction cycling keymap
    vim.keymap.set({ 'n', 't' }, '<C-ä>', cycle_terminal_direction, { noremap = true, silent = true, desc = 'Cycle terminal direction' })

    -- Dedicated direction keymaps
    vim.keymap.set({ 'n', 't' }, '<Leader>tf', function()
      change_terminal_direction 'float'
    end, { noremap = true, silent = true, desc = 'Terminal float' })
    vim.keymap.set({ 'n', 't' }, '<Leader>tv', function()
      change_terminal_direction 'vertical'
    end, { noremap = true, silent = true, desc = 'Terminal vertical' })
    vim.keymap.set({ 'n', 't' }, '<Leader>tt', function()
      change_terminal_direction 'tab'
    end, { noremap = true, silent = true, desc = 'Terminal tab (fullscreen)' })

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<esc><esc>', [[<C-\><C-n>]], opts)
      -- vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      -- vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      -- vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      -- vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      -- vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd 'autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()'
  end,
}
