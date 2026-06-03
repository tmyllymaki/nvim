-- Loader: requires every Lua file in this directory (except this one).
-- Each sibling file is imperative — it calls `vim.pack.add` and configures
-- itself. See MIGRATION.md for the conversion convention.

local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir) do
  if type == 'file' and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    -- Isolate failures: a broken plugin file reports itself but doesn't prevent
    -- the rest from loading.
    local ok, err = pcall(require, 'custom.plugins.' .. module)
    if not ok then
      vim.schedule(function()
        vim.notify(('Failed to load custom.plugins.%s:\n%s'):format(module, err), vim.log.levels.ERROR)
      end)
    end
  end
end
