local M = {}

-- Store all registered views
local views = {}

-- Current active view
local current_view = nil

--- Register a new view
--- @param name string The name of the view (e.g., 'chat', 'files')
--- @param component table The component to render for this view
function M.register(name, component)
  views[name] = component
end

--- Navigate to a specific view
--- @param name string The name of the view to navigate to
--- @param props table|nil Optional props to pass to the view
function M.navigate(name, props)
  if not views[name] then
    vim.notify(string.format('View %s not found', name), vim.log.levels.ERROR)
    return
  end

  current_view = {
    name = name,
    component = views[name],
    props = props or {},
  }

  -- Trigger UI re-render
  local ui = require 'pointer.ui'
  local app = require 'pointer.app'
  if app.sidepanel and app.sidepanel.buffer_id and app.root_component then
    ui.render_component(app.root_component, app.sidepanel.buffer_id)
  end
end

--- Get the current active view
--- @return table|nil The current view or nil if no view is active
function M.get_current_view()
  return current_view
end

--- Get all registered views
--- @return table Table of all registered views
function M.get_views()
  return views
end

return M
