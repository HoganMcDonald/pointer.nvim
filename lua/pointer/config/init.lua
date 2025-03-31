local M = {}

-- Default options
M.defaults = {
  width = 40,
  position = "right", -- 'left' or 'right'
}

-- Current options
M.options = vim.deepcopy(M.defaults)

-- Setup function to merge user options with defaults
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
  return M.options
end

return M
