local views = require 'pointer.ui.views'
local chat_view = require 'pointer.ui.views.chat'

local M = {}

--- Register all available views
function M.register_views()
  -- Register chat view
  views.register('chat', chat_view.create())
end

--- Set up default view
function M.setup_default_view()
  views.navigate('chat')
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