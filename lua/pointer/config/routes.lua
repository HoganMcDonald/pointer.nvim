local chat_view = require 'pointer.views.chat'
local router = require 'pointer.lib.router'

local M = {}

--- Register all available views
function M.register_views()
  -- Register chat view
  router.register('chat', chat_view.create())
end

--- Set up default view
function M.setup_default_view()
  router.navigate 'chat'
end

--- Get all available routes
--- @return table List of route names
function M.get_routes()
  return {
    'chat',
    -- Add more routes here as they are created
  }
end

return M
