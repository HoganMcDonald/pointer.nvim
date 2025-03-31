local base = require 'pointer.views.base'

local header = require 'pointer.components.header'

local M = {}

--- @param opts table Options for the chat view
--- @return table The chat view component
function M.create(opts)
  local view = base.create(opts)

  local chat_header = header.create {
    title = 'Chat',
    align = 'left',
    padding = 0,
    border = false,
  }

  -- Override the render function
  view.render = function(props, state)
    local content = {}

    -- Render the header
    local header_content = chat_header.render(chat_header.props)
    for _, line in ipairs(header_content) do
      table.insert(content, line)
    end

    -- Add chat content
    table.insert(content, '')
    table.insert(content, '  • Welcome to the chat!')
    table.insert(content, '  • This is an example view')
    table.insert(content, '')

    return content
  end

  return view
end

return M