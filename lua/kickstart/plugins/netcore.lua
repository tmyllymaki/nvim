local M = {}

--- Rebuilds the project before starting the debug session
---@param co thread
local function rebuild_project(co, path)
  local spinner = require('easy-dotnet.ui-modules.spinner').new()
  spinner:start_spinner 'Building'
  vim.fn.jobstart(string.format('dotnet build %s', path), {
    on_exit = function(_, return_code)
      if return_code == 0 then
        spinner:stop_spinner 'Built successfully'
      else
        spinner:stop_spinner('Build failed with exit code ' .. return_code, vim.log.levels.ERROR)
        error 'Build failed'
      end
      coroutine.resume(co)
    end,
  })
  coroutine.yield()
end

M.register_net_dap = function()
  local dap = require 'dap'
  local debug = require 'easy-dotnet.debugger'
  local polyfills = require 'easy-dotnet.polyfills'
  local sln_parse = require 'easy-dotnet.parsers.sln-parse'

  coroutine.resume(coroutine.create(function()
    local sln_file = sln_parse.find_solution_file()
    local cs_configs = {}

    if sln_file ~= nil then
      local projects = sln_parse.get_projects_and_frameworks_flattened_from_sln(sln_file, function(project)
        return project.runnable
      end)

      for _, project in pairs(projects) do
        local project_dll = project.get_dll_path()
        local project_profiles = debug.get_launch_profiles(vim.fs.dirname(project.path))

        if project_profiles ~= nil then
          local profile_names = polyfills.tbl_keys(project_profiles)
          for _, profile_name in pairs(profile_names) do
            local config_cs = {
              type = 'coreclr',
              name = project.name .. ' - ' .. profile_name,
              request = 'launch',
              env = function()
                local project_profile = project_profiles[profile_name]
                project_profile.environmentVariables['ASPNETCORE_URLS'] = project_profile.applicationUrl
                return project_profile.environmentVariables
              end,
              program = function()
                local co = coroutine.running()
                rebuild_project(co, project.path)
                return project_dll
              end,
              cwd = vim.fs.dirname(project.path),
            }

            table.insert(cs_configs, config_cs)
          end
        end
      end
    end

    dap.configurations.cs = cs_configs
  end))

  -- Find netcoredb from netcoredbg-macOS-arm64.nvim plugin direcotry under "netcoredbg/netcoredbg"
  local netcoredbg_path = vim.fn.stdpath 'data' .. '/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg'
  -- print the path for debugging
  print('Netcoredbg path: ' .. netcoredbg_path)
  dap.adapters.coreclr = {
    type = 'executable',
    command = netcoredbg_path,
    args = { '--interpreter=vscode' },
  }
end

return M
