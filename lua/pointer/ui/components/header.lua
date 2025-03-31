local ui = require 'pointer.ui'

local M = {}

--- @class HeaderProps
--- @field title string
--- @field align string|nil): Text alignment ('left', 'center', 'right', defaults to 'left'
--- @field padding number|nil): Padding around the header (defaults to 1
--- @field border boolean|nil): Whether to show a border below the header (defaults to true

--- Create a header component
--- @param props HeaderProps Component properties
--- @return table Component
function M.create(props)
  -- The second argument is likely a parent component or options
  local component = ui.create_component(props, {})

  component.render = function(render_props)
    local title = render_props.title or 'Pointer'
    local align = render_props.align or 'left'
    local padding = render_props.padding or 1
    local show_border = render_props.border ~= false

    -- Calculate width from buffer if available
    local width = 40
    if component.bufnr and vim.api.nvim_buf_is_valid(component.bufnr) then
      local win_id = vim.fn.bufwinid(component.bufnr)
      if win_id ~= -1 then
        width = vim.api.nvim_win_get_width(win_id)
      end
    end

    -- Create padding lines
    local result = {}
    for _ = 1, padding do
      table.insert(result, '')
    end

    -- Create title line with proper alignment
    local title_line = title
    if align == 'center' then
      local padding_size = math.floor((width - #title) / 2)
      title_line = string.rep(' ', padding_size) .. title
    elseif align == 'right' then
      local padding_size = width - #title - 1
      title_line = string.rep(' ', padding_size) .. title
    end

    -- Add title with highlight
    table.insert(result, {
      text = title_line,
      hl_group = 'PointerUITitle',
    })

    -- Add border if requested
    if show_border then
      -- Use the horizontal split character for the border
      local border_char = vim.opt.fillchars:get().horiz or '─'
      table.insert(result, {
        text = string.rep(border_char, width),
        hl_group = 'PointerUIBorder',
      })
    end

    -- Add bottom padding
    for _ = 1, padding do
      table.insert(result, '')
    end

    return result
  end

  return component
end

return M
