-- Shared "modal vs fullscreen" toggle for the floating AI / terminal windows.
--
-- Both sidekick's CLI terminals and snacks' terminal are floats sized 0.9x0.9.
-- One global flag drives both, so whichever you toggle from, they agree on the
-- layout: `modal` (centered popup) or `full` (edge-to-edge, no border).
local M = {}

M.fullscreen = false

-- Shared size; positioning differs per plugin and is added by the appliers.
local function size(fullscreen)
  if not fullscreen then
    return { width = 0.9, height = 0.9, border = 'rounded' }
  end
  return {
    width = vim.o.columns,
    -- Leave the cmdline (and global statusline, if any) visible.
    height = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0),
    border = 'none',
  }
end

-- `vim.NIL` marks a key to unset: a borderless float may not carry a title,
-- and plain assignment of `nil` can't express "remove" inside a table literal.
local function apply(target, opts)
  for k, v in pairs(opts) do
    target[k] = v ~= vim.NIL and v or nil
  end
end

---@param opts table
local function apply_sidekick(opts)
  -- sidekick reads row/col as a fraction of the leftover space, so 0.5 centers.
  -- A borderless float can't carry a title.
  local pos = opts.border == 'none' and { row = 0, col = 0, title = vim.NIL, title_pos = vim.NIL }
    or { row = 0.5, col = 0.5, title = ' Sidekick ', title_pos = 'center' }
  opts = vim.tbl_extend('force', opts, pos)
  local ok, Config = pcall(require, 'sidekick.config')
  if ok and Config.cli and Config.cli.win then
    -- New terminals inherit the current layout.
    Config.cli.win.float = Config.cli.win.float or {}
    apply(Config.cli.win.float, opts)
  end

  local ok_term, Terminal = pcall(require, 'sidekick.cli.terminal')
  if not ok_term then
    return
  end
  for _, t in pairs(Terminal.terminals or {}) do
    t.opts.float = t.opts.float or {}
    apply(t.opts.float, opts)
    if t:is_open() then
      -- sidekick sizes the window on open, so re-open it to resize.
      local refocus = t:is_focused()
      t:hide()
      t:show()
      if refocus then
        t:focus()
      end
    end
  end
end

---@param opts table
local function apply_snacks(opts)
  -- snacks reads row/col as an absolute screen position and centers when unset.
  local pos = opts.border == 'none' and { row = 0, col = 0 } or { row = vim.NIL, col = vim.NIL }
  opts = vim.tbl_extend('force', opts, pos)
  local ok = pcall(require, 'snacks')
  if not ok or not Snacks.config.terminal then
    return
  end
  local win = Snacks.config.terminal.win or {}
  Snacks.config.terminal.win = win
  apply(win, opts)

  for _, term in ipairs(Snacks.terminal.list()) do
    if term.opts.position == 'float' then
      apply(term.opts, opts)
      term:update()
    end
  end
end

--- Toggle every AI/terminal float between the centered popup and fullscreen.
---@param opts? { notify?: boolean }
function M.toggle(opts)
  M.fullscreen = not M.fullscreen
  local layout = size(M.fullscreen)

  apply_sidekick(layout)
  apply_snacks(layout)

  if not opts or opts.notify ~= false then
    vim.notify('Float layout: ' .. (M.fullscreen and 'fullscreen' or 'modal'), vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command('ToggleFloatLayout', function()
  M.toggle()
end, { desc = 'Toggle terminal/sidekick floats between modal and fullscreen' })

-- Keep fullscreen floats edge-to-edge when the editor is resized.
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('FloatLayoutResize', { clear = true }),
  callback = function()
    if M.fullscreen then
      M.fullscreen = false
      M.toggle { notify = false }
    end
  end,
})

vim.keymap.set({ 'n', 't', 'i', 'x' }, '<C-ö>', function()
  M.toggle()
end, { desc = 'Toggle Float Fullscreen' })

return M
