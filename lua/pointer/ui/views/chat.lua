local base = require 'pointer.ui.views.base'
local header = require 'pointer.ui.components.header'

local M = {}

--- Creates the chat view component
--- @param opts table Options for the chat view
--- @return table The chat view component
function M.create(opts)
    local view = base.create(opts)

    -- Create the chat header
    local chat_header = header.create {
        title = 'Chat',
        align = 'left',
        padding = 0,
        border = false,
    }

    -- Store child components
    view.children = {
        header = chat_header,
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