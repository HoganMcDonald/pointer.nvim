local ui = require 'pointer.ui'

local M = {}

--- Creates a base view component
--- @param opts table Options for the view
--- @return table The base view component
function M.create(opts)
    opts = opts or {}

    local view = ui.create_component(opts)

    -- Default render function that can be overridden
    view.render = function(props, state)
        return {}
    end

    -- Default mount function that can be overridden
    view.mount = function(props, state)
        -- Called when the view is mounted
    end

    -- Default unmount function that can be overridden
    view.unmount = function(props, state)
        -- Called when the view is unmounted
    end

    return view
end

return M
