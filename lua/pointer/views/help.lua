local base = require 'pointer.views.base'
local header = require 'pointer.components.header'

local M = {}

--- @param opts table Options for the help view
--- @return table The help view component
function M.create(opts)
  local view = base.create(opts)

  local help_header = header.create {
    title = 'Help',
    align = 'left',
    padding = 0,
    border = false,
  }

  -- Override the render function
  view.render = function(props, state)
    local content = {}

    -- Render the header
    local header_content = help_header.render(help_header.props)
    for _, line in ipairs(header_content) do
      table.insert(content, line)
    end

    -- Add help content
    table.insert(content, '')
    table.insert(content, 'Keybindings:')
    table.insert(content, '  ? - Show this help screen')
    table.insert(content, '  P - Configure AI models')
    table.insert(content, '  Esc - Close help/model config')
    table.insert(content, '')
    table.insert(content, 'Navigation:')
    table.insert(content, '  j/k - Move up/down')
    table.insert(content, '  gg/G - Move to top/bottom')
    table.insert(content, '')
    table.insert(content, 'Chat:')
    table.insert(content, '  Enter - Send message')
    table.insert(content, '  / - Start command')
    table.insert(content, '')

    return content
  end

  return view
end

return M 