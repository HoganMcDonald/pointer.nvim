--- Main view for the pointer sidepanel
local header = require 'pointer.components.header'
local router = require 'pointer.lib.router'
local ui = require 'pointer.ui'

local M = {}

--- Creates the main view with a single header
--- @param opts table Options for customizing the view
--- @return table Component representing the full view
function M.create(opts)
  opts = opts or {}

  -- Create the parent component that holds the entire view
  local view = ui.create_component(opts)

  -- Create a single header component
  local main_header = header.create {
    title = 'Pointer.nvim',
    align = 'center',
    padding = 1,
    border = true,
  }

  -- Store child components so they can be accessed later
  view.children = {
    main_header = main_header,
  }

  -- Define the render function for the view
  view.render = function(props, state)
    -- Calculate width from buffer if available
    local width = props.width or 40

    -- Start with empty content array
    local content = {}

    -- Render the main header
    local main_header_content = main_header.render(main_header.props, main_header.state)
    for _, line in ipairs(main_header_content) do
      table.insert(content, line)
    end

    -- Render the current view if one is active
    local current_view = router.get_current_view()
    if current_view then
      local view_content = current_view.component.render(current_view.props, current_view.component.state)
      for _, line in ipairs(view_content) do
        table.insert(content, line)
      end
    end

    return content
  end

  return view
end

return M
