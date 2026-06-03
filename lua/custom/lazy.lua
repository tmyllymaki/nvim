-- Minimal lazy-loader for vim.pack.
--
-- vim.pack has no declarative lazy-loading, so this registers a plugin to be
-- installed + configured on first use (FileType / command / keymap / event)
-- instead of at startup. The plugin is only `vim.pack.add`-ed when a trigger
-- fires, so its `plugin/` files and `setup()` cost nothing until then.
--
-- Spec fields:
--   src      string?            plugin git URL (omit if `setup` loads it itself)
--   name     string?            plugin dir name (default: derived from src)
--   version  string|range?      passed straight to vim.pack
--   deps     (string|spec)[]?   dependencies added before the plugin
--   setup    function?          runs after the plugin(s) are added
--   ft       string|string[]?   trigger on FileType
--   event    string|string[]?   trigger on autocmd event(s)
--   cmd      string|string[]?   trigger on user command(s)
--   keys     { lhs, rhs?, mode?, desc?, silent? }[]?  trigger on keymap(s)
--
-- Notes:
--   - `cmd`/`keys` stubs are removed on first trigger and the action replayed,
--     so the real command/mapping (defined by the plugin) takes over.
--   - `ft` re-fires FileType after loading so the plugin attaches to the buffer
--     that triggered it.
local M = {}

local function plugin_name(spec)
  return spec.name or (spec.src and spec.src:gsub('%.git$', ''):match '[^/]+$') or 'lazy-plugin'
end

---@param spec table
---@return function load  -- call to force-load immediately
function M.load(spec)
  local loaded = false
  local key_stubs = {} ---@type { mode: string|string[], lhs: string }[]
  local cmd_stubs = {} ---@type string[]

  local function do_load()
    if loaded then
      return
    end
    loaded = true
    -- Drop our stubs first so the plugin's real command/keymaps win.
    for _, c in ipairs(cmd_stubs) do
      pcall(vim.api.nvim_del_user_command, c)
    end
    for _, k in ipairs(key_stubs) do
      pcall(vim.keymap.del, k.mode, k.lhs)
    end
    -- Install dependencies + the plugin, then configure.
    local specs = {}
    for _, d in ipairs(spec.deps or {}) do
      specs[#specs + 1] = type(d) == 'string' and { src = d } or d
    end
    if spec.src then
      specs[#specs + 1] = { src = spec.src, name = spec.name, version = spec.version }
    end
    if #specs > 0 then
      vim.pack.add(specs)
    end
    if spec.setup then
      spec.setup()
    end
  end

  if spec.ft then
    vim.api.nvim_create_autocmd('FileType', {
      pattern = spec.ft,
      callback = function(args)
        if loaded then
          return
        end
        do_load()
        -- Re-fire FileType so the freshly-loaded plugin attaches to this buffer.
        vim.api.nvim_exec_autocmds('FileType', { buffer = args.buf, modeline = false })
      end,
    })
  end

  if spec.event then
    vim.api.nvim_create_autocmd(spec.event, {
      callback = function()
        do_load()
      end,
    })
  end

  if spec.cmd then
    local cmds = type(spec.cmd) == 'string' and { spec.cmd } or spec.cmd
    for _, name in ipairs(cmds) do
      cmd_stubs[#cmd_stubs + 1] = name
      vim.api.nvim_create_user_command(name, function(ev)
        do_load() -- removes stubs, defines the real commands
        local cmd = { cmd = name, bang = ev.bang, args = ev.fargs, mods = ev.smods }
        if ev.range == 1 then
          cmd.range = { ev.line1 }
        elseif ev.range == 2 then
          cmd.range = { ev.line1, ev.line2 }
        end
        pcall(vim.cmd, cmd)
      end, { nargs = '*', bang = true, range = true, desc = 'lazy: ' .. plugin_name(spec) })
    end
  end

  if spec.keys then
    for _, key in ipairs(spec.keys) do
      local lhs, rhs, mode = key[1], key[2], key.mode or 'n'
      key_stubs[#key_stubs + 1] = { mode = mode, lhs = lhs }
      vim.keymap.set(mode, lhs, function()
        do_load() -- removes our key stub, lets the plugin map lhs
        if type(rhs) == 'function' then
          rhs()
        elseif type(rhs) == 'string' then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(rhs, true, true, true), 'm', false)
        else
          -- No rhs: replay lhs so the plugin's own (now-defined) mapping runs.
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), 'm', false)
        end
      end, { desc = key.desc, silent = key.silent })
    end
  end

  return do_load
end

return M
