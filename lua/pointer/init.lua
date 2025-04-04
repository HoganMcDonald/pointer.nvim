local M = {}

local config = require("pointer.config")
local sidepanel = require("pointer.app")

--- Setup function that initializes the plugin with options
--- @param opts PointerOptions Configuration options for the plugin
function M.setup(opts)
  local options = config.setup(opts)

  vim.api.nvim_create_augroup("PointerSidepanel", {
    clear = true,
  })

  sidepanel.setup(options)
end

M.toggle_sidepanel = sidepanel.toggle

return M
