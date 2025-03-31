local M = {}

local components = {}
local next_component_id = 1

-- Global state
local state = {}

-- UI buffer namespace for highlights
local ns_id = vim.api.nvim_create_namespace("pointer_ui")

--- Generate a unique component ID
--- @return number Component ID
local function generate_id()
  local id = next_component_id
  next_component_id = next_component_id + 1
  return id
end

--- Renders content to a buffer
--- @param bufnr number Buffer to render to
--- @param content table Array of content lines with optional highlight information
local function render_to_buffer(bufnr, content)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Make buffer modifiable
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })

  -- Clear existing content and highlights
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- Convert content to plain lines
  local lines = {}
  for i, line in ipairs(content) do
    if type(line) == "string" then
      lines[i] = line
    elseif type(line) == "table" and line.text then
      lines[i] = line.text
    else
      lines[i] = ""
    end
  end

  -- Set lines in buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Apply highlights
  for i, line in ipairs(content) do
    if type(line) == "table" and line.text and line.hl_group then
      vim.api.nvim_buf_add_highlight(
        bufnr,
        ns_id,
        line.hl_group,
        i - 1, -- 0-indexed line
        0, -- Start column
        -1 -- End column (-1 = whole line)
      )
    end
  end

  -- Make buffer non-modifiable again
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

--- Create component
--- @param props table Component properties
--- @param children table Array of child components
--- @return table Component object
function M.create_component(props, children)
  local component = {
    id = generate_id(),
    props = props or {},
    children = children or {},
    state = {},
    render = nil, -- Will be set by the component factory
  }

  return component
end

--- Render component to buffer
--- @param component table Component to render
--- @param bufnr number|nil Buffer to render to (optional)
function M.render_component(component, bufnr)
  if not component.render then return end

  if not bufnr and components[component.id] and components[component.id].bufnr then
    bufnr = components[component.id].bufnr
  end

  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Store component reference
  components[component.id] = {
    component = component,
    bufnr = bufnr,
  }

  -- Call render function to get content
  local content = component.render(component.props, component.state, component.children)

  -- Render to buffer
  render_to_buffer(bufnr, content)
end

--- Get global state
--- @param key string|nil State key to retrieve (optional, returns all state if nil)
--- @return any State value
function M.get_state(key)
  if key then return state[key] end
  return state
end

--- Set global state and trigger re-render of components
--- @param key string|table State key or table of key-value pairs
--- @param value any|nil Value to set (if key is string)
function M.set_state(key, value)
  if type(key) == "table" then
    state = vim.tbl_deep_extend("force", state, key)
  else
    state[key] = value
  end

  -- Re-render all components
  for _, comp in pairs(components) do
    if comp.component and comp.bufnr then M.render_component(comp.component, comp.bufnr) end
  end
end

return M
