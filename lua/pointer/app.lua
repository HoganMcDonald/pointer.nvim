local M = {}

local theme = require("pointer.ui.theme")
local ui = require("pointer.ui")
local views = require("pointer.views")
local config = require("pointer.config")

M.options = config.options

--- Stores sidepanel state.
--- @type table
--- @field buffer_id number|nil The buffer ID of the sidepanel
--- @field window_id number|nil The window ID of the sidepanel
local sidepanel = {
  buffer_id = nil,
  window_id = nil,
}

-- Make sidepanel accessible
M.sidepanel = sidepanel

-- Initialize root_component as nil
local root_component = nil

--- Creates the sidepanel buffer if it doesn't exist.
--- @return number The buffer ID of the sidepanel
local function create_buffer()
  if sidepanel.buffer_id and vim.api.nvim_buf_is_valid(sidepanel.buffer_id) then
    return sidepanel.buffer_id
  end

  -- Create a new buffer for the sidepanel
  local buf = vim.api.nvim_create_buf(false, true) -- Not listed, scratch buffer

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(buf, "filetype", "pointer-sidepanel")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  -- Disable all indentation and formatting
  vim.api.nvim_buf_set_option(buf, "autoindent", false)
  vim.api.nvim_buf_set_option(buf, "smartindent", false)
  vim.api.nvim_buf_set_option(buf, "cindent", false)
  vim.api.nvim_buf_set_option(buf, "expandtab", false)
  vim.api.nvim_buf_set_option(buf, "tabstop", 1)
  vim.api.nvim_buf_set_option(buf, "shiftwidth", 1)
  vim.api.nvim_buf_set_option(buf, "softtabstop", 0)
  vim.api.nvim_buf_set_option(buf, "indentexpr", "")
  vim.api.nvim_buf_set_option(buf, "indentkeys", "")

  -- Store the buffer id
  sidepanel.buffer_id = buf

  return buf
end

--- Creates highlight group for sidepanel
--- Links to common file explorer highlight groups if available
local function create_sidepanel_highlights()
  -- Try to find existing highlight groups from popular plugins
  local highlight_groups = {
    "NvimTreeNormal", -- nvim-tree
    "NeoTreeNormal", -- neo-tree
    "TelescopeNormal", -- telescope
    "PMenu", -- standard Neovim menu
    "NormalFloat", -- standard floating window
  }

  local link_to = "NormalFloat" -- Default fallback

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
  vim.api.nvim_set_hl(0, "PointerSidepanel", { link = link_to })
end

--- Sets up sidepanel window options.
--- @param win number The window ID to configure
local function setup_window_options(win)
  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", false) -- Disable text wrapping
  vim.api.nvim_win_set_option(win, "number", false) -- Disable line numbers
  vim.api.nvim_win_set_option(win, "relativenumber", false) -- Disable relative numbers
  vim.api.nvim_win_set_option(win, "numberwidth", 1) -- Minimize number column width
  vim.api.nvim_win_set_option(win, "foldcolumn", "0") -- No fold column
  vim.api.nvim_win_set_option(win, "signcolumn", "no") -- No sign column
  vim.api.nvim_win_set_option(win, "winfixwidth", true) -- Keep width consistent
  vim.api.nvim_win_set_option(win, "list", false) -- Disable list mode
  vim.api.nvim_win_set_option(win, "breakindent", false) -- Disable break indent
  vim.api.nvim_win_set_option(win, "breakindentopt", "") -- Clear break indent options
  vim.api.nvim_win_set_option(win, "showbreak", "") -- Clear show break
  vim.api.nvim_win_set_option(win, "conceallevel", 0) -- Show all text
  vim.api.nvim_win_set_option(win, "concealcursor", "n") -- Show concealed text in normal mode

  -- Apply the custom highlighting
  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:PointerSidepanel")

  -- Set up keybindings
  local buf = vim.api.nvim_win_get_buf(win)

  -- Ensure buffer is modifiable for keybindings
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  -- Set up keybindings
  local keymaps = require("pointer.config.keymaps")
  keymaps.setup(buf)

  -- Make buffer non-modifiable after setting keybindings
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

--- Opens the sidepanel.
--- @return number The window ID of the opened sidepanel
local function open_sidepanel()
  -- Get the buffer to display
  local buf = create_buffer()

  -- Determine the split command based on position
  local split_cmd
  if M.options.position == "right" then
    split_cmd = "botright vsplit"
  else
    split_cmd = "topleft vsplit"
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

  -- Make buffer modifiable temporarily for rendering
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  -- Render UI components to the buffer
  if root_component then ui.render_component(root_component, buf) end

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

--- Initializes the sidepanel with options.
--- @param opts PointerOptions|table|nil Optional table of user options to override defaults
function M.setup(opts)
  create_sidepanel_highlights()

  theme.setup_highlights()
  theme.setup_theme_autocmds()

  root_component = views.create({
    width = opts.width,
  })

  M.root_component = root_component

  local routes = require("pointer.config.routes")
  routes.register_views()
  routes.setup_default_view()

  -- Create autocommand for maintaining width
  vim.api.nvim_create_autocmd("WinEnter", {
    group = "PointerSidepanel",
    callback = function()
      if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
        vim.api.nvim_win_set_width(sidepanel.window_id, M.options.width)
      end
    end,
  })

  -- Add autocmd to refresh highlights when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "PointerSidepanel",
    callback = function()
      create_sidepanel_highlights()

      -- Reapply highlights to window if it exists
      if sidepanel.window_id and vim.api.nvim_win_is_valid(sidepanel.window_id) then
        vim.api.nvim_win_set_option(sidepanel.window_id, "winhighlight", "Normal:PointerSidepanel")
      end
    end,
  })
end

return M
