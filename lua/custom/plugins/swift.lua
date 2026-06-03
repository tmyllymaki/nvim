-- Swift support: syntax + (conditionally) xcodebuild tooling.
vim.pack.add { 'https://github.com/keith/swift.vim' }

-- Only set up xcodebuild when the cwd looks like an Xcode/SwiftPM project
-- (mirrors the previous lazy `cond`).
local has_xcode_project = vim.fn.glob '*.xcodeproj' ~= ''
  or vim.fn.glob '*.xcworkspace' ~= ''
  or vim.fn.glob 'Package.swift' ~= ''

if has_xcode_project then
  vim.pack.add {
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
    'https://github.com/wojciech-kulik/xcodebuild.nvim',
  }
  require('xcodebuild').setup {
    integrations = {
      xcodebuild_offline = {
        enabled = false,
      },
    },
  }
end
