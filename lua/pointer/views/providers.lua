local base = require("pointer.views.base")
local header = require("pointer.components.header")
local button = require("pointer.components.button")

local M = {}

--- @param opts table Options for the providers view
--- @return table The providers view component
function M.create(opts)
  local view = base.create(opts)

  local models_header = header.create({
    title = "Providers",
    align = "left",
    padding = 0,
    border = false,
  })

  local setup_button = button.create({
    text = "Setup Anthropic",
    on_press = function()
      -- TODO: Implement setup functionality
    end,
    style = {
      padding = { left = 2, right = 2, top = 1, bottom = 1 },
      border = true,
      highlight = "Normal",
    },
  })

  -- Override the render function
  view.render = function(props, state)
    local content = {}

    -- Render the header
    local header_content = models_header.render(models_header.props)
    for _, line in ipairs(header_content) do
      table.insert(content, line)
    end

    -- Add some spacing
    table.insert(content, "")

    -- Render the button
    local button_content = setup_button.render(setup_button.props)
    for _, line in ipairs(button_content) do
      table.insert(content, line)
    end

    return content
  end

  return view
end

return M
