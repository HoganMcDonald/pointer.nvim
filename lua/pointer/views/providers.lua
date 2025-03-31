local base = require 'pointer.views.base'
local header = require 'pointer.components.header'

local M = {}

--- @param opts table Options for the models view
--- @return table The models view component
function M.create(opts)
  local view = base.create(opts)

  local models_header = header.create {
    title = 'Providers',
    align = 'left',
    padding = 0,
    border = false,
  }

  -- Override the render function
  view.render = function(props, state)
    local content = {}

    -- Render the header
    local header_content = models_header.render(models_header.props)
    for _, line in ipairs(header_content) do
      table.insert(content, line)
    end

    -- Anthropic section
    table.insert(content, '')
    table.insert(content, { text = 'Anthropic', hl_group = 'PointerUITitle' })
    table.insert(content, '  • Claude 3 Opus')
    table.insert(content, '  • Claude 3 Sonnet')
    table.insert(content, '  • Claude 3 Haiku')
    table.insert(content, '')
    table.insert(content, '  [ ] Enable Anthropic')
    table.insert(content, '  API Key: ********')
    table.insert(content, '')

    -- OpenAI section
    table.insert(content, { text = 'OpenAI', hl_group = 'PointerUITitle' })
    table.insert(content, '  • GPT-4 Turbo')
    table.insert(content, '  • GPT-3.5 Turbo')
    table.insert(content, '')
    table.insert(content, '  [ ] Enable OpenAI')
    table.insert(content, '  API Key: ********')
    table.insert(content, '')

    -- Add navigation hint
    table.insert(content, '')
    table.insert(content, 'Navigation:')
    table.insert(content, '  j/k - Move up/down')
    table.insert(content, '  <Space> - Toggle model')
    table.insert(content, '  i - Edit API key')
    table.insert(content, '  <Esc> - Return to chat')

    return content
  end

  return view
end

return M 