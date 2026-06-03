-- mcphub.nvim — MCP server hub. Lazy-loaded on :MCPHub.
-- (`mcp-hub` binary installed via the PackChanged hook; plenary is eager.)
require('custom.lazy').load {
  src = 'https://github.com/ravitemer/mcphub.nvim',
  cmd = 'MCPHub',
  setup = function()
    require('mcphub').setup()
  end,
}
