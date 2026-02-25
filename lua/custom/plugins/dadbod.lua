return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1

      -- 1. Define the selection logic
      local function select_smart_sql_scope()
        local ts_utils = require 'nvim-treesitter.ts_utils'

        -- 1. Get current visual selection bounds (if they exist)
        local mode = vim.api.nvim_get_mode().mode
        local is_visual = mode:match '[vV]'

        local cur_s_row, cur_s_col, cur_end_row_ts, cur_end_col_ts
        if is_visual then
          local s_pos = vim.fn.getpos 'v'
          local e_pos = vim.fn.getpos '.'
          local cur_e_row, cur_e_col
          cur_s_row, cur_s_col = s_pos[2] - 1, s_pos[3] - 1
          cur_e_row, cur_e_col = e_pos[2] - 1, e_pos[3] - 1
          -- Normalize so start is always before end
          if cur_s_row > cur_e_row or (cur_s_row == cur_e_row and cur_s_col > cur_e_col) then
            cur_s_row, cur_e_row = cur_e_row, cur_s_row
            cur_s_col, cur_e_col = cur_e_col, cur_s_col
          end
          -- Convert inclusive visual end to tree-sitter exclusive (handles end-of-line wrapping)
          cur_end_row_ts = cur_e_row
          cur_end_col_ts = cur_e_col + 1
          local line = vim.api.nvim_buf_get_lines(0, cur_e_row, cur_e_row + 1, true)[1]
          if cur_end_col_ts >= #line then
            cur_end_row_ts = cur_e_row + 1
            cur_end_col_ts = 0
          end
        end

        -- 2. Find the starting node
        local node = ts_utils.get_node_at_cursor()
        if not node then
          return
        end

        -- 3. Define the "Runnable" hierarchy
        local targets = { statement = true, subquery = true, common_table_expression = true, program = true, set_operation = true }

        -- 4. The Growth Loop — find the smallest unselected target scope
        local sel_s_row, sel_s_col, sel_e_row, sel_e_col
        while node do
          local ntype = node:type()
          local is_union_leg = ntype == 'from' and node:parent() and node:parent():type() == 'set_operation'

          if targets[ntype] or is_union_leg then
            local n_s_row, n_s_col, n_e_row, n_e_col = node:range()

            -- For a union leg, extend start to include the preceding select sibling
            if is_union_leg then
              local prev = node:prev_named_sibling()
              if prev and prev:type() == 'select' then
                n_s_row, n_s_col = prev:range()
              end
            end

            -- If it's a subquery, calculate "inner" bounds (stripping parens)
            local target_s_col = ntype == 'subquery' and n_s_col + 1 or n_s_col
            local target_e_col = ntype == 'subquery' and n_e_col - 1 or n_e_col

            -- Skip nodes whose range is within (or equal to) the current selection
            local within_selection = is_visual
              and (n_s_row > cur_s_row or (n_s_row == cur_s_row and target_s_col >= cur_s_col))
              and (n_e_row < cur_end_row_ts or (n_e_row == cur_end_row_ts and target_e_col <= cur_end_col_ts))

            if not within_selection then
              sel_s_row, sel_s_col = n_s_row, target_s_col
              sel_e_row, sel_e_col = n_e_row, target_e_col
              break
            end
          end
          node = node:parent()
        end

        -- 5. Execute the selection
        if sel_s_row then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
          vim.schedule(function()
            vim.api.nvim_win_set_cursor(0, { sel_s_row + 1, sel_s_col })
            vim.cmd 'normal! v'
            -- Convert exclusive tree-sitter end to inclusive visual-mode position
            local end_row = sel_e_row + 1
            local end_col = sel_e_col - 1
            if end_col < 0 then
              end_row = end_row - 1
              end_col = #vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1] - 1
            end
            vim.api.nvim_win_set_cursor(0, { end_row, math.max(0, end_col) })
          end)
        end
      end

      -- Normal mode: Jump to nearest unit
      vim.keymap.set('n', '<leader>mee', select_smart_sql_scope, { desc = 'Select SQL Scope' })

      -- Visual mode: Expand to NEXT unit
      vim.keymap.set('v', '<leader>mee', select_smart_sql_scope, { desc = 'Expand SQL Scope' })

      -- Visual mode: Standard execution
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function()
          -- Enter to Execute
          vim.keymap.set('v', '<CR>', '<Plug>(DBUI_ExecuteQuery)gv<Esc>', { buffer = true })

          -- Use Arrow Up to expand as well (DataGrip style)
          vim.keymap.set('v', '<Up>', select_smart_sql_scope, { buffer = true })

          -- Backspace to just exit selection if you messed up
          vim.keymap.set('v', '<BS>', '<Esc>', { buffer = true })
        end,
      })
    end,
  },
}
