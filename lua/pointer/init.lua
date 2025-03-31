local M = {}

local config = require 'pointer.config'
local sidepanel = require 'pointer.sidepanel'

--- Setup function that initializes the plugin with options
--- @param opts table|nil Configuration options for the plugin
function M.setup(opts)
  local options = config.setup(opts)

  vim.api.nvim_create_augroup('PointerSidepanel', {
    clear = true,
  })

  sidepanel.setup(options)
end

M.toggle_sidepanel = sidepanel.toggle

return M
