local chat_view = require 'pointer.views.chat'
local help_view = require 'pointer.views.help'
local providers_view = require 'pointer.views.providers'
local router = require 'pointer.lib.router'

local M = {}

function M.register_views()
  router.register('chat', chat_view.create())
  router.register('help', help_view.create())
  router.register('providers', providers_view.create())
end

function M.setup_default_view()
  router.navigate 'chat'
end

--- Get all available routes
--- @return table List of route names
function M.get_routes()
  return {
    'chat',
    'help',
    'providers',
  }
end

return M
