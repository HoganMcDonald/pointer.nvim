local M = {}

-- Variable to store sidepanel state
local sidepanel = {
  buffer_id = nil,
  window_id = nil,
}

-- Default options
local default_opts = {
  width = 40,
  position = 'right', -- 'left' or 'right'
}

-- Plugin options
local options = {}

-- Create the sidepanel buffer if it doesn't exist
local function create_buffer()
  if sidepanel.buffer_id and vim.api.nvim_buf_is_valid(sidepanel.buffer_id) then
    return sidepanel.buffer_id
  end

  -- Create a new buffer for the sidepanel
  local buf = vim.api.nvim_create_buf(false, true) -- Not listed, scratch buffer

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'pointer-sidepanel')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)

  -- Store the buffer id
  sidepanel.buffer_id = buf

  return buf
end

-- Setup sidepanel window options
local function setup_window_options(win)
  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win, 'winfixwidth', true) -- Keep width consistent
end

-- Open the sidepanel
local function open_sidepanel()
  -- Get the buffer to display
  local buf = create_buffer()

  -- Determine the split command based on position
  local split_cmd
  if options.position == 'right' then
    split_cmd = 'botright vsplit'
  else
    split_cmd = 'topleft vsplit'
  end

  -- Create the split and set the buffer
  vim.cmd(split_cmd)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- Set the width
  vim.api.nvim_win_set_width(win, options.width)

  -- Store window id
  sidepanel.window_id = win

  -- Set window options
  setup_window_options(win)

  return win
end

-- Close the sidepanel
local function close_sidepanel()
  if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
    vim.api.nvim_win_close(sidepanel.window_id, true)
    sidepanel.window_id = nil
  end
end

-- Toggle the sidepanel
function M.toggle_sidepanel()
  if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
    close_sidepanel()
  else
    open_sidepanel()
  end
end

--- Setup function that initializes the plugin with options
--- @param opts table|nil Configuration options for the plugin
function M.setup(opts)
  opts = opts or {}

  -- Merge default options with user provided options
  options = vim.tbl_deep_extend('force', default_opts, opts)

  -- Create autocommand group for the plugin
  vim.api.nvim_create_augroup('PointerSidepanel', { clear = true })

  -- Ensure the sidepanel maintains its width
  vim.api.nvim_create_autocmd('WinEnter', {
    group = 'PointerSidepanel',
    callback = function()
      if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
        vim.api.nvim_win_set_width(sidepanel.window_id, options.width)
      end
    end,
  })
end

return M
