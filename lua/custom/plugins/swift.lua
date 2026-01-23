return {
  -- Swift syntax highlighting
  {
    'keith/swift.vim',
    ft = 'swift',
  },

  -- Enhanced Swift support
  {
    'wojciech-kulik/xcodebuild.nvim',
    ft = 'swift',
    cmd = { 'XcodebuildSetup', 'XcodebuildPicker', 'XcodebuildBuild', 'XcodebuildRun' },
    cond = function()
      -- Only load if Xcode project files exist
      return vim.fn.glob('*.xcodeproj') ~= ''
        or vim.fn.glob('*.xcworkspace') ~= ''
        or vim.fn.glob('Package.swift') ~= ''
    end,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('xcodebuild').setup {
        integrations = {
          xcodebuild_offline = {
            enabled = false,
          },
        },
      }
    end,
  },
}
