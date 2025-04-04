--- Main view for the pointer sidepanel
local header = require("pointer.components.header")
local router = require("pointer.lib.router")
local ui = require("pointer.ui")

local M = {}

--- Creates the main view with a single header
--- @param opts table Options for customizing the view
--- @return table Component representing the full view
function M.create(opts)
  opts = opts or {}

  local view = ui.create_component(opts, {})

  local main_header = header.create({
    title = "Pointer.nvim",
    align = "center",
    padding = 0,
    border = true,
  })

  view.children = {
    main_header = main_header,
  }

  view.render = function(_, _)
    local content = {}

    local main_header_content = main_header.render(main_header.props, main_header.state)
    for _, line in ipairs(main_header_content) do
      table.insert(content, line)
    end

    local current_view = router.get_current_view()
    if current_view then
      local view_content =
        current_view.component.render(current_view.props, current_view.component.state)
      for _, line in ipairs(view_content) do
        table.insert(content, line)
      end
    end

    return content
  end

  return view
end

return M
