local M = {}

--- @param opts table Options for the button component
--- @return table The button component
function M.create(opts)
  opts = opts or {}
  
  -- Get theme colors
  local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
  local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
  
  local button = {
    props = {
      text = opts.text or '',
      on_press = opts.on_press or function() end,
      style = opts.style or {
        padding = { left = 2, right = 2, top = 1, bottom = 1 },
        border = true,
        highlight = 'Normal',
        bg = visual_hl.bg or '#2d3436',  -- Use Visual highlight background or fallback
        fg = normal_hl.fg or '#ffffff',  -- Use Normal highlight foreground or fallback
      }
    }
  }

  --- @param props table Button properties
  --- @return table Rendered button lines
  function button.render(props)
    local text = props.text
    local style = props.style
    local padding = style.padding
    
    -- Create the button line with padding
    local button_line = string.rep(' ', padding.left) .. text .. string.rep(' ', padding.right)
    
    -- Add top padding
    local lines = {}
    for _ = 1, padding.top do
      table.insert(lines, '')
    end
    
    -- Add the button line with highlight
    table.insert(lines, {
      text = button_line,
      highlight = {
        bg = style.bg,
        fg = style.fg,
        bold = true,
      }
    })
    
    -- Add bottom padding
    for _ = 1, padding.bottom do
      table.insert(lines, '')
    end
    
    return lines
  end

  return button
end

return M 