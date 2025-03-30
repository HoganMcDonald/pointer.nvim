--- Pointer sidepanel module.
--- Provides functionality to create and manage a sidepanel in Neovim.
local M = {}

--- Stores sidepanel state.
--- @type table
--- @field buffer_id number|nil The buffer ID of the sidepanel
--- @field window_id number|nil The window ID of the sidepanel
local sidepanel = {
  buffer_id = nil,
  window_id = nil,
}

--- Creates the sidepanel buffer if it doesn't exist.
--- @return number The buffer ID of the sidepanel
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

--- Creates highlight group for sidepanel
--- Links to common file explorer highlight groups if available
local function create_sidepanel_highlights()
  -- Try to find existing highlight groups from popular plugins
  local highlight_groups = {
    'NvimTreeNormal', -- nvim-tree
    'NeoTreeNormal', -- neo-tree
    'TelescopeNormal', -- telescope
    'PMenu', -- standard Neovim menu
    'NormalFloat', -- standard floating window
  }

  local link_to = 'NormalFloat' -- Default fallback

  -- Find the first available highlight group
  for _, hl_group in ipairs(highlight_groups) do
    -- Check if the highlight group exists and has attributes
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
    if ok and next(hl) then
      link_to = hl_group
      break
    end
  end

  -- Create our highlight group
  vim.api.nvim_set_hl(0, 'PointerSidepanel', { link = link_to })
end

--- Sets up sidepanel window options.
--- @param win number The window ID to configure
local function setup_window_options(win)
  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)
  vim.api.nvim_win_set_option(win, 'numberwidth', 1)   -- Minimize number column width
  vim.api.nvim_win_set_option(win, 'foldcolumn', '0')  -- No fold column
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win, 'winfixwidth', true) -- Keep width consistent

  -- Apply the custom highlighting
  vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:PointerSidepanel')
end

--- Opens the sidepanel.
--- @return number The window ID of the opened sidepanel
local function open_sidepanel()
  -- Get the buffer to display
  local buf = create_buffer()

  -- Determine the split command based on position
  local split_cmd
  if M.options.position == 'right' then
    split_cmd = 'botright vsplit'
  else
    split_cmd = 'topleft vsplit'
  end

  -- Create the split and set the buffer
  vim.cmd(split_cmd)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- Set the width
  vim.api.nvim_win_set_width(win, M.options.width)

  -- Store window id
  sidepanel.window_id = win

  -- Set window options
  setup_window_options(win)

  return win
end

--- Closes the sidepanel if it's open.
local function close_sidepanel()
  if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
    vim.api.nvim_win_close(sidepanel.window_id, true)
    sidepanel.window_id = nil
  end
end

--- Toggles the sidepanel visibility.
function M.toggle()
  if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
    close_sidepanel()
  else
    open_sidepanel()
  end
end

--- Default options for the sidepanel.
--- @type table
--- @field width number Width of the sidepanel in columns
--- @field position string Position of the sidepanel ('left' or 'right')
M.options = {
  width = 40,
  position = 'right', -- 'left' or 'right'
}

--- Initializes the sidepanel with options.
--- @param opts table|nil Optional table of user options to override defaults
function M.setup(opts)
  -- Update options
  if opts then
    M.options = vim.tbl_deep_extend('force', M.options, opts)
  end

  -- Create sidepanel highlights
  create_sidepanel_highlights()

  -- Create autocommand for maintaining width
  vim.api.nvim_create_autocmd('WinEnter', {
    group = 'PointerSidepanel',
    callback = function()
      if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
        vim.api.nvim_win_set_width(sidepanel.window_id, M.options.width)
      end
    end,
  })

  -- Add autocmd to refresh highlights when colorscheme changes
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'PointerSidepanel',
    callback = function()
      create_sidepanel_highlights()

      -- Reapply highlights to window if it exists
      if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
        vim.api.nvim_win_set_option(sidepanel.window_id, 'winhighlight', 'Normal:PointerSidepanel')
      end
    end,
  })
end

return M
